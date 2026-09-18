import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import '../../Data/Models/tag.dart';
import '../../logic/providers/Api/api_connection.dart';

class CategoryScreen extends StatefulWidget {
  static String routeName = '/category';

  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  //
  PageController pageController = PageController(initialPage: 0);
  int typeOfTransaction = 1;

  List<Tag>? entryTag;
  List<Tag>? outputTag;

  Future getTypes() async {
    entryTag = await getTypeOfEntry(context: context);
    setState(() {});
    outputTag = await getTypeOfOutput(context: context);
    setState(() {});
  }

  Future showAddCategoryDialog() async {
    TextEditingController textEditingController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, changeState) {
            return AlertDialog(
              title: typeOfTransaction == 1
                  ? Text('افزودن دسته دخل')
                  : Text('افزودن دسته خرج'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: 'نام دسته',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (val) {
                      changeState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: const Text(
                    'انصراف',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed:
                      textEditingController.text.trim().isNotEmpty &&
                          textEditingController.text.trim().length > 1
                      ? () async {
                          bool exists = false;
                          if (typeOfTransaction == 1) {
                            // Entry
                            exists =
                                entryTag?.any(
                                  (item) =>
                                      item.name?.trim() ==
                                      textEditingController.text.trim(),
                                ) ??
                                false;
                          } else {
                            // Output

                            exists =
                                outputTag?.any(
                                  (item) =>
                                      item.name?.trim() ==
                                      textEditingController.text.trim(),
                                ) ??
                                false;
                          }
                          if (exists) {
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
                                  'نام دسته تکراری است.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ).show(context);
                          } else {
                            EasyLoading.show();
                            bool result;
                            if (typeOfTransaction == 1) {
                              result = await addTypeOfEntry(
                                context: context,
                                name: textEditingController.text,
                              );
                            } else {
                              result = await addTypeOfOutput(
                                context: context,
                                name: textEditingController.text,
                              );
                            }
                            if (result) {
                              await getTypes();
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
                                    'دسته با موفقیت اضافه شد',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ).show(context);
                            } else {
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
                                    'خطا در اضافه کردن دسته',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ).show(context);
                            }
                            Navigator.pop(context);
                            EasyLoading.dismiss();

                          }
                        }
                      : null,
                  style: TextButton.styleFrom(
                    disabledBackgroundColor: Colors.grey.shade400,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'ثبت',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future showEditCategoryDialog({required Tag tag}) async {
    TextEditingController textEditingController = TextEditingController(
      text: tag.name,
    );
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, changeState) {
            return AlertDialog(
              title: typeOfTransaction == 1
                  ? Text('ویرایش دسته دخل')
                  : Text('ویرایش دسته خرج'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: 'نام دسته',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (val) {
                      changeState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: const Text(
                    'انصراف',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed:
                      textEditingController.text.trim().isNotEmpty &&
                          textEditingController.text.trim().length > 1
                      ? () async {
                          bool exists = false;
                          if (typeOfTransaction == 1) {
                            // Entry
                            exists =
                                entryTag?.any(
                                  (item) =>
                                      item.name?.trim() ==
                                      textEditingController.text.trim(),
                                ) ??
                                false;
                          } else {
                            // Output

                            exists =
                                outputTag?.any(
                                  (item) =>
                                      item.name?.trim() ==
                                      textEditingController.text.trim(),
                                ) ??
                                false;
                          }
                          if (exists) {
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
                                  'نام دسته تکراری است.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ).show(context);
                          } else {
                            EasyLoading.show();
                            bool result;
                            if (typeOfTransaction == 1) {
                              result = await editTypeOfEntry(
                                context: context,
                                code: tag.code!,
                                name: textEditingController.text,
                              );
                            } else {
                              result = await editTypeOfOutput(
                                context: context,
                                code: tag.code!,
                                name: textEditingController.text,
                              );
                            }
                            if (result) {
                              await getTypes();
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
                                    'دسته با موفقیت ویرایش شد',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ).show(context);
                            } else {
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
                                    'خطا در ویرایش دسته',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ).show(context);
                            }
                            Navigator.pop(context);
                            EasyLoading.dismiss();

                          }
                        }
                      : null,
                  style: TextButton.styleFrom(
                    disabledBackgroundColor: Colors.grey.shade400,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'ویرایش',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future showDeleteCategoryDialog({required Tag tag}) async {
    TextEditingController textEditingController = TextEditingController(
      text: tag.name,
    );
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, changeState) {
            return AlertDialog(
              title: typeOfTransaction == 1
                  ? Text('حذف دسته دخل')
                  : Text('حذف دسته خرج'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'با این کار این دسته بندی و تراکنش های مرتبط با آن حذف می شوند آیا اطمینان دارید ؟!؟',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: const Text(
                    'انصراف',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    EasyLoading.show();
                    bool result;
                    if (typeOfTransaction == 1) {
                      result = await deleteTypeOfEntry(
                        context: context,
                        code: tag.code!,
                      );
                    } else {
                      result = await deleteTypeOfOutput(
                        context: context,
                        code: tag.code!,
                      );
                    }

                    if (result) {
                      await getTypes();
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
                            'دسته با موفقیت حذف شد',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ).show(context);
                    } else {
                      DelightToastBar(
                        position: DelightSnackbarPosition.top,
                        autoDismiss: true,
                        snackbarDuration: const Duration(milliseconds: 2500),
                        builder: (context) => const ToastCard(
                          color: Colors.red,
                          leading: Icon(
                            Iconsax.warning_2_outline,
                            size: 28,
                            color: Colors.white,
                          ),
                          title: Text(
                            'خطا در حذف دسته',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ).show(context);
                    }
                    Navigator.pop(context);
                    EasyLoading.dismiss();
                  },
                  style: TextButton.styleFrom(
                    disabledBackgroundColor: Colors.grey.shade400,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'بله حذف شود',
                    style: TextStyle(color: Colors.white),
                  ),
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
    // TODO: implement initState
    super.initState();
    getTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_outline),
          tooltip: 'بازگشت',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text('دسته بندی ها'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 45),
              Expanded(
                child: PageView(
                  controller: pageController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    entryTag != null
                        ? entryTag!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    children: [
                                      for (int i = 0; i < entryTag!.length; i++)
                                        PopupMenuButton(
                                          style:  OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          ),
                                          color: Colors.white,
                                          icon: Card(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            color: Colors.teal.shade100,
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 5,
                                              horizontal: 5,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 15,
                                                  ),
                                              child: Text(
                                                '${entryTag![i].name}'
                                                    .toPersianDigit(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.teal,
                                                ),
                                              ),
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          tooltip: 'گزینه های بیشتر',
                                          itemBuilder: (BuildContext context) {
                                            return [
                                              PopupMenuItem(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                      ),
                                                  child: Text(
                                                    '${entryTag![i].name}',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              PopupMenuItem(
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Iconsax.edit_outline,
                                                      color: Colors.lightBlue,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'ویرایش دسته بندی',
                                                      style: TextStyle(
                                                        color: Colors.lightBlue,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () =>
                                                    showEditCategoryDialog(
                                                      tag: entryTag![i],
                                                    ),
                                              ),
                                              PopupMenuItem(
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Iconsax.trash_outline,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'حذف دسته بندی',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () =>
                                                    showDeleteCategoryDialog(
                                                      tag: entryTag![i],
                                                    ),
                                              ),
                                            ];
                                          },
                                        ),
                                    ],
                                  ),
                                )
                              : const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Iconsax.category_2_outline,
                                        size: 40,
                                      ),
                                      SizedBox(height: 15),
                                      Text('دسته بندی وجود ندارد !'),
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
                                const Text('در حال بارگزاری دسته بندی ها'),
                              ],
                            ),
                          ),
                    outputTag != null
                        ? outputTag!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    children: [
                                      for (
                                        int i = 0;
                                        i < outputTag!.length;
                                        i++
                                      )
                                        PopupMenuButton(
                                          style:  OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          ),
                                          color: Colors.white,
                                          icon: Card(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            color: Colors.red.shade100,
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 5,
                                              horizontal: 5,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 15,
                                                  ),
                                              child: Text(
                                                '${outputTag![i].name}'
                                                    .toPersianDigit(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          tooltip: 'گزینه های بیشتر',
                                          itemBuilder: (BuildContext context) {
                                            return [
                                              PopupMenuItem(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                      ),
                                                  child: Text(
                                                    '${outputTag![i].name}',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              PopupMenuItem(
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Iconsax.edit_outline,
                                                      color: Colors.lightBlue,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'ویرایش دسته بندی',
                                                      style: TextStyle(
                                                        color: Colors.lightBlue,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () =>
                                                    showEditCategoryDialog(
                                                      tag: outputTag![i],
                                                    ),
                                              ),
                                              PopupMenuItem(
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Iconsax.trash_outline,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'حذف دسته بندی',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () =>
                                                    showDeleteCategoryDialog(
                                                      tag: outputTag![i],
                                                    ),
                                              ),
                                            ];
                                          },
                                        ),
                                    ],
                                  ),
                                )
                              : const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Iconsax.category_2_outline,
                                        size: 40,
                                      ),
                                      SizedBox(height: 15),
                                      Text('دسته بندی وجود ندارد !'),
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
                                const Text('در حال بارگزاری دسته بندی ها'),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: NeumorphicToggle(
              style: NeumorphicToggleStyle(
                //depth: 50,
                backgroundColor: typeOfTransaction == 1
                    ? Colors.teal.withValues(alpha: 0.4)
                    : Colors.red.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(15),
              ),
              selectedIndex: typeOfTransaction,
              thumb: Center(
                child: Container(color: Colors.white.withValues(alpha: 0.2)),
              ),
              children: [
                ToggleElement(
                  foreground: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.direct_inbox_outline),
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
                          Iconsax.direct_inbox_outline,
                          color: Colors.teal.shade700,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'دخل',
                          style: TextStyle(color: Colors.teal.shade700),
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
                        Icon(Iconsax.direct_send_outline),
                        SizedBox(width: 5),
                        Text('خرج'),
                      ],
                    ),
                  ),
                  background: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.direct_send_outline,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'خرج',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  if (value == 0) typeOfTransaction = 1;
                  if (value == 1) typeOfTransaction = 0;

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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showAddCategoryDialog();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: typeOfTransaction == 1
            ? Colors.teal.shade400
            : Colors.red.shade400,
        child: const Icon(Iconsax.add_outline, size: 30, color: Colors.white),
      ),
    );
  }
}
