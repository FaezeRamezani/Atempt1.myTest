import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../../Data/Models/notif/notif.dart';
import '../../Logic/Providers/Api/api_connection.dart';
import '../../logic/Helpers/number.dart';

class NotificationScreen extends StatefulWidget {
  static String routeName = '/notification';
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  //
  ScrollController scrollController = ScrollController();

  int totalCountItem = 0;
  int countItemPage = 0;
  int coefficient = 20;
  List<Notif>? notifList;

  Future getNotif() async {
    countItemPage = 0;
    coefficient = 20;
    notifList = null;

    try {
      var data = await getNotificationList(
        from: countItemPage,
        to: coefficient,
        context: context,
      );
      notifList = data.first;

      totalCountItem = data.last;

      countItemPage += coefficient;
    } catch (e) {}
    setState(() {});
  }

  Future loadMore() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      var data = await getNotificationList(
        from: countItemPage,
        to: countItemPage + coefficient,
        context: context,
      ) as List;
      notifList!.addAll(data.first);
      countItemPage += coefficient;
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotif();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اطلاعیه ها'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: notifList != null
                  ? notifList!.isNotEmpty
                      ? ListView.builder(
                          controller: scrollController,
                          itemCount: countItemPage < totalCountItem
                              ? notifList!.length + 1
                              : notifList!.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (countItemPage < totalCountItem &&
                                index == notifList!.length) {
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

                            return Column(
                              children: [
                                ExpandablePanel(
                                  theme: const ExpandableThemeData(
                                    iconColor: Colors.grey,
                                    iconSize: 30,
                                    iconPadding:
                                        EdgeInsets.fromLTRB(20, 20, 0, 10),
                                  ),
                                  header: ListTile(
                                    leading: GestureDetector(
                                      onLongPress: () async {
                                        if (!(notifList![index].isRead!)) {
                                          bool state =
                                              await setAsReadNotification(
                                            code: notifList![index].code!,
                                            context: context,
                                          );

                                          if (state) {
                                            notifList![index].isRead = true;

                                            setState(() {});
                                          }
                                        }
                                      },
                                      child: Icon(
                                        size: 30,
                                        !notifList![index].isRead!
                                            ? Iconsax.notification_bold
                                            : Iconsax.notification_outline,
                                        color: !notifList![index].isRead!
                                            ? Colors.red
                                            : null,
                                      ),
                                    ),
                                    title: Text(
                                      notifList![index]
                                          .notification!
                                          .displayName!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                          notifList![index]
                                              .notification!
                                              .registerTime!
                                              .replaceAll('-', '/')
                                              .substring(0, 19)
                                              .toPersianDigit(),
                                          textDirection: TextDirection.ltr,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: (notifList![index]
                                                          .notification!
                                                          .forWhat ==
                                                      3
                                                  ? Colors.blue
                                                  : notifList![index]
                                                              .notification!
                                                              .forWhat ==
                                                          1
                                                      ? Colors.purple
                                                      : Colors.orange)
                                              .shade100,
                                          border: Border.all(
                                            width: 1.5,
                                            color: notifList![index]
                                                        .notification!
                                                        .forWhat ==
                                                    3
                                                ? Colors.blue
                                                : notifList![index]
                                                            .notification!
                                                            .forWhat ==
                                                        1
                                                    ? Colors.purple
                                                    : Colors.orange,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                        notifList![index]
                                                    .notification!
                                                    .forWhat ==
                                                3
                                            ? 'سایر'
                                            : notifList![index]
                                                        .notification!
                                                        .forWhat ==
                                                    1
                                                ? '  چک  '
                                                : 'قسط',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: notifList![index]
                                                      .notification!
                                                      .forWhat ==
                                                  3
                                              ? Colors.blue
                                              : notifList![index]
                                                          .notification!
                                                          .forWhat ==
                                                      1
                                                  ? Colors.purple
                                                  : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ),
                                  collapsed: const Padding(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Row(),
                                  ),
                                  expanded: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 10),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'توضیحات : ',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                (notifList![index]
                                                            .notification!
                                                            .description ??
                                                        'ندارد')
                                                    .toPersianDigit(),
                                                textAlign: TextAlign.justify,
                                              ),
                                              if (notifList![index]
                                                      .notification!
                                                      .rowContent !=
                                                  null)
                                                Column(
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              50,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 20),
                                                      decoration:
                                                          DottedDecoration(
                                                        shape: Shape.line,
                                                        linePosition:
                                                            LinePosition.bottom,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Text('عنوان : '),
                                                        Text('${notifList![index].notification!.rowContent!.displayName}'
                                                            .toPersianDigit()),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Text(
                                                          'مبلغ : ',
                                                        ),
                                                        Text(
                                                          '${splitNumber(notifList![index].notification!.rowContent!.price!)}   تومان'
                                                              .toPersianDigit(),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    if (notifList![index]
                                                            .notification!
                                                            .forWhat ==
                                                        1)
                                                      Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                  'بابت : '),
                                                              Text(
                                                                  '${notifList![index].notification!.rowContent!.whatAbout}'),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                        ],
                                                      ),
                                                    if (notifList![index]
                                                            .notification!
                                                            .forWhat ==
                                                        1)
                                                      Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                  'واگذار کننده : '),
                                                              Text(
                                                                  '${notifList![index].notification!.rowContent!.from}'),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                        ],
                                                      ),
                                                    if (notifList![index]
                                                            .notification!
                                                            .forWhat ==
                                                        1)
                                                      Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                  'دریافت کننده : '),
                                                              Text(
                                                                  '${notifList![index].notification!.rowContent!.to}'),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                        ],
                                                      ),
                                                    if (notifList![index]
                                                            .notification!
                                                            .forWhat ==
                                                        2)
                                                      Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                  'تاریخ شروع : '),
                                                              Text('${notifList![index].notification!.rowContent!.startTime}'
                                                                  .replaceAll(
                                                                      '-', '/')
                                                                  .toPersianDigit()),
                                                            ],
                                                          ),
                                                          if (notifList![index]
                                                                  .notification!
                                                                  .forWhat ==
                                                              2)
                                                            const Column(
                                                              children: [
                                                                Text(
                                                                    '***************'),
                                                                SizedBox(
                                                                    height: 5),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                              ],
                            );
                          },
                        )
                      : const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.notification_outline,
                                size: 40,
                              ),
                              SizedBox(height: 5),
                              Text('اعلانی وجود ندارد !')
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
                          const Text('در حال بارگزاری اعلان ها')
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
