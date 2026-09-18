import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../Logic/Providers/Api/api_connection.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLogin = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0XFF041C32),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                alignment: Alignment.topRight,
                child: const Row(
                  children: [
                    Icon(
                      Iconsax.login_outline,
                      size: 30,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'ورود',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                    RegExp('[ء-ی]'),
                  ),
                ],
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.user_outline),
                  hintText: 'نام کاربری',
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(181, 158, 158, 158),
                    fontSize: 16,
                    letterSpacing: 0,
                  ),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha:0.2),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  counterText: '',
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.password_check_outline),
                  hintText: 'رمز عبور',
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(181, 158, 158, 158),
                    fontSize: 16,
                    letterSpacing: 0,
                  ),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha:0.2),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  counterText: '',
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              // const SizedBox(height: 20),
              // const Text(
              //   'فراموشی رمز عبور؟',
              //   style: TextStyle(
              //     color: Colors.blue,
              //     fontSize: 12,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 40),
              Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: usernameController.text.length > 2 &&
                            passwordController.text.length > 2
                        ? [
                            const Color(0XFF1AD5AD),
                            const Color(0XFF23D99D),
                          ]
                        : [
                            Colors.grey.withValues(alpha:0.5),
                            Colors.grey.withValues(alpha:0.5),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ElevatedButton(
                  onPressed: usernameController.text.length > 2 &&
                          passwordController.text.length > 2
                      ? () async {
                          isLogin = true;
                          setState(() {});
                          bool? state = await login(
                            username: usernameController.text,
                            password: passwordController.text,
                            context: context,
                          );
                          isLogin = false;

                          if (state != null) {
                            if (!state) {
                              DelightToastBar(
                                autoDismiss: true,
                                position: DelightSnackbarPosition.top,
                                snackbarDuration:
                                    const Duration(milliseconds: 2500),
                                builder: (context) => const ToastCard(
                                  color: Colors.red,
                                  leading: Icon(
                                    Iconsax.info_circle_outline,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    'نام کاربری یا رمز عبور اشتباه است',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ).show(context);
                            }
                          }
                          setState(() {});
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent),
                  child: isLogin
                      ? const SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ورود',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
