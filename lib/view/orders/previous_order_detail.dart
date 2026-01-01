
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:provider/provider.dart';
import 'package:uber_driver/shared/language/extension.dart';
import 'package:uber_driver/view/orders/update_status_screen.dart';
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
import '../../utils/app_dimens.dart';
import '../../utils/app_icons.dart';

class PreviousOrderDetail extends StatefulWidget {
  const PreviousOrderDetail({super.key, required this.data});

  final OrderModel data;

  @override
  State<PreviousOrderDetail> createState() => _PreviousOrderDetailState();
}

class _PreviousOrderDetailState extends State<PreviousOrderDetail> {
  late String orderDate;

  @override
  void initState() {
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
          actions: [
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10, left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                  color: AppColors.hexToColor(widget.data.statusColor!)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4)),
              child: Center(
                child: cText(
                    text: widget.data.statusName ?? '',
                    style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: AppDimens.fontSizeA14,
                        color: AppColors.hexToColor(widget.data.statusColor!),
                        fontWeight: FontWeight.w500)),
              ),
            )
          ],
        ),
        backgroundColor: BackgroundColor.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
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
                          icon: AppIcons.orderIcon,
                          width: 24,
                          height: 24,
                        ),
                        cText(
                            text: context
                                .translate('order.orderDetail.orderStatus'),
                            style: AppTextStyle.semiBoldBlack14),
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
                    DefaultOutlinedButton(
                      raduis: 6,
                      text: context.translate('buttons.updateOrder'),
                      textStyle: AppTextStyle.semiBoldPrimary14,
                      pressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UpdateStatusScreen(data: widget.data)));
                      },
                    ),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 8,
                      children: [
                        SvgIcon(
                          icon: AppIcons.orderCustomer, // use a store icon if you have one
                          width: 24,
                          height: 24,
                        ),
                        cText(
                          text: context.translate('order.orderDetail.merchant'),
                          style: AppTextStyle.semiBoldBlack14,
                        ),
                      ],
                    ),

                    // --- Merchant details from OrderModel ---
                    Builder(
                      builder: (context) {
                        final name = widget.data.merchantFullName ?? '';
                        final phone = widget.data.merchantPhone ?? '';
                        final note  = widget.data.merchantNote ?? '';

                        // If absolutely nothing exists, hide the section body.
                        final hasAny = name.isNotEmpty || phone.isNotEmpty || note.isNotEmpty;
                        if (!hasAny) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            if (name.isNotEmpty)
                              cText(
                                text: name,
                                style: AppTextStyle.semiBoldBlack14,
                              ),

                            if (phone.isNotEmpty)
                              GestureDetector(
                                onTap: () async {
                                  final uri = Uri(scheme: 'tel', path: phone);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                                child: Row(
                                  spacing: 8,
                                  children: [
                                    const Icon(Icons.phone, size: 18, color: Colors.black54),
                                    cText(
                                      text: phone,
                                      style: AppTextStyle.regularBlack1_14,
                                    ),
                                  ],
                                ),
                              ),

                            if (note.isNotEmpty)
                              cText(
                                text: note,
                                style: AppTextStyle.regularBlack1_14,
                              ),
                          ],
                        );
                      },
                    ),
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
                  spacing: 18,
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
                                      widget.data.lines![index].imageUrl ,
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
                                                widget.data.lines![index].name,
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
      );
    });
  }
}
