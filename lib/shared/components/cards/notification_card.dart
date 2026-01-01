import 'package:flutter/material.dart';

import '../../../models/notification_model.dart';
import '../../../utils/app_icons.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/colors.dart';
import '../../logique_function/date_functions.dart';
import '../image/svg_icon.dart';
import '../text/CText.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification.isRead ?? false;

    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: isRead ? BackgroundColor.background : BackgroundColor.background.withOpacity(0.95),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: notification.type == 'orders'
                          ? AppColors.primary
                          : BackgroundColor.red2,
                    ),
                    child: SvgIcon(
                        icon: notification.type == 'orders'
                            ? AppIcons.notificationType1
                            : AppIcons.notificationType2)),
                // Unread indicator dot
                if (!isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cText(
                      text: notification.title ?? '',
                      style: isRead
                          ? AppTextStyle.regularBlack4_14
                          : AppTextStyle.semiBoldBlack14),
                  cText(
                      text: notification.body ?? '',
                      style: AppTextStyle.regularBlack4_14)
                ],
              ),
            ),
            cText(
                text: notification.date != null
                    ? convertToArabicDate(notification.date!)
                    : '',
                style: AppTextStyle.regularBlack4_12)
          ],
        ),
      ),
    );
  }
}
