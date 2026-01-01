import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_driver/shared/language/extension.dart';
import 'package:uber_driver/shared/language/language_provider.dart';
import 'package:uber_driver/view/profile/profile_detail_screen.dart';
import 'package:uber_driver/view/profile/rules_screen.dart';
import 'package:uber_driver/view/profile/wallet_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/components/appBar/design_sheet_app_bar.dart';
import '../../../shared/local/cash_helper.dart';
import '../../../shared/local/secure_cash_helper.dart';
import '../../providers/profile_provider.dart';
import '../../shared/components/cards/profile_card.dart';
import '../../shared/components/text/CText.dart';
import '../../utils/app_icons.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/colors.dart';
import '../login/login_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String followers = '0';
  String trades = '0';
  String image = '';

  @override
  void initState() {
    // CashHelper.getData(key: 'personalInfo').then((value) {
    //   setState(() {
    //     userName = '${value![1]} ${value[2]}';
    //     followers = value[6];
    //   });
    // });
    // CashHelper.getDataString(key: 'profileImage').then((value) {
    //   if (value != null) {
    //     setState(() {
    //       image = value;
    //     });
    //   }
    // });
    // getPersonalInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cText(
                pRight: 24,
                  text: context.translate('profile.title'),
                  style: AppTextStyle.semiBoldBlack22),
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                    top: 20, bottom: 80, right: 20, left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(
                    //   height: defaultPadding * 2.5,
                    // ),
                    // appBarText(text: context.translate('profile.title')),
                    // SizedBox(
                    //   height: defaultPadding * 1.5,
                    // ),
                    // ProfileCard(
                    //   image: image,
                    //   userName: userName,
                    //   followers: followers,
                    //   trades: trades,
                    // ),

                    ProfileOptionCard(
                      pressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileDetailScreen(),
                            ));
                      },
                      text: 'profile.detail',
                      icon: AppIcons.detailP,
                    ),

                    Container(
                      height: 1,
                      color: BorderColor.grey,
                      margin: EdgeInsets.symmetric(vertical: 8),
                    ),
                    ProfileOptionCard(
                      pressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RulesScreen(),
                            ));
                      },
                      text: 'profile.privacy',
                      icon: AppIcons.privacyP,
                    ),
                    Container(
                      height: 1,
                      color: BorderColor.grey,
                      margin: EdgeInsets.symmetric(vertical: 8),
                    ),
                    ProfileOptionCard(

                      pressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WalletScreen(),
                            ));
                      },
                      text: 'profile.wallet',
                      icon: AppIcons.walletP,
                    ),
                    Container(
                      height: 1,
                      color: BorderColor.grey,
                      margin: EdgeInsets.symmetric(vertical: 8),
                    ),
                    ProfileOptionCard(
                      withForword: 1,
                      pressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WalletScreen(),
                            ));
                      },
                      text: 'profile.notification',
                      icon: AppIcons.notification,
                    ),

                    Container(
                      height: 1,
                      color: BorderColor.grey,
                      margin: EdgeInsets.symmetric(vertical: 8),
                    ),
                    // Language Selection
                    Consumer<LanguageProvider>(
                      builder: (context, languageProvider, child) {
                        return ProfileOptionCard(
                          withForword: 3,
                          pressed: () {
                            _showLanguageDialog(context, languageProvider);
                          },
                          text: 'profile.language',
                          icon: AppIcons.privacyP,
                          trailing: Text(
                            languageProvider.isArabic
                                ? context.translate('profile.arabic')
                                : context.translate('profile.english'),
                            style: AppTextStyle.regularBlack4_14,
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 1,
                      color: BorderColor.grey,
                      margin: EdgeInsets.symmetric(vertical: 8),
                    ),
                    ProfileOptionCard(
                      withForword: 2,
                      pressed: () async {
                        await CashHelper.clearData();
                        await SecureCashHelper.clear();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginLayout(),
                            ));
                      },
                      text: 'profile.logout',
                      icon: AppIcons.logoutP,
                    ),

                    const SizedBox(
                      height: 20,
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

  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.translate('profile.language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  languageProvider.isArabic
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.primary,
                ),
                title: Text(context.translate('profile.arabic')),
                onTap: () {
                  languageProvider.setArabic();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  languageProvider.isEnglish
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.primary,
                ),
                title: Text(context.translate('profile.english')),
                onTap: () {
                  languageProvider.setEnglish();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.translate('buttons.cancel')),
            ),
          ],
        );
      },
    );
  }
}
