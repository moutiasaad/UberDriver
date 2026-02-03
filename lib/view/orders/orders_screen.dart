import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride_model.dart';
import '../../providers/order_provider.dart';
import '../../shared/components/appBar/design_sheet_app_bar.dart';
import '../../shared/components/text/CText.dart';
import '../../shared/error/error_component.dart';
import '../../shared/language/extension.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/colors.dart';
import 'active_ride.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.profile = false});

  final bool profile;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<void> _historyFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadHistory() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.getRideHistory();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      if (orderProvider.hasMoreHistory && !orderProvider.loadingMore) {
        orderProvider.loadMoreHistory();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return Scaffold(
          appBar: designSheetAppBar(
            isLeading: widget.profile,
            isCentred: false,
            icon: Icons.arrow_back,
            text: context.translate('orders.title'),
            context: context,
            style: AppTextStyle.semiBoldBlack18,
          ),
          backgroundColor: BackgroundColor.background,
          body: FutureBuilder(
            future: _historyFuture,
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error state
              if (orderProvider.hasHistoryError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.translate('orders.connectionError'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _historyFuture = _loadHistory();
                            });
                          },
                          child: Text(context.translate('buttons.retry')),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // No data state
              if (!orderProvider.hasHistory) {
                return Center(
                  child: noOrders(context: context),
                );
              }

              final rides = orderProvider.historyRides;

              return RefreshIndicator(
                onRefresh: () => orderProvider.refreshHistory(),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: 18,
                    bottom: 80,
                    right: 18,
                    left: 18,
                  ),
                  itemCount: rides.length + (orderProvider.hasMoreHistory ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == rides.length) {
                      return _buildLoadMoreIndicator(orderProvider);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _showRideDetails(context, rides[index]),
                        child: _RideHistoryCard(ride: rides[index]),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showRideDetails(BuildContext context, RideModel ride) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveRideScreen(ride: ride),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(OrderProvider orderProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: orderProvider.loadingMore
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: () => orderProvider.loadMoreHistory(),
                child: Text(context.translate('orders.loadMore')),
              ),
      ),
    );
  }
}

class _RideHistoryCard extends StatelessWidget {
  final RideModel ride;

  const _RideHistoryCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BorderColor.grey1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(context, ride.status),
              Text(
                _formatDate(ride.timestamps.createdAt),
                style: AppTextStyle.regularBlack1_12,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Pickup location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cText(
                      text: context.translate('orders.from'),
                      style: AppTextStyle.regularBlack1_12,
                    ),
                    const SizedBox(height: 2),
                    cText(
                      text: ride.pickup.address,
                      style: AppTextStyle.mediumBlack14,
                      maxLine: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Dotted line connector
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Column(
              children: List.generate(
                3,
                (index) => Container(
                  width: 2,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: Colors.grey[300],
                ),
              ),
            ),
          ),

          // Dropoff location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cText(
                      text: context.translate('orders.to'),
                      style: AppTextStyle.regularBlack1_12,
                    ),
                    const SizedBox(height: 2),
                    cText(
                      text: ride.dropoff.address,
                      style: AppTextStyle.mediumBlack14,
                      maxLine: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Fare and distance
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context: context,
                  icon: Icons.attach_money,
                  label: context.translate('ride.fare'),
                  value: ride.fare.finalAmount.toStringAsFixed(2),
                  color: AppColors.success,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: BorderColor.grey1,
              ),
              Expanded(
                child: _buildInfoItem(
                  context: context,
                  icon: Icons.straighten,
                  label: context.translate('ride.distance'),
                  value: '${ride.distanceKm.toStringAsFixed(1)} ${context.translate('ride.km')}',
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status?.toLowerCase()) {
      case 'completed':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        text = context.translate('status.completed');
        break;
      case 'cancelled':
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        text = context.translate('status.cancelled');
        break;
      default:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        text = context.translate('status.inProgress');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyle.regularBlack1_12,
            ),
            Text(
              value,
              style: AppTextStyle.mediumBlack14.copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Bottom sheet for ride details
class _RideDetailBottomSheet extends StatelessWidget {
  final RideModel ride;

  const _RideDetailBottomSheet({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${context.translate('orders.rideDetails')} #${ride.id}',
                  style: AppTextStyle.semiBoldBlack18,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  _buildSection(
                    title: context.translate('rideDetail.status'),
                    child: _buildStatusBadge(context, ride.status),
                  ),
                  const SizedBox(height: 20),

                  // Customer Info
                  _buildSection(
                    title: context.translate('orders.customerInfo'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(ride.customer.name, style: AppTextStyle.mediumBlack14),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(ride.customer.phone, style: AppTextStyle.regularBlack1_14),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Locations
                  _buildSection(
                    title: context.translate('rideDetail.locations'),
                    child: Column(
                      children: [
                        // Pickup
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.circle, size: 12, color: AppColors.success),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(context.translate('orders.from'), style: AppTextStyle.regularBlack1_12),
                                  const SizedBox(height: 4),
                                  Text(ride.pickup.address, style: AppTextStyle.mediumBlack14),
                                  if (ride.pickup.time != null) ...[
                                    const SizedBox(height: 4),
                                    Text(ride.pickup.time!, style: AppTextStyle.regularBlack1_12),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Connector
                        Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Column(
                            children: List.generate(
                              3,
                              (index) => Container(
                                width: 2,
                                height: 6,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                        // Dropoff
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, size: 14, color: AppColors.error),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(context.translate('orders.to'), style: AppTextStyle.regularBlack1_12),
                                  const SizedBox(height: 4),
                                  Text(ride.dropoff.address, style: AppTextStyle.mediumBlack14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fare Details
                  _buildSection(
                    title: context.translate('rideDetail.fareDetails'),
                    child: Column(
                      children: [
                        _buildFareRow(context.translate('rideDetail.baseFare'), ride.fare.baseFare),
                        _buildFareRow(context.translate('rideDetail.distanceFare'), ride.fare.distanceFare),
                        if (ride.fare.discountAmount > 0)
                          _buildFareRow(context.translate('rideDetail.discount'), -ride.fare.discountAmount, isDiscount: true),
                        if (ride.fare.pointsDiscount > 0)
                          _buildFareRow(context.translate('orders.pointsDiscount'), -ride.fare.pointsDiscount, isDiscount: true),
                        const Divider(),
                        _buildFareRow(context.translate('rideDetail.totalFare'), ride.fare.finalAmount, isBold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Trip Info
                  _buildSection(
                    title: context.translate('rideDetail.rideInfo'),
                    child: Column(
                      children: [
                        _buildInfoRow(context.translate('ride.distance'), '${ride.distanceKm.toStringAsFixed(1)} ${context.translate('ride.km')}'),
                        _buildInfoRow(context.translate('orders.estimatedDuration'), '${ride.estimatedDurationMinutes} ${context.translate('orders.minute')}'),
                        if (ride.actualDurationMinutes != null)
                          _buildInfoRow(context.translate('orders.actualDuration'), '${ride.actualDurationMinutes} ${context.translate('orders.minute')}'),
                        _buildInfoRow(context.translate('ride.paymentMethod'), _getPaymentMethodText(context, ride.paymentMethod)),
                        _buildInfoRow(context.translate('rideDetail.paymentStatus'), _getPaymentStatusText(context, ride.paymentStatus)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Timestamps
                  _buildSection(
                    title: context.translate('orders.timestamps'),
                    child: Column(
                      children: [
                        if (ride.timestamps.createdAt != null)
                          _buildTimestampRow(context.translate('rideDetail.createdAt'), ride.timestamps.createdAt!),
                        if (ride.timestamps.acceptedAt != null)
                          _buildTimestampRow(context.translate('orders.acceptedAt'), ride.timestamps.acceptedAt!),
                        if (ride.timestamps.driverArrivedAt != null)
                          _buildTimestampRow(context.translate('orders.driverArrived'), ride.timestamps.driverArrivedAt!),
                        if (ride.timestamps.startedAt != null)
                          _buildTimestampRow(context.translate('orders.rideStarted'), ride.timestamps.startedAt!),
                        if (ride.timestamps.completedAt != null)
                          _buildTimestampRow(context.translate('orders.rideCompleted'), ride.timestamps.completedAt!),
                        if (ride.timestamps.cancelledAt != null)
                          _buildTimestampRow(context.translate('orders.cancelledAt'), ride.timestamps.cancelledAt!),
                      ],
                    ),
                  ),

                  // Cancellation Info (if cancelled)
                  if (ride.status.toLowerCase() == 'cancelled') ...[
                    const SizedBox(height: 20),
                    _buildSection(
                      title: context.translate('orders.cancellationInfo'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ride.cancelledBy != null)
                            _buildInfoRow(context.translate('orders.cancelledBy'), ride.cancelledBy!),
                          if (ride.cancellationReason != null)
                            _buildInfoRow(context.translate('orders.cancellationReason'), ride.cancellationReason!),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.semiBoldBlack14),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: BorderColor.grey1),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status?.toLowerCase()) {
      case 'completed':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        text = context.translate('status.completed');
        break;
      case 'cancelled':
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        text = context.translate('status.cancelled');
        break;
      default:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        text = context.translate('status.inProgress');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFareRow(String label, double amount, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? AppTextStyle.semiBoldBlack14 : AppTextStyle.regularBlack1_14,
          ),
          Text(
            '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(2)}',
            style: isBold
                ? AppTextStyle.semiBoldBlack14.copyWith(color: AppColors.success)
                : isDiscount
                    ? AppTextStyle.regularBlack1_14.copyWith(color: AppColors.error)
                    : AppTextStyle.regularBlack1_14,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.regularBlack1_14),
          Text(value, style: AppTextStyle.mediumBlack14),
        ],
      ),
    );
  }

  Widget _buildTimestampRow(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.regularBlack1_14),
          Text(
            '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
            style: AppTextStyle.mediumBlack14,
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodText(BuildContext context, String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return context.translate('ride.cash');
      case 'card':
        return context.translate('ride.card');
      case 'wallet':
        return context.translate('orders.wallet');
      default:
        return method;
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
}
