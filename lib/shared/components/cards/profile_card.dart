import 'package:flutter/material.dart';
import 'package:uber_driver/shared/language/extension.dart';


import '../../../utils/app_text_styles.dart';
import '../../../utils/colors.dart';
import '../image/svg_icon.dart';
import '../text/CText.dart';

class ProfileOptionCard extends StatefulWidget {
  final String text;
  final String icon;
  final Function pressed;
  final int withForword;

  const ProfileOptionCard(
      {super.key,
      required this.text,
      required this.icon,
      required this.pressed,
      this.withForword = 0});

  @override
  State<ProfileOptionCard> createState() => _ProfileOptionCardState();
}

class _ProfileOptionCardState extends State<ProfileOptionCard> {
  @override
  Widget build(BuildContext context) {
    bool notification = false;
    return Container(
      height: 60,
      child: MaterialButton(
        onPressed: () {
          widget.pressed();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgIcon(
              icon: widget.icon,
              height: 22,
              width: 22,
            ),
            const SizedBox(
              width: 16,
            ),
            cText(
                text: context.translate(widget.text),
                style: AppTextStyle.mediumBlack14),
            const Spacer(),
            widget.withForword == 0
                ? Icon(
                    Icons.arrow_forward_ios,
                    color: BorderColor.grey,
                    size: 18,
                  )
                : widget.withForword == 1
                    ? Switch(value: notification, onChanged: (value){
                      print(value);
                      setState(() {
                        notification = value;
                      });

            })
                    : SizedBox()
          ],
        ),
      ),
    );
  }
}
