import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


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
import '../../shared/components/buttons/cancel_button.dart';
import '../../shared/components/buttons/default_outlined_button.dart';
import '../../shared/components/image/svg_icon.dart';
import '../../shared/components/map/map_component.dart';
import '../../utils/app_icons.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({super.key, required this.data});

  final OrderModel data;

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  late String orderDate;

  @override
  void initState() {
    print('this');
    print(widget.data.lines![0].imageUrl,);
    print("addresssssssssssssssssssssssss"+widget.data.latitudeM!.toString());
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
          actions: [
            TextButton(
                onPressed: () {
                  orderProvider.unAssignOrder(
                      context: context, orderId: widget.data.id!);
                },
                child: orderProvider.unAssignLoading
                    ? Container(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TextColor.red,
                        ),
                      )
                    : Row(
                        spacing: 4,
                        children: [
                          Icon(
                            CupertinoIcons.xmark,
                            color: TextColor.red,
                            size: 18,
                          ),
                          cText(
                              text: context.translate('order.rejectOrder'),
                              style: AppTextStyle.mediumRed14),
                        ],
                      )),
            SizedBox(
              width: 20,
            )
          ],
          title: cText(
              text:
                  '${context.translate('order.orderDetail.orderNumber')} ${widget.data.id}#',
              style: AppTextStyle.semiBoldBlack14),
          elevation: 0.5,
          backgroundColor: BackgroundColor.background,
        ),
        backgroundColor: BackgroundColor.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                          icon: AppIcons.orderCustomer,
                          width: 24,
                          height: 24,
                        ),
                        cText(
                            text:
                                context.translate('order.orderDetail.customer'),
                            style: AppTextStyle.semiBoldBlack14),
                      ],
                    ),
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
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 6,
                color: BorderColor.grey1,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgIcon(
                          icon: AppIcons.orderLocation,
                          width: 24,
                          height: 24,
                        ),
                        cText(
                            text:
                                context.translate('order.orderDetail.location'),
                            style: AppTextStyle.semiBoldBlack14,
                            pBottom: 8),
                      ],
                    ),
                    SizedBox(
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: MapScreenComponent(
                          zoom: 10,
                          merchantName: widget.data.groupName!,
                          userName: widget.data.fullName,
                          latitudeC: double.parse(widget.data.latitudeC!),
                          longitudeC: double.parse(widget.data.longitudeC!),
                          latitudeS: double.parse(widget.data.latitudeM!),
                          longitudeS: double.parse(widget.data.longitudeM!)
                          ,
                          onFullScreen: true,
                        ),
                      ),
                    ),
                    cText(
                      text: widget.data.address ?? '',
                      style: AppTextStyle.semiBoldBlack14,
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 6,
                color: BorderColor.grey1,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        SvgIcon(
                          icon: AppIcons.orderProduct,
                          width: 24,
                          height: 24,
                        ),
                        cText(
                          text: context.translate('order.orderDetail.product'),
                          style: AppTextStyle.semiBoldBlack14,
                        ),
                      ],
                    ),
                    Column(
                      children: List.generate(
                        widget.data.lines?.length ?? 0,
                        (index) {
                          return Column(
                            children: [
                              Row(
                                spacing: 12,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4.0),
                                    child: ImageNet(
                                      imageUrl:
                                          widget.data.lines![index].imageUrl,
                                      height: 72,
                                      width: 72,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      spacing: 4,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        cText(
                                            text:
                                                widget.data.lines![index].name!,
                                            style:
                                                AppTextStyle.semiBoldBlack14),
                                        Row(
                                          spacing: 4,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            cText(
                                                isPrice: true,
                                                text: widget.data.lines![index]
                                                    .totalPrice
                                                    .toString(),
                                                style: AppTextStyle
                                                    .regularBlack1_14),
                                            cText(
                                                text:
                                                    "${widget.data.lines![index].quantity}  قطعة",
                                                style: AppTextStyle
                                                    .regularBlack1_14),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              index < widget.data.lines!.length - 1
                                  ? const SizedBox(height: 12)
                                  : const SizedBox(),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 6,
                color: BorderColor.grey1,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        SvgIcon(
                          icon: AppIcons.orderSummary,
                          width: 24,
                          height: 24,
                        ),
                        cText(
                          text: context.translate('order.orderDetail.summary'),
                          style: AppTextStyle.semiBoldBlack14,
                        ),
                      ],
                    ),
                    Column(
                      spacing: 12,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            cText(
                              text: context.translate('order.orderDetail.date'),
                              style: AppTextStyle.regularBlack1_14,
                            ),
                            cText(
                              text: convertToArabicDate(
                                  widget.data.createdAt ?? ''),
                              style: AppTextStyle.mediumBlack14,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            cText(
                              text: context
                                  .translate('order.orderDetail.sumExtra'),
                              style: AppTextStyle.regularBlack1_14,
                            ),
                            cText(
                              isPrice: true,
                              text: (double.parse(widget.data.totalPrice != null
                                          ? widget.data.totalPrice.toString()
                                          : '0') -
                                      double.parse(widget.data.deliveryCost !=
                                              null
                                          ? widget.data.deliveryCost.toString()
                                          : '0'))
                                  .toStringAsFixed(2),
                              style: AppTextStyle.mediumBlack14,
                            ),
                          ],
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     cText(
                        //       text: context
                        //           .translate('order.orderDetail.discount'),
                        //       style: AppTextStyle.regularBlack1_14,
                        //     ),
                        //     cText(
                        //       isPrice: true,
                        //       text: widget.data.lines!.product!.discountPrice!
                        //               .isEmpty
                        //           ? "0"
                        //           : widget.data.lines!.product!.discountPrice!,
                        //       style: AppTextStyle.mediumBlack14,
                        //     ),
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            cText(
                              text: context
                                  .translate('order.orderDetail.deliveryFee'),
                              style: AppTextStyle.regularBlack1_14,
                            ),
                            cText(
                              isPrice: true,
                              text: widget.data.deliveryCost ?? '0',
                              style: AppTextStyle.mediumBlack14,
                            ),
                          ],
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     cText(
                        //       text: context
                        //           .translate('order.orderDetail.addition'),
                        //       style: AppTextStyle.regularBlack1_14,
                        //     ),
                        //     cText(
                        //       isPrice: true,
                        //       text: '0',
                        //       style: AppTextStyle.mediumBlack14,
                        //     ),
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            cText(
                              text: context.translate('order.orderDetail.sum'),
                              style: AppTextStyle.regularBlack1_14,
                            ),
                            cText(
                              isPrice: true,
                              text: widget.data.totalPrice.toString(),
                              style: AppTextStyle.mediumBlack14,
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
          visible: true,
          //widget.data.status == OrderStatus.awaitingPayment,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: DefaultButton(
                raduis: 6,
                loading: orderProvider.assignLoading,
                text: context.translate('buttons.acceptOrder'),
                pressed: () {

                  orderProvider.assignOrder(
                      context: context, orderId: widget.data.id!);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => PaymentChoiceScreen(
                  //         data: widget.data,
                  //       ),
                  //     ));
                },
                activated: true),
          ),
        ),
      );
    });
  }
}
