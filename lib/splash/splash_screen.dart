import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/driver_provider.dart';
import '../shared/local/secure_cash_helper.dart';
import '../view/layout/driver_home_layout.dart';
import '../view/login/login_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Future<Widget> initialData() async {
    //return const LoginLayout();
    String token = await SecureCashHelper.getToken();
    if (token.isEmpty) {
      return const LoginLayout();
    } else {
      // Call go-online API when token exists
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      await driverProvider.goOnline();
      return DriverHomeLayout();
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 6), () {
      initialData().then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => value),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/tshl_tawsil_captin_icon.png',
          height: 240,
          width: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
