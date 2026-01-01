import 'package:flutter/material.dart';
import 'package:uber_driver/shared/language/extension.dart';
import '../../../utils/colors.dart';
import '../../shared/components/image/svg_icon.dart';
import '../../utils/app_icons.dart';
import '../../utils/app_text_styles.dart';
import '../home/home_screen.dart';
import '../notification/notification_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';

class DriverHomeLayout extends StatefulWidget {
  const DriverHomeLayout({super.key});

  @override
  State<DriverHomeLayout> createState() => _DriverHomeLayoutState();
}

class _DriverHomeLayoutState extends State<DriverHomeLayout> {
  int currentIndex = 0;
  var scaffoldKEy = GlobalKey<ScaffoldState>();
  PageController? homeLayoutController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDialogsInSequence(); // Call your dialog sequence here
    });
  }

  void _showDialogsInSequence() async {
    // Show the first dialog
    // await showNotificationDialogs(context).then((_) async {
    //   print('then');
    //   await Future.delayed(const Duration(milliseconds: 400));
    //   // Once the first dialog is closed, show the second dialog
    //   showLocalisationDialogs(context);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKEy,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: homeLayoutController,
          children: const [
            HomeScreen(),
            OrdersScreen(),
            ProfileScreen(),
            NotificationScreen(),
          ],
        ),
        extendBody: true,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          selectedItemColor: IconColors.primary,
          selectedLabelStyle: AppTextStyle.mediumSecondary12,
          unselectedItemColor: IconColors.grey6,
          unselectedLabelStyle: AppTextStyle.mediumBlack3_12,
          onTap: (int index) {
            homeLayoutController?.jumpToPage(index);
            setState(() {
              currentIndex = index;
            });
            print('Current Index: $index');
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const SvgIcon(
                icon: AppIcons.homeOutlined,
                color: IconColors.black7,
              ),
              activeIcon: const SvgIcon(
                icon: AppIcons.homeFill,
                color: AppColors.primary,
              ),
              label: context.translate('bottomBar.home'),
            ),
            BottomNavigationBarItem(
              icon: const SvgIcon(
                icon: AppIcons.orderOutlined,
                color: IconColors.black7,
              ),
              activeIcon: const SvgIcon(
                icon: AppIcons.orderFill,
                color: AppColors.primary,
              ),
              label: context.translate('bottomBar.order'),
            ),
            BottomNavigationBarItem(
              icon: const SvgIcon(
                icon: AppIcons.profileOutlined,
                color: IconColors.black7,
              ),
              activeIcon: const SvgIcon(
                icon: AppIcons.profileFill,
                color: AppColors.primary,
              ),
              label: context.translate('bottomBar.profile'),
            ),
            BottomNavigationBarItem(
              icon: const SvgIcon(
                icon: AppIcons.notificationOutlined,
                color: IconColors.black7,
              ),
              activeIcon: const SvgIcon(
                icon: AppIcons.notificationFill,
                color: AppColors.primary,
              ),
              label: context.translate('bottomBar.notification'),
            ),
          ],
        ));
  }
}
