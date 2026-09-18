import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  String appVersion = '';

  Future<void> getAppVersion() async {
    PackageInfo appInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = appInfo.version;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('درباره برنامه'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/icon/logo.png'),
                      onError: (exception, stackTrace) => Icon(
                        Icons.broken_image_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                'حسابچی',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'دستیار'),
                  TextSpan(
                    text: ' هوشمند ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: 'مالی شما'),
                ]),
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: const Text(
                  'حسابچی یک نرم‌افزار دستیار مالی است که به شما در مدیریت مالی و حسابداری کمک می‌کند. این نرم‌افزار با ارائه خدمات و گزارش‌های دقیق، به شما اطلاعات لازم را ارائه می‌دهد تا تصمیم‌گیری های مالی خود را بهبود بخشید.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'چرا حسابچی را انتخاب کنیم ؟',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: const Text(
                  '● سادگی و کاربرپسندی : حسابچی با رابط کاربری ساده و قابل فهم، به شما امکان استفاده آسان را می‌دهد.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: const Text(
                  '● دقت و قابلیت تنظیم : اطلاعات دقیق و قابلیت تنظیم گزارش‌ها به شما کمک می‌کند تا مالیات‌ها و مدیریت مالی خود را بهبود بخشید.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: const Text(
                  'با حسابچی، مدیریت مالی به سادگی در دستان شماست!',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('نسخه برنامه  :  '),
                  Text('Hesabchi-$appVersion'),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(width: 0.3, color: Colors.grey))),
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: const Wrap(
          textDirection: TextDirection.ltr,
          alignment: WrapAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                ' Copyright © 2024 ',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: Colors.green,
                size: 20,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                ' Torshiz Green Cedar ',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                ' All rights reserved ',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
