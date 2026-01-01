import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../../../models/enum/order_status.dart';
import '../../../models/order_model.dart';
import '../../../shared/components/buttons/default_button.dart';
import '../../../shared/components/buttons/default_outlined_button.dart';
import '../../../shared/components/image/image_net.dart';
import '../../../shared/components/image/svg_icon.dart';
import '../../../shared/components/text/CText.dart';
import '../../../shared/logique_function/date_functions.dart';
import '../../../shared/logique_function/time_function.dart';
import '../../../utils/app_dimens.dart';
import '../../../utils/app_icons.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/colors.dart';
import '../previous_order_detail.dart';

class MyOrderCard extends StatefulWidget {
  const MyOrderCard({super.key, required this.order});

  final OrderModel order;

  @override
  State<MyOrderCard> createState() => _MyOrderCardState();
}

class _MyOrderCardState extends State<MyOrderCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviousOrderDetail(data: widget.order),
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: BackgroundColor.background,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: BorderColor.grey, width: 0.5),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 18,
              children: [
                Container(
                  height: 45,
                  width: 45,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: BackgroundColor.grey1, shape: BoxShape.circle),
                  child: Center(
                    child: SvgIcon(
                      icon: AppIcons.orderIcon,
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 0,
                    children: [
                      cText(
                          text: widget.order.groupName ?? '',
                          style: AppTextStyle.semiBoldBlack14),
                      cText(
                          text: widget.order.address ?? '',
                          style: AppTextStyle.regularBlack1_14),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 14),
              height: 1,
              width: double.infinity,
              color: BorderColor.grey1,
            ),
            Column(
              spacing: 12,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    cText(
                        text: context.translate('order.orderNumber'),
                        //convertToArabicDate(widget.order.createDate!),
                        style: AppTextStyle.regularBlack1_14),
                    cText(
                        text: '#${widget.order.id}',
                        //convertToArabicDate(widget.order.createDate!),
                        style: AppTextStyle.mediumBlack14),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    cText(
                        text: context.translate('order.orderDate'),
                        //convertToArabicDate(widget.order.createDate!),
                        style: AppTextStyle.regularBlack1_14),
                    cText(
                        text: convertToArabicDate(
                            widget.order.createdAt!),
                        style: AppTextStyle.mediumBlack14),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    cText(
                        text: context.translate('order.orderDeliveryDate'),
                        //convertToArabicDate(widget.order.createDate!),
                        style: AppTextStyle.regularBlack1_14),
                    cText(
                        text: getTimeFromDate(widget.order.createdAt!),
                        //convertToArabicDate(widget.order.createDate!),
                        style: AppTextStyle.mediumBlack14),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    cText(
                        text: context.translate('order.orderStatus'),
                        //convertToArabicDate(widget.order.createDate!),
                        style: AppTextStyle.regularBlack1_14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.hexToColor(widget.order.statusColor!)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: cText(
                          text: widget.order.statusName ?? '',
                          style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: AppDimens.fontSizeA14,
                              color: AppColors.hexToColor(
                                  widget.order.statusColor!),
                              fontWeight: FontWeight.w500)),
                    )
                  ],
                ),
              ],
            ),

            // SizedBox(
            //   height: 25,
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: DefaultButton(text:'تأكيد الطلب',
            //             textStyle: AppTextStyle.regularWhite12,
            //             pressed: (){
            //
            //             }, activated: true),
            //       ),
            //       SizedBox(width: 24,),
            //       Expanded(
            //         child: DefaultOutlinedButton(
            //             textStyle: AppTextStyle.regularSecondary12,
            //             text: 'تتبع الطلب',
            //             pressed: (){
            //
            //             }),
            //       )
            //
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
