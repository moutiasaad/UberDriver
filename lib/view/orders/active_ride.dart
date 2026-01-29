import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/ride_model.dart';
import '../../providers/LocationProvider.dart';
import '../../providers/order_provider.dart';
import '../../shared/components/buttons/default_button.dart';
import '../../shared/components/buttons/default_outlined_button.dart';
import '../../shared/components/map/ride_tracking_map.dart';
import '../../shared/components/text/CText.dart';
import '../../shared/local/cash_helper.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/colors.dart';

// Hardcoded Arabic strings for active ride screen
class _ActiveRideStrings {
  static const String pickup = 'نقطة الانطلاق';
  static const String dropoff = 'نقطة الوصول';
  static const String distance = 'المسافة';
  static const String duration = 'المدة';
  static const String fare = 'الأجرة';
  static const String navigate = 'تنقل';
  static const String arrivedAtPickup = 'وصلت لنقطة الانطلاق';
  static const String startRide = 'بدء الرحلة';
  static const String completeRide = 'إنهاء الرحلة';
  static const String updateStatus = 'تحديث الحالة';
  static const String confirmStatus = 'تأكيد تحديث الحالة';
  static const String confirmArrived = 'هل أنت متأكد أنك وصلت لنقطة الانطلاق؟';
  static const String confirmStart = 'هل أنت متأكد من بدء الرحلة؟';
  static const String confirmComplete = 'هل أنت متأكد من إنهاء الرحلة؟';
  static const String confirmUpdate = 'هل أنت متأكد من تحديث الحالة؟';
  static const String cancel = 'الغاء';
  static const String confirm = 'تأكيد';
}

class ActiveRideScreen extends StatefulWidget {
  const ActiveRideScreen({super.key, required this.ride});

  final RideModel ride;

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  late RideModel _currentRide;

  @override
  void initState() {
    super.initState();
    _currentRide = widget.ride;
    // Start location tracking when ride becomes active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.startDriverLocationTracking();
    });
  }

  @override
  void dispose() {
    // Stop location tracking when leaving the screen
    // Note: We don't stop tracking here because the ride might still be active
    // The tracking will be stopped when the ride is completed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = CashHelper.getCurrency();
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Full screen map with driver location and polylines
          Positioned.fill(
            child: RideTrackingMap(
              zoom: 14,
              pickupLabel: _ActiveRideStrings.pickup,
              dropoffLabel: _ActiveRideStrings.dropoff,
              driverLabel: 'موقعك',
              pickupLatitude: _currentRide.pickup.latitude,
              pickupLongitude: _currentRide.pickup.longitude,
              dropoffLatitude: _currentRide.dropoff.latitude,
              dropoffLongitude: _currentRide.dropoff.longitude,
              driverLatitude: locationProvider.driverLatitude,
              driverLongitude: locationProvider.driverLongitude,
              showPolylines: true,
              showNavigateButton: false,
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BackgroundColor.background,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: IconColors.black,
                  size: 24,
                ),
              ),
            ),
          ),

          // Status badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(_currentRide.statusColor),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: cText(
                text: _currentRide.statusText,
                style: AppTextStyle.semiBoldWhite14,
              ),
            ),
          ),

          // Bottom sheet with ride details
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: BackgroundColor.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: BorderColor.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Customer info
                      Row(
                        children: [
                          Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              color: BackgroundColor.grey1,
                              shape: BoxShape.circle,
                            ),
                            child: _currentRide.customer.profileImage != null
                                ? ClipOval(
                                    child: Image.network(
                                      _currentRide.customer.profileImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildDefaultAvatar(),
                                    ),
                                  )
                                : _buildDefaultAvatar(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                cText(
                                  text: _currentRide.customer.name,
                                  style: AppTextStyle.mediumBlack16,
                                ),
                                const SizedBox(height: 2),
                                cText(
                                  text: _currentRide.customer.phone,
                                  style: AppTextStyle.regularBlack1_14,
                                ),
                              ],
                            ),
                          ),
                          // Call button
                          GestureDetector(
                            onTap: () =>
                                _makePhoneCall(_currentRide.customer.phone),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success.withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.phone,
                                color: AppColors.success,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Locations
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: BackgroundColor.grey1,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Pickup
                            _buildLocationRow(
                              icon: Icons.radio_button_checked,
                              iconColor: AppColors.success,
                              label: _ActiveRideStrings.pickup,
                              address: _currentRide.pickup.address,
                            ),
                            // Line connector
                            Padding(
                              padding: const EdgeInsets.only(left: 11),
                              child: Container(
                                height: 24,
                                width: 2,
                                color: BorderColor.grey,
                              ),
                            ),
                            // Dropoff
                            _buildLocationRow(
                              icon: Icons.location_on,
                              iconColor: AppColors.error,
                              label: _ActiveRideStrings.dropoff,
                              address: _currentRide.dropoff.address,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ride info row
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.route,
                              label: _ActiveRideStrings.distance,
                              value:
                                  '${_currentRide.distanceKm.toStringAsFixed(1)} km',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.access_time,
                              label: _ActiveRideStrings.duration,
                              value:
                                  '${_currentRide.estimatedDurationMinutes} min',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.attach_money,
                              label: _ActiveRideStrings.fare,
                              value:
                                  '${_currentRide.fare.finalAmount.toStringAsFixed(0)} $currency',
                              valueColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          // Navigate button
                          Expanded(
                            child: DefaultOutlinedButton(
                              raduis: 8,
                              text: _ActiveRideStrings.navigate,
                              textStyle: AppTextStyle.semiBoldPrimary14,
                              leftIcon: Icon(
                                Icons.navigation,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              pressed: () => _openNavigation(),
                            ),
                          ),
                          // Only show update status button if ride can be updated
                          if (_canUpdateStatus()) ...[
                            const SizedBox(width: 12),
                            // Update status button
                            Expanded(
                              flex: 2,
                              child: DefaultButton(
                                raduis: 8,
                                text: _getNextStatusButtonText(),
                                pressed: () {
                                  _showStatusUpdateDialog(context);
                                },
                                activated: true,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        color: IconColors.grey6,
        size: 28,
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cText(
                text: label,
                style: AppTextStyle.regularBlack1_12,
              ),
              const SizedBox(height: 2),
              cText(
                text: address,
                style: AppTextStyle.mediumBlack14,
                maxLine: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: BackgroundColor.grey1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: IconColors.grey6),
          const SizedBox(height: 4),
          cText(
            text: label,
            style: AppTextStyle.regularBlack1_12,
          ),
          const SizedBox(height: 2),
          cText(
            text: value,
            style: AppTextStyle.mediumBlack12.copyWith(
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String statusColor) {
    switch (statusColor.toLowerCase()) {
      case 'success':
      case 'green':
        return AppColors.success;
      case 'warning':
      case 'yellow':
      case 'orange':
        return AppColors.warning;
      case 'danger':
      case 'error':
      case 'red':
        return AppColors.error;
      case 'info':
      case 'blue':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  /// Check if the ride status can be updated (not completed or cancelled)
  bool _canUpdateStatus() {
    final status = _currentRide.status.toLowerCase();
    return status == 'accepted' ||
           status == 'driver_arrived' ||
           status == 'in_progress';
  }

  String _getNextStatusButtonText() {
    switch (_currentRide.status.toLowerCase()) {
      case 'accepted':
        return _ActiveRideStrings.arrivedAtPickup;
      case 'driver_arrived':
        return _ActiveRideStrings.startRide;
      case 'in_progress':
        return _ActiveRideStrings.completeRide;
      default:
        return _ActiveRideStrings.updateStatus;
    }
  }

  /// Get the next status based on current ride status
  /// API expects: 'arrived', 'started', 'completed'
  String _getNextStatus() {
    switch (_currentRide.status.toLowerCase()) {
      case 'accepted':
        return 'arrived';
      case 'driver_arrived':
        return 'started';
      case 'in_progress':
        return 'completed';
      default:
        return '';
    }
  }

  void _showStatusUpdateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final orderProvider = Provider.of<OrderProvider>(context);
          final isLoading = orderProvider.updateRideStatusLoading;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BackgroundColor.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: BorderColor.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  cText(
                    text: _ActiveRideStrings.confirmStatus,
                    style: AppTextStyle.mediumBlack16,
                  ),
                  const SizedBox(height: 8),
                  cText(
                    text: _getStatusConfirmMessage(),
                    style: AppTextStyle.regularBlack1_14,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: DefaultOutlinedButton(
                          raduis: 8,
                          text: _ActiveRideStrings.cancel,
                          textStyle: AppTextStyle.semiBoldBlack14,
                          pressed: isLoading ? () {} : () => Navigator.pop(dialogContext),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DefaultButton(
                          raduis: 8,
                          text: isLoading ? '...' : _ActiveRideStrings.confirm,
                          pressed: isLoading
                              ? () {}
                              : () async {
                                  final nextStatus = _getNextStatus();
                                  if (nextStatus.isEmpty) {
                                    Navigator.pop(dialogContext);
                                    return;
                                  }

                                  final updatedRide = await orderProvider.updateRideStatus(
                                    context: context,
                                    rideId: _currentRide.id,
                                    status: nextStatus,
                                  );

                                  if (updatedRide != null) {
                                    // Update local ride state
                                    setState(() {
                                      _currentRide = updatedRide;
                                    });

                                    // Close the dialog
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }

                                    // Stop location tracking and go back if ride is completed
                                    if (nextStatus == 'completed') {
                                      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
                                      locationProvider.stopDriverLocationTracking();

                                      // Navigate back after completing the ride
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  }
                                },
                          activated: !isLoading,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getStatusConfirmMessage() {
    switch (_currentRide.status.toLowerCase()) {
      case 'accepted':
        return _ActiveRideStrings.confirmArrived;
      case 'driver_arrived':
        return _ActiveRideStrings.confirmStart;
      case 'in_progress':
        return _ActiveRideStrings.confirmComplete;
      default:
        return _ActiveRideStrings.confirmUpdate;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openNavigation() async {
    // Open Google Maps with navigation to pickup or dropoff based on status
    final double lat;
    final double lng;

    if (_currentRide.status.toLowerCase() == 'accepted') {
      // Navigate to pickup
      lat = _currentRide.pickup.latitude;
      lng = _currentRide.pickup.longitude;
    } else {
      // Navigate to dropoff
      lat = _currentRide.dropoff.latitude;
      lng = _currentRide.dropoff.longitude;
    }

    final Uri googleMapsUri = Uri.parse(
      'google.navigation:q=$lat,$lng&mode=d',
    );

    final Uri fallbackUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    }
  }
}
