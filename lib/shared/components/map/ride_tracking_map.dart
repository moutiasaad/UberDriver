import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_text_styles.dart';
import '../../../utils/colors.dart';
import '../buttons/default_button.dart';

class RideTrackingMap extends StatefulWidget {
  const RideTrackingMap({
    super.key,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    this.driverLatitude,
    this.driverLongitude,
    this.pickupLabel = 'نقطة الانطلاق',
    this.dropoffLabel = 'نقطة الوصول',
    this.driverLabel = 'موقعك',
    this.showNavigateButton = true,
    this.showPolylines = true,
    this.zoom = 14,
    this.onMapCreated,
  });

  final double pickupLatitude;
  final double pickupLongitude;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final double? driverLatitude;
  final double? driverLongitude;
  final String pickupLabel;
  final String dropoffLabel;
  final String driverLabel;
  final bool showNavigateButton;
  final bool showPolylines;
  final double zoom;
  final Function(MapController)? onMapCreated;

  @override
  State<RideTrackingMap> createState() => _RideTrackingMapState();
}

class _RideTrackingMapState extends State<RideTrackingMap> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    if (widget.showPolylines) {
      _fetchRoute();
    }
  }

  @override
  void didUpdateWidget(RideTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driverLatitude != widget.driverLatitude ||
        oldWidget.driverLongitude != widget.driverLongitude) {
      if (widget.showPolylines) {
        _fetchRoute();
      }
      _fitBounds();
    }
  }

  /// Fetch route from OSRM (free routing service)
  Future<void> _fetchRoute() async {
    if (_isLoadingRoute) return;

    setState(() => _isLoadingRoute = true);

    try {
      final List<LatLng> waypoints = [];

      // Add driver location if available
      if (widget.driverLatitude != null && widget.driverLongitude != null) {
        waypoints.add(LatLng(widget.driverLatitude!, widget.driverLongitude!));
      }

      // Add pickup
      waypoints.add(LatLng(widget.pickupLatitude, widget.pickupLongitude));

      // Add dropoff
      waypoints.add(LatLng(widget.dropoffLatitude, widget.dropoffLongitude));

      if (waypoints.length < 2) {
        setState(() => _isLoadingRoute = false);
        return;
      }

      // Build OSRM URL
      final coordinates = waypoints
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');

      final url = 'https://router.project-osrm.org/route/v1/driving/$coordinates?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coords = data['routes'][0]['geometry']['coordinates'] as List;
          _routePoints = coords
              .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();
        }
      }
    } catch (e) {
      // Fallback to straight line if OSRM fails
      _routePoints = _buildStraightLine();
    }

    setState(() => _isLoadingRoute = false);
  }

  List<LatLng> _buildStraightLine() {
    final List<LatLng> points = [];

    if (widget.driverLatitude != null && widget.driverLongitude != null) {
      points.add(LatLng(widget.driverLatitude!, widget.driverLongitude!));
    }

    points.add(LatLng(widget.pickupLatitude, widget.pickupLongitude));
    points.add(LatLng(widget.dropoffLatitude, widget.dropoffLongitude));

    return points;
  }

  LatLng _calculateCenter() {
    final List<double> lats = [widget.pickupLatitude, widget.dropoffLatitude];
    final List<double> lngs = [widget.pickupLongitude, widget.dropoffLongitude];

    if (widget.driverLatitude != null && widget.driverLongitude != null) {
      lats.add(widget.driverLatitude!);
      lngs.add(widget.driverLongitude!);
    }

    final avgLat = lats.reduce((a, b) => a + b) / lats.length;
    final avgLng = lngs.reduce((a, b) => a + b) / lngs.length;

    return LatLng(avgLat, avgLng);
  }

  void _fitBounds() {
    final List<LatLng> points = [
      LatLng(widget.pickupLatitude, widget.pickupLongitude),
      LatLng(widget.dropoffLatitude, widget.dropoffLongitude),
    ];

    if (widget.driverLatitude != null && widget.driverLongitude != null) {
      points.add(LatLng(widget.driverLatitude!, widget.driverLongitude!));
    }

    if (points.length < 2) return;

    try {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    } catch (e) {
      // Ignore if map not ready
    }
  }

  Future<void> _openNavigation() async {
    final double lat = widget.dropoffLatitude;
    final double lng = widget.dropoffLongitude;

    String url;
    if (widget.driverLatitude != null && widget.driverLongitude != null) {
      final pickup = '${widget.pickupLatitude},${widget.pickupLongitude}';
      final dropoff = '${widget.dropoffLatitude},${widget.dropoffLongitude}';
      url = 'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$dropoff&waypoints=$pickup&travelmode=driving';
    } else {
      url = 'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$lat,$lng&travelmode=driving';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Pickup marker (green)
    markers.add(
      Marker(
        point: LatLng(widget.pickupLatitude, widget.pickupLongitude),
        width: 40,
        height: 40,
        child: Tooltip(
          message: widget.pickupLabel,
          child: const Icon(
            Icons.radio_button_checked,
            color: Colors.green,
            size: 32,
          ),
        ),
      ),
    );

    // Dropoff marker (red)
    markers.add(
      Marker(
        point: LatLng(widget.dropoffLatitude, widget.dropoffLongitude),
        width: 40,
        height: 40,
        child: Tooltip(
          message: widget.dropoffLabel,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 36,
          ),
        ),
      ),
    );

    // Driver marker (blue)
    if (widget.driverLatitude != null && widget.driverLongitude != null) {
      markers.add(
        Marker(
          point: LatLng(widget.driverLatitude!, widget.driverLongitude!),
          width: 40,
          height: 40,
          child: Tooltip(
            message: widget.driverLabel,
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
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _calculateCenter(),
            initialZoom: widget.zoom,
            onMapReady: () {
              widget.onMapCreated?.call(_mapController);
              Future.delayed(const Duration(milliseconds: 300), _fitBounds);
            },
          ),
          children: [
            // OpenStreetMap tile layer (free, no API key needed)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.uber_driver',
            ),
            // Route polyline
            if (widget.showPolylines && _routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                ],
              ),
            // Fallback straight line while loading
            if (widget.showPolylines && _routePoints.isEmpty && !_isLoadingRoute)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _buildStraightLine(),
                    color: AppColors.primary.withOpacity(0.5),
                    strokeWidth: 3,
                    pattern: const StrokePattern.dotted(),
                  ),
                ],
              ),
            // Markers
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),
        // Loading indicator for route
        if (_isLoadingRoute)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        // Navigate button
        if (widget.showNavigateButton)
          Positioned(
            top: 10,
            right: 10,
            child: DefaultButton(
              textStyle: AppTextStyle.mediumWhite12,
              width: 80,
              height: 28,
              text: 'تتبع المسار',
              pressed: _openNavigation,
              activated: true,
            ),
          ),
      ],
    );
  }
}
