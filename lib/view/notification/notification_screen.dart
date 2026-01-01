import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_driver/providers/notification_provider.dart';
import 'package:uber_driver/shared/language/extension.dart';
import '../../../shared/components/cards/notification_card.dart';
import '../../../utils/colors.dart';
import '../../shared/components/header/driver_header.dart';
import '../../shared/error/error_component.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch notifications when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<NotificationProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                driverHeader(
                    text: context.translate('bottomBar.notification'),
                    context: context),
                Expanded(
                  child: _buildContent(notificationProvider),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(NotificationProvider provider) {
    // Show loading indicator on first load
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error state
    if (provider.error != null && provider.notifications.isEmpty) {
      if (provider.error == 'connection timeout') {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              undefinedError(context: context),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.refresh(),
                child: Text(context.translate('common.retry')),
              ),
            ],
          ),
        );
      }
      return Center(child: undefinedError(context: context));
    }

    // Show empty state
    if (provider.notifications.isEmpty) {
      return Center(
        child: noNotification(context: context),
      );
    }

    // Show notifications list
    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.separated(
        controller: _scrollController,
        itemBuilder: (context, index) {
          if (index < provider.notifications.length) {
            return NotificationCard(
              notification: provider.notifications[index],
              onTap: () async {
                final notification = provider.notifications[index];
                if (notification.id != null && notification.isRead != true) {
                  await provider.markAsRead(notification.id! as String);
                }
              },
            );
          }
          // Loading indicator at the bottom for pagination
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        },
        separatorBuilder: (context, index) {
          return Container(
            height: 1,
            width: double.infinity,
            color: BorderColor.grey5,
          );
        },
        itemCount: provider.notifications.length + (provider.hasMore ? 1 : 0),
      ),
    );
  }
}
