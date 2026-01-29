
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:uber_driver/providers/LocationProvider.dart';
import 'package:uber_driver/providers/driver_provider.dart';
import 'package:uber_driver/providers/merchant_provider.dart';
import 'package:uber_driver/providers/notification_provider.dart';
import 'package:uber_driver/providers/order_provider.dart';
import 'package:uber_driver/providers/profile_provider.dart';
import 'package:uber_driver/providers/register_provider.dart';
import 'package:uber_driver/providers/wallet_provide.dart';
import '../shared/language/language_provider.dart';

class ProviderConfig {
  List<SingleChildWidget> providers = [
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
    ),
    ChangeNotifierProvider<RegisterProvider>(
      create: (_) => RegisterProvider(),
    ),
    ChangeNotifierProvider<DriverProvider>(
      create: (_) => DriverProvider(),
    ),
    ChangeNotifierProvider<OrderProvider>(
      create: (_) => OrderProvider(),
    ),
    ChangeNotifierProvider<ProfileProvider>(
      create: (_) => ProfileProvider(),
    ),
    ChangeNotifierProvider<WalletProvider>(
      create: (_) => WalletProvider(),
    ),
    ChangeNotifierProvider<NotificationProvider>(
      create: (_) => NotificationProvider(),
    ),
    ChangeNotifierProvider(create: (_) => MerchantProvider()),
    ChangeNotifierProvider(create: (_) => LocationProvider()),
  ];
}
