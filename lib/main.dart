import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uber_driver/shared/language/app_localizations.dart';
import 'package:uber_driver/shared/language/language_provider.dart';
import 'package:uber_driver/shared/local/cash_helper.dart';
import 'package:uber_driver/shared/local/secure_cash_helper.dart';
import 'package:uber_driver/shared/remote/dio_helper.dart';
import 'package:uber_driver/splash/splash_screen.dart';
import 'package:uber_driver/utils/colors.dart';

import 'config/provider_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DioHelper.init();
  await CashHelper.init();
  await SecureCashHelper.init();
  runApp(
    MultiProvider(
      providers: ProviderConfig().providers,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: languageProvider.locale,
      supportedLocales: const [
        Locale('ar'), // English
      ],


      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.secondary),
        useMaterial3: false,
      ),
      home: SplashScreen(),
    );
  }
}
