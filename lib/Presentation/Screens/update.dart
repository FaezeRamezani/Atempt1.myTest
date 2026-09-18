import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../Constant/urls.dart';
import '../../Logic/Providers/Api/api_connection.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key, this.newApp});

  final Map? newApp;

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  double downloadedPercent = 0;
  Map? newApp;
  bool? isUpdate = false;
  bool updating = false;
  bool installing = false;
  late String downloadPath;

  void getUpdate() {
    updating = true;

    setState(() {});

    FileDownloader.downloadFile(
        url: widget.newApp!['Link'] != null
            ? '${widget.newApp!['Link']}'
            : '${Urls.hostUrl}${widget.newApp!['App']}',
        onProgress: (String? fileName, double progress) {
          downloadedPercent = progress / 100;
          setState(() {});
        },
        onDownloadCompleted: (String path) {
          downloadPath = path;
          installing = true;
          setState(() {});
        },
        onDownloadError: (String error) {
          updating = false;

          setState(() {});
        });
  }

  Future<void> checkUpdate() async {
    PackageInfo appInfo = await PackageInfo.fromPlatform();
    String appVersion = appInfo.version;


    await checkVersion(appVersion: appVersion, context: context);
  }

  @override
  void initState() {
    if (widget.newApp != null) {
      isUpdate = false;
    } else {
      isUpdate = true;
    }

    super.initState();

    checkUpdate();
  }

  void popPage() {
    if (widget.newApp != null) {
      exit(0);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false,
     onPopInvokedWithResult: (didPop, result) {
       popPage;
     },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بروزرسانی'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: isUpdate == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10),
                      child: Lottie.asset(
                        'assets/images/search.json',
                        height: MediaQuery.of(context).size.width * 0.7,
                        width: MediaQuery.of(context).size.width * 0.7,
                        fit: BoxFit.fill,
                      ),
                    ),
                    const Text(
                      'در حال بررسی وجود بروزرسانی ',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : isUpdate!
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          child: Lottie.asset(
                            'assets/lottie/update.json',
                            height: MediaQuery.of(context).size.width * 0.7,
                            width: MediaQuery.of(context).size.width * 0.7,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const Text(
                          'شما بروز هستید',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'در حال حاضر از آخرین نسخه حسابچی استفاده می‌کنید',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          child: Lottie.asset(
                            'assets/lottie/newUpdate.json',
                            height: MediaQuery.of(context).size.width * 0.7,
                            width: MediaQuery.of(context).size.width * 0.7,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const Text(
                          'نسخه جدید',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'نسخه جدیدی برنامه در دسترس است',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        !updating
                            ? GestureDetector(
                                onTap: () async {
                                  getUpdate();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.black),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Iconsax.arrow_up_1_outline,
                                            size: 30,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'بروزرسانی',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : !installing
                                ? Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      SimpleAnimationProgressBar(
                                        height: 20,
                                        width: 300,
                                        backgroundColor: Colors.grey.shade800,
                                        foregroundColor: Colors.purple,
                                        ratio: downloadedPercent,
                                        direction: Axis.horizontal,
                                        curve: Curves.fastLinearToSlowEaseIn,
                                        duration: const Duration(seconds: 3),
                                        borderRadius: BorderRadius.circular(10),
                                        gradientColor:
                                            const LinearGradient(colors: [
                                          Colors.orange,
                                          Colors.yellow,
                                        ]),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.yellow.withValues(alpha:0.5),
                                            offset: const Offset(
                                              5.0,
                                              5.0,
                                            ),
                                            blurRadius: 10.0,
                                            spreadRadius: 2.0,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${(downloadedPercent * 100).toInt()} ٪'
                                            .toPersianDigit(),
                                        textDirection: TextDirection.ltr,
                                      )
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: () async {
                                      OpenFile.open(downloadPath);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: Colors.red,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Iconsax.verify_bold,
                                                size: 30,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'نصب بروزرسانی',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      ],
                    ),
        ),
      ),
    );
  }
}

Future update(context, {required Map infoNewApp}) async {
  String appVersion = '';

  PackageInfo appInfo = await PackageInfo.fromPlatform();
  appVersion = appInfo.version;

  return (
    await showDialog(
      barrierColor: const Color.fromARGB(97, 178, 216, 218),
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(
        onPopInvokedWithResult:(didPop, result) {
          exit(0);
        },
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Row(
            children: [
              Icon(Iconsax.arrow_up_1_outline),
              SizedBox(width: 5),
              Text('بروزرسانی برنامه'),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  ' به دلیل توسعه و بهینه سازی ، نسخه جدیدی از برنامه منتشر شده است . برای استفاده از برنامه ابتدا برنامه را بروزرسانی کنید',
                ),
                SizedBox(height: 10),
                const Text(
                  'نسخه فعلی برنامه',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 10),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icon/logo.png',
                        height: 22,
                        width: 22,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'v$appVersion',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => exit(0),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                overlayColor: WidgetStateProperty.all<Color>(
                    Colors.orange.withValues(alpha: 0.15)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.logout_1_outline,
                    size: 20,
                  ),
                  SizedBox(width: 2),
                  Text('خروج از برنامه '),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateScreen(
                      newApp: infoNewApp,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    OctIcons.rocket,
                    size: 20,
                  ),
                  SizedBox(width: 2),
                  Text('بروزرسانی'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
