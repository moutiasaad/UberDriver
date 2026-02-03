import 'package:flutter/material.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../../shared/components/buttons/cancel_button.dart';
import '../../shared/components/text/CText.dart';
import '../../utils/app_text_styles.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
          cText(text: context.translate('profile.privacyPolicyTitle'), style: AppTextStyle.semiBoldBlack18),
          elevation: 1,
          backgroundColor: Colors.white,
          leading: CancelButton(
            context: context,
            icon: Icons.arrow_back,
            cancel: () {
              Navigator.pop(context);
            },
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          children: [
            cText(text: context.translate('profile.privacyPolicyContent'),
                style: AppTextStyle.mediumBlack3_14)
          ],
        ),
      ),
    );
  }
}
