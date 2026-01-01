import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_images.dart';
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
  final Function(GoogleMapController)? onMapCreated;

  @override
  State<RideTrackingMap> createState() => _RideTrackingMapState();
}

class _RideTrackingMapState extends State<RideTrackingMap> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _dropoffIcon;
  BitmapDescriptor? _driverIcon;
  bool _iconsLoaded = false;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  @override
  void didUpdateWidget(RideTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update polylines if driver location changed
    if (oldWidget.driverLatitude != widget.driverLatitude ||
        oldWidget.driverLongitude != widget.driverLongitude) {
      _buildPolylines();
      _animateToBounds();
    }
  }

  Future<void> _loadIcons() async {
    try {
      _pickupIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        AppImages.shopMarker,
      );
      _dropoffIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        AppImages.customerMarker,
      );
      // Use default blue marker for driver
      _driverIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    } catch (e) {
      // Use default markers if custom icons fail
      _pickupIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      _dropoffIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      _driverIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    setState(() {
      _iconsLoaded = true;
    });

    _buildPolylines();
  }

  void _buildPolylines() {
    if (!widget.showPolylines) {
      _polylines = {};
      return;
    }

    final List<LatLng> points = [];

    // Add driver location if available
    if (widget.driverLatitude != null && widget.driverLongitude != null) {
      points.add(LatLng(widget.driverLatitude!, widget.driverLongitude!));
    }

    // Add pickup location
    points.add(LatLng(widget.pickupLatitude, widget.pickupLongitude));

    // Add dropoff location
    points.add(LatLng(widget.dropoffLatitude, widget.dropoffLongitude));

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: AppColors.primary,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };

    setState(() {});
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Pickup marker
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.pickupLatitude, widget.pickupLongitude),
        icon: _pickupIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: widget.pickupLabel),
      ),
    );

    // Dropoff marker
    markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(widget.dropoffLatitude, widget.dropoffLongitude),
        icon: _dropoffIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.dropoffLabel),
      ),
    );

    // Driver marker (if location available)
    if (widget.driverLatitude != null && widget.driverLongitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(widget.driverLatitude!, widget.driverLongitude!),
          icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: widget.driverLabel),
        ),
      );
    }

    return markers;
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    widget.onMapCreated?.call(controller);

    // Animate to show all markers
    _animateToBounds();
  }

  void _animateToBounds() {
    if (_mapController == null) return;

    final List<LatLng> points = [
      LatLng(widget.pickupLatitude, widget.pickupLongitude),
      LatLng(widget.dropoffLatitude, widget.dropoffLongitude),
    ];

    if (widget.driverLatitude != null && widget.driverLongitude != null) {
      points.add(LatLng(widget.driverLatitude!, widget.driverLongitude!));
    }

    if (points.length < 2) return;

    double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    if (!Platform.isIOS) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      });
    }
  }

  Future<void> _openNavigation() async {
    final double lat = widget.dropoffLatitude;
    final double lng = widget.dropoffLongitude;

    String url;
    if (widget.driverLatitude != null && widget.driverLongitude != null) {
      // Include waypoint for pickup
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

  @override
  Widget build(BuildContext context) {
    if (!_iconsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        GoogleMap(
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
          },
          mapType: MapType.normal,
          markers: _buildMarkers(),
          polylines: _polylines,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _calculateCenter(),
            zoom: widget.zoom,
          ),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
