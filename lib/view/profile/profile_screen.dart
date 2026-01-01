import 'dart:io';


import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:uber_driver/shared/language/extension.dart';
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

// getPersonalInfo() async {
//   try {
//     List<String>? info = await CashHelper.getData(key: 'personalInfo');
//     int memberId = int.parse(info![0]);
//     String token = '';
//     await CashHelper.getDataString(key: 'token').then((value) {
//       if (value != null) {
//         token = value;
//       }
//     });
//     print(token);
//
//     final response = await DioHelper.getData(url: 'api/members', query: {
//       'id': memberId,
//     }, header: {
//       'Authorization': 'Bearer $token',
//     }); // Replace with your API endpoint
//     print(response.data['data'][0]);
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = response.data['data'][0];
//       print(data['firstname'] + ' ' + data['lastname']);
//       print(data['followers']);
//       setState(() {
//         userName = data['firstname'] + ' ' + data['lastname'];
//         followers = '${data['followers']}';
//         // trades = data['trades'];
//         image = data['image'] ?? '';
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   } catch (error) {
//     print(error);
//     if (error is DioException &&
//         (error.type == DioExceptionType.connectionTimeout ||
//             error.type == DioExceptionType.connectionError)) {
//       // Handle connection timeout error
//       return Future.error('connection timeout');
//     } else if (error is DioException) {
//       return Future.error('connection other');
//     }
//
//     // print(error.response);
//     // print('Error message: ${error.error}');
//     // print('Error description: ${error.message}');
//     else {
//       return Future.error('connection other');
//     }
//   }
// }
}
