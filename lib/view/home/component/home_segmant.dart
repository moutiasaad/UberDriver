import 'package:flutter/material.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../../../shared/components/text/CText.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/colors.dart';

class HomeSegmant extends StatefulWidget {
  HomeSegmant({
    super.key,
  });

  @override
  State<HomeSegmant> createState() => _HomeSegmantState();
}

class _HomeSegmantState extends State<HomeSegmant> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              color: BorderColor.grey,
              height: 1,
            ),
          ),
          Row(
            spacing: 18,
            children: [
              Container(
                width: 110,
                child: Column(
                  spacing: 8,
                  children: [
                    cText(
                        text: context.translate("home.allOrder"),
                        style: AppTextStyle.mediumPrimary16),
                    Container(
                      color: BorderColor.primary,
                      height: 2,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
