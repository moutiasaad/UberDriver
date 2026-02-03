import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:uber_driver/shared/language/extension.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_text_styles.dart';
import '../../../utils/colors.dart' show AppColors;
import '../buttons/default_button.dart';

class MapTrack extends StatefulWidget {
  const MapTrack({
    super.key,
    required this.latitudeS,
    required this.longitudeS,
    this.latitudeC,
    this.longitudeC,
    this.merchantName,
    this.userName,
    this.onFullScreen = false,
    this.selectResult,
    this.zoom = 16,
  });

  final double latitudeS;
  final double longitudeS;
  final double? latitudeC;
  final double? longitudeC;
  final String? merchantName;
  final bool onFullScreen;
  final Function? selectResult;
  final String? userName;
  final double zoom;

  @override
  State<MapTrack> createState() => _MapTrackState();
}

class _MapTrackState extends State<MapTrack> {
  final MapController _mapController = MapController();
  late LatLng _center;
  Position? _currentPosition;
  List<LatLng> _pathPoints = [];
  List<LatLng> _routePoints = [];
  StreamSubscription<Position>? _positionStream;
  bool _mapReady = false;
  String? _estimatedTime;
  String? _estimatedDistance;

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.latitudeS, widget.longitudeS);
    _startLocationTracking();
  }

  void _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      _updateUserLocation(initialPosition);
    } catch (e) {
      debugPrint('Error getting initial position: $e');
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      (Position position) => _updateUserLocation(position),
      onError: (error) => debugPrint('Position stream error: $error'),
    );
  }

  void _updateUserLocation(Position position) {
    final userLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentPosition = position;
      _pathPoints.add(userLatLng);
    });

    _getDirectionsRoute(userLatLng, _center);

    if (_mapReady) {
      _focusOnAllPoints();
    }
  }

  Future<void> _getDirectionsRoute(LatLng origin, LatLng destination) async {
    try {
      // Use OSRM for free routing
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];

          // Extract duration and distance
          final duration = route['duration']; // in seconds
          final distance = route['distance']; // in meters

          _estimatedTime = '${(duration / 60).round()} min';
          _estimatedDistance = '${(distance / 1000).toStringAsFixed(1)} km';

          // Decode polyline points
          final coords = route['geometry']['coordinates'] as List;
          _routePoints = coords
              .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();

          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error getting directions: $e');
      // Fallback to straight line
      setState(() {
        _routePoints = [origin, destination];
      });
    }
  }

  void _focusOnAllPoints() {
    List<LatLng> points = [];

    if (_currentPosition != null) {
      points.add(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    }
    points.add(_center);
    if (widget.latitudeC != null && widget.longitudeC != null) {
      points.add(LatLng(widget.latitudeC!, widget.longitudeC!));
    }

    if (points.isEmpty) return;

    try {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
      );
    } catch (e) {
      // Ignore if map not ready
    }
  }

  Future<void> _openExternalDirections() async {
    String url;

    if (widget.latitudeC != null && widget.longitudeC != null) {
      String destination1 = '${widget.latitudeC},${widget.longitudeC}';
      String destination2 = '${widget.latitudeS},${widget.longitudeS}';
      url = 'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$destination1&waypoints=$destination2&travelmode=driving';
    } else {
      String destination1 = '${widget.latitudeS},${widget.longitudeS}';
      url = 'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$destination1&travelmode=driving';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Merchant marker
    markers.add(
      Marker(
        point: _center,
        width: 40,
        height: 40,
        child: Tooltip(
          message: widget.merchantName ?? 'Merchant',
          child: const Icon(
            Icons.store,
            color: Colors.green,
            size: 36,
          ),
        ),
      ),
    );

    // Client marker (if provided)
    if (widget.latitudeC != null && widget.longitudeC != null) {
      markers.add(
        Marker(
          point: LatLng(widget.latitudeC!, widget.longitudeC!),
          width: 40,
          height: 40,
          child: Tooltip(
            message: widget.userName ?? 'Client',
            child: const Icon(
              Icons.person_pin_circle,
              color: Colors.orange,
              size: 36,
            ),
          ),
        ),
      );
    }

    // Driver (live) marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  List<Polyline> _buildPolylines() {
    final polylines = <Polyline>[];

    // Movement path (user's trail)
    if (_pathPoints.length > 1) {
      polylines.add(
        Polyline(
          points: _pathPoints,
          color: Colors.blue,
          strokeWidth: 3,
        ),
      );
    }

    // Route to merchant
    if (_routePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          points: _routePoints,
          color: AppColors.primary,
          strokeWidth: 5,
        ),
      );
    }

    // Line between merchant and client
    if (widget.latitudeC != null && widget.longitudeC != null) {
      polylines.add(
        Polyline(
          points: [
            LatLng(widget.latitudeS, widget.longitudeS),
            LatLng(widget.latitudeC!, widget.longitudeC!),
          ],
          color: Colors.orange,
          strokeWidth: 4,
          pattern: const StrokePattern.dotted(),
        ),
      );
    }

    return polylines;
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition != null
                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                : _center,
            initialZoom: widget.zoom,
            onMapReady: () {
              _mapReady = true;
              if (_currentPosition != null) {
                Future.delayed(const Duration(milliseconds: 500), _focusOnAllPoints);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.uber_driver',
            ),
            PolylineLayer(polylines: _buildPolylines()),
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),

        // Navigate button
        if (widget.onFullScreen)
          Positioned(
            top: 60,
            right: 10,
            child: DefaultButton(
              textStyle: AppTextStyle.mediumWhite12,
              width: 80,
              height: 28,
              text: context.translate('map.trackRoute'),
              pressed: _openExternalDirections,
              activated: true,
            ),
          ),

        // Route info overlay
        if (_estimatedTime != null && _estimatedDistance != null)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(_estimatedTime!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.straighten, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(_estimatedDistance!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // Debug info overlay (only in debug mode)
        if (kDebugMode)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User: ${_currentPosition?.latitude.toStringAsFixed(4)}, ${_currentPosition?.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Path Points: ${_pathPoints.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Route: ${_routePoints.isNotEmpty ? "Yes" : "No"}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
