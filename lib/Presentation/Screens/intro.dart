// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:gradiantbutton/gradiantbutton.dart';

class IntroScreen extends StatefulWidget {
  static String routeName = '/intro';

  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  var check = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: const BoxDecoration(
                    color: Color(0XFF041C32),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradiantButton(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0XFF1AD5AD),
                            Color(0XFF23D99D),
                          ],
                        ),
                        onPressed: () {},
                        width: 150,
                        radius: 50,
                        child: const Text(
                          'بزن بریم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.18,
              left: 0,
              child: Transform.flip(
                flipX: true,
                child: Image.asset(
                  'assets/images/welcome.png',
                  height: 450,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            const Positioned(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'سلام',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(text: '👋', style: TextStyle(fontSize: 30))
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Text.rich(
                      TextSpan(
                        text: 'حسابچی',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                              text:
                                  ' اینجاست \n تا بـــــــــــــدونی \n حــســاب کتــابـات \n چـــی بــه چـــیـــه !؟!',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.normal))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
