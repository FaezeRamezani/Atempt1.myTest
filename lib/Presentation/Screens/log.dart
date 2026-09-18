import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../../Data/App/dynamic_data.dart';
import '../../Data/App/static_data.dart';
import '../../Data/Models/log/log.dart';
import '../../Data/Models/user/user.dart';
import '../../Logic/Providers/Api/api_connection.dart';
import '../../logic/Helpers/date.dart';
import '../../logic/Helpers/number.dart';

class LogScreen extends StatefulWidget {
  static String routeName = '/report';
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  //
  ScrollController scrollController = ScrollController();

  int totalCountItem = 0;
  int countItemPage = 0;
  int coefficient = 15;
  int? userCode;
  int? operationCode;
  TextEditingController phraseController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  Jalali? fromDate;

  List<Log>? logList;

  Future clearFilter() async {
    phraseController.clear();
    fromDateController.clear();
    toDateController.clear();
    userCode = null;
    operationCode = null;
  }

  Future getLogs() async {
    countItemPage = countItemPage;
    coefficient = coefficient;
    logList = null;

    try {
      var data = await getLogList(
        from: countItemPage,
        to: coefficient,
        phrase: phraseController.text,
        userCode: userCode,
        operation: operationCode,
        fromDate: fromDateController.text,
        toDate: toDateController.text,
        context: context,
      );
      logList = data.first;

      totalCountItem = data.last;

      countItemPage += coefficient;
    } catch (e) {}
    setState(() {});
  }

  Future loadMore() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (countItemPage < totalCountItem) {
        var data = await getLogList(
          from: countItemPage,
          to: countItemPage + coefficient,
          phrase: phraseController.text,
          userCode: userCode,
          operation: operationCode,
          fromDate: fromDateController.text,
          toDate: toDateController.text,
          context: context,
        ) as List;
        logList!.addAll(data.first);
        countItemPage += coefficient;
        setState(() {});
      }
    }
  }

  Future logInfo({required int code}) async {
    Log? info = await getLogInfo(
      code: code,
      context: context,
    );

    Widget divider = Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: DottedDecoration(
        shape: Shape.line,
        linePosition: LinePosition.bottom,
        color: Colors.black26,
      ),
    );

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  const Icon(
                    Iconsax.note_1_outline,
                    size: 30,
                  ),
                  const SizedBox(width: 5),
                  const Text('فعالیت'),
                  Expanded(child: Container()),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.close_circle_outline))
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
                          const Text('کد فعالیت : '),
                          Text('Log-${info!.code}'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('عنوان فعالیت :'),
                          Expanded(
                            child: Text('${operation[info.operation]}',
                                textAlign: TextAlign.left),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ' کد ${operation[info.operation].split(' ').last} : ',
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            '${info.content == null ? 'حذف شده' : info.content!.code}'
                                .toPersianDigit(),
                            style: TextStyle(
                              fontSize: 11,
                              color: info.content == null ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            ' عنوان : ',
                            style: TextStyle(fontSize: 11),
                          ),
                          Expanded(
                            child: Text(
                              '${info.content == null ? 'حذف شده' : info.content!.displayName}'
                                  .toPersianDigit(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 11,
                                color: info.content == null ? Colors.red : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            ' مبلغ : ',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            (info.content == null
                                    ? 'حذف شده'
                                    : '${splitNumber(info.content!.price!)}  تومان')
                                .toPersianDigit(),
                            style: TextStyle(
                              fontSize: 11,
                              color: info.content == null ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'کاربر : ',
                          ),
                          Text('${info.user!.sirName}'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'تاریخ : ',
                          ),
                          Text(info.registerTime!
                              .substring(0, 10)
                              .replaceAll('-', '/')
                              .toPersianDigit()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ساعت : ',
                          ),
                          Text(info.registerTime!
                              .substring(11, 19)
                              .toPersianDigit()),
                        ],
                      ),
                      divider,
                      const Text(
                        'توضیحات : ',
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${info.description}'.toPersianDigit(),
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )),
          );
        });
  }

  Future filter() async {
    List<User>? groupMate;

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, Function changeState) {
            fetch() async {
              groupMate = await getGroupMate(
                context: context,
              );
              groupMate!.add(user);

              changeState(() {});
            }

            if (groupMate == null) {
              fetch();
            }

            return AlertDialog(
              title: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.filter_search_outline,
                      size: 30,
                    ),
                    const SizedBox(width: 5),
                    const Text('جستجوی پیشرفته'),
                    Expanded(child: Container()),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Iconsax.close_circle_outline))
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.user_outline,
                            size: 21,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'کاربر',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Neumorphic(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      style: NeumorphicStyle(
                        color: Colors.transparent,
                        shadowDarkColor: Colors.black,
                        depth: 5,
                        intensity: 0.4,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: DropdownButton(
                              hint: (groupMate != null)
                                  ? Text(
                                      'انتخاب کاربر',
                                      style: TextStyle(
                                          color: Colors.grey.shade400),
                                    )
                                  : Row(
                                      children: [
                                        Text(
                                          'در حال بارگذاری',
                                          style: TextStyle(
                                              color: Colors.grey.shade400),
                                        ),
                                        const SizedBox(width: 5),
                                        LoadingAnimationWidget
                                            .staggeredDotsWave(
                                          color: Colors.grey.shade400,
                                          size: 40,
                                        ),
                                      ],
                                    ),
                              value: userCode,
                              underline: Container(),
                              icon: Container(),
                              items: (groupMate != null)
                                  ? groupMate!.map((User user) {
                                      return DropdownMenuItem(
                                        value: user.code,
                                        child: Text(user.sirName!),
                                      );
                                    }).toList()
                                  : [],
                              onChanged: (value) {
                                if (groupMate != null) {
                                  changeState(() {
                                    userCode = value as int?;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.activity_outline,
                            size: 21,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'عملیات',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Neumorphic(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      style: NeumorphicStyle(
                        color: Colors.transparent,
                        shadowDarkColor: Colors.black,
                        depth: 5,
                        intensity: 0.4,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: DropdownButton(
                              hint: Text(
                                'انتخاب عملیات',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                              value: operationCode,
                              underline: Container(),
                              icon: Container(),
                              items: operation.entries.map((user) {
                                return DropdownMenuItem(
                                  value: user.key,
                                  child: Text(user.value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                changeState(() {
                                  operationCode = value as int?;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.calendar_2_outline,
                            size: 22,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'از تاریخ',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Neumorphic(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      style: NeumorphicStyle(
                        color: Colors.transparent,
                        shadowDarkColor: Colors.black,
                        depth: 5,
                        intensity: 0.4,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20)),
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
                              borderSide: BorderSide.none),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none),
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
                            fromDateController.text = (picked
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
                          Icon(
                            Iconsax.calendar_2_outline,
                            size: 22,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'تا تاریخ',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Neumorphic(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      style: NeumorphicStyle(
                        color: Colors.transparent,
                        shadowDarkColor: Colors.black,
                        depth: 5,
                        intensity: 0.4,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20)),
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
                              borderSide: BorderSide.none),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none),
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
                            toDateController.text = (picked
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
                        getLogs();
                        Navigator.pop(context);
                      },
                      child: Neumorphic(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        style: NeumorphicStyle(
                          color: Colors.red,
                          shadowDarkColor: Colors.black,
                          depth: 5,
                          intensity: 0.4,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          'حذف فیلتر',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        getLogs();
                        Navigator.pop(context);
                      },
                      child: Neumorphic(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        style: NeumorphicStyle(
                          color: Colors.green[400],
                          shadowDarkColor: Colors.black,
                          depth: 5,
                          intensity: 0.4,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(20)),
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
          });
        });
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(loadMore);
    getLogs();
  }

  @override
  dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 85),
            logList != null
                ? logList!.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: countItemPage < totalCountItem
                              ? logList!.length + 1
                              : logList!.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (countItemPage < totalCountItem &&
                                index == logList!.length) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: LoadingAnimationWidget
                                        .staggeredDotsWave(
                                      color: Colors.orange,
                                      size: 40,
                                    ),
                                  )
                                ],
                              );
                            }

                            Jalali day =
                                strToJalaliDate(logList![index].registerTime!);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.withValues(alpha:0.1),
                                child: Center(
                                  child: Icon(
                                    [1, 2, 3, 4]
                                            .contains(logList![index].operation)
                                        ? Iconsax.card_pos_outline
                                        : Iconsax.arrow_swap_outline,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                              title: Text(
                                  '${operation[logList![index].operation]}'),
                              subtitle: Text(
                                '${day.formatter.wN}  ${day.formatter.d}  ${day.formatter.mN}  ${day.formatter.yyyy}  ${logList![index].registerTime!.split('T')[1].substring(0, 5)}'
                                    .toPersianDigit(),
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Text(
                                (logList![index].content == null ? 'حذف شده' : '${splitNumber(logList![index].content!.price!)} تومان').toPersianDigit(),
                                style: TextStyle(
                                    color: logList![index].content == null
                                        ? Colors.red
                                        : null),
                              ),
                              onTap: () {
                                logInfo(code: logList![index].code!);
                              },
                            );
                          },
                        ),
                      )
                    : const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.activity_outline,
                                size: 40,
                              ),
                              SizedBox(height: 5),
                              Text('فعالیتی وجود ندارد !')
                            ],
                          ),
                        ),
                      )
                : Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.orange,
                            size: 50,
                          ),
                          const Text('در حال بارگزاری فعالیت ها')
                        ],
                      ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    style: NeumorphicStyle(
                      color: Colors.transparent,
                      shadowDarkColor: Colors.black,
                      depth: 5,
                      intensity: 0.4,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20)),
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
                            hintStyle: TextStyle(
                              fontSize: 13,
                            ),
                            enabledBorder:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            focusedBorder:
                                OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          onEditingComplete: () {
                            getLogs();

                            FocusScopeNode currentFocus =
                                FocusScope.of(context);

                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                        )
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
                        horizontal: 15, vertical: 15),
                    style: NeumorphicStyle(
                      color: Colors.transparent,
                      shadowDarkColor: Colors.black,
                      depth: 5,
                      intensity: 0.4,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20)),
                    ),
                    child: const Icon(Iconsax.filter_search_outline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
