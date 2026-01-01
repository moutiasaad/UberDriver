import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/colors.dart' show AppColors;
import '../buttons/default_button.dart';
import 'full_map_screen.dart';

class MapTrack extends StatefulWidget {
  const MapTrack(
      {super.key,
      required this.latitudeS,
      required this.longitudeS,
        this.latitudeC,
        this.longitudeC,
      this.merchantName,
      this.userName,
      this.onFullScreen = false,
      this.selectResult,
      this.zoom = 16});

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
  _MapTrackState createState() => _MapTrackState();
}

class _MapTrackState extends State<MapTrack> {
  late GoogleMapController mapController;
  BitmapDescriptor? _customIconShop;
  BitmapDescriptor? _customIconCustomer;
  bool doneLoading = false;
  late LatLng _center;
  Position? _currentPosition;
  Marker? _userMarker;
  List<LatLng> _pathPoints = [];
  Polyline? _movementPolyline;
  Polyline? _routePolyline;
  StreamSubscription<Position>? _positionStream;
  bool _mapCreated = false;
  String? _estimatedTime;
  String? _estimatedDistance;

  // Replace with your Google Maps API key
  static const String _googleMapsApiKey =
      'AIzaSyCrDYCXAVQZeXxbZx84iRVe5SMmBpm5sy8';

  @override
  void initState() {
    print('MapTrack: initState called');
    _center = LatLng(widget.latitudeS, widget.longitudeS);
    print(
        'MapTrack: Merchant location set to ${_center.latitude}, ${_center.longitude}');

    _loadCustomIcon().then((value) {
      print('MapTrack: Custom icons loaded');
      setState(() {
        doneLoading = true;
      });
    });
    _startLocationTracking();
    super.initState();
  }

  void _startLocationTracking() async {
    print('MapTrack: Starting location tracking...');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('MapTrack: Location service enabled: $serviceEnabled');
    if (!serviceEnabled) {
      print('MapTrack: Location services are disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print('MapTrack: Current permission: $permission');

    if (permission == LocationPermission.denied) {
      print('MapTrack: Permission denied, requesting permission...');
      permission = await Geolocator.requestPermission();
      print('MapTrack: Permission after request: $permission');
      if (permission == LocationPermission.denied) {
        print('MapTrack: Permission still denied after request');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('MapTrack: Permission denied forever');
      return;
    }

    print('MapTrack: Permission granted, getting initial position...');

    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      print(
          'MapTrack: Initial position obtained: ${initialPosition.latitude}, ${initialPosition.longitude}');
      _updateUserLocation(initialPosition);
    } catch (e) {
      print('MapTrack: Error getting initial position: $e');
    }

    print('MapTrack: Starting position stream...');
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update route every 10 meters
      ),
    ).listen(
      (Position position) {
        print(
            'MapTrack: New position received: ${position.latitude}, ${position.longitude}');
        _updateUserLocation(position);
      },
      onError: (error) {
        print('MapTrack: Position stream error: $error');
      },
      onDone: () {
        print('MapTrack: Position stream done');
      },
    );
  }

  void _updateUserLocation(Position position) {
    print(
        'MapTrack: Updating user location to ${position.latitude}, ${position.longitude}');

    final userLatLng =
        LatLng(position.latitude, position.longitude); // Define it here first

    setState(() {
      _currentPosition = position;
      _pathPoints.add(userLatLng);

      _userMarker = Marker(
        markerId: const MarkerId('user'),
        position: userLatLng,
        icon: _customIconCustomer ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: widget.userName ?? 'User'),
      );

      // Update movement path (user's trail)
      _movementPolyline = Polyline(
        polylineId: const PolylineId('movement_path'),
        color: Colors.blue,
        width: 3,
        points: _pathPoints,
      );
    });

    // Get route from current position to merchant
    _getDirectionsRoute(userLatLng, _center);

    if (_mapCreated && mapController != null) {
      _focusOnUserAndMerchant();
    }
  }

  Future<void> _getDirectionsRoute(LatLng origin, LatLng destination) async {
    print(
        'MapTrack: Getting directions from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}');

    if (_googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      print('MapTrack: Please add your Google Maps API key');
      // Fallback to straight line
      _createStraightLineRoute(origin, destination);
      return;
    }

    try {
      final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${origin.latitude},${origin.longitude}&'
          'destination=${destination.latitude},${destination.longitude}&'
          'mode=driving&'
          'key=$_googleMapsApiKey';

      print('MapTrack: Making API request to: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('MapTrack: API response received');

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          // Extract duration and distance
          _estimatedTime = leg['duration']['text'];
          _estimatedDistance = leg['distance']['text'];
          print(
              'MapTrack: Route info - Distance: $_estimatedDistance, Time: $_estimatedTime');

          // Decode polyline points
          final polylinePoints =
              _decodePolyline(route['overview_polyline']['points']);

          setState(() {
            _routePolyline = Polyline(
              polylineId: const PolylineId('route_to_merchant'),
              color: AppColors.primary,
              width: 5,
              points: polylinePoints,
            );
          });
          print(
              'MapTrack: Route polyline created with ${polylinePoints.length} points');
        } else {
          print('MapTrack: No routes found in API response: ${data['status']}');
          _createStraightLineRoute(origin, destination);
        }
      } else {
        print(
            'MapTrack: API request failed with status: ${response.statusCode}');
        _createStraightLineRoute(origin, destination);
      }
    } catch (e) {
      print('MapTrack: Error getting directions: $e');
      _createStraightLineRoute(origin, destination);
    }
  }

  void _createStraightLineRoute(LatLng origin, LatLng destination) {
    print('MapTrack: Creating straight line route as fallback');
    setState(() {
      _routePolyline = Polyline(
        polylineId: const PolylineId('route_to_merchant'),
        color: AppColors.primary,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        points: [origin, destination],
      );
    });
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _focusOnUserAndMerchant() {
    List<LatLng> points = [];

    if (_currentPosition != null) {
      points.add(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    }
    points.add(_center);
    if (widget.latitudeC != null && widget.longitudeC != null) {
      points.add(LatLng(widget.latitudeC!, widget.longitudeC!));
    }

    if (points.isEmpty) return;

    double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }


  Future<void> _loadCustomIcon() async {
    print('MapTrack: Loading custom icons...');
    try {
      _customIconShop = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        AppImages.shopMarker,
      );
      print('MapTrack: Shop icon loaded successfully');
    } catch (e) {
      print('MapTrack: Error loading shop icon: $e');
    }

    try {
      _customIconCustomer = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        AppImages.customerMarker,
      );
      print('MapTrack: Customer icon loaded successfully');
    } catch (e) {
      print('MapTrack: Error loading customer icon: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    print('MapTrack: Map created');
    mapController = controller;
    _mapCreated = true;

    if (_currentPosition != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _focusOnUserAndMerchant();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_center, widget.zoom),
        );
      });
    }
  }

  @override
  void dispose() {
    print('MapTrack: Disposing...');
    _positionStream?.cancel();
    super.dispose();
  }
  Future<void> _openExternalDirections() async {
    String url;

    if (widget.latitudeC != null && widget.longitudeC != null) {
      // Client (B)
      String destination1 = '${widget.latitudeC},${widget.longitudeC}';
      // Merchant (A)
      String destination2 = '${widget.latitudeS},${widget.longitudeS}';

      // Route: current location → merchant → client
      url =
      'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$destination1&waypoints=$destination2&travelmode=driving';
    } else {
      // Only merchant available
      String destination1 = '${widget.latitudeS},${widget.longitudeS}';
      url =
      'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$destination1&travelmode=driving';
    }

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  Widget build(BuildContext context) {
    return doneLoading
        ? Stack(
            children: [
              Container(
                child: GoogleMap(
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer()),
                  },
                  mapType: MapType.normal,
                  markers: {
                    // Merchant marker
                    Marker(
                      markerId: const MarkerId('merchant'),
                      position: _center,
                      icon: _customIconShop ?? BitmapDescriptor.defaultMarker,
                      infoWindow: InfoWindow(
                        title: widget.merchantName ?? 'Merchant',
                      ),
                    ),

                    // Client marker (if provided)
                    if (widget.latitudeC != null && widget.longitudeC != null)
                      Marker(
                        markerId: const MarkerId('client'),
                        position: LatLng(widget.latitudeC!, widget.longitudeC!),
                        icon: _customIconCustomer ??
                            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                        infoWindow: InfoWindow(title: widget.userName ?? 'Client'),
                      ),

                    // Driver (live) marker
                    if (_userMarker != null) _userMarker!,
                  },

                  polylines: {
                    if (_movementPolyline != null) _movementPolyline!,
                    if (_routePolyline != null) _routePolyline!,

                    // 🔹 Add this polyline between merchant and client
                    if (widget.latitudeC != null && widget.longitudeC != null)
                      Polyline(
                        polylineId: const PolylineId('merchant_client_line'),
                        color: Colors.orange,
                        width: 4,
                        patterns: [PatternItem.dash(15), PatternItem.gap(10)],
                        points: [
                          LatLng(widget.latitudeS, widget.longitudeS),
                          LatLng(widget.latitudeC!, widget.longitudeC!)
                        ],
                      ),
                  },

                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude)
                        : _center,
                    zoom: widget.zoom,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
              if (widget.onFullScreen)
                Positioned(
                  top: 360,
                  right: 320,
                  child: DefaultButton(
                    textStyle: AppTextStyle.mediumWhite12,
                    width: 80,
                    height: 28,
                    text: 'تتبع المسار',
                    pressed: _openExternalDirections, // <-- call the method
                    activated: true,
                  ),
                ),

              // Route info overlay
              if (_estimatedTime != null && _estimatedDistance != null)
                Positioned(
                  top: 10,
                  right: 320,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
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
                            Icon(Icons.access_time,
                                size: 16, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(_estimatedTime!,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.straighten,
                                size: 16, color: Colors.green),
                            SizedBox(width: 4),
                            Text(_estimatedDistance!,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              // Debug info overlay
              if (!kDebugMode)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.black54,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'User Pos: ${_currentPosition?.latitude.toStringAsFixed(4)}, ${_currentPosition?.longitude.toStringAsFixed(4)}',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                        Text('Marker: ${_userMarker != null ? "Yes" : "No"}',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                        Text('Path Points: ${_pathPoints.length}',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                        Text('Route: ${_routePolyline != null ? "Yes" : "No"}',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }
}
