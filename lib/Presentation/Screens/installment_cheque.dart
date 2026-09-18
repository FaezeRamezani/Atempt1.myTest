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
import '../../Data/Models/cheque.dart';
import '../../Data/Models/installment/installment.dart';
import '../../Data/Models/log/log.dart';
import '../../logic/Helpers/date.dart';
import '../../logic/Helpers/number.dart';
import '../../logic/providers/Api/api_connection.dart';
import 'add_installment.dart';

class InstallmentScreen extends StatefulWidget {
  static String routeName = '/installment';

  const InstallmentScreen({super.key});

  @override
  State<InstallmentScreen> createState() => _InstallmentScreenState();
}

class _InstallmentScreenState extends State<InstallmentScreen> {
  //
  ScrollController scrollController = ScrollController();
  PageController pageController = PageController(initialPage: 0);
  int typeOfInstallment = 1;
  int typeCheque = 2;

  TextEditingController phraseController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  TextEditingController warningDateController = TextEditingController();

  int totalCountItemCheque = 0;
  int countItemPageCheque = 0;
  int totalCountItemInstallment = 0;
  int countItemPageInstallment = 0;
  int coefficient = 15;

  List<Installment>? installmentList;

  List<Cheque>? chequeList;

  Future clearFilter() async {
    typeCheque = 2;
    phraseController.clear();
    startTimeController.clear();
    priceController.clear();
    dueDateController.clear();
    warningDateController.clear();
  }

  Future getInstallments() async {
    totalCountItemInstallment = 0;
    countItemPageInstallment = 0;
    installmentList = null;

    setState(() {});

    var data =
        await getInstallmentList(
              from: countItemPageInstallment,
              to: coefficient,
              phrase: phraseController.text,
              startTime: startTimeController.text.toEnglishDigit(),
              price: priceController.text.toEnglishDigit(),
              context: context,
            )
            as List;
    installmentList = data.first;

    totalCountItemInstallment = data.last;

    countItemPageInstallment += coefficient;

    setState(() {});
  }

  Future getCheques() async {
    totalCountItemCheque = 0;
    countItemPageCheque = 0;

    chequeList = null;

    setState(() {});

    var data =
        await getChequeList(
              from: countItemPageCheque,
              to: coefficient,
              phrase: phraseController.text,
              typeCheque: typeCheque == 1
                  ? 2
                  : typeCheque == 0
                  ? 1
                  : null,
              dueDate: dueDateController.text.toEnglishDigit(),
              warningDate: warningDateController.text.toEnglishDigit(),
              price: priceController.text.toEnglishDigit(),
              context: context,
            )
            as List;

    chequeList = data.first;

    totalCountItemCheque = data.last;

    countItemPageCheque += coefficient;

    setState(() {});
  }

  Future loadMore() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (typeOfInstallment == 1) {
        if (countItemPageInstallment < totalCountItemInstallment) {
          var data =
              await getInstallmentList(
                    from: countItemPageInstallment,
                    to: countItemPageInstallment + coefficient,
                    phrase: phraseController.text,
                    startTime: startTimeController.text.toEnglishDigit(),
                    price: priceController.text.toEnglishDigit(),
                    context: context,
                  )
                  as List;
          installmentList!.addAll(data.first);
          countItemPageInstallment += coefficient;
        }
      }
      if (typeOfInstallment == 0) {
        if (countItemPageCheque < totalCountItemCheque) {
          var data =
              await getChequeList(
                    from: countItemPageCheque,
                    to: countItemPageCheque + coefficient,
                    phrase: phraseController.text,
                    typeCheque: typeCheque == 1
                        ? 2
                        : typeCheque == 0
                        ? 1
                        : null,
                    dueDate: dueDateController.text.toEnglishDigit(),
                    warningDate: warningDateController.text.toEnglishDigit(),
                    price: priceController.text.toEnglishDigit(),
                    context: context,
                  )
                  as List;
          chequeList!.addAll(data.first);
          countItemPageCheque += coefficient;
        }
      }
      setState(() {});
    }
  }

  Future installmentInfo({required int code}) async {
    var data = await getInstallmentInfo(code: code, context: context) as List;
    Installment? info = data.first;
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
          builder: (BuildContext context, changState) {
            return AlertDialog(
              backgroundColor:
                  !(info!.dueDate!.any((dueDate) => dueDate.isPaid == false))
                  ? Colors.purple.shade100
                  : null,
              title: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    const Icon(Iconsax.card_outline, size: 30),
                    const SizedBox(width: 5),
                    const Text('اطلاعات قسط'),
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
                          const Text('کد قسط : '),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('تاریخ شروع : '),
                          Text(
                            info!.startTime!
                                .substring(0, 10)
                                .replaceAll('-', '/')
                                .toPersianDigit(),
                          ),
                        ],
                      ),
                      divider,
                      for (
                        int index = 0;
                        index < info!.dueDate!.length;
                        index++
                      )
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: GestureDetector(
                            onLongPress: () async {
                              await changeStatusIsPaidInstallment(
                                context: context,
                                code: info!.dueDate![index].code!,
                              );
                              changState(() {
                                info!.dueDate![index].isPaid =
                                    !(info!.dueDate![index].isPaid ?? false);
                              });
                            },
                            child: Row(
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          info!.dueDate![index].isPaid!
                                              ? Iconsax.tick_circle_bold
                                              : Iconsax.tick_circle_outline,
                                          size: info!.dueDate![index].isPaid!
                                              ? 20
                                              : 18,
                                          color: info!.dueDate![index].isPaid!
                                              ? Colors.purple.shade600
                                              : Colors.grey,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '  قسط ${(index + 1).toString().toWord()}م'
                                                .replaceAll('سهم', 'سوم')
                                                .replaceAll(
                                                  'قسط یکم',
                                                  'قسط اول',
                                                ),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: info!.dueDate![index].isPaid!
                                              ? Colors.purple.shade600
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${info!.dueDate![index].dueDate}'
                                      .replaceAll('-', '/')
                                      .toPersianDigit(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: info!.dueDate![index].isPaid!
                                        ? Colors.purple.shade600
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                          color:
                              !(info!.dueDate!.any(
                                (dueDate) => dueDate.isPaid == false,
                              ))
                              ? Colors.purple.shade200
                              : null,

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
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddInstallmentScreen(
                              typeOfInstallment: 1,
                              installment: info,
                            ),
                          ),
                        );
                        var data =
                            await getInstallmentInfo(
                                  code: code,
                                  context: context,
                                )
                                as List;
                        info = data.first;

                        logList = data.last;

                        changState(() {});
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

  Future chequeInfo({required int code}) async {
    var data = await getChequeInfo(code: code, context: context) as List;
    Cheque? info = data.first;
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
                    const Icon(Iconsax.card_outline, size: 30),
                    const SizedBox(width: 5),
                    const Text('اطلاعات چک'),
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
                          const Text('کد چک : '),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('بابت : '),
                          Expanded(
                            child: Text(
                              '${info!.whatAbout}',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('تاریخ سر رسید : '),
                          Text(
                            info!.dueDate!
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
                          const Text('زمان هشدار : '),
                          Text(
                            info!.warningDate!
                                .substring(0, 16)
                                .replaceAll('-', '/')
                                .replaceAll('T', '  ')
                                .toPersianDigit(),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('مالک چک : '),
                          Text(info!.type == 1 ? 'خودم' : 'دیگران'),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('واگذار کننده : '),
                          Expanded(
                            child: Text(
                              '${info!.from}',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      divider,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('دریافت کننده : '),
                          Expanded(
                            child: Text(
                              '${info!.to}',
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
                          if (info!.image == null)
                            const Text('ندارد')
                          else
                            GestureDetector(
                              onTap: () async {
                                await launchUrl(
                                  Uri.parse('${Urls.hostUrl}/${info!.image}'),
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
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddInstallmentScreen(
                              typeOfInstallment: 0,
                              cheque: info,
                            ),
                          ),
                        );

                        var data =
                            await getChequeInfo(code: code, context: context)
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
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, Function changeState) {
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
                    if (typeOfInstallment == 1)
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Icon(Iconsax.timer_start_outline, size: 22),
                                SizedBox(width: 5),
                                Text(
                                  'تاریخ شروع',
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
                              controller: startTimeController,
                              textDirection: TextDirection.ltr,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: Jalali.now()
                                    .toJalaliDateTime()
                                    .toString()
                                    .replaceAll('-', '/')
                                    .substring(0, 10)
                                    .toPersianDigit(),
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
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
                                  startTimeController.text =
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
                        ],
                      ),
                    if (typeOfInstallment == 0)
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Icon(Iconsax.timer_pause_outline, size: 22),
                                SizedBox(width: 5),
                                Text(
                                  'تاریخ سر رسید',
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
                              controller: dueDateController,
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
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
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
                                  dueDateController.text =
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
                          const SizedBox(height: 20),
                        ],
                      ),
                    if (typeOfInstallment == 0)
                      Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text('صاحب چک')],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: NeumorphicToggle(
                              style: NeumorphicToggleStyle(
                                //depth: 50,
                                backgroundColor: typeCheque == 0
                                    ? Colors.red.withValues(alpha: 0.3)
                                    : typeCheque == 1
                                    ? Colors.teal.withValues(alpha: 0.3)
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              selectedIndex: typeCheque,
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
                                          Iconsax.people_outline,
                                          size: 20,
                                          color: typeCheque == 1
                                              ? Colors.teal
                                              : null,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'دیگران',
                                          style: TextStyle(
                                            color: typeCheque == 1
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
                                        Icon(Iconsax.people_outline, size: 20),
                                        SizedBox(width: 3),
                                        Text('دیگران'),
                                      ],
                                    ),
                                  ),
                                ),
                                ToggleElement(
                                  foreground: const Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Iconsax.user_outline, size: 17),
                                        SizedBox(width: 3),
                                        Text('خودم'),
                                      ],
                                    ),
                                  ),
                                  background: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Iconsax.user_outline,
                                          size: 17,
                                          color: typeCheque == 0
                                              ? Colors.red
                                              : null,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'خودم',
                                          style: TextStyle(
                                            color: typeCheque == 0
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
                                    typeCheque = 2;
                                  }
                                  if (value == 1) {
                                    typeCheque = 1;
                                  }
                                  if (value == 2) {
                                    typeCheque = 0;
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    if (typeOfInstallment == 0)
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Icon(Iconsax.calendar_2_outline, size: 22),
                                SizedBox(width: 5),
                                Text(
                                  'تاریخ هشدار',
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
                              controller: warningDateController,
                              textDirection: TextDirection.ltr,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: Jalali.now()
                                    .addDays(29)
                                    .toJalaliDateTime()
                                    .toString()
                                    .replaceAll('-', '/')
                                    .substring(0, 10)
                                    .toPersianDigit(),
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
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
                                  firstDate: Jalali.now(),
                                  lastDate: Jalali.now().addYears(10),
                                  errorFormatText: 'فرمت تاریخ نامعتبر است',
                                  errorInvalidText: 'تاریخ خارج از محدوده است ',
                                );
                                if (picked != null) {
                                  warningDateController.text =
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
                        ],
                      ),
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
                        if (typeOfInstallment == 1) {
                          getInstallments();
                        } else {
                          getCheques();
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
                        if (typeOfInstallment == 1) {
                          getInstallments();
                        } else {
                          getCheques();
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
    getInstallments();
    getCheques();
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
                    installmentList != null
                        ? installmentList!.isNotEmpty
                              ? ListView.builder(
                                  controller: scrollController,
                                  itemCount:
                                      countItemPageInstallment <
                                          totalCountItemInstallment
                                      ? installmentList!.length + 1
                                      : installmentList!.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    if (countItemPageInstallment <
                                            totalCountItemInstallment &&
                                        index == installmentList!.length) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                LoadingAnimationWidget.staggeredDotsWave(
                                                  color: Colors.purple,
                                                  size: 40,
                                                ),
                                          ),
                                        ],
                                      );
                                    }

                                    Jalali day = strToJalaliDate(
                                      installmentList![index].startTime!,
                                    );

                                    return Container(
                                      decoration: BoxDecoration(
                                        color:
                                            !(installmentList![index].dueDate!
                                                .any(
                                                  (dueDate) =>
                                                      dueDate.isPaid == false,
                                                ))
                                            ? Colors.purple.shade100.withValues(
                                                alpha: 0.5,
                                              )
                                            : null,
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.purple
                                              .withValues(alpha: 0.2),
                                          child: Center(
                                            child: Icon(
                                              !(installmentList![index].dueDate!
                                                      .any(
                                                        (dueDate) =>
                                                            dueDate.isPaid ==
                                                            false,
                                                      ))
                                                  ? Iconsax.card_bold
                                                  : Iconsax.card_outline,
                                              color: Colors.purple,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          '${installmentList![index].displayName}'
                                              .toPersianDigit(),
                                        ),
                                        subtitle: Text(
                                          '${day.formatter.wN}  ${day.formatter.d}  ${day.formatter.mN}  ${day.formatter.yyyy}'
                                              .toPersianDigit(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        trailing: Text(
                                          '${splitNumber(installmentList![index].price!).toPersianDigit()} تومان',
                                        ),
                                        onTap: () async {
                                          await installmentInfo(
                                            code: installmentList![index].code!,
                                          );

                                          if (typeOfInstallment == 1) {
                                            getInstallments();
                                          } else {
                                            getCheques();
                                          }
                                        },
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Iconsax.activity_outline, size: 40),
                                      SizedBox(height: 5),
                                      Text('قسطی وجود ندارد !'),
                                    ],
                                  ),
                                )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.purple,
                                  size: 50,
                                ),
                                const Text('در حال بارگزاری قسط ها'),
                              ],
                            ),
                          ),
                    chequeList != null
                        ? chequeList!.isNotEmpty
                              ? ListView.builder(
                                  controller: scrollController,
                                  itemCount:
                                      countItemPageCheque < totalCountItemCheque
                                      ? chequeList!.length + 1
                                      : chequeList!.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    if (countItemPageCheque <
                                            totalCountItemCheque &&
                                        index == chequeList!.length) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                LoadingAnimationWidget.staggeredDotsWave(
                                                  color: Colors.purple,
                                                  size: 40,
                                                ),
                                          ),
                                        ],
                                      );
                                    }

                                    Jalali day = strToJalaliDate(
                                      chequeList![index].dueDate!,
                                    );

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.purple
                                            .withValues(alpha: 0.2),
                                        child: Center(
                                          child: chequeList![index].type == 1
                                              ? const Icon(
                                                  Iconsax.user_bold,
                                                  size: 18,
                                                  color: Colors.purple,
                                                )
                                              : const Icon(
                                                  Iconsax.people_bold,
                                                  size: 27,
                                                  color: Colors.purple,
                                                ),
                                        ),
                                      ),
                                      title: Text(
                                        '${chequeList![index].displayName}'
                                            .toPersianDigit(),
                                      ),
                                      subtitle: Text(
                                        'سررسید : ${day.formatter.wN}  ${day.formatter.d}  ${day.formatter.mN}  ${day.formatter.yyyy}'
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
                                                  '${splitNumber(chequeList![index].price!).toPersianDigit()} ',
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
                                        await chequeInfo(
                                          code: chequeList![index].code!,
                                        );

                                        if (typeOfInstallment == 1) {
                                          getInstallments();
                                        } else {
                                          getCheques();
                                        }
                                      },
                                    );
                                  },
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Iconsax.activity_outline, size: 40),
                                      SizedBox(height: 5),
                                      Text('چکی وجود ندارد !'),
                                    ],
                                  ),
                                )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.purple,
                                  size: 50,
                                ),
                                const Text('در حال بارگزاری چک ها'),
                              ],
                            ),
                          ),
                  ],
                  onPageChanged: (index) {
                    setState(() {
                      typeOfInstallment = index == 0 ? 1 : 0;
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
                              if (typeOfInstallment == 1) {
                                getInstallments();
                              } else {
                                getCheques();
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
                    backgroundColor: Colors.purple.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  selectedIndex: typeOfInstallment,
                  thumb: Center(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  children: [
                    ToggleElement(
                      foreground: const Center(child: Text('قسط')),
                      background: const Center(
                        child: Text(
                          'قسط',
                          style: TextStyle(color: Colors.purple),
                        ),
                      ),
                    ),
                    ToggleElement(
                      foreground: const Center(child: Text('چک')),
                      background: const Center(
                        child: Text(
                          'چک',
                          style: TextStyle(color: Colors.purple),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value == 0) typeOfInstallment = 1;
                      if (value == 1) typeOfInstallment = 0;

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
                  AddInstallmentScreen(typeOfInstallment: typeOfInstallment),
            ),
          );
          if (typeOfInstallment == 1) {
            getInstallments();
          } else {
            getCheques();
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.purple.shade200,
        child: const Icon(Iconsax.add_outline, size: 30),
      ),
    );
  }
}
