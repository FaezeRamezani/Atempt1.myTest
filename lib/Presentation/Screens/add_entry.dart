import 'dart:io';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../../Data/Models/entry/entry.dart';
import '../../Data/Models/output/output.dart';
import '../../Data/Models/tag.dart';
import '../../Logic/Providers/Api/api_connection.dart';

class AddReportScreen extends StatefulWidget {
  static String routeName = '/add_report';

  const AddReportScreen({
    super.key,
    this.typeOfTransaction,
    this.entry,
    this.output,
  });

  final int? typeOfTransaction;
  final Entry? entry;
  final Output? output;

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  int typeOfTransaction = 1;
  int? categoryCode;

  // int? reasonCode;

  File? attachmentFile;
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController(text: '');
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  TextEditingController dueTimeController = TextEditingController();
  bool incompleteError = false;

  List<Tag>? entryTag;
  List<Tag>? outputTag;

  // List<Tag>? reasonTag;

  Future getType() async {
    entryTag = await getTypeOfEntry(context: context);
    setState(() {});
    outputTag = await getTypeOfOutput(context: context);
    setState(() {});
    // reasonTag = await getReasonOfOutput();
    // setState(() {});
  }

  void loadData() {
    if (typeOfTransaction == 1 && widget.entry != null) {
      dueDateController.text = widget.entry!.registerTime!
          .split("T")
          .first
          .replaceAll("-", "/")
          .toPersianDigit();
      dueTimeController.text = widget.entry!.registerTime!
          .split("T")
          .last
          .substring(0, 5)
          .toPersianDigit();
      titleController.text = widget.entry!.displayName!;
      priceController.text = widget.entry!.price!.toString().toPersianDigit();
      categoryCode = widget.entry!.type!.code;
      if (widget.entry!.description != null) {
        descriptionController.text = widget.entry!.description!;
      }
    }
    if (typeOfTransaction == 0 && widget.output != null) {
      dueDateController.text = widget.output!.registerTime!
          .split("T")
          .first
          .replaceAll("-", "/")
          .toPersianDigit();
      dueTimeController.text = widget.output!.registerTime!
          .split("T")
          .last
          .substring(0, 5)
          .toPersianDigit();
      titleController.text = widget.output!.displayName!;
      priceController.text = widget.output!.price!.toString().toPersianDigit();
      categoryCode = widget.output!.type!.code;
      // reasonCode = widget.output!.reason!.code;
      if (widget.output!.description != null) {
        descriptionController.text = widget.output!.description!;
      }
    }
    setState(() {});
  }

  void clearField() {
    titleController.clear();
    priceController.clear();
    descriptionController.clear();
    attachmentFile = null;
    categoryCode = null;
    // reasonCode = null;
    setState(() {});
    incompleteError = false;
  }

  Future initialDueDateTime() async {
    await Future.delayed(Duration(milliseconds: 200));
    dueTimeController.text = TimeOfDay.now().format(context).toPersianDigit();
    dueDateController.text = Jalali.now()
        .toJalaliDateTime()
        .toString()
        .replaceAll('-', '/')
        .substring(0, 10)
        .toPersianDigit();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    typeOfTransaction = widget.typeOfTransaction ?? 1;
    getType();
    if (widget.entry == null && widget.output == null) initialDueDateTime();
    if (widget.entry != null || widget.output != null) loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.entry != null || widget.output != null)
              ? 'ویرایش تراکنش'
              : 'ثبت تراکنش جدید',
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
                icon: const Icon(Iconsax.arrow_right_outline),
                tooltip: 'بازگشت',
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('نوع تراکنش')],
            ),
            const SizedBox(height: 10),
            Opacity(
              opacity: (widget.entry != null || widget.output != null)
                  ? 0.5
                  : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: NeumorphicToggle(
                  style: NeumorphicToggleStyle(
                    //depth: 50,
                    backgroundColor: Colors.black12,
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
                      background: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.arrow_down_2_outline),
                            SizedBox(width: 5),
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
                            SizedBox(width: 5),
                            Text('خرج'),
                          ],
                        ),
                      ),
                      background: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.arrow_up_1_outline),
                            SizedBox(width: 5),
                            Text('خرج'),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (widget.entry == null && widget.output == null) {
                      clearField();
                      setState(() {
                        if (value == 0) typeOfTransaction = 1;
                        if (value == 1) typeOfTransaction = 0;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Icon(
                    Iconsax.message_2_outline,
                    size: 22,
                    color: incompleteError && titleController.text.length < 2
                        ? Colors.red
                        : null,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'عنوان',
                    style: TextStyle(
                      fontSize: 12,
                      color: incompleteError && titleController.text.length < 2
                          ? Colors.red
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Neumorphic(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
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
                controller: titleController,
                maxLength: 50,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(
                      text: (newValue.text).toPersianDigit(),
                    );
                  }),
                ],
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'حقوق',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  counterText: '',
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Icon(
                    Iconsax.money_3_outline,
                    size: 22,
                    color:
                        incompleteError &&
                            (priceController.text.isEmpty ||
                                int.parse(
                                      priceController.text
                                          .replaceAll(',', '')
                                          .toEnglishDigit(),
                                    ) <=
                                    0)
                        ? Colors.red
                        : null,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'مبلغ',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          incompleteError &&
                              (priceController.text.isEmpty ||
                                  int.parse(
                                        priceController.text
                                            .replaceAll(',', '')
                                            .toEnglishDigit(),
                                      ) <=
                                      0)
                          ? Colors.red
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Neumorphic(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
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
                  hintText: ('10000000').toPersianDigit(),
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  hintTextDirection: TextDirection.ltr,
                  suffixIcon: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('تومان', style: TextStyle(fontSize: 12))],
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
                  setState(() {
                    if (int.parse(value.toEnglishDigit()) == 0) {
                      priceController.clear();
                    }
                  });
                },
              ),
            ),
            if (priceController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 40, left: 40, bottom: 5),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
                  child: Text(
                    '${priceController.text.toWord()} تومان',
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Icon(
                    Iconsax.category_2_outline,
                    size: 21,
                    color: incompleteError && categoryCode == null
                        ? Colors.red
                        : null,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'دسته بندی',
                    style: TextStyle(
                      fontSize: 12,
                      color: incompleteError && categoryCode == null
                          ? Colors.red
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Neumorphic(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
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
                          ((entryTag != null && typeOfTransaction == 1) ||
                              (outputTag != null && typeOfTransaction == 0))
                          ? Text(
                              'انتخاب دسته بندی',
                              style: TextStyle(color: Colors.grey.shade400),
                            )
                          : Row(
                              children: [
                                Text(
                                  'در حال بارگذاری',
                                  style: TextStyle(color: Colors.grey.shade400),
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
                          ((entryTag != null && typeOfTransaction == 1) ||
                              (outputTag != null && typeOfTransaction == 0))
                          ? (typeOfTransaction == 1 ? entryTag! : outputTag!)
                                .map((Tag tag) {
                                  return DropdownMenuItem(
                                    value: tag.code,
                                    child: Text(tag.name!),
                                  );
                                })
                                .toList()
                          : [],
                      onChanged: (value) {
                        if ((entryTag != null && typeOfTransaction == 1) ||
                            (outputTag != null && typeOfTransaction == 0)) {
                          setState(() {
                            categoryCode = value as int?;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // if (typeOfTransaction == 0)
            //   Column(
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 40),
            //         child: Row(
            //           children: [
            //             Icon(
            //               Iconsax.message_question_outline,
            //               size: 21,
            //               color: incompleteError && reasonCode == null
            //                   ? Colors.red
            //                   : null,
            //             ),
            //             const SizedBox(width: 5),
            //             Text(
            //               'علت برداشت',
            //               style: TextStyle(
            //                 fontSize: 12,
            //                 color: incompleteError && reasonCode == null
            //                     ? Colors.red
            //                     : null,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //       Neumorphic(
            //         margin:
            //             const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
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
            //               padding: const EdgeInsets.symmetric(vertical: 8),
            //               child: DropdownButton(
            //                 hint: (reasonTag != null)
            //                     ? Text(
            //                         'انتخاب علت',
            //                         style:
            //                             TextStyle(color: Colors.grey.shade400),
            //                       )
            //                     : Row(
            //                         children: [
            //                           Text(
            //                             'در حال بارگذاری',
            //                             style: TextStyle(
            //                                 color: Colors.grey.shade400),
            //                           ),
            //                           const SizedBox(width: 5),
            //                           LoadingAnimationWidget.staggeredDotsWave(
            //                             color: Colors.grey.shade400,
            //                             size: 40,
            //                           ),
            //                         ],
            //                       ),
            //                 value: reasonCode,
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
            //                     setState(() {
            //                       reasonCode = value as int?;
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
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.calendar_2_outline,
                              size: 22,
                              color:
                                  incompleteError &&
                                      dueDateController.text.isEmpty
                                  ? Colors.red
                                  : null,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'تاریخ انجام',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    incompleteError &&
                                        dueDateController.text.isEmpty
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Neumorphic(
                        margin: const EdgeInsets.fromLTRB(10, 5, 25, 5),
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
                                .addDays(29)
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
                              dueDateController.text =
                                  (picked
                                          .toJalaliDateTime()
                                          .toString()
                                          .replaceAll('-', '/')
                                          .substring(0, 10))
                                      .toPersianDigit();

                              dueTimeController.text = TimeOfDay.now()
                                  .format(context)
                                  .toPersianDigit();

                              setState(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.clock_outline,
                              size: 22,
                              color:
                                  incompleteError &&
                                      dueTimeController.text.isEmpty
                                  ? Colors.red
                                  : null,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'ساعت انجام',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    incompleteError &&
                                        dueTimeController.text.isEmpty
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Neumorphic(
                        margin: const EdgeInsets.fromLTRB(25, 5, 10, 5),
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
                          controller: dueTimeController,
                          textDirection: TextDirection.ltr,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: ('14:20').toPersianDigit(),
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
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (BuildContext context, Widget? child) {
                                return MediaQuery(
                                  data: MediaQuery.of(
                                    context,
                                  ).copyWith(alwaysUse24HourFormat: true),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              dueTimeController.text = picked
                                  .format(context)
                                  .toPersianDigit();

                              setState(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Icon(Iconsax.edit_outline, size: 21),
                  SizedBox(width: 5),
                  Text('توضیحات ( اختیاری )', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Neumorphic(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
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
                controller: descriptionController,
                maxLength: 1000,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(
                      text: (newValue.text).toPersianDigit(),
                    );
                  }),
                ],
                style: const TextStyle(fontSize: 14),
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'حقوق ماهانه با پاداش ...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  counterText: '',
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Icon(Iconsax.attach_square_outline, size: 21),
                  SizedBox(width: 5),
                  Text('پیوست ( اختیاری )', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Neumorphic(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
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
                  if (attachmentFile == null)
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles();

                          if (result != null) {
                            attachmentFile = File(result.files.single.path!);
                          } else {
                            // User canceled the picker
                          }
                          setState(() {});
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                const Icon(
                                  Iconsax.add_circle_outline,
                                  size: 35,
                                ),
                                Text(
                                  (widget.entry != null ||
                                          widget.output != null)
                                      ? 'پیوست جدید'
                                      : 'افزودن پیوست',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child:
                                      attachmentFile!.path.contains('jpg') ||
                                          attachmentFile!.path.contains(
                                            'jpeg',
                                          ) ||
                                          attachmentFile!.path.contains('png')
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.file(
                                            File(attachmentFile!.path),
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Iconsax.attach_square_outline,
                                              size: 50,
                                            ),
                                            Text(
                                              attachmentFile!.path
                                                  .split('.')
                                                  .last,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  attachmentFile = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            (widget.entry != null || widget.output != null)
                ? NeumorphicButton(
                    onPressed: () async {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }

                      if (typeOfTransaction == 0) {
                        if (titleController.text.length < 2 ||
                            priceController.text.isEmpty ||
                            int.parse(
                                  priceController.text
                                      .replaceAll(',', '')
                                      .toEnglishDigit(),
                                ) <=
                                0 ||
                            categoryCode == null
                        // || reasonCode == null
                        ) {
                          incompleteError = true;

                          DelightToastBar(
                            position: DelightSnackbarPosition.top,
                            autoDismiss: true,
                            snackbarDuration: const Duration(
                              milliseconds: 2500,
                            ),
                            builder: (context) => const ToastCard(
                              color: Colors.red,
                              leading: Icon(
                                Iconsax.warning_2_outline,
                                size: 28,
                                color: Colors.white,
                              ),
                              title: Text(
                                'ورودی نا معتبر',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                'خطاهای مشخص شده را برطرف نمایید',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ).show(context);
                        } else {
                          if (titleController.text ==
                                  widget.output!.displayName &&
                              priceController.text.toEnglishDigit() ==
                                  widget.output!.price.toString() &&
                              categoryCode! == widget.output!.type!.code &&
                              ((descriptionController.text ==
                                      widget.output!.description) ||
                                  (descriptionController.text.isEmpty &&
                                      widget.output!.description == null)) &&
                              attachmentFile == null &&
                              ("${dueDateController.text} ${dueTimeController.text}"
                                      .toEnglishDigit() ==
                                  widget.output!.registerTime!
                                      .replaceAll("T", " ")
                                      .replaceAll("-", "/")
                                      .substring(0, 16))) {
                            DelightToastBar(
                              position: DelightSnackbarPosition.top,
                              autoDismiss: true,
                              snackbarDuration: const Duration(
                                milliseconds: 2500,
                              ),
                              builder: (context) => const ToastCard(
                                color: Colors.red,
                                leading: Icon(
                                  Iconsax.warning_2_outline,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  'تغییری اعمال نشده است',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ).show(context);
                          } else {
                            bool accept = await editOutput(
                              code: widget.output!.code!,
                              displayName:
                                  titleController.text !=
                                      widget.output!.displayName
                                  ? titleController.text
                                  : null,
                              price:
                                  priceController.text.toEnglishDigit() !=
                                      widget.output!.price.toString()
                                  ? priceController.text.toEnglishDigit()
                                  : null,
                              typeOutput:
                                  categoryCode! != widget.output!.type!.code
                                  ? categoryCode!
                                  : null,
                              // reasonOutput:
                              //     reasonCode! != widget.output!.reason!.code
                              //         ? reasonCode!
                              //         : null,
                              description:
                                  descriptionController.text !=
                                      widget.output!.description
                                  ? descriptionController.text
                                  : null,
                              file: attachmentFile,
                              dueDateTime:
                                  "${dueDateController.text} ${dueTimeController.text}"
                                      .toEnglishDigit(),
                              context: context,
                            );
                            if (accept) {
                              DelightToastBar(
                                position: DelightSnackbarPosition.top,
                                autoDismiss: true,
                                snackbarDuration: const Duration(
                                  milliseconds: 2500,
                                ),
                                builder: (context) => const ToastCard(
                                  color: Colors.green,
                                  leading: Icon(
                                    Iconsax.tick_circle_bold,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    'تراکنش با موفقیت ویرایش شد',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ).show(context);

                              incompleteError = false;
                              Navigator.pop(context);
                            }
                          }
                        }
                        setState(() {});
                      }
                      if (typeOfTransaction == 1) {
                        if (titleController.text.length < 2 ||
                            priceController.text.isEmpty ||
                            int.parse(
                                  priceController.text
                                      .replaceAll(',', '')
                                      .toEnglishDigit(),
                                ) <=
                                0 ||
                            categoryCode == null) {
                          incompleteError = true;

                          DelightToastBar(
                            position: DelightSnackbarPosition.top,
                            autoDismiss: true,
                            snackbarDuration: const Duration(
                              milliseconds: 2500,
                            ),
                            builder: (context) => const ToastCard(
                              color: Colors.red,
                              leading: Icon(
                                Iconsax.warning_2_outline,
                                size: 28,
                                color: Colors.white,
                              ),
                              title: Text(
                                'ورودی نا معتبر',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                'خطاهای مشخص شده را برطرف نمایید',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ).show(context);
                        } else {
                          if (titleController.text ==
                                  widget.entry!.displayName &&
                              priceController.text.toEnglishDigit() ==
                                  widget.entry!.price.toString() &&
                              categoryCode! == widget.entry!.type!.code &&
                              ((descriptionController.text ==
                                      widget.entry!.description) ||
                                  (descriptionController.text.isEmpty &&
                                      widget.entry!.description == null)) &&
                              attachmentFile == null &&
                              ("${dueDateController.text} ${dueTimeController.text}"
                                      .toEnglishDigit() ==
                                  widget.entry!.registerTime!
                                      .replaceAll("T", " ")
                                      .replaceAll("-", "/")
                                      .substring(0, 16))) {
                            DelightToastBar(
                              position: DelightSnackbarPosition.top,
                              autoDismiss: true,
                              snackbarDuration: const Duration(
                                milliseconds: 2500,
                              ),
                              builder: (context) => const ToastCard(
                                color: Colors.red,
                                leading: Icon(
                                  Iconsax.warning_2_outline,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  'تغییری اعمال نشده است',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ).show(context);
                          } else {
                            bool accept = await editEntry(
                              code: widget.entry!.code!,
                              displayName:
                                  titleController.text !=
                                      widget.entry!.displayName
                                  ? titleController.text
                                  : null,
                              price:
                                  priceController.text.toEnglishDigit() !=
                                      widget.entry!.price.toString()
                                  ? priceController.text.toEnglishDigit()
                                  : null,
                              typeCode:
                                  categoryCode! != widget.entry!.type!.code
                                  ? categoryCode!
                                  : null,
                              description:
                                  descriptionController.text !=
                                      widget.entry!.description
                                  ? descriptionController.text
                                  : null,
                              file: attachmentFile,
                              dueDateTime:
                                  "${dueDateController.text} ${dueTimeController.text}"
                                      .toEnglishDigit(),
                              context: context,
                            );

                            if (accept) {
                              DelightToastBar(
                                position: DelightSnackbarPosition.top,
                                autoDismiss: true,
                                snackbarDuration: const Duration(
                                  milliseconds: 2500,
                                ),
                                builder: (context) => const ToastCard(
                                  color: Colors.green,
                                  leading: Icon(
                                    Iconsax.tick_circle_bold,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    'تراکنش با موفقیت ویرایش شد',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ).show(context);

                              incompleteError = false;
                              Navigator.pop(context);
                            }
                          }
                        }
                        setState(() {});
                      }
                    },
                    margin: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
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
                      'ویرایش',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : NeumorphicButton(
                    onPressed: () async {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }

                      if (typeOfTransaction == 0) {
                        if (titleController.text.length < 2 ||
                            priceController.text.isEmpty ||
                            int.parse(
                                  priceController.text
                                      .replaceAll(',', '')
                                      .toEnglishDigit(),
                                ) <=
                                0 ||
                            categoryCode == null
                        // || reasonCode == null
                        ) {
                          incompleteError = true;

                          DelightToastBar(
                            position: DelightSnackbarPosition.top,
                            autoDismiss: true,
                            snackbarDuration: const Duration(
                              milliseconds: 2500,
                            ),
                            builder: (context) => const ToastCard(
                              color: Colors.red,
                              leading: Icon(
                                Iconsax.warning_2_outline,
                                size: 28,
                                color: Colors.white,
                              ),
                              title: Text(
                                'ورودی نا معتبر',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                'خطاهای مشخص شده را برطرف نمایید',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ).show(context);
                        } else {
                          bool accept = await setOutput(
                            displayName: titleController.text,
                            price: priceController.text.toEnglishDigit(),
                            typeOutput: categoryCode!,
                            // reasonOutput: reasonCode!,
                            description: descriptionController.text,
                            file: attachmentFile,
                            dueDateTime:
                                "${dueDateController.text} ${dueTimeController.text}"
                                    .toEnglishDigit(),
                            context: context,
                          );
                          if (accept) {
                            DelightToastBar(
                              position: DelightSnackbarPosition.top,
                              autoDismiss: true,
                              snackbarDuration: const Duration(
                                milliseconds: 2500,
                              ),
                              builder: (context) => const ToastCard(
                                color: Colors.green,
                                leading: Icon(
                                  Iconsax.tick_circle_bold,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  'تراکنش با موفقیت ثبت شد',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ).show(context);
                            clearField();
                            incompleteError = false;
                            if (widget.typeOfTransaction != null) {
                              Navigator.pop(context);
                            }
                          }
                        }
                        setState(() {});
                      }
                      if (typeOfTransaction == 1) {
                        if (titleController.text.length < 2 ||
                            priceController.text.isEmpty ||
                            int.parse(
                                  priceController.text
                                      .replaceAll(',', '')
                                      .toEnglishDigit(),
                                ) <=
                                0 ||
                            categoryCode == null) {
                          incompleteError = true;

                          DelightToastBar(
                            position: DelightSnackbarPosition.top,
                            autoDismiss: true,
                            snackbarDuration: const Duration(
                              milliseconds: 2500,
                            ),
                            builder: (context) => const ToastCard(
                              color: Colors.red,
                              leading: Icon(
                                Iconsax.warning_2_outline,
                                size: 28,
                                color: Colors.white,
                              ),
                              title: Text(
                                'ورودی نا معتبر',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                'خطاهای مشخص شده را برطرف نمایید',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ).show(context);
                        } else {
                          bool accept = await setEntry(
                            displayName: titleController.text,
                            price: priceController.text.toEnglishDigit(),
                            typeCode: categoryCode!,
                            description: descriptionController.text,
                            file: attachmentFile,
                            dueDateTime:
                                "${dueDateController.text} ${dueTimeController.text}"
                                    .toEnglishDigit(),
                            context: context,
                          );

                          if (accept) {
                            DelightToastBar(
                              position: DelightSnackbarPosition.top,
                              autoDismiss: true,
                              snackbarDuration: const Duration(
                                milliseconds: 2500,
                              ),
                              builder: (context) => const ToastCard(
                                color: Colors.green,
                                leading: Icon(
                                  Iconsax.tick_circle_bold,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  'تراکنش با موفقیت ثبت شد',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ).show(context);
                            clearField();
                            incompleteError = false;

                            if (widget.typeOfTransaction != null) {
                              Navigator.pop(context);
                            }
                          }
                        }
                        setState(() {});
                      }
                    },
                    margin: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
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
                      'ثبت',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
