import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Constant/urls.dart';
import '../../Data/App/static_data.dart';
import '../../Data/Models/entry/entry.dart';
import '../../Data/Models/log/log.dart';
import '../../Data/Models/output/output.dart';
import '../../Data/Models/tag.dart';
import '../../Logic/Providers/Api/api_connection.dart';
import '../../logic/Helpers/date.dart';
import '../../logic/Helpers/number.dart';
import 'add_entry.dart';

class EntryScreen extends StatefulWidget {
  static String routeName = '/entry';

  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  //
  ScrollController scrollController = ScrollController();
  PageController pageController = PageController(initialPage: 0);
  int typeOfTransaction = 1;

  TextEditingController phraseController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  int? categoryCode;

  // int? reasonOutput;

  int totalCountItemEntry = 0;
  int countItemPageEntry = 0;
  int totalCountItemOutput = 0;
  int countItemPageOutput = 0;
  int coefficient = 15;

  List<Entry>? entryList;

  List<Output>? outputList;

  Future clearFilter() async {
    phraseController.clear();
    startTimeController.clear();
    priceController.clear();
    categoryCode = null;
    // reasonOutput = null;
  }

  Future getEntries() async {
    totalCountItemEntry = 0;
    countItemPageEntry = 0;
    entryList = null;

    setState(() {});

    try {
      var data =
          await getEntryList(
                from: countItemPageEntry,
                to: coefficient,
                phrase: phraseController.text,
                typeEntry: categoryCode,
                price: priceController.text.toEnglishDigit(),
                context: context,
              )
              as List;
      entryList = data.first;

      totalCountItemEntry = data.last;

      countItemPageEntry += coefficient;
    } catch (e) {}

    setState(() {});
  }

  Future getOutputs() async {
    totalCountItemOutput = 0;
    countItemPageOutput = 0;

    outputList = null;

    setState(() {});

    try {
      var data =
          await getOutputList(
                from: countItemPageOutput,
                to: coefficient,
                phrase: phraseController.text,
                typeOutput: categoryCode,
                // reasonOutput: reasonOutput,
                price: priceController.text.toEnglishDigit(),
                context: context,
              )
              as List;

      outputList = data.first;

      totalCountItemOutput = data.last;

      countItemPageOutput += coefficient;
    } catch (e) {}

    setState(() {});
  }

  Future loadMore() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (typeOfTransaction == 1) {
        if (countItemPageEntry < totalCountItemEntry) {
          var data =
              await getEntryList(
                    from: countItemPageEntry,
                    to: countItemPageEntry + coefficient,
                    phrase: phraseController.text,
                    typeEntry: categoryCode,
                    price: priceController.text.toEnglishDigit(),
                    context: context,
                  )
                  as List;
          entryList!.addAll(data.first);
          countItemPageEntry += coefficient;
        }
      }
      if (typeOfTransaction == 0) {
        if (countItemPageOutput < totalCountItemOutput) {
          var data =
              await getOutputList(
                    from: countItemPageOutput,
                    to: countItemPageOutput + coefficient,
                    phrase: phraseController.text,
                    typeOutput: categoryCode,
                    // reasonOutput: null,
                    price: priceController.text.toEnglishDigit(),
                    context: context,
                  )
                  as List;
          outputList!.addAll(data.first);
          countItemPageOutput += coefficient;
        }
      }
      setState(() {});
    }
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
                              '${info!.displayName}'.toPersianDigit(),
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
                            '${splitNumber(info!.price!)}   تومان'
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
                              '${info!.type!.name}',
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
                            info!.registerTime!
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
                            info!.registerTime!
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
                          if (info!.file == null)
                            const Text('ندارد')
                          else
                            GestureDetector(
                              onTap: () async {
                                await launchUrl(
                                  Uri.parse('${Urls.hostUrl}/${info!.file}'),
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
                          if (info!.description == null)
                            const Text('ندارد')
                          else
                            Container(),
                        ],
                      ),
                      if (info!.description != null)
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              '${info!.description}'.toPersianDigit(),
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
                      if (logList!.isNotEmpty)
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
                                  for (int i = 0; i < logList!.length; i++)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${operation[logList![i]!.operation]}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${logList![i]!.registerTime!.substring(0, 10).replaceAll('-', '/').toPersianDigit()} ',
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
                                              '${logList![i]!.user!.sirName}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${logList![i]!.registerTime!.substring(11, 19).toPersianDigit()} ',
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
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        DelightToastBar(
                          position: DelightSnackbarPosition.top,
                          autoDismiss: true,
                          snackbarDuration: const Duration(milliseconds: 1000),
                          builder: (context) => const ToastCard(
                            color: Colors.blue,
                            leading: Icon(
                              Iconsax.info_circle_outline,
                              size: 28,
                              color: Colors.white,
                            ),
                            title: Text(
                              'برای حذف دکمه را نگه دارید',
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
                      onLongPress: () async {
                        await deleteEntry(code: code, context: context);
                        DelightToastBar(
                          position: DelightSnackbarPosition.top,
                          autoDismiss: true,
                          snackbarDuration: const Duration(milliseconds: 2500),
                          builder: (context) => const ToastCard(
                            color: Colors.green,
                            leading: Icon(
                              Iconsax.tick_circle_bold,
                              size: 28,
                              color: Colors.white,
                            ),
                            title: Text(
                              'تراکنش با موفقیت حذف شد',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ).show(context);
                        changeState(() {});
                        Navigator.pop(context);
                      },
                      child: Neumorphic(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
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
                          '  حذف  ',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddReportScreen(
                              typeOfTransaction: 1,
                              entry: info,
                            ),
                          ),
                        );
                        var data =
                            await getEntryInfo(code: code, context: context)
                                as List;
                        info = data.first;

                        logList = data.last;

                        changeState(() {});
                      },
                      child: Neumorphic(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
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
                          'ویرایش',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                              '${info!.displayName}'.toPersianDigit(),
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
                            '${splitNumber(info!.price!)}   تومان'
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
                              '${info!.type!.name}',
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
                            info!.registerTime!
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
                            info!.registerTime!
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
                          if (info!.file == null)
                            const Text('ندارد')
                          else
                            GestureDetector(
                              onTap: () async {
                                await launchUrl(
                                  Uri.parse('${Urls.hostUrl}/${info!.file}'),
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
                          if (info!.description == null)
                            const Text('ندارد')
                          else
                            Container(),
                        ],
                      ),
                      if (info!.description != null)
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              '${info!.description}'.toPersianDigit(),
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
                      if (logList!.isNotEmpty)
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
                                  for (int i = 0; i < logList!.length; i++)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${operation[logList![i]!.operation]}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${logList![i]!.registerTime!.substring(0, 10).replaceAll('-', '/').toPersianDigit()} ',
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
                                              '${logList![i]!.user!.sirName}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${logList![i]!.registerTime!.substring(11, 19).toPersianDigit()} ',
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
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        DelightToastBar(
                          position: DelightSnackbarPosition.top,
                          autoDismiss: true,
                          snackbarDuration: const Duration(milliseconds: 1000),
                          builder: (context) => const ToastCard(
                            color: Colors.blue,
                            leading: Icon(
                              Iconsax.info_circle_outline,
                              size: 28,
                              color: Colors.white,
                            ),
                            title: Text(
                              'برای حذف دکمه را نگه دارید',
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
                      onLongPress: () async {
                        await deleteOutput(code: code, context: context);
                        DelightToastBar(
                          position: DelightSnackbarPosition.top,
                          autoDismiss: true,
                          snackbarDuration: const Duration(milliseconds: 2500),
                          builder: (context) => const ToastCard(
                            color: Colors.green,
                            leading: Icon(
                              Iconsax.tick_circle_bold,
                              size: 28,
                              color: Colors.white,
                            ),
                            title: Text(
                              'تراکنش با موفقیت حذف شد',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ).show(context);
                        changeState(() {});
                        Navigator.pop(context);
                      },
                      child: Neumorphic(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
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
                          '  حذف  ',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddReportScreen(
                              typeOfTransaction: 0,
                              output: info,
                            ),
                          ),
                        );

                        var data =
                            await getOutputInfo(code: code, context: context)
                                as List;
                        info = data.first;

                        logList = data.last;

                        changeState(() {});
                      },
                      child: Neumorphic(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
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
                          'ویرایش',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future filter() async {
    List<Tag>? entryTag;
    List<Tag>? outputTag;
    // List<Tag>? reasonTag;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, Function changeState) {
            func() async {
              entryTag = await getTypeOfEntry(context: context);

              outputTag = await getTypeOfOutput(context: context);

              // reasonTag = await getReasonOfOutput();
              changeState(() {});
            }

            if (entryTag == null ||
                outputTag == null /*|| reasonTag == null */ ) {
              func();
            }

            return AlertDialog(
              title: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    const Icon(Iconsax.filter_search_outline, size: 30),
                    const SizedBox(width: 5),
                    const Text('جستجوی پیشرفته'),
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.close_circle_outline),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Iconsax.category_2_outline, size: 21),
                          SizedBox(width: 5),
                          Text('دسته بندی', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Neumorphic(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      style: NeumorphicStyle(
                        color: Colors.transparent,
                        shadowDarkColor: Colors.black,
                        depth: 5,
                        intensity: 0.4,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: DropdownButton(
                              hint:
                                  ((entryTag != null &&
                                          typeOfTransaction == 1) ||
                                      (outputTag != null &&
                                          typeOfTransaction == 0))
                                  ? Text(
                                      'انتخاب دسته بندی',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                      ),
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
                              value: categoryCode,
                              underline: Container(),
                              icon: Container(),
                              items:
                                  ((entryTag != null &&
                                          typeOfTransaction == 1) ||
                                      (outputTag != null &&
                                          typeOfTransaction == 0))
                                  ? (typeOfTransaction == 1
                                            ? entryTag!
                                            : outputTag!)
                                        .map((Tag tag) {
                                          return DropdownMenuItem(
                                            value: tag.code,
                                            child: Text(tag.name!),
                                          );
                                        })
                                        .toList()
                                  : [],
                              onChanged: (value) {
                                if ((entryTag != null &&
                                        typeOfTransaction == 1) ||
                                    (outputTag != null &&
                                        typeOfTransaction == 0)) {
                                  changeState(() {
                                    categoryCode = value as int?;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // if (typeOfTransaction == 0)
                    //   Column(
                    //     children: [
                    //       const SizedBox(height: 10),
                    //       const Padding(
                    //         padding: EdgeInsets.symmetric(horizontal: 20),
                    //         child: Row(
                    //           children: [
                    //             Icon(
                    //               Iconsax.message_question_outline,
                    //               size: 21,
                    //             ),
                    //             SizedBox(width: 5),
                    //             Text(
                    //               'علت برداشت',
                    //               style: TextStyle(
                    //                 fontSize: 12,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       Neumorphic(
                    //         margin: const EdgeInsets.symmetric(
                    //             horizontal: 10, vertical: 5),
                    //         padding: const EdgeInsets.symmetric(horizontal: 25),
                    //         style: NeumorphicStyle(
                    //           color: Colors.transparent,
                    //           shadowDarkColor: Colors.black,
                    //           depth: 5,
                    //           intensity: 0.4,
                    //           boxShape: NeumorphicBoxShape.roundRect(
                    //               BorderRadius.circular(20)),
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             Padding(
                    //               padding:
                    //                   const EdgeInsets.symmetric(vertical: 8),
                    //               child: DropdownButton(
                    //                 hint: (reasonTag != null)
                    //                     ? Text(
                    //                         'انتخاب علت',
                    //                         style: TextStyle(
                    //                             color: Colors.grey.shade400),
                    //                       )
                    //                     : Row(
                    //                         children: [
                    //                           Text(
                    //                             'در حال بارگذاری',
                    //                             style: TextStyle(
                    //                                 color:
                    //                                     Colors.grey.shade400),
                    //                           ),
                    //                           const SizedBox(width: 5),
                    //                           LoadingAnimationWidget
                    //                               .staggeredDotsWave(
                    //                             color: Colors.grey.shade400,
                    //                             size: 40,
                    //                           ),
                    //                         ],
                    //                       ),
                    //                 value: reasonOutput,
                    //                 underline: Container(),
                    //                 icon: Container(),
                    //                 items: (reasonTag != null)
                    //                     ? reasonTag!.map((Tag tag) {
                    //                         return DropdownMenuItem(
                    //                           value: tag.code,
                    //                           child: Text(tag.name!),
                    //                         );
                    //                       }).toList()
                    //                     : [],
                    //                 onChanged: (value) {
                    //                   if (reasonTag != null) {
                    //                     changeState(() {
                    //                       reasonOutput = value as int?;
                    //                     });
                    //                   }
                    //                 },
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       const SizedBox(height: 10),
                    //     ],
                    //   ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Iconsax.money_3_outline, size: 22),
                          SizedBox(width: 5),
                          Text('مبلغ', style: TextStyle(fontSize: 12)),
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
                        controller: priceController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9۰-۹]')),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return newValue.copyWith(
                              text: (newValue.text).toPersianDigit(),
                            );
                          }),
                        ],
                        keyboardType: TextInputType.number,
                        style: const TextStyle(letterSpacing: 1),
                        textDirection: TextDirection.ltr,
                        maxLength: 12,
                        decoration: InputDecoration(
                          hintText: '10000000'.toPersianDigit(),
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          hintTextDirection: TextDirection.ltr,
                          suffixIcon: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('تومان', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          counterText: '',
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          changeState(() {});
                        },
                      ),
                    ),
                    if (priceController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 40,
                          left: 40,
                          bottom: 5,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 80,
                          child: Text(
                            '${priceController.text.toWord()} تومان',
                            style: const TextStyle(fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        clearFilter();
                        if (typeOfTransaction == 1) {
                          getEntries();
                        } else {
                          getOutputs();
                        }
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
                          'حذف فیلتر',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (typeOfTransaction == 1) {
                          getEntries();
                        } else {
                          getOutputs();
                        }
                        Navigator.pop(context);
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
                          'اعمال فیلتر',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(loadMore);
    getEntries();
    getOutputs();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 130),
              Expanded(
                child: PageView(
                  controller: pageController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    entryList != null
                        ? entryList!.isNotEmpty
                              ? ListView.builder(
                                  controller: scrollController,
                                  itemCount:
                                      countItemPageEntry < totalCountItemEntry
                                      ? entryList!.length + 1
                                      : entryList!.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    if (countItemPageEntry <
                                            totalCountItemEntry &&
                                        index == entryList!.length) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                LoadingAnimationWidget.staggeredDotsWave(
                                                  color: Colors.teal,
                                                  size: 40,
                                                ),
                                          ),
                                        ],
                                      );
                                    }

                                    Jalali day = strToJalaliDate(
                                      entryList![index].registerTime!,
                                    );

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.teal.withValues(
                                          alpha: 0.2,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Iconsax.arrow_down_2_outline,
                                            size: 22,
                                            color: Colors.teal,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        '${entryList![index].displayName}'
                                            .toPersianDigit(),
                                      ),
                                      subtitle: Text(
                                        '${day.formatter.wN}  ${day.formatter.d}  ${day.formatter.mN}  ${day.formatter.yyyy} ${entryList![index].registerTime!.split('T')[1].substring(0, 5)}'
                                            .toPersianDigit(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      trailing: Text(
                                        '${splitNumber(entryList![index].price!).toPersianDigit()} تومان',
                                      ),
                                      onTap: () async {
                                        await entryInfo(
                                          code: entryList![index].code!,
                                        );
                                        if (typeOfTransaction == 1) {
                                          getEntries();
                                        } else {
                                          getOutputs();
                                        }
                                      },
                                    );
                                  },
                                )
                              : const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Iconsax.activity_outline, size: 40),
                                      SizedBox(height: 5),
                                      Text('دخلی وجود ندارد !'),
                                    ],
                                  ),
                                )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.teal,
                                  size: 50,
                                ),
                                const Text('در حال بارگزاری دخل ها'),
                              ],
                            ),
                          ),
                    outputList != null
                        ? outputList!.isNotEmpty
                              ? ListView.builder(
                                  controller: scrollController,
                                  itemCount:
                                      countItemPageOutput < totalCountItemOutput
                                      ? outputList!.length + 1
                                      : outputList!.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    if (countItemPageOutput <
                                            totalCountItemOutput &&
                                        index == outputList!.length) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                LoadingAnimationWidget.staggeredDotsWave(
                                                  color: Colors.red,
                                                  size: 40,
                                                ),
                                          ),
                                        ],
                                      );
                                    }

                                    Jalali day = strToJalaliDate(
                                      outputList![index].registerTime!,
                                    );

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.red.withValues(
                                          alpha: 0.2,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Iconsax.arrow_up_1_outline,
                                            size: 22,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        '${outputList![index].displayName}'
                                            .toPersianDigit(),
                                      ),
                                      subtitle: Text(
                                        '${day.formatter.wN}  ${day.formatter.d}  ${day.formatter.mN}  ${day.formatter.yyyy} ${outputList![index].registerTime!.split('T')[1].substring(0, 5)}'
                                            .toPersianDigit(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      trailing: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${splitNumber(outputList![index].price!).toPersianDigit()} ',
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
                                      onTap: () async {
                                        await outputInfo(
                                          code: outputList![index].code!,
                                        );

                                        if (typeOfTransaction == 1) {
                                          getEntries();
                                        } else {
                                          getOutputs();
                                        }
                                      },
                                    );
                                  },
                                )
                              : const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Iconsax.activity_outline, size: 40),
                                      SizedBox(height: 5),
                                      Text('خرجی وجود ندارد !'),
                                    ],
                                  ),
                                )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.red,
                                  size: 50,
                                ),
                                const Text('در حال بارگزاری خرج ها'),
                              ],
                            ),
                          ),
                  ],
                  onPageChanged: (index) {
                    setState(() {
                      typeOfTransaction = index == 0 ? 1 : 0;
                    });
                  },
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Neumorphic(
                      margin: const EdgeInsets.fromLTRB(10, 15, 25, 15),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      style: NeumorphicStyle(
                        color: Colors.transparent,
                        shadowDarkColor: Colors.black,
                        depth: 5,
                        intensity: 0.4,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: phraseController,
                            style: const TextStyle(fontSize: 14),
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              prefixIcon: Icon(Iconsax.search_normal_1_outline),
                              hintText: 'جستجو',
                              hintStyle: TextStyle(fontSize: 13),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onEditingComplete: () {
                              if (typeOfTransaction == 1) {
                                getEntries();
                              } else {
                                getOutputs();
                              }

                              FocusScopeNode currentFocus = FocusScope.of(
                                context,
                              );

                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      filter();
                    },
                    child: Neumorphic(
                      margin: const EdgeInsets.fromLTRB(25, 15, 10, 15),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      style: NeumorphicStyle(
                        color: Colors.transparent,
                        shadowDarkColor: Colors.black,
                        depth: 5,
                        intensity: 0.4,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: const Icon(Iconsax.filter_search_outline),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: NeumorphicToggle(
                  style: NeumorphicToggleStyle(
                    //depth: 50,
                    backgroundColor: typeOfTransaction == 1
                        ? Colors.teal.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3),
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
                            Icon(Iconsax.arrow_down_2_outline),
                            SizedBox(width: 5),
                            Text('دخل'),
                          ],
                        ),
                      ),
                      background: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.arrow_down_2_outline,
                              color: typeOfTransaction == 1
                                  ? Colors.teal
                                  : Colors.red,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'دخل',
                              style: TextStyle(
                                color: typeOfTransaction == 1
                                    ? Colors.teal
                                    : Colors.red,
                              ),
                            ),
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
                            SizedBox(width: 5),
                            Text('خرج'),
                          ],
                        ),
                      ),
                      background: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.arrow_up_1_outline, color: Colors.red),
                            SizedBox(width: 5),
                            Text('خرج', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value == 0) typeOfTransaction = 1;
                      if (value == 1) typeOfTransaction = 0;
                      categoryCode = null;
                      // reasonOutput = null;

                      pageController.animateToPage(
                        value,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddReportScreen(typeOfTransaction: typeOfTransaction),
            ),
          );
          if (typeOfTransaction == 1) {
            getEntries();
          } else {
            getOutputs();
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: typeOfTransaction == 1
            ? Colors.teal.shade200
            : Colors.red.shade200,
        child: const Icon(Iconsax.add_outline, size: 30),
      ),
    );
  }
}
