import 'dart:io';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:financial_management/logic/Helpers/date.dart';

import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../../Data/App/dynamic_data.dart';
import '../../Data/Models/cheque.dart';
import '../../Data/Models/installment/installment.dart';
import '../../Logic/Providers/Api/api_connection.dart';

class AddInstallmentScreen extends StatefulWidget {
  static String routeName = '/add_installment';

  const AddInstallmentScreen({
    super.key,
    this.typeOfInstallment,
    this.installment,
    this.cheque,
  });

  final int? typeOfInstallment;
  final Installment? installment;
  final Cheque? cheque;

  @override
  State<AddInstallmentScreen> createState() => _AddInstallmentScreenState();
}

class _AddInstallmentScreenState extends State<AddInstallmentScreen> {
  late int typeOfInstallment;
  int typeOfCheque = 1;
  File? attachmentFile;
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController whatAboutController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  Jalali? startDate = Jalali.now();
  int installmentCount = 1;
  List<TextEditingController> paymentDateControllers = List.generate(
    1,
    (index) => TextEditingController(),
  );
  List<Jalali?> paymentDate = [Jalali.now().addYears(1)];
  TextEditingController dueDateController = TextEditingController();
  Jalali? dueDate;
  TextEditingController warningDateController = TextEditingController();
  TextEditingController warningTimeController = TextEditingController();
  bool incompleteError = false;

  void loadData() {
    if (widget.installment != null) {
      titleController.text = widget.installment!.displayName!;
      priceController.text = widget.installment!.price!
          .toString()
          .toPersianDigit();

      startDateController.text = widget.installment!.startTime!
          .replaceAll('-', '/')
          .toPersianDigit();
      installmentCount = 0;
      paymentDateControllers = [];
      paymentDate = [];
      for (var element in widget.installment!.dueDate!) {
        paymentDateControllers.add(
          TextEditingController(
            text: element.dueDate!.replaceAll('-', '/').toPersianDigit(),
          ),
        );
        installmentCount++;
        paymentDate.add(strToJalaliDate(element.dueDate!));
      }
      if (widget.installment!.description != null) {
        descriptionController.text = widget.installment!.description!;
      }
    }
    if (widget.cheque != null) {
      titleController.text = widget.cheque!.displayName!;
      priceController.text = widget.cheque!.price!.toString().toPersianDigit();
      whatAboutController.text = widget.cheque!.whatAbout!;
      fromController.text = widget.cheque!.from!;
      toController.text = widget.cheque!.to!;
      dueDateController.text = widget.cheque!.dueDate!
          .replaceAll('-', '/')
          .toPersianDigit();
      warningDateController.text = widget.cheque!.warningDate!
          .substring(0, 10)
          .replaceAll('-', '/')
          .toPersianDigit();
      warningTimeController.text = widget.cheque!.warningDate!
          .substring(11, 16)
          .replaceAll('-', '/')
          .toPersianDigit();
      if (widget.cheque!.description != null) {
        descriptionController.text = widget.cheque!.description!;
      }
    }
    setState(() {});
  }

  void clearField() {
    titleController.clear();
    priceController.clear();
    whatAboutController.clear();
    startDateController.clear();
    installmentCount = 1;
    paymentDateControllers = [TextEditingController()];
    paymentDate = [Jalali.now().addYears(1)];
    fromController.clear();
    toController.clear();
    descriptionController.clear();
    dueDateController.clear();
    warningDateController.clear();
    warningTimeController.clear();
    attachmentFile = null;
    typeOfCheque = 1;
    incompleteError = false;
  }

  @override
  void initState() {
    super.initState();
    typeOfInstallment = widget.typeOfInstallment ?? 1;
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.installment != null || widget.cheque != null)
              ? 'ویرایش ${typeOfInstallment == 0 ? 'چک' : 'قسط'} '
              : 'ثبت ${typeOfInstallment == 0 ? 'چک' : 'قسط'} جدید',
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_outline),
          tooltip: 'بازگشت',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('نوع')],
            ),
            const SizedBox(height: 10),
            Opacity(
              opacity: (widget.installment != null || widget.cheque != null)
                  ? 0.5
                  : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: NeumorphicToggle(
                  style: NeumorphicToggleStyle(
                    //depth: 50,
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
                    if (widget.installment == null && widget.cheque == null) {
                      clearField();
                      toController.text = user.sirName!;
                      setState(() {
                        if (value == 0) typeOfInstallment = 1;
                        if (value == 1) typeOfInstallment = 0;

                        incompleteError = false;
                      });
                    }
                  },
                ),
              ),
            ),
            if (typeOfInstallment == 0)
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('صاحب چک')],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: NeumorphicToggle(
                      style: NeumorphicToggleStyle(
                        //depth: 50,
                        backgroundColor: typeOfCheque == 1
                            ? Colors.teal.withValues(alpha: 0.3)
                            : Colors.red.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      selectedIndex: typeOfCheque,
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
                                Icon(Iconsax.people_outline),
                                SizedBox(width: 5),
                                Text('دیگران'),
                              ],
                            ),
                          ),
                          background: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.people_outline,
                                  color: Colors.teal,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'دیگران',
                                  style: TextStyle(color: Colors.teal),
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
                                Icon(Iconsax.user_outline, size: 17),
                                SizedBox(width: 5),
                                Text('خودم'),
                              ],
                            ),
                          ),
                          background: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.user_outline,
                                  size: 17,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'خودم',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value == 0) {
                            typeOfCheque = 1;
                            fromController.clear();
                            toController.text = user.sirName!;
                          }
                          if (value == 1) {
                            typeOfCheque = 0;
                            toController.clear();
                            fromController.text = user.sirName!;
                          }
                        });
                      },
                    ),
                  ),
                ],
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
                  hintText: typeOfInstallment == 1
                      ? 'قسط صندوق خانگی'
                      : typeOfCheque == 1
                      ? 'چک مشتری'
                      : 'خرید وسایل',
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
                  hintText: '10000000'.toPersianDigit(),
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
            if (typeOfInstallment == 0)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.pen_add_outline,
                          size: 22,
                          color:
                              incompleteError &&
                                  whatAboutController.text.length < 2
                              ? Colors.red
                              : null,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'بابت',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                incompleteError &&
                                    whatAboutController.text.length < 2
                                ? Colors.red
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Neumorphic(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 25,
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
                      controller: whatAboutController,
                      maxLength: 50,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: typeOfCheque == 1 ? 'دستمزد' : 'خرید کالا',
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
                ],
              ),
            if (typeOfInstallment == 1)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.timer_start_outline,
                          size: 22,
                          color:
                              incompleteError &&
                                  startDateController.text.isEmpty
                              ? Colors.red
                              : null,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'تاریخ شروع',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                incompleteError &&
                                    startDateController.text.isEmpty
                                ? Colors.red
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Neumorphic(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 25,
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
                      controller: startDateController,
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
                          lastDate: paymentDate.first!,
                          errorFormatText: 'فرمت تاریخ نامعتبر است',
                          errorInvalidText: 'تاریخ خارج از محدوده است ',
                        );
                        if (picked != null) {
                          startDateController.text =
                              (picked
                                      .toJalaliDateTime()
                                      .toString()
                                      .replaceAll('-', '/')
                                      .substring(0, 10))
                                  .toPersianDigit();

                          startDate = picked;

                          setState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            if (typeOfInstallment == 0)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.arrow_up_1_outline,
                                size: 22,
                                color:
                                    incompleteError &&
                                        fromController.text.length < 2
                                    ? Colors.red
                                    : null,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'واگذار کننده',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      incompleteError &&
                                          fromController.text.length < 2
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
                            controller: fromController,
                            maxLength: 50,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: typeOfCheque == 1
                                  ? 'علی نجف زاده'
                                  : '${user.sirName}',
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
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.arrow_down_2_outline,
                                size: 22,
                                color:
                                    incompleteError &&
                                        toController.text.length < 2
                                    ? Colors.red
                                    : null,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'گیرنده',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      incompleteError &&
                                          toController.text.length < 2
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
                            controller: toController,
                            maxLength: 50,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: typeOfCheque == 1
                                  ? '${user.sirName}'
                                  : 'علی نجف زاده',
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
                      ],
                    ),
                  ),
                ],
              ),
            if (typeOfInstallment == 0)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.timer_pause_outline,
                          size: 22,
                          color:
                              incompleteError && dueDateController.text.isEmpty
                              ? Colors.red
                              : null,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'تاریخ سر رسید',
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
                    margin: const EdgeInsets.symmetric(
                      horizontal: 25,
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

                          warningDateController.text =
                              (picked
                                      .addDays(-2)
                                      .toJalaliDateTime()
                                      .toString()
                                      .replaceAll('-', '/')
                                      .substring(0, 10))
                                  .toPersianDigit();

                          warningTimeController.text = TimeOfDay.now()
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
            if (typeOfInstallment == 0)
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
                                        warningDateController.text.isEmpty
                                    ? Colors.red
                                    : null,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'تاریخ هشدار',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      incompleteError &&
                                          warningDateController.text.isEmpty
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
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            if (typeOfInstallment == 1)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Wrap(
                        children: [
                          for (int index = 0; index < installmentCount; index++)
                            Column(
                              children: [
                                SizedBox(
                                  width:
                                      (installmentCount % 2 == 1 &&
                                          index == installmentCount - 1)
                                      ? (MediaQuery.of(context).size.width - 40)
                                      : ((MediaQuery.of(context).size.width -
                                                40) /
                                            2),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Iconsax.calendar_2_outline,
                                          size: 22,
                                          color:
                                              incompleteError &&
                                                  paymentDateControllers[index]
                                                      .text
                                                      .isEmpty
                                              ? Colors.red
                                              : null,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'تاریخ قسط ${(index + 1).toString().toWord()}م'
                                              .replaceAll('سهم', 'سوم')
                                              .replaceAll('یکم', 'اول'),
                                          style: TextStyle(
                                            fontSize: index > 19 ? 10 : 12,
                                            color:
                                                incompleteError &&
                                                    paymentDateControllers[index]
                                                        .text
                                                        .isEmpty
                                                ? Colors.red
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (installmentCount % 2 == 1 &&
                                          index == installmentCount - 1)
                                      ? (MediaQuery.of(context).size.width - 40)
                                      : ((MediaQuery.of(context).size.width -
                                                40) /
                                            2),
                                  child: Neumorphic(
                                    margin: const EdgeInsets.all(5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
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
                                    child: TextField(
                                      controller: paymentDateControllers[index],
                                      // style: TextStyle(fontSize: 14),
                                      textDirection: TextDirection.ltr,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                              minWidth: 0,
                                              minHeight: 0,
                                            ),
                                        prefixIcon: index != 0
                                            ? GestureDetector(
                                                onTap: () {
                                                  paymentDateControllers
                                                      .removeAt(index);
                                                  paymentDate.removeAt(index);
                                                  installmentCount--;
                                                  setState(() {});
                                                },
                                                child: Icon(
                                                  Iconsax.close_circle_bold,
                                                  color: Colors.red,
                                                  size: 25,
                                                ),
                                              )
                                            : null,
                                        hintText: Jalali.now()
                                            .addMonths(1)
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
                                        Jalali? picked =
                                            await showPersianDatePicker(
                                              context: context,
                                              initialDate: index == 0
                                                  ? Jalali.now()
                                                  : paymentDate[index]!,
                                              firstDate: index == 0
                                                  ? startDate ?? Jalali.now()
                                                  : paymentDate[index - 1]!
                                                        .addDays(1),
                                              lastDate:
                                                  index == installmentCount - 1
                                                  ? Jalali.now().addYears(10)
                                                  : paymentDate[index + 1]!
                                                        .addDays(-1),
                                              errorFormatText:
                                                  'فرمت تاریخ نامعتبر است',
                                              errorInvalidText:
                                                  'تاریخ خارج از محدوده است ',
                                            );
                                        if (picked != null) {
                                          paymentDate[index] = picked;

                                          paymentDateControllers[index].text =
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
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                        ],
                      ),
                      if (paymentDateControllers.first.text.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                paymentDateControllers.add(
                                  TextEditingController(
                                    text:
                                        (paymentDate[installmentCount - 1]!
                                                .addDays(
                                                  (paymentDate[installmentCount -
                                                                      1]!
                                                                  .month ==
                                                              6 &&
                                                          paymentDate[installmentCount -
                                                                      1]!
                                                                  .day ==
                                                              31)
                                                      ? 30
                                                      : paymentDate[installmentCount -
                                                                    1]!
                                                                .month <
                                                            7
                                                      ? 31
                                                      : 30,
                                                )
                                                .toJalaliDateTime()
                                                .toString()
                                                .replaceAll('-', '/')
                                                .substring(0, 10))
                                            .toPersianDigit(),
                                  ),
                                );
                                paymentDate.add(
                                  paymentDate[installmentCount - 1]!.addDays(
                                    (paymentDate[installmentCount - 1]!.month ==
                                                6 &&
                                            paymentDate[installmentCount - 1]!
                                                    .day ==
                                                31)
                                        ? 30
                                        : paymentDate[installmentCount - 1]!
                                                  .month <
                                              7
                                        ? 31
                                        : 30,
                                  ),
                                );
                                installmentCount++;
                                setState(() {});
                              },
                              child: Neumorphic(
                                margin: const EdgeInsets.only(
                                  top: 5,
                                  bottom: 10,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                style: NeumorphicStyle(
                                  color: Colors.red.shade100,
                                  border: NeumorphicBorder(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  shadowDarkColor: Colors.black,
                                  depth: 5,
                                  intensity: 0.4,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  'افزودن قسط',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            if (typeOfInstallment == 0)
              Column(
                children: [
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Icon(Iconsax.attach_square_outline, size: 21),
                        SizedBox(width: 5),
                        Text(
                          'پیوست ( اختیاری )',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Neumorphic(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 20,
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
                    child: Row(
                      children: [
                        if (attachmentFile == null)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                ImagePicker picker = ImagePicker();
                                var file = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                attachmentFile = File(file!.path);
                                setState(() {});
                              },
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Iconsax.add_circle_outline,
                                        size: 35,
                                      ),
                                      Text(
                                        (widget.installment != null ||
                                                widget.cheque != null)
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
                                      onTap: () {
                                        // showPhoto();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.file(
                                            attachmentFile!,
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          ),
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
                ],
              ),
            const SizedBox(height: 20),
            (widget.installment != null || widget.cheque != null)
                ? NeumorphicButton(
                    onPressed: () async {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }

                      if (typeOfInstallment == 0) {
                        if (titleController.text.length < 2 ||
                            priceController.text.isEmpty ||
                            int.parse(
                                  priceController.text
                                      .replaceAll(',', '')
                                      .toEnglishDigit(),
                                ) <=
                                0 ||
                            whatAboutController.text.length < 2 ||
                            fromController.text.length < 2 ||
                            toController.text.length < 2 ||
                            dueDateController.text.isEmpty ||
                            warningDateController.text.isEmpty ||
                            warningTimeController.text.isEmpty) {
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
                          if (typeOfCheque + 1 == widget.cheque!.type! &&
                              titleController.text ==
                                  widget.cheque!.displayName &&
                              priceController.text.toEnglishDigit() ==
                                  widget.cheque!.price.toString() &&
                              whatAboutController.text ==
                                  widget.cheque!.whatAbout &&
                              fromController.text == widget.cheque!.from &&
                              toController.text == widget.cheque!.to &&
                              ((descriptionController.text ==
                                      widget.cheque!.description) ||
                                  (descriptionController.text.isEmpty &&
                                      widget.cheque!.description == null)) &&
                              dueDateController.text
                                      .replaceAll('/', '-')
                                      .toEnglishDigit() ==
                                  widget.cheque!.dueDate &&
                              (widget.cheque!.warningDate!.contains(
                                '${warningDateController.text.replaceAll('/', '-').toEnglishDigit()}T${warningTimeController.text.toEnglishDigit()}',
                              )) &&
                              attachmentFile == null) {
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
                            bool accept = await editCheque(
                              code: widget.cheque!.code!,
                              typeCheque:
                                  typeOfCheque + 1 != widget.cheque!.type!
                                  ? typeOfCheque + 1
                                  : null,
                              displayName:
                                  titleController.text !=
                                      widget.cheque!.displayName
                                  ? titleController.text
                                  : null,
                              price:
                                  priceController.text.toEnglishDigit() !=
                                      widget.cheque!.price.toString()
                                  ? priceController.text.toEnglishDigit()
                                  : null,
                              whatAbout:
                                  whatAboutController.text !=
                                      widget.cheque!.whatAbout
                                  ? whatAboutController.text
                                  : null,
                              from: fromController.text != widget.cheque!.from
                                  ? fromController.text
                                  : null,
                              to: toController.text != widget.cheque!.to
                                  ? toController.text
                                  : null,
                              description:
                                  descriptionController.text !=
                                          widget.cheque!.description &&
                                      descriptionController.text.isNotEmpty
                                  ? descriptionController.text
                                  : null,
                              dueDate:
                                  dueDateController.text
                                          .replaceAll('/', '-')
                                          .toEnglishDigit() !=
                                      widget.cheque!.dueDate
                                  ? dueDateController.text.toString()
                                  : null,
                              warningDate:
                                  !(widget.cheque!.warningDate!.contains(
                                    '${warningDateController.text.replaceAll('/', '-').toEnglishDigit()}T${warningTimeController.text.toEnglishDigit()}',
                                  ))
                                  ? '${warningDateController.text.toEnglishDigit()} ${warningTimeController.text.toEnglishDigit()}'
                                  : null,
                              image: attachmentFile,
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
                                    'چک با موفقیت ویرایش شد',
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
                      }
                      if (typeOfInstallment == 1) {
                        if (titleController.text.length < 2 ||
                            priceController.text.isEmpty ||
                            int.parse(
                                  priceController.text
                                      .replaceAll(',', '')
                                      .toEnglishDigit(),
                                ) <=
                                0 ||
                            startDateController.text.isEmpty ||
                            paymentDateControllers.first.text.isEmpty) {
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
                          List<String> dueDate = [];
                          bool isDuplicate = true;

                          if (paymentDate.length !=
                              widget.installment!.dueDate!.length) {
                            isDuplicate = false;
                          }

                          int index = 0;
                          for (var element in paymentDateControllers) {
                            dueDate.add(element.text.toEnglishDigit());

                            if (isDuplicate) {
                              if (!(widget.installment!.dueDate![index].dueDate!
                                  .contains(
                                    element.text.toEnglishDigit().replaceAll(
                                      '/',
                                      '-',
                                    ),
                                  ))) {
                                isDuplicate = false;
                              }
                            }

                            index++;
                          }

                          if (titleController.text ==
                                  widget.installment!.displayName &&
                              priceController.text.toEnglishDigit() ==
                                  widget.installment!.price.toString() &&
                              startDateController.text
                                      .replaceAll('/', '-')
                                      .toEnglishDigit() ==
                                  widget.installment!.startTime &&
                              ((descriptionController.text ==
                                      widget.installment!.description) ||
                                  (descriptionController.text.isEmpty &&
                                      widget.installment!.description ==
                                          null)) &&
                              isDuplicate) {
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
                            bool accept = await editInstallment(
                              code: widget.installment!.code!,
                              displayName:
                                  titleController.text !=
                                      widget.installment!.displayName
                                  ? titleController.text
                                  : null,
                              price:
                                  priceController.text.toEnglishDigit() !=
                                      widget.installment!.price.toString()
                                  ? priceController.text.toEnglishDigit()
                                  : null,
                              startTime:
                                  startDateController.text
                                          .replaceAll('/', '-')
                                          .toEnglishDigit() !=
                                      widget.installment!.startTime
                                  ? startDateController.text.toEnglishDigit()
                                  : null,
                              dueDate: !isDuplicate ? dueDate : null,
                              description:
                                  descriptionController.text !=
                                      widget.installment!.description
                                  ? descriptionController.text
                                  : null,
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
                                    'قسط با موفقیت ویرایش شد',
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
                      }
                      setState(() {});
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
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                : NeumorphicButton(
                    onPressed: () async {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }

                      if (typeOfInstallment == 0) {
                        if (titleController.text.length < 2 ||
                            priceController.text.isEmpty ||
                            int.parse(
                                  priceController.text
                                      .replaceAll(',', '')
                                      .toEnglishDigit(),
                                ) <=
                                0 ||
                            whatAboutController.text.length < 2 ||
                            fromController.text.length < 2 ||
                            toController.text.length < 2 ||
                            dueDateController.text.isEmpty ||
                            warningDateController.text.isEmpty ||
                            warningTimeController.text.isEmpty) {
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
                          bool accept = await setCheque(
                            typeCheque: typeOfCheque == 0 ? 1 : 2,
                            displayName: titleController.text,
                            price: priceController.text.toEnglishDigit(),
                            whatAbout: whatAboutController.text,
                            from: fromController.text,
                            to: toController.text,
                            description: descriptionController.text,
                            dueDate: dueDateController.text.toEnglishDigit(),
                            warningDate:
                                '${warningDateController.text.toEnglishDigit()} ${warningTimeController.text.toEnglishDigit()}',
                            image: attachmentFile,
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
                                  'چک با موفقیت ثبت شد',
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
                            if (widget.typeOfInstallment != null) {
                              Navigator.pop(context);
                            }
                          }
                        }
                      }
                      if (typeOfInstallment == 1) {
                        if (titleController.text.length < 2 ||
                            priceController.text.isEmpty ||
                            int.parse(
                                  priceController.text
                                      .replaceAll(',', '')
                                      .toEnglishDigit(),
                                ) <=
                                0 ||
                            startDateController.text.isEmpty ||
                            paymentDateControllers.first.text.isEmpty) {
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
                          List<String> dueDate = [];

                          for (var element in paymentDateControllers) {
                            dueDate.add(element.text.toEnglishDigit());
                          }

                          bool accept = await setInstallment(
                            displayName: titleController.text,
                            price: priceController.text.toEnglishDigit(),
                            startTime: startDateController.text
                                .toEnglishDigit(),
                            dueDate: dueDate,
                            description: descriptionController.text,
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
                                  'قسط با موفقیت ثبت شد',
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
                            if (widget.typeOfInstallment != null) {
                              Navigator.pop(context);
                            }
                          }
                        }
                      }
                      setState(() {});
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
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
