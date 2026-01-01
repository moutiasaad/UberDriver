import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../../../utils/app_images.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/colors.dart';
import '../../local/cash_helper.dart';

import '../image/image_net.dart';
import '../text/CText.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.primary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              cText(
                  text: context.translate('home.welcome'),
                  style: AppTextStyle.boldWhite18),
              cText(
                  text: context.translate('home.seeToDayOrder'),
                  style: AppTextStyle.semiBoldWhite16),
            ],
          ),
          ClipOval(
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  )),
              child: ImageNet(
                imageUrl:
                //CashHelper.getUserData().image ??
                    '',
                boxFit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
