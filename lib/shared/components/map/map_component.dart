import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_text_styles.dart';
import '../buttons/default_button.dart';

class MapScreenComponent extends StatefulWidget {
  const MapScreenComponent({
    super.key,
    required this.latitudeS,
    required this.longitudeS,
    this.merchantName,
    this.userName,
    this.onFullScreen = false,
    this.selectResult,
    this.latitudeC,
    this.longitudeC,
    this.zoom = 16,
  });

  final double? latitudeC;
  final double? longitudeC;
  final double latitudeS;
  final double longitudeS;
  final String? merchantName;
  final bool onFullScreen;
  final Function? selectResult;
  final String? userName;
  final double zoom;

  @override
  State<MapScreenComponent> createState() => _MapScreenComponentState();
}

class _MapScreenComponentState extends State<MapScreenComponent> {
  final MapController _mapController = MapController();
  late LatLng _center;

  @override
  void initState() {
    super.initState();
    if (widget.latitudeC != null && widget.longitudeC != null) {
      _center = LatLng(
        (widget.latitudeS + widget.latitudeC!) / 2,
        (widget.longitudeS + widget.longitudeC!) / 2,
      );
    } else {
      _center = LatLng(widget.latitudeS, widget.longitudeS);
    }
  }

  void _fitBounds() {
    if (widget.latitudeC != null && widget.longitudeC != null) {
      final bounds = LatLngBounds(
        LatLng(
          widget.latitudeS < widget.latitudeC! ? widget.latitudeS : widget.latitudeC!,
          widget.longitudeS < widget.longitudeC! ? widget.longitudeS : widget.longitudeC!,
        ),
        LatLng(
          widget.latitudeS > widget.latitudeC! ? widget.latitudeS : widget.latitudeC!,
          widget.longitudeS > widget.longitudeC! ? widget.longitudeS : widget.longitudeC!,
        ),
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        try {
          _mapController.fitCamera(
            CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
          );
        } catch (e) {
          // Ignore if map not ready
        }
      });
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Shop/Merchant marker
    markers.add(
      Marker(
        point: LatLng(widget.latitudeS, widget.longitudeS),
        width: 40,
        height: 40,
        child: Tooltip(
          message: widget.merchantName ?? 'Location',
          child: const Icon(
            Icons.store,
            color: Colors.green,
            size: 36,
          ),
        ),
      ),
    );

    // Customer marker (if provided)
    if (widget.latitudeC != null && widget.longitudeC != null) {
      markers.add(
        Marker(
          point: LatLng(widget.latitudeC!, widget.longitudeC!),
          width: 40,
          height: 40,
          child: Tooltip(
            message: widget.userName ?? 'Customer',
            child: const Icon(
              Icons.person_pin_circle,
              color: Colors.blue,
              size: 36,
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
            initialCenter: _center,
            initialZoom: widget.zoom,
            onMapReady: _fitBounds,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.uber_driver',
            ),
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),
        if (widget.onFullScreen)
          Positioned(
            top: 10,
            right: 10,
            child: DefaultButton(
              textStyle: AppTextStyle.mediumWhite12,
              width: 80,
              height: 28,
              text: 'تتبع المسار',
              pressed: () async {
                String destination1 = '${widget.latitudeC},${widget.longitudeC}';
                String url;

                if (widget.latitudeC != null && widget.longitudeC != null) {
                  String destination2 = '${widget.latitudeS},${widget.longitudeS}';
                  url = 'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$destination1&waypoints=$destination2&travelmode=driving';
                } else {
                  url = 'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$destination1&travelmode=driving';
                }

                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                }
              },
              activated: true,
            ),
          ),
      ],
    );
  }
}
