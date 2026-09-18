import 'dart:io';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Constant/urls.dart';
import '../../../Data/Api/api.dart';
import '../../../Data/App/dynamic_data.dart';
import '../../../Data/Models/cheque.dart';
import '../../../Data/Models/entry/entry.dart';
import '../../../Data/Models/installment/installment.dart';
import '../../../Data/Models/last_log.dart';
import '../../../Data/Models/log/log.dart';
import '../../../Data/Models/notif/notif.dart';
import '../../../Data/Models/output/output.dart';
import '../../../Data/Models/server.dart';
import '../../../Data/Models/tag.dart';
import '../../../Data/Models/transaction.dart';
import '../../../Data/Models/user/user.dart';
import '../../../Presentation/Screens/login.dart';
import '../../../Presentation/Screens/navigation.dart';
import '../SharedPreferences/shared_preferences.dart';
import 'status_handler.dart';

Future checkSession({required context}) async {
  String? session = await getSession();
  if (session != null) {
    try {
      Response response = await Api().checkSession();

      await statusHandler(context, response);

      if (response.data['Status'] == 200) {
        user = User.fromMap(response.data['User']);

        await saveSession(session: user.session!);

        Navigator.pushReplacementNamed(context, NavigationScreen.routeName);

        return true;
      } else {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        return false;
      }
    } catch (e) {
      DelightToastBar(
        autoDismiss: true,
        position: DelightSnackbarPosition.top,
        snackbarDuration: const Duration(milliseconds: 2500),
        builder: (context) => const ToastCard(
          color: Colors.orange,
          leading: Icon(
            Iconsax.warning_2_outline,
            size: 28,
            color: Colors.white,
          ),
          title: Text(
            'اتصال به اینترنت را بررسی و مجدد تلاش نمایید',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ).show(context);
      return false;
    }
  } else {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    return false;
  }
}

Future login({
  required String username,
  required String password,
  required context,
}) async {
  try {
    Response response = await Api().login(
      username: username,
      password: password,
    );

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      user = User.fromMap(response.data['User']);

      await saveSession(session: user.session!);

      Navigator.pushReplacementNamed(context, NavigationScreen.routeName);

      return true;
    } else {
      return false;
    }
  } catch (e) {
    DelightToastBar(
      autoDismiss: true,
      position: DelightSnackbarPosition.top,
      snackbarDuration: const Duration(milliseconds: 2500),
      builder: (context) => const ToastCard(
        color: Colors.orange,
        leading: Icon(Iconsax.warning_2_outline, size: 28, color: Colors.white),
        title: Text(
          'اتصال به اینترنت را بررسی و مجدد تلاش نمایید',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ).show(context);
    return null;
  }
}

Future getGroupMate({required context}) async {
  List<User> groupMate = [];
  try {
    Response response = await Api().getGroupMate();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var item in response.data['User']) {
        groupMate.add(User.fromMap(item));
      }

      return groupMate;
    } else {
      return groupMate;
    }
  } catch (e) {}
}

Future getSmsPanelInfo({required context}) async {
  try {
    Response response = await Api().getSmsPanelInfo();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return (response.data['Data']).toInt();
    } else {}
  } catch (e) {}
}

Future getServerInfo() async {
  try {
    Response response = await Api().getServerInfo();

    if (response.data['Status'] == 200) {
      return Server.fromMap(response.data['Server']);
    } else {
      return Server;
    }
  } catch (e) {}
}

Future getProfileInfo({required context}) async {
  try {
    Response response = await Api().getProfileInfo();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      lastLogUser = LastLog.fromMap(response.data['NewestLog']);
      user = User.fromMap(response.data['User']);

      user.profile =
          '${response.data['User']['Profile']}?${DateTime.now().millisecond}';

      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future editProfile({
  required String? sirName,
  required String? currentPassword,
  required String? newPassword,
  required String? retypeNewPassword,
  required XFile? profileImage,
  required context,
}) async {
  EasyLoading.show();
  try {
    Response response = await Api().editProfile(
      sirName: sirName,
      currentPassword: currentPassword,
      newPassword: newPassword,
      retypeNewPassword: retypeNewPassword,
      profileImage: profileImage,
    );

    await statusHandler(context, response);

    EasyLoading.dismiss();

    if (response.data['Status'] == 200) {
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
            'اطلاعات با موفقیت تغییر یافت',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ).show(context);

      await getProfileInfo(context: context);

      user.profile =
          '${response.data['User']['Profile']}?${DateTime.now().millisecond}';

      return true;
    } else if (response.data['Status'] == 401) {
      DelightToastBar(
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        snackbarDuration: const Duration(milliseconds: 2500),
        builder: (context) => const ToastCard(
          color: Colors.red,
          leading: Icon(
            Iconsax.info_circle_outline,
            size: 28,
            color: Colors.white,
          ),
          title: Text(
            'رمز عبور درست وارد نشده است',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ).show(context);
      return false;
    } else if (response.data['Status'] == 403) {
      DelightToastBar(
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        snackbarDuration: const Duration(milliseconds: 2500),
        builder: (context) => const ToastCard(
          color: Colors.red,
          leading: Icon(
            Iconsax.info_circle_outline,
            size: 28,
            color: Colors.white,
          ),
          title: Text(
            'رمز عبور  درست وارد نشده است',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ).show(context);
      return false;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future getLogList({
  required int from,
  required int to,
  required String? phrase,
  required int? userCode,
  required int? operation,
  required String? fromDate,
  required String? toDate,
  required context,
}) async {
  List<Log> logList = [];
  try {
    Response response = await Api().getLogList(
      from: from,
      to: to,
      phrase: phrase,
      userCode: userCode,
      operation: operation,
      fromDate: fromDate,
      toDate: toDate,
    );

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var log in response.data['Log']) {
        logList.add(Log.fromMap(log));
      }

      return [logList, response.data['Count']];
    } else {
      return [logList, 0];
    }
  } catch (e) {
    return [logList, 0];
  }
}

Future getLogInfo({required int code, required context}) async {
  EasyLoading.show();
  try {
    Response response = await Api().getLogInfo(code: code);
    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      Log log = Log.fromMap(response.data['Log']);

      return log;
    } else {}
  } catch (e) {
    EasyLoading.dismiss();
  }
}

Future setCheque({
  required int typeCheque,
  required String displayName,
  required String price,
  required String whatAbout,
  required String from,
  required String to,
  required String? description,
  required String dueDate,
  required String warningDate,
  required File? image,
  required context,
}) async {
  EasyLoading.show();

  try {
    Response response = await Api().setCheque(
      typeCheque: typeCheque,
      displayName: displayName,
      price: price,
      whatAbout: whatAbout,
      from: from,
      to: to,
      description: description,
      dueDate: dueDate,
      warningDate: warningDate,
      image: image,
    );

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();

    return false;
  }
}

Future editCheque({
  required int code,
  required int? typeCheque,
  required String? displayName,
  required String? price,
  required String? whatAbout,
  required String? from,
  required String? to,
  required String? description,
  required String? dueDate,
  required String? warningDate,
  required File? image,
  required context,
}) async {
  EasyLoading.show();

  try {
    Response response = await Api().editCheque(
      code: code,
      typeCheque: typeCheque,
      displayName: displayName,
      price: price,
      whatAbout: whatAbout,
      from: from,
      to: to,
      description: description,
      dueDate: dueDate,
      warningDate: warningDate,
      image: image,
    );

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();

    return false;
  }
}

Future getChequeList({
  required int from,
  required int to,
  required String? phrase,
  required int? typeCheque,
  required String? dueDate,
  required String? warningDate,
  required String? price,
  required context,
}) async {
  try {
    List<Cheque> chequeList = [];
    Response response = await Api().getChequeList(
      from: from,
      to: to,
      phrase: phrase,
      typeCheque: typeCheque,
      dueDate: dueDate,
      warningDate: warningDate,
      price: price,
    );

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var cheque in response.data['Cheque']) {
        chequeList.add(Cheque.fromMap(cheque));
      }

      return [chequeList, response.data['Count']];
    } else {
      return [chequeList, 0];
    }
  } catch (e) {}
}

Future getChequeInfo({required int code, required context}) async {
  try {
    EasyLoading.show();

    List<Log> logList = [];
    Response response = await Api().getChequeInfo(code: code);

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var log in response.data['Log'] ?? []) {
        logList.add(Log.fromMap(log));
      }

      Cheque cheque = Cheque.fromMap(response.data['Cheque']);

      return [cheque, logList];
    } else {}
  } catch (e) {
    EasyLoading.dismiss();
  }
}

Future setInstallment({
  required String displayName,
  required String price,
  required String startTime,
  required List<String> dueDate,
  required String? description,
  required context,
}) async {
  try {
    EasyLoading.show();

    Response response = await Api().setInstallment(
      displayName: displayName,
      price: price,
      startTime: startTime,
      dueDate: dueDate,
      description: description,
    );

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();

    return false;
  }
}

Future editInstallment({
  required int code,
  required String? displayName,
  required String? price,
  required String? startTime,
  required List<String>? dueDate,
  required String? description,
  required context,
}) async {
  EasyLoading.show();

  try {
    Response response = await Api().editInstallment(
      code: code,
      displayName: displayName,
      price: price,
      startTime: startTime,
      dueDate: dueDate,
      description: description,
    );

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();

    return false;
  }
}

Future getInstallmentList({
  required int from,
  required int to,
  required String? phrase,
  required String? startTime,
  required String? price,
  required context,
}) async {
  List<Installment> installmentList = [];
  try {
    Response response = await Api().getInstallmentList(
      from: from,
      to: to,
      phrase: phrase,
      startTime: startTime,
      price: price,
    );

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var installment in response.data['Installment']) {
        installmentList.add(Installment.fromMap(installment));
      }
      return [installmentList, response.data['Count']];
    } else {
      return [installmentList, 0];
    }
  } catch (e) {}
}

Future getInstallmentInfo({required int code, required context}) async {
  EasyLoading.show();

  try {
    List<Log> logList = [];
    Response response = await Api().getInstallmentInfo(code: code);

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var log in response.data['Log'] ?? []) {
        logList.add(Log.fromMap(log));
      }

      Installment installment = Installment.fromMap(
        response.data['Installment'],
      );

      return [installment, logList];
    } else {}
  } catch (e) {
    EasyLoading.dismiss();
  }
}

Future getTypeOfEntry({required context}) async {
  List<Tag> entryTag = [];
  try {
    Response response = await Api().getTypeOfEntry();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var item in response.data['Type']) {
        entryTag.add(Tag.fromMap(item));
      }
      return entryTag;
    } else {
      return entryTag;
    }
  } catch (e) {}
}

Future addTypeOfEntry({required context, required String name}) async {
  try {
    Response response = await Api().addTypeOfEntry(name: name);
    await statusHandler(context, response);
    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    // Nothing to do.
  }
}

Future editTypeOfEntry({
  required context,
  required int code,
  required String name,
}) async {
  try {
    Response response = await Api().editTypeOfEntry(code: code, name: name);
    await statusHandler(context, response);
    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {}
}

Future deleteTypeOfEntry({required context, required int code}) async {
  try {
    Response response = await Api().deleteTypeOfEntry(code: code);
    await statusHandler(context, response);
    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {}
}

Future getTypeOfOutput({required context}) async {
  List<Tag> outputTag = [];
  try {
    Response response = await Api().getTypeOfOutput();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var item in response.data['Type']) {
        outputTag.add(Tag.fromMap(item));
      }
      return outputTag;
    } else {
      return outputTag;
    }
  } catch (e) {}
}

Future addTypeOfOutput({required context, required String name}) async {
  try {
    Response response = await Api().addTypeOfOutput(name: name);
    await statusHandler(context, response);
    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {}
}

Future editTypeOfOutput({
  required context,
  required int code,
  required String name,
}) async {
  try {
    Response response = await Api().editTypeOfOutput(code: code, name: name);
    await statusHandler(context, response);
    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {}
}

Future deleteTypeOfOutput({required context, required int code}) async {
  try {
    Response response = await Api().deleteTypeOfOutput(code: code);
    await statusHandler(context, response);
    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {}
}

// Future getReasonOfOutput() async {
//   List<Tag> reasonOfOutputTag = [];
//   try {
//     Response response = await Api().getReasonOfOutput();
//
//     print(response);
//
//     if (response.data['Status'] == 200) {
//       for (var item in response.data['Reason']) {
//         reasonOfOutputTag.add(Tag.fromMap(item));
//       }
//       return reasonOfOutputTag;
//     } else {
//       return reasonOfOutputTag;
//     }
//   } catch (e) {}
// }

Future setEntry({
  required String displayName,
  required String price,
  required int typeCode,
  required String dueDateTime,
  required String? description,
  required File? file,
  required context,
}) async {
  EasyLoading.show();

  try {
    Response response = await Api().setEntry(
      displayName: displayName,
      price: price,
      typeCode: typeCode,
      description: description,
      file: file,
      dueDateTime: dueDateTime,
    );

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();

    return false;
  }
}

Future editEntry({
  required int code,
  required String? displayName,
  required String? price,
  required int? typeCode,
  required String? description,
  required File? file,
  required String dueDateTime,
  required context,
}) async {
  EasyLoading.show();
  try {
    Response response = await Api().editEntry(
      code: code,
      displayName: displayName,
      price: price,
      typeCode: typeCode,
      description: description,
      file: file,
      dueDateTime: dueDateTime,
    );

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();

    return false;
  }
}

Future deleteEntry({required int code, required context}) async {
  EasyLoading.show();

  try {
    Response response = await Api().deleteEntry(code: code);

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();

    return false;
  }
}

Future getEntryList({
  required int from,
  required int to,
  required String? phrase,
  required int? typeEntry,
  required String? price,
  required context,
}) async {
  List<Entry> entryList = [];
  try {
    Response response = await Api().getEntryList(
      from: from,
      to: to,
      phrase: phrase,
      typeEntry: typeEntry,
      price: price,
    );

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var entry in response.data['Entry']) {
        entryList.add(Entry.fromMap(entry));
      }
      return [entryList, response.data['Count']];
    } else {
      return [entryList, 0];
    }
  } catch (e) {}
}

Future getEntryInfo({required int code, required context}) async {
  EasyLoading.show();

  try {
    List<Log> logList = [];
    Response response = await Api().getEntryInfo(code: code);

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      Entry entry = Entry.fromMap(response.data['Entry']);

      for (var log in response.data['Log'] ?? []) {
        logList.add(Log.fromMap(log));
      }
      return [entry, logList];
    } else {}
  } catch (e) {
    EasyLoading.dismiss();
  }
}

Future setOutput({
  required String displayName,
  required String price,
  required int typeOutput,
  required String dueDateTime,
  // required int reasonOutput,
  required String? description,
  required File? file,
  required context,
}) async {
  EasyLoading.show();

  try {
    Response response = await Api().setOutput(
      displayName: displayName,
      price: price,
      typeOutput: typeOutput,
      // reasonOutput: reasonOutput,
      description: description,
      file: file,
      dueDateTime: dueDateTime,
    );

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();
    return false;
  }
}

Future editOutput({
  required int code,
  required String? displayName,
  required String? price,
  required int? typeOutput,
  // required int? reasonOutput,
  required String? description,
  required File? file,
  required String dueDateTime,
  required context,
}) async {
  EasyLoading.show();

  try {
    Response response = await Api().editOutput(
      code: code,
      displayName: displayName,
      price: price,
      typeOutput: typeOutput,
      // reasonOutput: reasonOutput,
      description: description,
      file: file,
      dueDateTime: dueDateTime,
    );

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();
    return false;
  }
}

Future deleteOutput({required int code, required context}) async {
  EasyLoading.show();

  try {
    Response response = await Api().deleteOutput(code: code);

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();
    return false;
  }
}

Future getOutputList({
  required int from,
  required int to,
  required String? phrase,
  required int? typeOutput,
  // required int? reasonOutput,
  required String? price,
  required context,
}) async {
  List<Output> outputList = [];
  try {
    Response response = await Api().getOutputList(
      from: from,
      to: to,
      phrase: phrase,
      typeOutput: typeOutput,
      // reasonOutput: reasonOutput,
      price: price,
    );

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var output in response.data['Output']) {
        outputList.add(Output.fromMap(output));
      }

      return [outputList, response.data['Count']];
    } else {
      return [outputList, 0];
    }
  } catch (e) {}
}

Future getOutputInfo({required int code, required context}) async {
  EasyLoading.show();

  try {
    List<Log> logList = [];
    Response response = await Api().getOutputInfo(code: code);

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      Output output = Output.fromMap(response.data['Output']);

      for (var log in response.data['Log'] ?? []) {
        logList.add(Log.fromMap(log));
      }

      return [output, logList];
    } else {}
  } catch (e) {
    EasyLoading.dismiss();
  }
}

Future getReport({
  required String fromDate,
  required String toDate,
  required String? filterBy,
  required List<int>? typeOfFilter,
  required context,
}) async {
  EasyLoading.show();

  List<Transaction> report = [];
  String? reportFileUrl;
  try {
    Response response = await Api().getReport(
      fromDate: fromDate,
      toDate: toDate,
      filterBy: filterBy,
      typeOfFilter: typeOfFilter,
    );

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var transaction in response.data['List'] ?? []) {
        report.add(Transaction.fromMap(transaction));
      }
      if (response.data['File'] != null) {
        reportFileUrl = Urls.hostUrl + response.data['File'];
      }

      return [report, reportFileUrl];
    } else {
      return [report, reportFileUrl];
    }
  } catch (e) {
    EasyLoading.dismiss();
  }
}

Future getResultLast7day({required context}) async {
  try {
    Response response = await Api().getResultLast7day();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return response.data['7dayAgo'];
    } else {
      return null;
    }
  } catch (e) {}
}

Future getInfoHomePage({required context}) async {
  try {
    Response response = await Api().getInfoHomePage();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return [
        response.data['Result7DayAgo'],
        response.data['Result30DayAgo'],
        response.data['ResultAll'],
      ];
    } else {
      return [0, 0, 0];
    }
  } catch (e) {}
}

Future getNotificationList({
  required int from,
  required int to,
  required context,
}) async {
  List<Notif> notificationList = [];
  try {
    Response response = await Api().getNotificationList(from: from, to: to);

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      for (var notification in response.data['Notif']) {
        notificationList.add(Notif.fromMap(notification));
      }
      return [notificationList, response.data['Count']];
    } else {
      return [notificationList, 0];
    }
  } catch (e) {}
}

Future setAsReadNotification({required int code, required context}) async {
  EasyLoading.show();

  try {
    Response response = await Api().setAsReadNotification(code: code);

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();

    return false;
  }
}

Future checkVersion({required String appVersion, required context}) async {
  try {
    Response response = await Api().checkVersion(appVersion: appVersion);

    await statusHandler(context, response);

    if (response.data['Status'] == 401) {
      return response.data['App'];
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future getUpcomingEvent({required context, required int? day}) async {
  List<Cheque> upcomingCheque = [];
  List<Installment> upcomingInstallment = [];
  try {
    Response response = await Api().getUpcomingEvent(day: day);

    await statusHandler(context, response);


    if (response.data['Status'] == 200) {
      if (response.data['Cheque'] != null) {
        for (var cheque in response.data['Cheque']) {
          upcomingCheque.add(Cheque.fromMap(cheque));
        }
      }
      if (response.data['Installment'] != null) {
        for (var installment in response.data['Installment']) {
          upcomingInstallment.add(Installment.fromMap(installment));
        }
      }
      return [upcomingCheque, upcomingInstallment];
    } else {
      return [[], []];
    }
  } catch (e) {
    return null;
  }
}

Future changeStatusIsPaidInstallment({
  required int code,
  required context,
}) async {
  EasyLoading.show();

  try {
    Response response = await Api().changeStatusIsPaidInstallment(code: code);

    EasyLoading.dismiss();

    await statusHandler(context, response);

    if (response.data['Status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    EasyLoading.dismiss();

    return false;
  }
}
