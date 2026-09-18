import 'dart:async';
import 'dart:io';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Constant/urls.dart';
import '../../Data/App/static_data.dart';
import '../../Data/Models/entry/entry.dart';
import '../../Data/Models/log/log.dart';
import '../../Data/Models/output/output.dart';
import '../../Data/Models/tag.dart';
import '../../Data/Models/transaction.dart';
import '../../Logic/Providers/Api/api_connection.dart';
import '../../logic/Helpers/number.dart';
import '../../logic/providers/Storage/storage.dart';

class ReportScreen extends StatefulWidget {
  static String routeName = '/report';

  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  //

  bool fullScreen = false;
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  Jalali? fromDate;
  int typeOfTransaction = 2;
  int sumEntry = 0;
  int sumOutput = 0;

  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();

  List<Transaction>? transactionList;
  String? reportFileUrl;
  String? downloadPath;

  void pop() {
    Navigator.pop(context);
  }

  Timer popPage() {
    return Timer(const Duration(milliseconds: 50), pop);
  }

  Future filter() async {
    List<Tag>? entryTag;
    List<Tag>? outputTag;
    List<Tag> selectedTag = [];

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, Function changeState) {
            func() async {
              entryTag = await getTypeOfEntry(context: context);

              outputTag = await getTypeOfOutput(context: context);

              changeState(() {});
            }

            if (entryTag == null || outputTag == null) {
              func();
            }

            return PopScope(
              onPopInvokedWithResult: (didPop, result) {
                if (transactionList != null) {
                } else {
                  popPage();
                }
              },
              child: AlertDialog(
                title: const Row(
                  children: [
                    Icon(Iconsax.calendar_2_outline, size: 30),
                    SizedBox(width: 5),
                    Text('فیلتر گزارش'),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'نوع تراکنش',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: NeumorphicToggle(
                              style: NeumorphicToggleStyle(
                                //depth: 50,
                                backgroundColor: typeOfTransaction == 0
                                    ? Colors.red.withValues(alpha: 0.3)
                                    : typeOfTransaction == 1
                                    ? Colors.teal.withValues(alpha: 0.3)
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              selectedIndex: typeOfTransaction,
                              thumb: Center(
                                child: Container(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              children: [
                                ToggleElement(
                                  foreground: const Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Iconsax.tick_circle_outline),
                                        SizedBox(width: 3),
                                        Text('همه'),
                                      ],
                                    ),
                                  ),
                                  background: const Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Iconsax.tick_circle_outline),
                                        SizedBox(width: 3),
                                        Text('همه'),
                                      ],
                                    ),
                                  ),
                                ),
                                ToggleElement(
                                  foreground: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Iconsax.arrow_down_2_outline,
                                          color: typeOfTransaction == 1
                                              ? Colors.teal
                                              : null,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'دخل',
                                          style: TextStyle(
                                            color: typeOfTransaction == 1
                                                ? Colors.teal
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  background: const Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Iconsax.arrow_down_2_outline),
                                        SizedBox(width: 3),
                                        Text('دخل'),
                                      ],
                                    ),
                                  ),
                                ),
                                ToggleElement(
                                  foreground: const Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Iconsax.arrow_up_1_outline),
                                        SizedBox(width: 3),
                                        Text('خرج'),
                                      ],
                                    ),
                                  ),
                                  background: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Iconsax.arrow_up_1_outline,
                                          color: typeOfTransaction == 0
                                              ? Colors.red
                                              : null,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'خرج',
                                          style: TextStyle(
                                            color: typeOfTransaction == 0
                                                ? Colors.red
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                changeState(() {
                                  if (value == 0) {
                                    typeOfTransaction = 2;
                                  }
                                  if (value == 1) {
                                    typeOfTransaction = 1;
                                    selectedTag = [];
                                  }
                                  if (value == 2) {
                                    typeOfTransaction = 0;
                                    selectedTag = [];
                                  }
                                });
                                changeState(() {});
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      if (typeOfTransaction != 2)
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Icon(Iconsax.category_2_outline, size: 21),
                                  SizedBox(width: 5),
                                  Text(
                                    'دسته بندی ( اختیاری )',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Neumorphic(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              padding: const EdgeInsets.all(6),
                              style: NeumorphicStyle(
                                color: Colors.transparent,
                                shadowDarkColor: Colors.black,
                                depth: 5,
                                intensity: 0.4,
                                boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(20),
                                ),
                              ),
                              child:
                                  ((entryTag != null &&
                                          typeOfTransaction == 1) ||
                                      (outputTag != null &&
                                          typeOfTransaction == 0))
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.start,
                                            children: [
                                              for (Tag tag in selectedTag)
                                                Container(
                                                  margin: EdgeInsets.all(4),
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              changeState(() {
                                                                selectedTag
                                                                    .remove(
                                                                      tag,
                                                                    );
                                                              });
                                                            },
                                                            child: Transform.rotate(
                                                              angle: 0.7854,
                                                              // 45 degrees in radians
                                                              child: Icon(
                                                                Iconsax
                                                                    .add_outline,
                                                                color: Colors.grey,
                                                                size: 24,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            '${tag.name}',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Color(
                                                                0XFF7F7F7F,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              PopupMenuButton(
                                                color: Colors.white,
                                                enabled:
                                                    !(selectedTag.length ==
                                                        (((entryTag != null &&
                                                                        typeOfTransaction ==
                                                                            1) ||
                                                                    (outputTag !=
                                                                            null &&
                                                                        typeOfTransaction ==
                                                                            0))
                                                                ? (typeOfTransaction ==
                                                                          1
                                                                      ? entryTag!
                                                                      : outputTag!)
                                                                : [])
                                                            .length),
                                                padding: EdgeInsets.zero,
                                                elevation: 1,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                constraints: BoxConstraints(

                                                  minWidth: 150,
                                                ),
                                                icon: Container(
                                                  margin: EdgeInsets.all(4),
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (selectedTag.isEmpty)
                                                        Text(
                                                          'انتخاب دسته بندی',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey
                                                                .shade400,
                                                          ),
                                                        ),
                                                      Icon(
                                                        Iconsax.add_outline,
                                                        color: Color(
                                                          0XFF7F7F7F,
                                                        ),
                                                        size: 24,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                itemBuilder: (BuildContext context) {
                                                  return [
                                                    for (Tag tag
                                                        in ((entryTag != null &&
                                                                    typeOfTransaction ==
                                                                        1) ||
                                                                (outputTag !=
                                                                        null &&
                                                                    typeOfTransaction ==
                                                                        0))
                                                            ? (typeOfTransaction ==
                                                                      1
                                                                  ? entryTag!
                                                                  : outputTag!)
                                                            : [])
                                                      if (!(selectedTag
                                                          .contains(tag)))
                                                        PopupMenuItem(
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                tag.name!,
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          onTap: () {
                                                            changeState(() {
                                                              if (!(selectedTag
                                                                  .contains(
                                                                    tag,
                                                                  ))) {
                                                                selectedTag.add(
                                                                  tag,
                                                                );
                                                              }
                                                            });
                                                          },
                                                        ),
                                                  ];
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Text(
                                          'در حال بارگذاری',
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        LoadingAnimationWidget.staggeredDotsWave(
                                          color: Colors.grey.shade400,
                                          size: 40,
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(Iconsax.calendar_2_outline, size: 22),
                            SizedBox(width: 5),
                            Text('از تاریخ', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      Neumorphic(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        style: NeumorphicStyle(
                          color: Colors.transparent,
                          shadowDarkColor: Colors.black,
                          depth: 5,
                          intensity: 0.4,
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20),
                          ),
                        ),
                        child: TextField(
                          controller: fromDateController,
                          textDirection: TextDirection.ltr,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: Jalali.now()
                                .toJalaliDateTime()
                                .toString()
                                .replaceAll('-', '/')
                                .substring(0, 10)
                                .toPersianDigit(),
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            hintTextDirection: TextDirection.ltr,
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onTap: () async {
                            Jalali? picked = await showPersianDatePicker(
                              context: context,
                              initialDate: Jalali.now(),
                              firstDate: Jalali.now().addYears(-10),
                              lastDate: Jalali.now().addYears(10),
                              errorFormatText: 'فرمت تاریخ نامعتبر است',
                              errorInvalidText: 'تاریخ خارج از محدوده است ',
                            );
                            if (picked != null) {
                              fromDate = picked;
                              fromDateController.text =
                                  (picked
                                          .toJalaliDateTime()
                                          .toString()
                                          .replaceAll('-', '/')
                                          .substring(0, 10))
                                      .toPersianDigit();

                              setState(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(Iconsax.calendar_2_outline, size: 22),
                            SizedBox(width: 5),
                            Text('تا تاریخ', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      Neumorphic(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        style: NeumorphicStyle(
                          color: Colors.transparent,
                          shadowDarkColor: Colors.black,
                          depth: 5,
                          intensity: 0.4,
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20),
                          ),
                        ),
                        child: TextField(
                          controller: toDateController,
                          textDirection: TextDirection.ltr,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: Jalali.now()
                                .addDays(30)
                                .toJalaliDateTime()
                                .toString()
                                .replaceAll('-', '/')
                                .substring(0, 10)
                                .toPersianDigit(),
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            hintTextDirection: TextDirection.ltr,
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onTap: () async {
                            Jalali? picked = await showPersianDatePicker(
                              context: context,
                              initialDate: fromDate ?? Jalali.now(),
                              firstDate: fromDate ?? Jalali.now(),
                              lastDate: Jalali.now().addYears(10),
                              errorFormatText: 'فرمت تاریخ نامعتبر است',
                              errorInvalidText: 'تاریخ خارج از محدوده است ',
                            );
                            if (picked != null) {
                              toDateController.text =
                                  (picked
                                          .toJalaliDateTime()
                                          .toString()
                                          .replaceAll('-', '/')
                                          .substring(0, 10))
                                      .toPersianDigit();

                              changeState(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Neumorphic(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          style: NeumorphicStyle(
                            color: Colors.red,
                            shadowDarkColor: Colors.black,
                            depth: 5,
                            intensity: 0.4,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'بازگشت',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            fromDateController.text.isNotEmpty &&
                                toDateController.text.isNotEmpty
                            ? () async {
                              List<int> selectedTagCodes = [];
                              for (Tag tag
                              in selectedTag) {
                                selectedTagCodes.add(tag.code!);
                              }

                              var data = await getReport(
                                fromDate: fromDateController.text
                                    .toEnglishDigit(),
                                toDate: toDateController.text
                                    .toEnglishDigit(),
                                filterBy: typeOfTransaction == 2
                                    ? null
                                    : typeOfTransaction == 1
                                    ? 'Entry'
                                    : 'Output',
                                typeOfFilter: typeOfTransaction == 2 || selectedTagCodes.isEmpty
                                    ? null
                                    : selectedTagCodes,
                                context: context,
                              );
                                transactionList = data.first;
                                reportFileUrl = data.last;

                                sumTransaction();

                                setState(() {});
                                Navigator.pop(context);
                              }
                            : () {
                                DelightToastBar(
                                  position: DelightSnackbarPosition.top,
                                  autoDismiss: true,
                                  snackbarDuration: const Duration(
                                    milliseconds: 2500,
                                  ),
                                  builder: (context) => const ToastCard(
                                    color: Colors.red,
                                    leading: Icon(
                                      Iconsax.tick_circle_bold,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                    title: Text(
                                      'تاریخ شروع و پایان الزامی است',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ).show(context);

                                changeState(() {});
                              },
                        child: Neumorphic(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          style: NeumorphicStyle(
                            color: Colors.green[400],
                            shadowDarkColor: Colors.black,
                            depth: 5,
                            intensity: 0.4,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'دریافت گزارش',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future downloadFile() async {
    double downloadedPercent = 0;

    try {
      Directory downloadDirectory = await getDownloadStorage();

      bool hasFile = File(
        '${downloadDirectory.path}/${reportFileUrl!.split('/').last}',
      ).existsSync();

      if (hasFile) {
        downloadPath =
            '${downloadDirectory.path}/${reportFileUrl!.split('/').last}';
      } else {
        downloadPath = null;
      }
    } catch (e) {}

    bool startDownload = false;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, Function changeState) {
            if (downloadPath != null) {
              startDownload = true;
              downloadedPercent = 1;
              changeState(() {});
            }
            if (!startDownload) {
              startDownload = true;
              changeState(() {});
              FileDownloader.downloadFile(
                url: reportFileUrl!,
                onProgress: (String? fileName, double progress) {
                  downloadedPercent = progress / 100;
                  if (downloadedPercent > 5) {
                    changeState(() {});
                  }
                },
                onDownloadCompleted: (String path) {
                  downloadPath = path;

                  changeState(() {});
                },
                onDownloadError: (String error) {
                  changeState(() {});
                },
              );
            }
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Iconsax.document_download_outline, size: 30),
                  const SizedBox(width: 5),
                  const Text('دریافت فایل'),
                  Expanded(child: Container()),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Iconsax.close_circle_outline),
                  ),
                ],
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reportFileUrl!.split('/').last,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
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
                      gradientColor: LinearGradient(
                        colors: [Colors.teal.shade200, Colors.teal.shade400],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.5),
                          offset: const Offset(5.0, 5.0),
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(downloadedPercent * 100).toInt()} ٪'.toPersianDigit(),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: downloadPath != null
                  ? [
                      GestureDetector(
                        onTap: () {
                          OpenFile.open(downloadPath!);
                        },
                        child: Neumorphic(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          style: NeumorphicStyle(
                            color: Colors.red[400],
                            shadowDarkColor: Colors.black,
                            depth: 5,
                            intensity: 0.4,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(20),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'باز کردن',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                  : null,
            );
          },
        );
      },
    );
  }

  Timer openFilter() {
    return Timer(const Duration(milliseconds: 50), filter);
  }

  void scroll() {
    draggableScrollableController.addListener(() async {
      if (draggableScrollableController.pixels.toInt() - 5 ==
          MediaQuery.of(context).size.height.toInt()) {
        fullScreen = true;
        setState(() {});
      } else {
        fullScreen = false;
        setState(() {});
      }
    });
  }

  Future entryInfo({required int code}) async {
    var data = await getEntryInfo(code: code, context: context) as List;
    Entry? info = data.first;
    List<Log?>? logList = data.last;

    Widget divider = Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: DottedDecoration(
        shape: Shape.line,
        linePosition: LinePosition.bottom,
        color: Colors.black26,
      ),
    );

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, changeState) {
            return AlertDialog(
              title: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    const Icon(Iconsax.arrow_down_2_outline, size: 30),
                    const SizedBox(width: 5),
                    const Text('تراکنش ورودی'),
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.close_circle_outline),
                    ),
                  ],
                ),
              ),
              content: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: const Radius.circular(20),
                  dashPattern: const [5, 7],
                  strokeWidth: 2,
                  color: Colors.black26,
                  padding: const EdgeInsets.all(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('کد دخل : '),
                          Text('${info!.code}'.toPersianDigit()),
                        ],
                      ),
                      divider,
                      Row(
                        children: [
                          const Text('عنوان : '),
                          Expanded(
                            child: Text(
                              '${info.displayName}'.toPersianDigit(),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('مبلغ : '),
                          Text(
                            '${splitNumber(info.price!)}   تومان'
                                .toPersianDigit(),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        children: [
                          const Text('دسته بندی : '),
                          Expanded(
                            child: Text(
                              '${info.type!.name}',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('تاریخ : '),
                          Text(
                            info.registerTime!
                                .substring(0, 10)
                                .replaceAll('-', '/')
                                .toPersianDigit(),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ساعت : '),
                          Text(
                            info.registerTime!
                                .substring(11, 19)
                                .toPersianDigit(),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('پیوست : '),
                          if (info.file == null)
                            const Text('ندارد')
                          else
                            GestureDetector(
                              onTap: () async {
                                await launchUrl(
                                  Uri.parse('${Urls.hostUrl}/${info.file}'),
                                );
                              },
                              child: const Text(
                                'باز کردن',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('توضیحات : '),
                          if (info.description == null)
                            const Text('ندارد')
                          else
                            Container(),
                        ],
                      ),
                      if (info.description != null)
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              '${info.description}'.toPersianDigit(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      divider,
                      Row(
                        children: [
                          const Icon(Iconsax.note_1_outline, size: 20),
                          const SizedBox(width: 3),
                          const Text(
                            'تاریخچه تغییرات : ',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '( ${logList!.length} عملیات )'.toPersianDigit(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (logList.isNotEmpty)
                        Card(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            height: 150,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (int i = 0; i < logList.length; i++)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${operation[logList[i]!.operation]}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${logList[i]!.registerTime!.substring(0, 10).replaceAll('-', '/').toPersianDigit()} ',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const Icon(
                                                  Iconsax.calendar_2_outline,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${logList[i]!.user!.sirName}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${logList[i]!.registerTime!.substring(11, 19).toPersianDigit()} ',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const Icon(
                                                  Iconsax.clock_outline,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Container(
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          decoration: DottedDecoration(
                                            shape: Shape.line,
                                            linePosition: LinePosition.bottom,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        const Center(
                          child: Text('تاریخچه ای برای این تراکنش وجود ندارد'),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future outputInfo({required int code}) async {
    var data = await getOutputInfo(code: code, context: context) as List;
    Output? info = data.first;
    List<Log?>? logList = data.last;

    Widget divider = Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: DottedDecoration(
        shape: Shape.line,
        linePosition: LinePosition.bottom,
        color: Colors.black26,
      ),
    );

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, changeState) {
            return AlertDialog(
              title: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    const Icon(Iconsax.arrow_up_1_outline, size: 30),
                    const SizedBox(width: 5),
                    const Text('تراکنش خروجی'),
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.close_circle_outline),
                    ),
                  ],
                ),
              ),
              content: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: const Radius.circular(20),
                  dashPattern: const [5, 7],
                  strokeWidth: 2,
                  color: Colors.black26,
                  padding: const EdgeInsets.all(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('کد خرج : '),
                          Text('${info!.code}'.toPersianDigit()),
                        ],
                      ),
                      divider,
                      Row(
                        children: [
                          const Text('عنوان : '),
                          Expanded(
                            child: Text(
                              '${info.displayName}'.toPersianDigit(),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('مبلغ : '),
                          Text(
                            '${splitNumber(info.price!)}   تومان'
                                .toPersianDigit(),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        children: [
                          const Text('دسته بندی : '),
                          Expanded(
                            child: Text(
                              '${info.type!.name}',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      divider,
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     const Text(
                      //       'علت برداشت : ',
                      //     ),
                      //     Text(
                      //       '${info!.reason!.name}',
                      //     ),
                      //   ],
                      // ),
                      // divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('تاریخ : '),
                          Text(
                            info.registerTime!
                                .substring(0, 10)
                                .replaceAll('-', '/')
                                .toPersianDigit(),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ساعت : '),
                          Text(
                            info.registerTime!
                                .substring(11, 19)
                                .toPersianDigit(),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('پیوست : '),
                          if (info.file == null)
                            const Text('ندارد')
                          else
                            GestureDetector(
                              onTap: () async {
                                await launchUrl(
                                  Uri.parse('${Urls.hostUrl}/${info.file}'),
                                );
                              },
                              child: const Text(
                                'باز کردن',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('توضیحات : '),
                          if (info.description == null)
                            const Text('ندارد')
                          else
                            Container(),
                        ],
                      ),
                      if (info.description != null)
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              '${info.description}'.toPersianDigit(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      divider,
                      Row(
                        children: [
                          const Icon(Iconsax.note_1_outline, size: 20),
                          const SizedBox(width: 3),
                          const Text(
                            'تاریخچه تغییرات : ',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            '( ${logList!.length} عملیات )'.toPersianDigit(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (logList.isNotEmpty)
                        Card(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            height: 150,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (int i = 0; i < logList.length; i++)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${operation[logList[i]!.operation]}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${logList[i]!.registerTime!.substring(0, 10).replaceAll('-', '/').toPersianDigit()} ',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const Icon(
                                                  Iconsax.calendar_2_outline,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${logList[i]!.user!.sirName}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${logList[i]!.registerTime!.substring(11, 19).toPersianDigit()} ',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const Icon(
                                                  Iconsax.clock_outline,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Container(
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          decoration: DottedDecoration(
                                            shape: Shape.line,
                                            linePosition: LinePosition.bottom,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        const Center(
                          child: Text('تاریخچه ای برای این تراکنش وجود ندارد'),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void sumTransaction() {
    for (var transaction in transactionList!) {
      if (transaction.operation == 'ورودی') {
        sumEntry += int.parse(
          transaction.price!.split(' ').first.replaceAll(',', ''),
        );
      } else {
        sumOutput += int.parse(
          transaction.price!.split(' ').first.replaceAll(',', ''),
        );
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    scroll();
    openFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: fullScreen
          ? AppBar(
              elevation: 10,
              title: const Text('گزارش تراکنش ها'),
              centerTitle: true,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
            )
          : null,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30),
            ),
            margin: const EdgeInsets.fromLTRB(20, 40, 20, 10),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Neumorphic(
                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          style: NeumorphicStyle(
                            color: Colors.orange.withValues(alpha: 0.1),
                            shadowDarkColor: Colors.black,
                            depth: 5,
                            intensity: 0.4,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.activity_outline,
                                    size: 35,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'هزینه برآیند',
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    splitNumber(
                                      sumEntry -
                                          sumOutput *
                                              (typeOfTransaction == 0 ? -1 : 1),
                                    ).toString().toPersianDigit(),
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: (sumEntry - sumOutput < 0)
                                          ? Colors.yellow
                                          : Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'تومان',
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: (sumEntry - sumOutput < 0)
                                          ? Colors.yellow
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Neumorphic(
                          margin: const EdgeInsets.fromLTRB(5, 5, 10, 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          style: NeumorphicStyle(
                            color: Colors.red.withValues(alpha: 0.1),
                            shadowDarkColor: Colors.black,
                            depth: 5,
                            intensity: 0.4,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.arrow_down_2_outline,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'دخل',
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    splitNumber(
                                      sumEntry,
                                    ).toString().toPersianDigit(),
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 7),
                                    child: Text(
                                      'تومان',
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Neumorphic(
                          margin: const EdgeInsets.fromLTRB(10, 5, 5, 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          style: NeumorphicStyle(
                            color: Colors.purple.withValues(alpha: 0.1),
                            shadowDarkColor: Colors.black,
                            depth: 5,
                            intensity: 0.4,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.arrow_up_1_outline,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'خرج',
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    splitNumber(
                                      sumOutput,
                                    ).toString().toPersianDigit(),
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 7),
                                    child: Text(
                                      'تومان',
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            controller: draggableScrollableController,
            initialChildSize: 0.58,
            minChildSize: 0.58,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                margin: const EdgeInsets.only(top: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: transactionList != null
                    ? transactionList!.isNotEmpty
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      height: 4,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    controller: scrollController,
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: transactionList!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.black12,
                                          child: Center(
                                            child: Icon(
                                              transactionList![index]
                                                          .operation ==
                                                      'ورودی'
                                                  ? Iconsax.arrow_down_2_outline
                                                  : Iconsax.arrow_up_1_outline,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          transactionList![index].operation ==
                                                  'ورودی'
                                              ? entryInfo(
                                                  code: transactionList![index]
                                                      .code!,
                                                )
                                              : outputInfo(
                                                  code: transactionList![index]
                                                      .code!,
                                                );
                                        },
                                        title: Text(
                                          '${transactionList![index].displayName}',
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Text(
                                              transactionList![index]
                                                  .registerTime!
                                                  .replaceAll(' ', '  ')
                                                  .toPersianDigit(),
                                              textDirection: TextDirection.ltr,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${transactionList![index].price!.toPersianDigit().split(' ')[0]} ',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const TextSpan(
                                                text: 'تومان',
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Iconsax.activity_outline, size: 40),
                                  SizedBox(height: 5),
                                  Text('تراکنشی وجود ندارد !'),
                                ],
                              ),
                            )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.blue,
                              size: 50,
                            ),
                            const Text('در حال بارگزاری تراکنش ها'),
                          ],
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: reportFileUrl != null
          ? Padding(
              padding: const EdgeInsets.all(10),
              child: FloatingActionButton.extended(
                onPressed: downloadFile,
                label: const Text('دریافت PDF'),
                icon: const Icon(Iconsax.document_download_outline),
              ),
            )
          : null,
    );
  }
}
