import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:native_auth/native_auth.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Constant/urls.dart';
import '../../Data/App/dynamic_data.dart';
import '../../Data/App/static_data.dart';
import '../../Data/Models/log/log.dart';
import '../../Data/Models/server.dart';
import '../../Data/Models/user/user.dart';
import '../../Logic/Providers/SharedPreferences/shared_preferences.dart';
import '../../logic/Helpers/number.dart';
import '../../logic/providers/Api/api_connection.dart';
import 'develop.dart';
import 'info.dart';
import 'splash.dart';
import 'update.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool darkTheme = false;
  bool fingerPrint = false;
  int type = 1;
  List<User>? groupMate;
  Server? infoServer;
  int? smsCount;

  Future getFingerState() async {
    fingerPrint = await getFingerPermission();
    setState(() {});
  }

  Future editProfileDialog() async {
    TextEditingController sirNameController =
        TextEditingController(text: user.sirName);
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    XFile? photo;

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, changeState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(
                    Iconsax.user_edit_outline,
                    size: 30,
                  ),
                  const SizedBox(width: 5),
                  const Text('ویرایش اطلاعات'),
                  Expanded(child: Container()),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.close_circle_outline))
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Stack(
                        //  alignment: Alignment.center,
                        children: [
                          Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: photo == null
                                  ? Image.network(
                                      '${Urls.hostUrl}${user.profile}',
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(photo!.path),
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    ImagePicker picker = ImagePicker();
                                    photo = await picker.pickImage(
                                        source: ImageSource.gallery);

                                    changeState(() {
                                      photo;
                                    });
                                  },
                                  icon: const Icon(
                                    Iconsax.camera_outline,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.user_outline,
                              size: 21,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'مشخصات کاربری',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: sirNameController,
                        maxLength: 30,
                        decoration: const InputDecoration(
                          labelText: 'نام نمایشی',
                          counterText: '',
                        ),
                        onChanged: (value) {
                          changeState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.lock_outline,
                              size: 21,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'ایمنی و رمز عبور',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: oldPasswordController,
                        maxLength: 50,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'رمز عبور فعلی',
                          counterText: '',
                        ),
                        onChanged: (value) {
                          changeState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: newPasswordController,
                        maxLength: 50,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'رمز عبور جدید',
                          counterText: '',
                        ),
                        onChanged: (value) {
                          changeState(() {});
                        },
                      ),
                      const SizedBox(height: 10),
                      (newPasswordController.text.contains(RegExp(r'[A-Z]')) &&
                              newPasswordController.text
                                  .contains(RegExp(r'[a-z]')))
                          ? Container()
                          : const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  SizedBox(width: 5),
                                  Icon(
                                    Iconsax.close_circle_outline,
                                    size: 21,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'استفاده از حروف بزرگ و کوچک ( A-Z  a-z )',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      if (!newPasswordController.text
                          .contains(RegExp(r'[0-9]')))
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              SizedBox(width: 5),
                              Icon(
                                Iconsax.close_circle_outline,
                                size: 21,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'استفاده از اعداد',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (newPasswordController.text.length < 8)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              SizedBox(width: 5),
                              Icon(
                                Iconsax.close_circle_outline,
                                size: 21,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'حداقل 8 کاراکتر',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: confirmPasswordController,
                        maxLength: 50,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'تکرار رمز عبور جدید',
                          errorText: newPasswordController.text !=
                                  confirmPasswordController.text
                              ? 'رمز عبور ها مطابقت ندارند'
                              : null,
                          counterText: '',
                        ),
                        onChanged: (value) {
                          changeState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:
                      const Text('انصراف', style: TextStyle(color: Colors.red)),
                ),
                GestureDetector(
                  onTap: (photo != null ||
                          sirNameController.text != user.sirName ||
                          (oldPasswordController.text.isNotEmpty &&
                              newPasswordController.text.isNotEmpty &&
                              confirmPasswordController.text.isNotEmpty &&
                              newPasswordController.text ==
                                  confirmPasswordController.text &&
                              (newPasswordController.text
                                      .contains(RegExp(r'[A-Z]')) &&
                                  newPasswordController.text
                                      .contains(RegExp(r'[a-z]')))))
                      ? () async {
                          await editProfile(
                            sirName: sirNameController.text,
                            currentPassword: oldPasswordController.text,
                            newPassword: newPasswordController.text,
                            retypeNewPassword: confirmPasswordController.text,
                            profileImage: photo,
                            context: context,
                          );
                          setState(() {});
                          Navigator.pop(context);
                        }
                      : () {},
                  child: Neumorphic(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    style: NeumorphicStyle(
                      color: (photo != null ||
                              sirNameController.text != user.sirName ||
                              (oldPasswordController.text.isNotEmpty &&
                                  newPasswordController.text.isNotEmpty &&
                                  confirmPasswordController.text.isNotEmpty &&
                                  newPasswordController.text ==
                                      confirmPasswordController.text &&
                                  (newPasswordController.text
                                          .contains(RegExp(r'[A-Z]')) &&
                                      newPasswordController.text
                                          .contains(RegExp(r'[a-z]')))))
                          ? Colors.green[400]
                          : Colors.grey.shade300,
                      shadowDarkColor: Colors.black,
                      depth: 5,
                      intensity: 0.4,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20)),
                    ),
                    child: const Text(
                      'ویرایش',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          });
        });
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
                            '${info.content!.code}'.toPersianDigit(),
                            style: const TextStyle(fontSize: 11),
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
                              '${info.content!.displayName}'.toPersianDigit(),
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 11),
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
                            '${splitNumber(info.content!.price!)}   تومان'
                                .toPersianDigit(),
                            style: const TextStyle(fontSize: 11),
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
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getFingerState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${Urls.hostUrl}${user.profile}',
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Shimmer.fromColors(
                                direction: ShimmerDirection.rtl,
                                baseColor: Colors.blueAccent,
                                highlightColor: Colors.white,
                                period: const Duration(milliseconds: 4000),
                                child: const Icon(
                                  Iconsax.user_outline,
                                  size: 80,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Container(
                        padding: const EdgeInsets.only(right: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              '${user.sirName}',
                              style: const TextStyle(
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'نام کاربری',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  ('${user.username}').toPersianDigit(),
                                  style: const TextStyle(
                                      fontSize: 12, letterSpacing: 0.8),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'شماره همراه',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  ('${user.phone}').toPersianDigit(),
                                  style: const TextStyle(
                                      fontSize: 14, letterSpacing: 0.8),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'تاریخ عضویت',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  (user.registerTime!
                                          .substring(0, 10)
                                          .replaceAll('-', '/'))
                                      .toPersianDigit(),
                                  style: const TextStyle(
                                      fontSize: 14, letterSpacing: 0.8),
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
              Positioned(
                top: 25,
                left: 25,
                child: GestureDetector(
                  onTap: () async {
                    await editProfileDialog();
                  },
                  child: Neumorphic(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(7),
                    style: NeumorphicStyle(
                      color: Colors.blue,
                      shadowDarkColor: Colors.black,
                      depth: 5,
                      intensity: 0.4,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20)),
                    ),
                    child: Icon(
                      Iconsax.user_edit_outline,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width - 50,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: DottedDecoration(
              shape: Shape.line,
              linePosition: LinePosition.bottom,
              color: Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: NeumorphicToggle(
              style: NeumorphicToggleStyle(
                //depth: 50,
                backgroundColor: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              selectedIndex: type,
              thumb: Center(
                child: Container(
                  color: Colors.white.withValues(alpha:0.2),
                ),
              ),
              children: [
                ToggleElement(
                  foreground: const Center(child: Text('اطلاعات کاربر')),
                  background: const Center(child: Text('اطلاعات کاربر')),
                ),
                ToggleElement(
                  foreground: const Center(child: Text('تنظیمات')),
                  background: const Center(child: Text('تنظیمات')),
                ),
                ToggleElement(
                  foreground: const Center(child: Text('اطلاعات سامانه')),
                  background: const Center(child: Text('اطلاعات سامانه')),
                ),
              ],
              onChanged: (value) async {
                if (value == 0) {
                  type = 2;
                  setState(() {});
                  await getProfileInfo(
                    context: context,
                  );
                  setState(() {});
                  groupMate = await getGroupMate(context: context);
                  setState(() {});
                }
                if (value == 1) {
                  type = 1;
                  setState(() {});
                }
                if (value == 2) {
                  type = 0;
                  setState(() {});
                  smsCount = await getSmsPanelInfo(context: context);
                  setState(() {});
                  infoServer = await getServerInfo();
                  setState(() {});
                }
              },
            ),
          ),
          const SizedBox(height: 15),
          if (type == 0)
            Column(
              children: [
                Neumorphic(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  style: NeumorphicStyle(
                    color: Colors.white,
                    shadowDarkColor: Colors.black,
                    depth: 5,
                    intensity: 0.4,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Iconsax.messages_outline),
                        title: const Text('پنل پیامکی'),
                        subtitle: Row(
                          children: [
                            const Text(
                              'اعتبار موجودی :  ',
                              style: TextStyle(fontSize: 12),
                            ),
                            if (infoServer != null)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: (splitNumber(smsCount ?? 0))
                                          .toPersianDigit(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const TextSpan(
                                      text: '  پیامک  ',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              )
                            else
                              LoadingAnimationWidget.staggeredDotsWave(
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            !await launchUrl(
                                Uri.parse('https://sms.ir/panel/'));
                          },
                          icon: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.add_square_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'افزایش',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Neumorphic(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  style: NeumorphicStyle(
                    color: Colors.white,
                    shadowDarkColor: Colors.black,
                    depth: 5,
                    intensity: 0.4,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Iconsax.cloud_outline),
                        title: const Text('سرور ابری'),
                        subtitle: Row(
                          children: [
                            const Text(
                              'اعتبار موجودی :  ',
                              style: TextStyle(fontSize: 12),
                            ),
                            if (infoServer != null)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: (splitNumber(infoServer!.price!))
                                          .toPersianDigit(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const TextSpan(
                                      text: '  تومان  ',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              )
                            else
                              LoadingAnimationWidget.staggeredDotsWave(
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            !await launchUrl(
                                Uri.parse('https://panel.arvancloud.ir/'));
                          },
                          icon: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.add_square_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'افزایش',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (type == 1)
            Column(
              children: [
                Neumorphic(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  style: NeumorphicStyle(
                    color: Colors.white,
                    shadowDarkColor: Colors.black,
                    depth: 5,
                    intensity: 0.4,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Iconsax.finger_scan_outline),
                        title: const Text('ورود با احراز هویت'),
                        minLeadingWidth: 0,
                        trailing: NeumorphicSwitch(
                          height: 30,
                          style: const NeumorphicSwitchStyle(
                            activeTrackColor: Colors.blue,
                            inactiveTrackColor: Colors.transparent,
                            trackDepth: -5,
                            thumbDepth: 10,
                          ),
                          value: fingerPrint,
                          onChanged: (value) async {
                            if (value) {
                              final response = await Auth.isAuthenticate(
                                title: 'احراز هویت',
                                description: 'برای ادامه باید احراز هویت شوید',
                                noAuthMethodsReturn: AuthResult.auth,
                              );
                              if (response.isAuthenticated) {
                                saveFingerPermission(permissionState: value);
                                fingerPrint = response.isAuthenticated;
                              } else {
                                fingerPrint = response.isAuthenticated;
                              }
                              setState(() {});
                            } else {
                              saveFingerPermission(permissionState: value);
                              setState(() {
                                fingerPrint = value;
                              });
                            }
                          },
                        ),
                      ),
                      // ListTile(
                      //   leading: const Icon(Iconsax.moon_outline),
                      //   title: const Text('حالت شب'),
                      //   minLeadingWidth: 0,
                      //   trailing: NeumorphicSwitch(
                      //     height: 30,
                      //     style: const NeumorphicSwitchStyle(
                      //         activeTrackColor: Colors.red,
                      //         inactiveTrackColor: Colors.transparent,
                      //         trackDepth: -5,
                      //         thumbDepth: 10),
                      //     value: darkTheme,
                      //     onChanged: (value) {
                      //       if (value) {
                      //         setState(() {
                      //           darkTheme = value;
                      //         });
                      //       } else {
                      //         setState(() {
                      //           darkTheme = value;
                      //         });
                      //       }
                      //     },
                      //   ),
                      // ),
                      ListTile(
                        leading: const Icon(Iconsax.arrow_up_1_outline),
                        title: const Text('بررسی بروزرسانی'),
                        minLeadingWidth: 0,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UpdateScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Neumorphic(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  style: NeumorphicStyle(
                    color: Colors.transparent,
                    shadowDarkColor: Colors.black,
                    depth: 5,
                    intensity: 0.4,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Iconsax.info_circle_outline),
                        title: const Text('درباره برنامه'),
                        minLeadingWidth: 0,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InfoScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Iconsax.mobile_programming_outline),
                        title: const Text('توسعه دهندگان'),
                        minLeadingWidth: 0,
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DevelopScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Neumorphic(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  style: NeumorphicStyle(
                    color: Colors.red,
                    shadowDarkColor: Colors.black,
                    depth: 5,
                    intensity: 0.4,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Iconsax.logout_1_outline,
                          color: Colors.white,
                        ),
                        title: const Text(
                          'خروج از حساب کاربری',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: const Icon(
                          Iconsax.arrow_left_2_outline,
                          color: Colors.white,
                        ),
                        minLeadingWidth: 0,
                        onTap: () {
                          resetSession();
                          user = User();
                          lastLogUser = null;
                          Navigator.pushReplacementNamed(
                              context, SplashScreen.routeName);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (type == 2)
            Column(
              children: [
                Neumorphic(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  style: NeumorphicStyle(
                    color: Colors.white,
                    shadowDarkColor: Colors.black,
                    depth: 5,
                    intensity: 0.4,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  ),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(CupertinoIcons.group),
                              const SizedBox(width: 5),
                              Text(
                                'گروه ${user.group!.name}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'اعضای گروه',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      decoration: DottedDecoration(
                        shape: Shape.line,
                        linePosition: LinePosition.top,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    if (groupMate != null)
                      ListTile(
                        leading: const Icon(
                          Iconsax.emoji_happy_outline,
                          size: 20,
                        ),
                        title: Row(
                          children: [
                            Text(
                              '${user.sirName} ',
                              style: const TextStyle(fontSize: 15),
                            ),
                            const Icon(
                              Iconsax.verify_bold,
                              size: 22,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    if (groupMate != null)
                      for (var mate in groupMate!)
                        ListTile(
                          leading: const Icon(
                            Iconsax.emoji_happy_outline,
                            size: 20,
                          ),
                          title: Text(
                            '${mate.sirName}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Theme.of(context).primaryColor,
                              size: 40,
                            ),
                          )
                        ],
                      ),
                  ]),
                ),
                Neumorphic(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  style: NeumorphicStyle(
                    color: Colors.white,
                    shadowDarkColor: Colors.black,
                    depth: 5,
                    intensity: 0.4,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Iconsax.messages_outline),
                        title: const Text('آخرین فعالیت'),
                        subtitle: lastLogUser != null
                            ? lastLogUser!.code != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 5),
                                      Text(
                                        '${operation[lastLogUser!.operation]}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        lastLogUser!.registerTime!
                                            .substring(0, 19)
                                            .replaceAll('-', '/')
                                            .replaceAll(' ', '  -  ')
                                            .toPersianDigit(),
                                        textDirection: TextDirection.ltr,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  )
                                : const Text('اطلاعاتی یافت نشد')
                            : const Text('در حال بارگزاری . . .'),
                        trailing: IconButton(
                          onPressed: () async {
                            if (lastLogUser != null) {
                              await logInfo(code: lastLogUser!.code!);
                            }
                          },
                          tooltip: 'جزئیات',
                          icon: const Icon(Iconsax.info_circle_outline),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
