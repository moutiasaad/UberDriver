import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride_model.dart';
import '../../providers/order_provider.dart';
import '../../shared/components/appBar/design_sheet_app_bar.dart';
import '../../shared/components/text/CText.dart';
import '../../shared/error/error_component.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/colors.dart';

// Hardcoded Arabic strings for orders screen
class _OrdersStrings {
  static const String title = 'سجل الرحلات';
  static const String noRides = 'لا توجد رحلات';
  static const String connectionError = 'مشكلة في الاتصال';
  static const String retry = 'إعادة المحاولة';
  static const String loadMore = 'تحميل المزيد';
  static const String from = 'من';
  static const String to = 'إلى';
  static const String fare = 'الأجرة';
  static const String distance = 'المسافة';
  static const String km = 'كم';
  static const String completed = 'مكتملة';
  static const String cancelled = 'ملغية';
  static const String inProgress = 'جارية';
}

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
            text: _OrdersStrings.title,
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
                          _OrdersStrings.connectionError,
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
                          child: const Text(_OrdersStrings.retry),
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
                      child: _RideHistoryCard(ride: rides[index]),
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

  Widget _buildLoadMoreIndicator(OrderProvider orderProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: orderProvider.loadingMore
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: () => orderProvider.loadMoreHistory(),
                child: const Text(_OrdersStrings.loadMore),
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
              _buildStatusBadge(ride.status),
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
                      text: _OrdersStrings.from,
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
                      text: _OrdersStrings.to,
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
                  icon: Icons.attach_money,
                  label: _OrdersStrings.fare,
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
                  icon: Icons.straighten,
                  label: _OrdersStrings.distance,
                  value: '${ride.distanceKm.toStringAsFixed(1)} ${_OrdersStrings.km}',
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status?.toLowerCase()) {
      case 'completed':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        text = _OrdersStrings.completed;
        break;
      case 'cancelled':
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        text = _OrdersStrings.cancelled;
        break;
      default:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        text = _OrdersStrings.inProgress;
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
