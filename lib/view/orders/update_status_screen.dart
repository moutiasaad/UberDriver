
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:uber_driver/shared/language/extension.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/enum/order_status.dart';
import '../../../providers/order_provider.dart';
import '../../../shared/components/appBar/design_sheet_app_bar.dart';
import '../../../shared/components/buttons/default_button.dart';
import '../../../shared/components/image/image_net.dart';
import '../../../shared/components/text/CText.dart';
import '../../../shared/logique_function/date_functions.dart';
import '../../../shared/logique_function/time_function.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/colors.dart';
import 'package:intl/intl.dart';

import '../../models/order_model.dart';
import '../../models/order_status_model.dart';
import '../../providers/LocationProvider.dart';
import '../../providers/register_provider.dart';
import '../../shared/components/buttons/cancel_button.dart';
import '../../shared/components/buttons/default_outlined_button.dart';
import '../../shared/components/image/svg_icon.dart';
import '../../shared/components/map/map_component.dart';
import '../../shared/components/map/map_track.dart';
import '../../shared/error/error_component.dart';
import '../../shared/local/cash_helper.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_icons.dart';

class UpdateStatusScreen extends StatefulWidget {
  const UpdateStatusScreen({super.key, required this.data});

  final OrderModel data;

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  late String orderDate;
  bool _isMapInteracting = false;

  void _setMapGesture(bool isInteracting) {
    setState(() {
      print('${_isMapInteracting}   sdqdsssd');
      _isMapInteracting = isInteracting;
    });
  }

  @override
  void initState() {
    orderDate = '';
    //     DateFormat('yyyy/MM/dd hh:mm a')
    //     .format(DateTime.parse(widget.data.createDate!));
    // print(widget.data.createDate);
    // print(orderDate);
    // print(widget.data.cardDescription);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (context, orderProvider, child) {
      return Scaffold(
        appBar: AppBar(
          leading: CancelButton(
            context: context,
            icon: Icons.arrow_back,
          ),
          title: cText(
              text:
                  '${context.translate('order.orderDetail.orderNumber')} ${widget.data.id}#',
              style: AppTextStyle.semiBoldBlack14),
          elevation: 0.5,
          backgroundColor: BackgroundColor.background,
        ),
        backgroundColor: BackgroundColor.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 400,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: MapTrack(
                    zoom: 12,
                    merchantName: widget.data.groupName!,
                    userName: widget.data.fullName,
                    latitudeS: double.parse(widget.data.latitudeM!),
                    longitudeS: double.parse(widget.data.longitudeM!),
                    latitudeC: double.parse(widget.data.latitudeC!),     // ✅ client latitude
                    longitudeC: double.parse(widget.data.longitudeC!),
                    onFullScreen: true,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        cText(
                            text: widget.data.fullName ?? '',
                            style: AppTextStyle.semiBoldBlack14),
                        cText(
                            text: widget.data.phone ?? '',
                            style: AppTextStyle.regularBlack1_14),
                      ],
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BackgroundColor.grey1,
                        ),
                        child: SvgIcon(icon: AppIcons.phone))
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: BorderColor.grey1,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: cText(
                  text: widget.data.address ?? '',
                  style: AppTextStyle.semiBoldBlack14,
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: BorderColor.grey1,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 8,
                      children: [
                        SvgIcon(
                          icon: AppIcons.orderFill,
                          width: 24,
                          height: 24,
                        ),
                        cText(
                            text: context
                                .translate('order.orderDetail.orderStatus'),
                            style: AppTextStyle.semiBoldPrimary20),
                      ],
                    ),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side (status dots and lines)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 8, left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(
                                  widget.data.orderStatus!.length, (index) {
                                bool isLast = index ==
                                    widget.data.orderStatus!.length - 1;
                                final item = widget.data.orderStatus![index];
                                return Column(
                                  children: [
                                    // Circle Dot
                                    Container(
                                      height: 18,
                                      width: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: item.status == '1'
                                              ? AppColors.primary
                                              : BorderColor.grey,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          height: 8,
                                          width: 8,
                                          decoration: BoxDecoration(
                                            color: item.status == '1'
                                                ? AppColors.primary
                                                : Colors.transparent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Dotted line (only if not last item)
                                    if (!isLast)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: DottedLine(
                                          direction: Axis.vertical,
                                          lineLength: 45,
                                          lineThickness: 2.0,
                                          dashLength: 4.0,
                                          dashColor: AppColors.primary,
                                          dashGapLength: 4.0,
                                        ),
                                      ),
                                  ],
                                );
                              }),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                    widget.data.orderStatus!.length, (index) {
                                  final item = widget.data.orderStatus![index];
                                  print(item.date);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 28),
                                    // space between steps
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        cText(
                                          text: item.title ?? 'Title',
                                          style: AppTextStyle.mediumBlack14,
                                        ),
                                        cText(
                                          text: item.date == '-'
                                              ? '--'
                                              : convertToArabicDate(
                                                  item.date ?? ''),
                                          style: AppTextStyle.regularBlack1_14,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DefaultButton(
                      raduis: 6,
                      text: context.translate('buttons.updateOrder'),
                      pressed: () {
                        _showStatusSheet(
                            order: orderProvider, orderId: widget.data.id!);
                      },
                      activated: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  final Map<int, String> orderStatuses = {
    1: 'تم قبول الطلب',
    2: 'جاري الشحن',
    3: 'تم الاستلام',
    4: 'ملغاة',
    5: 'مسترجعة',
  };

  void _showStatusSheet({
    required OrderProvider order,
    required int orderId,
  }) {
    final Future<List<OrderStatusModel>>? statusFuture = order.getOrderStatus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int? _selectedStatusId;
        String? _selectedStatusName;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: FutureBuilder(
                          future: statusFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.error == 'Failed to load data') {
                              return Center(child: noOrders(context: context));
                            }

                            if (snapshot.hasError) {
                              if (snapshot.error == 'connection timeout') {
                                return const Center(child: Text("Connection timeout"));
                              } else {
                                return Center(child: undefinedError(context: context));
                              }
                            }

                            final status = snapshot.data as List<OrderStatusModel>;
                            return ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              itemCount: status.length,
                              itemBuilder: (context, index) {
                                final isSelected = status[index].id == _selectedStatusId;
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      _selectedStatusId = status[index].id;
                                      _selectedStatusName = status[index].name;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? TextColor.black1
                                          : BackgroundColor.grey2,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: cText(
                                        text: status[index].name!,
                                        style: isSelected
                                            ? AppTextStyle.semiBoldWhite14
                                            : AppTextStyle.semiBoldBlack14,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      DefaultButton(
                        activated: _selectedStatusId != null,
                        loading: order.updateStatus,
                        text: context.translate('buttons.updateOrder'),
                        raduis: 6,
                        pressed: () async {
                          print("selecttttttttttttt: '${_selectedStatusName!}'");
                          print("Length: ${_selectedStatusName!.length}");

                          // Clean the string for comparison
                          String cleanSelectedStatus = _selectedStatusName!.trim().replaceAll(RegExp(r'\s+'), ' ');

                          // Robust comparison
                          bool isOnTheWay = cleanSelectedStatus == "في الطريق" ||
                              _selectedStatusName!.contains("في الطريق") ||
                              cleanSelectedStatus.contains("الطريق");

                          bool isDelivered = cleanSelectedStatus == "تم التسليم" ||
                              _selectedStatusName!.contains("تم التسليم") ||
                              cleanSelectedStatus.contains("التسليم");

                          print("Is on the way: $isOnTheWay");
                          print("Is delivered: $isDelivered");

                          if (isOnTheWay) {
                            print("Starting location tracking flow...");
                            // Check location permission before updating status
                            final locationProvider = Provider.of<LocationProvider>(context, listen: false);
                            final registerProvider = Provider.of<RegisterProvider>(context, listen: false);
                            final driverId = await CashHelper.getUserId();
                            try {
                              // Request location permission
                              LocationPermission permission = await Geolocator.checkPermission();
                              if (permission == LocationPermission.denied) {
                                permission = await Geolocator.requestPermission();
                                if (permission != LocationPermission.whileInUse &&
                                    permission != LocationPermission.always) {
                                  // Show error if permission not granted
                                  print("Location permission denied");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.translate('errorsMessage.locationPermissionRequired')),
                                    ),
                                  );
                                  return;
                                }
                              }

                              print("Updating order status...");
                              // Update order status first
                              await order.updateOrderStatus(
                                context: context,
                                orderId: orderId,
                                status: _selectedStatusId!,
                              );

                              // Start location tracking after successful status update
                              // final driverId = 20; // Replace with actual driver ID

                              print("Starting periodic tracking...");
                              locationProvider.startPeriodicTracking(
                                context: context,
                                driverId: driverId,
                                driverOrderId: orderId,
                                interval: const Duration(seconds: 30),
                              );

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.translate('successMessage.statusUpdatedWithTracking')),
                                ),
                              );

                              print("Location tracking started successfully");

                            } catch (error) {
                              print("Error in location tracking: $error");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: ${error.toString()}"),
                                ),
                              );
                              return;
                            }
                          }
                          else if (isDelivered) {
                            print("Stopping location tracking flow...");
                            // Update order status first
                            await order.updateOrderStatus(
                              context: context,
                              orderId: orderId,
                              status: _selectedStatusId!,
                            );

                            // Stop location tracking
                            final locationProvider = Provider.of<LocationProvider>(context, listen: false);
                            locationProvider.stopPeriodicTracking();

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.translate('successMessage.statusUpdatedTrackingStopped')),
                              ),
                            );
                            print("Location tracking stopped successfully");
                          }
                          else {
                            print("Regular status update flow...");
                            // For other statuses, just update the order status
                            order.updateOrderStatus(
                              context: context,
                              orderId: orderId,
                              status: _selectedStatusId!,
                            );
                            print("Regular status updated successfully");
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
