import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_driver/shared/language/extension.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/ride_model.dart';
import '../../providers/LocationProvider.dart';
import '../../providers/order_provider.dart';
import '../../shared/components/buttons/cancel_button.dart';
import '../../shared/components/buttons/default_button.dart';
import '../../shared/components/image/svg_icon.dart';
import '../../shared/components/map/ride_tracking_map.dart';
import '../../shared/components/text/CText.dart';
import '../../shared/local/cash_helper.dart';
import '../../shared/logique_function/date_functions.dart';
import '../../utils/app_icons.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/colors.dart';
import 'active_ride.dart';

class RideDetailScreen extends StatefulWidget {
  const RideDetailScreen({super.key, required this.ride});

  final RideModel ride;

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Get current driver position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.getCurrentDriverPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = CashHelper.getCurrency();
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: CancelButton(
          context: context,
          icon: Icons.arrow_back,
        ),
        title: cText(
          text: '${context.translate('rideDetail.title')} #${widget.ride.id}',
          style: AppTextStyle.semiBoldBlack14,
        ),
        elevation: 0.5,
        backgroundColor: BackgroundColor.background,
      ),
      backgroundColor: BackgroundColor.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map, size: 24, color: AppColors.primary),
                      const SizedBox(width: 8),
                      cText(
                        text: context.translate('rideDetail.route'),
                        style: AppTextStyle.semiBoldBlack14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: RideTrackingMap(
                        zoom: 12,
                        pickupLabel: context.translate('ride.pickup'),
                        dropoffLabel: context.translate('ride.dropoff'),
                        driverLabel: context.translate('rideDetail.yourLocation'),
                        pickupLatitude: widget.ride.pickup.latitude,
                        pickupLongitude: widget.ride.pickup.longitude,
                        dropoffLatitude: widget.ride.dropoff.latitude,
                        dropoffLongitude: widget.ride.dropoff.longitude,
                        driverLatitude: locationProvider.driverLatitude,
                        driverLongitude: locationProvider.driverLongitude,
                        showPolylines: true,
                        showNavigateButton: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildDivider(),

            // Customer Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 24, color: AppColors.primary),
                      const SizedBox(width: 8),
                      cText(
                        text: context.translate('rideDetail.customer'),
                        style: AppTextStyle.semiBoldBlack14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Customer avatar
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: BackgroundColor.grey1,
                          shape: BoxShape.circle,
                        ),
                        child: widget.ride.customer.profileImage != null
                            ? ClipOval(
                                child: Image.network(
                                  widget.ride.customer.profileImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
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
                              text: widget.ride.customer.name,
                              style: AppTextStyle.semiBoldBlack14,
                            ),
                            cText(
                              text: widget.ride.customer.phone,
                              style: AppTextStyle.regularBlack1_14,
                            ),
                          ],
                        ),
                      ),
                      // Call button
                      GestureDetector(
                        onTap: () => _makePhoneCall(widget.ride.customer.phone),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.phone,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _buildDivider(),

            // Pickup & Dropoff Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 24, color: AppColors.primary),
                      const SizedBox(width: 8),
                      cText(
                        text: context.translate('rideDetail.locations'),
                        style: AppTextStyle.semiBoldBlack14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Pickup
                  _buildLocationRow(
                    icon: Icons.radio_button_checked,
                    iconColor: AppColors.success,
                    label: context.translate('ride.pickup'),
                    address: widget.ride.pickup.address,
                  ),
                  // Line connector
                  Padding(
                    padding: const EdgeInsets.only(left: 11),
                    child: Container(
                      height: 30,
                      width: 2,
                      color: BorderColor.grey,
                    ),
                  ),
                  // Dropoff
                  _buildLocationRow(
                    icon: Icons.location_on,
                    iconColor: AppColors.error,
                    label: context.translate('ride.dropoff'),
                    address: widget.ride.dropoff.address,
                  ),
                ],
              ),
            ),

            _buildDivider(),

            // Ride Info Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 24, color: AppColors.primary),
                      const SizedBox(width: 8),
                      cText(
                        text: context.translate('rideDetail.rideInfo'),
                        style: AppTextStyle.semiBoldBlack14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context.translate('rideDetail.rideId'),
                    '#${widget.ride.id}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context.translate('rideDetail.status'),
                    widget.ride.statusText,
                    valueColor: _getStatusColor(widget.ride.statusColor),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context.translate('ride.distance'),
                    '${widget.ride.distanceKm.toStringAsFixed(1)} km',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context.translate('ride.duration'),
                    '${widget.ride.estimatedDurationMinutes} ${context.translate('rideDetail.minutes')}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context.translate('rideDetail.createdAt'),
                    widget.ride.timestamps.createdAt != null
                        ? convertToArabicDate(widget.ride.timestamps.createdAt!.toIso8601String())
                        : '-',
                  ),
                ],
              ),
            ),

            _buildDivider(),

            // Fare Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, size: 24, color: AppColors.primary),
                      const SizedBox(width: 8),
                      cText(
                        text: context.translate('rideDetail.fareDetails'),
                        style: AppTextStyle.semiBoldBlack14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context.translate('rideDetail.baseFare'),
                    '${widget.ride.fare.baseFare.toStringAsFixed(2)} $currency',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context.translate('rideDetail.distanceFare'),
                    '${widget.ride.fare.distanceFare.toStringAsFixed(2)} $currency',
                  ),
                  if (widget.ride.fare.discountAmount > 0) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context.translate('rideDetail.discount'),
                      '-${widget.ride.fare.discountAmount.toStringAsFixed(2)} $currency',
                      valueColor: AppColors.success,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: BorderColor.grey1,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context.translate('rideDetail.totalFare'),
                    '${widget.ride.fare.finalAmount.toStringAsFixed(2)} $currency',
                    labelStyle: AppTextStyle.semiBoldBlack14,
                    valueStyle: AppTextStyle.semiBoldPrimary16,
                  ),
                ],
              ),
            ),

            _buildDivider(),

            // Payment Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, size: 24, color: AppColors.primary),
                      const SizedBox(width: 8),
                      cText(
                        text: context.translate('rideDetail.payment'),
                        style: AppTextStyle.semiBoldBlack14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context.translate('ride.paymentMethod'),
                    widget.ride.paymentMethod == 'cash'
                        ? context.translate('ride.cash')
                        : context.translate('ride.card'),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context.translate('rideDetail.paymentStatus'),
                    _getPaymentStatusText(context, widget.ride.paymentStatus),
                    valueColor: _getPaymentStatusColor(widget.ride.paymentStatus),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DefaultButton(
              raduis: 6,
              text: context.translate('buttons.acceptOrder'),
              pressed: () async {
                if (orderProvider.acceptRideLoading) return;

                final acceptedRide = await orderProvider.acceptRide(
                  context: context,
                  rideId: widget.ride.id,
                );

                if (acceptedRide != null && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveRideScreen(ride: acceptedRide),
                    ),
                  );
                }
              },
              activated: !orderProvider.acceptRideLoading,
              loading: orderProvider.acceptRideLoading,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 6,
      color: BorderColor.grey1,
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
              const SizedBox(height: 4),
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

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        cText(
          text: label,
          style: labelStyle ?? AppTextStyle.regularBlack1_14,
        ),
        cText(
          text: value,
          style: valueStyle ??
              AppTextStyle.mediumBlack14.copyWith(
                color: valueColor,
              ),
        ),
      ],
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
        return AppColors.warning;
    }
  }

  String _getPaymentStatusText(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return context.translate('rideDetail.paymentPending');
      case 'paid':
        return context.translate('rideDetail.paymentPaid');
      case 'failed':
        return context.translate('rideDetail.paymentFailed');
      default:
        return status;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'paid':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.warning;
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
}
