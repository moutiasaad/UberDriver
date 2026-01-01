import 'package:flutter/material.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../../../models/ride_model.dart';
import '../../../shared/components/buttons/default_outlined_button.dart';
import '../../../shared/components/text/CText.dart';
import '../../../shared/local/cash_helper.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/colors.dart';

class RideCard extends StatelessWidget {
  const RideCard({
    super.key,
    required this.ride,
    this.onDetailPressed,
    this.onAcceptPressed,
  });

  final RideModel ride;
  final VoidCallback? onDetailPressed;
  final VoidCallback? onAcceptPressed;

  @override
  Widget build(BuildContext context) {
    final currency = CashHelper.getCurrency();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: BackgroundColor.background,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: BorderColor.grey, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Customer info and status
          Row(
            children: [
              // Customer avatar
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: BackgroundColor.grey1,
                  shape: BoxShape.circle,
                ),
                child: ride.customer.profileImage != null
                    ? ClipOval(
                        child: Image.network(
                          ride.customer.profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                        ),
                      )
                    : _buildDefaultAvatar(),
              ),
              const SizedBox(width: 12),
              // Customer name and phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cText(
                      text: ride.customer.name,
                      style: AppTextStyle.semiBoldBlack14,
                    ),
                    cText(
                      text: ride.customer.phone,
                      style: AppTextStyle.regularBlack1_14,
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(ride.statusColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: cText(
                  text: ride.statusText,
                  style: AppTextStyle.mediumBlack12.copyWith(
                    color: _getStatusColor(ride.statusColor),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pickup location
          _buildLocationRow(
            icon: Icons.radio_button_checked,
            iconColor: AppColors.success,
            label: context.translate('ride.pickup'),
            address: ride.pickup.address,
          ),

          // Dotted line
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Container(
              height: 20,
              width: 2,
              color: BorderColor.grey,
            ),
          ),

          // Dropoff location
          _buildLocationRow(
            icon: Icons.location_on,
            iconColor: AppColors.error,
            label: context.translate('ride.dropoff'),
            address: ride.dropoff.address,
          ),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            height: 1,
            width: double.infinity,
            color: BorderColor.grey1,
          ),

          // Ride details
          Row(
            children: [
              // Distance
              Expanded(
                child: _buildInfoColumn(
                  label: context.translate('ride.distance'),
                  value: '${ride.distanceKm.toStringAsFixed(1)} km',
                ),
              ),
              // Duration
              Expanded(
                child: _buildInfoColumn(
                  label: context.translate('ride.duration'),
                  value: '${ride.estimatedDurationMinutes} min',
                ),
              ),
              // Fare
              Expanded(
                child: _buildInfoColumn(
                  label: context.translate('ride.fare'),
                  value: '${ride.fare.finalAmount.toStringAsFixed(2)} $currency',
                  valueStyle: AppTextStyle.semiBoldPrimary14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Payment method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              cText(
                text: context.translate('ride.paymentMethod'),
                style: AppTextStyle.regularBlack1_14,
              ),
              Row(
                children: [
                  Icon(
                    ride.paymentMethod == 'cash'
                        ? Icons.money
                        : Icons.credit_card,
                    size: 18,
                    color: IconColors.grey6,
                  ),
                  const SizedBox(width: 4),
                  cText(
                    text: ride.paymentMethod == 'cash'
                        ? context.translate('ride.cash')
                        : context.translate('ride.card'),
                    style: AppTextStyle.mediumBlack14,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: DefaultOutlinedButton(
                  raduis: 6,
                  text: context.translate('buttons.rideDetail'),
                  textStyle: AppTextStyle.semiBoldPrimary14,
                  leftIcon: const Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: IconColors.primary,
                  ),
                  pressed: onDetailPressed ?? () {},
                ),
              ),
            ],
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
        size: 24,
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
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cText(
                text: label,
                style: AppTextStyle.regularBlack1_12,
              ),
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

  Widget _buildInfoColumn({
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cText(
          text: label,
          style: AppTextStyle.regularBlack1_12,
        ),
        const SizedBox(height: 2),
        cText(
          text: value,
          style: valueStyle ?? AppTextStyle.semiBoldBlack14,
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
}
