import 'package:financial_management/Data/Models/cheque.dart';
import 'package:financial_management/Data/Models/installment/due_date.dart';
import 'package:financial_management/Data/Models/installment/installment.dart';
import 'package:financial_management/logic/Helpers/number.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../../Data/Models/notif/notif.dart';
import '../../logic/Helpers/date.dart';
import '../../logic/Helpers/week.dart';
import '../../logic/providers/Api/api_connection.dart';
import 'add_entry.dart';
import 'add_installment.dart';
import 'candle_chart.dart';
import 'category.dart';
import 'notification.dart';
import 'report.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = '/report';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Notif> notifList = [];
  bool unReadNotif = false;
  List weekData = List.generate(
    7,
    (index) => {
      'Index': index + 1,
      'Date': '',
      'WeekName': '',
      'Transactions': {'Entry': 0, 'Output': 0},
    },
  );
  List weekDataList = [];
  List? result;
  int upcomingDay = 5;

  List<Cheque>? upcomingCheque;
  List<Installment>? upcomingInstallment;

  Future<void> checkNotification() async {
    var data = await getNotificationList(from: 0, to: 20, context: context);

    notifList = data.first;

    unReadNotif = false;

    for (var notif in notifList) {
      if (notif.isRead == false) {
        unReadNotif = true;
        break;
      }
    }
    setState(() {});
  }

  Future<void> getLast7day() async {
    weekDataList = [weekData, 1];

    setState(() {});

    Map last7day = await getResultLast7day(context: context);

    weekDataList = await sortWeekDays(last7day);

    setState(() {});
  }

  Future<void> getInfoHome() async {
    result = await getInfoHomePage(context: context);

    setState(() {});
  }

  Future<void> getUpcomingEvents() async {
    List data = await getUpcomingEvent(context: context, day: upcomingDay);

    upcomingCheque = data.first;
    upcomingInstallment = data.last;

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // checkNotification();
    getInfoHome();
    getLast7day();
    getUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('حسابچی'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
                checkNotification();
              },
              icon: Icon(
                unReadNotif
                    ? Iconsax.notification_bold
                    : Iconsax.notification_outline,
                size: 28,
                color: unReadNotif ? Colors.red : null,
              ),
              tooltip: 'اعلان ها',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    // color: Colors.red.withValues(alpha:0.1),
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: CandleChart(weekData: weekDataList),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(
                          Iconsax.refresh_outline,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          checkNotification();
                          getInfoHome();
                          getLast7day();
                          getUpcomingEvents();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Neumorphic(
            //   margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            //   style: NeumorphicStyle(
            //     color: Colors.transparent,
            //     shadowDarkColor: Colors.black,
            //     depth: 5,
            //     intensity: 0.4,
            //     boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
            //   ),
            //   child: const Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       TextField(
            //         decoration: InputDecoration(
            //           contentPadding: EdgeInsets.zero,
            //           prefixIcon: Icon(Iconsax.search_normal_1_outline),
            //           hintText: 'جستجو',
            //           hintStyle: TextStyle(
            //             fontSize: 13,
            //           ),
            //           enabledBorder:
            //               OutlineInputBorder(borderSide: BorderSide.none),
            //           focusedBorder:
            //               OutlineInputBorder(borderSide: BorderSide.none),
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        AddReportScreen.routeName,
                      );
                      getLast7day();
                    },
                    child: Neumorphic(
                      padding: const EdgeInsets.all(10),
                      style: NeumorphicStyle(
                        color: Colors.teal.withValues(alpha: 0.1),
                        shadowDarkColor: Colors.black,
                        depth: 5,
                        intensity: 0.4,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.13,
                        width: MediaQuery.of(context).size.width * 0.13,
                        child: const Icon(
                          Iconsax.empty_wallet_add_outline,
                          size: 40,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        AddInstallmentScreen.routeName,
                      );
                      getLast7day();
                    },
                    child: Neumorphic(
                      padding: const EdgeInsets.all(10),
                      style: NeumorphicStyle(
                        color: Colors.purple.withValues(alpha: 0.1),
                        shadowDarkColor: Colors.black,
                        depth: 5,
                        intensity: 0.4,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.13,
                        width: MediaQuery.of(context).size.width * 0.13,
                        child: const Icon(
                          Iconsax.card_add_outline,
                          size: 40,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportScreen(),
                        ),
                      );
                    },
                    child: Neumorphic(
                      padding: const EdgeInsets.all(10),
                      style: NeumorphicStyle(
                        color: Colors.purple.withValues(alpha: 0.1),
                        shadowDarkColor: Colors.black,
                        depth: 5,
                        intensity: 0.4,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.13,
                        width: MediaQuery.of(context).size.width * 0.13,
                        child: const Icon(
                          Iconsax.activity_outline,
                          size: 40,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        CategoryScreen.routeName,
                      );
                    },
                    child: Neumorphic(
                      padding: const EdgeInsets.all(10),
                      style: NeumorphicStyle(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shadowDarkColor: Colors.black,
                        depth: 5,
                        intensity: 0.4,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.13,
                        width: MediaQuery.of(context).size.width * 0.13,
                        child: const Icon(
                          Iconsax.category_2_outline,
                          size: 40,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.activity_bold,
                          size: 28,
                          color: Colors.white,
                        ),
                        Text(
                          '  برآیند ها  ',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'هفت روز قبل : ',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            children: [
                              result != null
                                  ? Text(
                                      splitNumber(
                                        int.parse(result![0]),
                                      ).toPersianDigit(),
                                      textDirection: TextDirection.ltr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    )
                                  : LoadingAnimationWidget.staggeredDotsWave(
                                      color: Colors.red,
                                      size: 30,
                                    ),
                              const SizedBox(width: 5),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  'تومان'.toPersianDigit(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'یک ماه قبل : ',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            children: [
                              result != null
                                  ? Text(
                                      splitNumber(
                                        int.parse(result![1]),
                                      ).toPersianDigit(),
                                      textDirection: TextDirection.ltr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    )
                                  : LoadingAnimationWidget.staggeredDotsWave(
                                      color: Colors.red,
                                      size: 30,
                                    ),
                              const SizedBox(width: 5),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  'تومان'.toPersianDigit(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'از اول تا الان : ',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            children: [
                              result != null
                                  ? Text(
                                      splitNumber(
                                        int.parse(result![2]),
                                      ).toPersianDigit(),
                                      textDirection: TextDirection.ltr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    )
                                  : LoadingAnimationWidget.staggeredDotsWave(
                                      color: Colors.red,
                                      size: 30,
                                    ),
                              const SizedBox(width: 5),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  'تومان'.toPersianDigit(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                  ),
                                ),
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
            Container(
              margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Iconsax.clock_bold, size: 28, color: Colors.white),
                        Text(
                          ' رویداد های پیش رو ',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                        Spacer(),
                        PopupMenuButton(
                          icon: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  upcomingDay.toString().toPersianDigit(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 2),

                                Text(
                                  'روز',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Iconsax.arrow_down_1_outline,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),

                          tooltip: 'تعداد روز',
                          itemBuilder: (BuildContext context) {
                            return [
                              for (int index = 5; index <= 30; index += 5)
                                PopupMenuItem(
                                  child: Text(
                                    ' ${index.toString().toPersianDigit()}  روز آینده ',
                                    style: TextStyle(),
                                  ),
                                  onTap: () async {
                                    if (upcomingDay != index) {
                                      upcomingDay = index;
                                      upcomingCheque = null;
                                      upcomingInstallment = null;
                                      setState(() {});
                                      await getUpcomingEvents();
                                    }
                                  },
                                ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          'چک های نزدیک',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  upcomingCheque != null
                      ? upcomingCheque!.isNotEmpty
                            ? Column(
                                children: [
                                  for (
                                    int index = 0;
                                    index < upcomingCheque!.length;
                                    index++
                                  )
                                    StatefulBuilder(
                                      builder: (context, setState) {
                                        Jalali day = strToJalaliDate(
                                          upcomingCheque![index].dueDate!,
                                        );
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.2),
                                            child: Center(
                                              child:
                                                  upcomingCheque![index].type ==
                                                      1
                                                  ? const Icon(
                                                      Iconsax.user_bold,
                                                      size: 18,
                                                      color: Colors.white,
                                                    )
                                                  : const Icon(
                                                      Iconsax.people_bold,
                                                      size: 27,
                                                      color: Colors.white,
                                                    ),
                                            ),
                                          ),
                                          title: Text(
                                            '${upcomingCheque![index].displayName}'
                                                .toPersianDigit(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${day.formatter.wN}  ${day.formatter.d}  ${day.formatter.mN}  ${day.formatter.yyyy}'
                                                .toPersianDigit(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.yellow,
                                            ),
                                          ),
                                          trailing: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${splitNumber(upcomingCheque![index].price!).toPersianDigit()} ',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: 'تومان',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              )
                            : Center(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: ' در ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      TextSpan(
                                        text:
                                            ' ${upcomingDay.toString().toWord()} ',
                                        style: const TextStyle(
                                          color: Colors.yellow,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' روز آینده چکی وجود ندارد ! ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                      : Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.red.shade900,
                            size: 50,
                          ),
                        ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          'قسط های نزدیک',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  upcomingInstallment != null
                      ? upcomingInstallment!.isNotEmpty
                            ? Column(
                                children: [
                                  for (
                                    int index = 0;
                                    index < upcomingInstallment!.length;
                                    index++
                                  )
                                    StatefulBuilder(
                                      builder: (context, setState) {
                                        DueDate near =
                                            upcomingInstallment![index].dueDate!
                                                .firstWhere((date) {
                                                  return strToJalaliDate(
                                                        date.dueDate!,
                                                      ).isAfter(Jalali.now()) &&
                                                      date.isPaid == false;
                                                });

                                        Jalali day = strToJalaliDate(
                                          near.dueDate!,
                                        );

                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.2),
                                            child: Center(
                                              child: Icon(
                                                Iconsax.card_outline,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            '${upcomingInstallment![index].displayName}'
                                                .toPersianDigit(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),

                                          subtitle: Text(
                                            '${day.formatter.wN}  ${day.formatter.d}  ${day.formatter.mN}  ${day.formatter.yyyy}'
                                                .toPersianDigit(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.yellow,
                                            ),
                                          ),
                                          trailing: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${splitNumber(upcomingInstallment![index].price!).toPersianDigit()} ',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: 'تومان',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              )
                            : Center(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: ' در ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      TextSpan(
                                        text:
                                            ' ${upcomingDay.toString().toWord()} ',
                                        style: const TextStyle(
                                          color: Colors.yellow,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' روز آینده قسطی وجود ندارد ! ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                      : Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.red.shade900,
                            size: 50,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
