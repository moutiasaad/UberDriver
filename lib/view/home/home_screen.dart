
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../../providers/order_provider.dart';
import '../../shared/components/header/home_header.dart';
import '../../shared/error/error_component.dart';
import '../orders/ride_detail.dart';
import 'component/home_segmant.dart';
import 'component/ride_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.profile = false});

  final bool profile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _pendingRidesFuture;

  @override
  void initState() {
    super.initState();
    _pendingRidesFuture = _loadPendingRides();
  }

  Future<void> _loadPendingRides() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.getPendingRides();
  }

  Future<void> _refreshRides() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.refreshPendingRides();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshRides,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
                    HomeSegmant(),
                    Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: FutureBuilder(
                        future: _pendingRidesFuture,
                        builder: (context, snapshot) {
                          // Loading state
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          // Error state
                          if (orderProvider.hasError) {
                            final error = orderProvider.errorMessage;

                            if (error == 'connection_timeout' ||
                                error == 'connection_error') {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wifi_off,
                                        size: 60,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        context.translate(
                                            'errorsMessage.connection'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _pendingRidesFuture =
                                                _loadPendingRides();
                                          });
                                        },
                                        child: Text(
                                            context.translate('buttons.retry')),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Center(
                              child: undefinedError(context: context),
                            );
                          }

                          // Empty state
                          if (!orderProvider.hasRides) {
                            return Center(
                              child: noOrders(context: context),
                            );
                          }

                          // Success state - show rides
                          final rides = orderProvider.pendingRides;

                          return ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(
                              top: 18,
                              bottom: 80,
                              right: 18,
                              left: 18,
                            ),
                            itemBuilder: (context, index) {
                              final ride = rides[index];
                              return RideCard(
                                ride: ride,
                                onDetailPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RideDetailScreen(ride: ride),
                                    ),
                                  );
                                },
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 12);
                            },
                            itemCount: rides.length,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
