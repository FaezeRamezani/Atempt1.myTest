import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:native_auth/native_auth.dart';

import '../../Logic/Providers/Api/api_connection.dart';
import '../../logic/providers/SharedPreferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool? check;

  void initLoading() {
    EasyLoading.instance
      ..indicatorWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Image.asset(
              'assets/icon/logo.png',
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'صبر نمایید',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(width: 5),
                LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.red,
                  size: 35,
                ),
              ],
            ),
          ],
        ),
      )
      ..loadingStyle = EasyLoadingStyle.custom
      ..maskType = EasyLoadingMaskType.custom
      ..radius = 30
      ..backgroundColor = Colors.transparent
      ..maskColor = Colors.white.withValues(alpha:0.9)
      ..dismissOnTap = false
      ..indicatorSize = 60
      ..indicatorColor = Colors.red
      ..textColor = Colors.red
      ..textStyle =
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
      ..boxShadow = const [];

    setState(() {});
  }

  Future<void> authUser() async {
    bool authFinger = await getFingerPermission();
    initLoading();
    if (authFinger) {
      final response = await Auth.isAuthenticate(
        title: 'احراز هویت',
        description: 'برای ادامه باید احراز هویت شوید',
        noAuthMethodsReturn: AuthResult.auth,
      );
      if (response.isAuthenticated) {
        initialCheck();
        check = true;
        setState(() {});
      }
    } else {
      initialCheck();
      check = true;
      setState(() {});
    }
  }

  Future<void> initialCheck() async {
    check = await checkSession(context: context);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    authUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                height: 250,
                width: 250,
                child: Image(
                  image: AssetImage('assets/icon/logo.png'),
                ),
              ),
              Column(
                children: [
                  const Text(
                    'حسابچی',
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text('دستیار هوشمند مالی شما',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 30),
                  check == null
                      ? ElevatedButton(
                          onPressed: () {
                            authUser();
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                                Colors.red.shade100),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30))),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 15),
                            child: Text(
                              'صحت سنجی',
                              style: TextStyle(fontSize: 20, color: Colors.red),
                            ),
                          ),
                        )
                      : check!
                          ? LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.red,
                              size: 60,
                            )
                          : ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  check = true;
                                });
                                initialCheck();
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors.red.shade100),
                                foregroundColor:
                                    WidgetStateProperty.all<Color>(Colors.red),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                child: Text(
                                  'تلاش مجدد',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
