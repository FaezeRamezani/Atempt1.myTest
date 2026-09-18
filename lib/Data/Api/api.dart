import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../Constant/keys.dart';
import '../../Constant/urls.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../App/dynamic_data.dart';

Future<Options> apiHeaders({String? session}) async {
  PackageInfo appInfo = await PackageInfo.fromPlatform();
  return Options(
    headers: {
      'API-X-KEY': Keys.apiKey,
      'App-Version': appInfo.version,
      if (session != null) 'Session': session,
    },
  );
}

class Api {
  Dio request = Dio();

  Future checkSession() async {
    Response response = await request
        .get(
          Urls.checkSessionUrl,
          options: await apiHeaders(session: user.session!),
        )
        .timeout(const Duration(seconds: 5));
    return response;
  }

  Future login({required String username, required String password}) async {
    Response response = await request.post(
      Urls.loginUrl,
      options: await apiHeaders(),
      data: {'Username': username, 'Password': password},
    );
    return response;
  }

  Future getGroupMate() async {
    Response response = await request.get(
      Urls.getGroupMateUrl,
      options: await apiHeaders(session: user.session),
    );
    return response;
  }

  Future getSmsPanelInfo() async {
    Response response = await request.get(
      Urls.getSmsPanelInfoUrl,
      options: await apiHeaders(session: user.session!),
    );
    return response;
  }

  Future getServerInfo() async {
    Response response = await request.get(
      Urls.getServerInfoUrl,
      options: await apiHeaders(session: user.session!),
    );
    return response;
  }

  Future getLogList({
    required int from,
    required int to,
    required String? phrase,
    required int? userCode,
    required int? operation,
    required String? fromDate,
    required String? toDate,
  }) async {
    Response response = await request.post(
      Urls.getLogListUrl,
      options: await apiHeaders(session: user.session!),
      data: {
        'From': from,
        'To': to,
        if (phrase != null) 'Phrase': phrase.trim(),
        if (userCode != null) 'UserCode': userCode,
        if (operation != null) 'Operation': operation,
        if (fromDate != null) 'FromDate': fromDate,
        if (toDate != null) 'ToDate': toDate,
      },
    );
    return response;
  }

  Future getLogInfo({required int code}) async {
    Response response = await request.post(
      Urls.getLogInfoUrl,
      options: await apiHeaders(session: user.session!),
      data: {'Code': code},
    );
    return response;
  }

  Future getProfileInfo() async {
    Response response = await request.get(
      Urls.getProfileInfoUrl,
      options: await apiHeaders(session: user.session),
    );
    return response;
  }

  Future editProfile({
    required String? sirName,
    required String? currentPassword,
    required String? newPassword,
    required String? retypeNewPassword,
    required XFile? profileImage,
  }) async {
    FormData formData = FormData.fromMap({
      if (sirName != null) 'SirName': sirName.trim(),
      if (currentPassword != null) 'CurrentPassword': currentPassword,
      if (newPassword != null) 'NewPassword': newPassword,
      if (retypeNewPassword != null) 'RetypeNewPassword': retypeNewPassword,
      if (profileImage != null)
        'Profile': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        ),
    });
    Response response = await request.post(
      Urls.editProfileUrl,
      options: await apiHeaders(session: user.session),
      data: formData,
    );
    return response;
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
  }) async {
    FormData formData = FormData.fromMap({
      'TypeCheque': typeCheque,
      'DisplayName': displayName.trim(),
      'Price': price,
      'WhatAbout': whatAbout.trim(),
      'From': from.trim(),
      'To': to.trim(),
      if (description != null) 'Description': description.trim(),
      'DueDate': dueDate,
      'WarningDate': warningDate,
      if (image != null)
        'Image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
    });
    Response response = await request.post(
      Urls.setChequeUrl,
      options: await apiHeaders(session: user.session!),
      data: formData,
    );
    return response;
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
  }) async {
    Response response = await request.post(
      Urls.editChequeUrl,
      options: await apiHeaders(session: user.session!),
      data: {
        'Code': code,
        if (typeCheque != null) 'TypeCheque': typeCheque,
        if (displayName != null) 'DisplayName': displayName.trim(),
        if (price != null) 'Price': price,
        if (whatAbout != null) 'WhatAbout': whatAbout.trim(),
        if (from != null) 'From': from.trim(),
        if (to != null) 'To': to.trim(),
        if (description != null) 'Description': description.trim(),
        if (dueDate != null) 'DueDate': dueDate,
        if (warningDate != null) 'WarningDate': warningDate,
        if (image != null)
          'File': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      },
    );
    return response;
  }

  Future getChequeList({
    required int from,
    required int to,
    required String? phrase,
    required int? typeCheque,
    required String? dueDate,
    required String? warningDate,
    required String? price,
  }) async {
    Response response = await request.post(
      Urls.getChequeListUrl,
      options: await apiHeaders(session: user.session),
      data: {
        'From': from,
        'To': to,
        if (phrase != null) 'Phrase': phrase.trim(),
        'TypeCheque': typeCheque,
        'DueDate': dueDate,
        'WarningDate': warningDate,
        'Price': price,
      },
    );
    return response;
  }

  Future getChequeInfo({required int code}) async {
    Response response = await request.post(
      Urls.getChequeInfoUrl,
      options: await apiHeaders(session: user.session!),
      data: {'Code': code},
    );
    return response;
  }

  Future setInstallment({
    required String displayName,
    required String price,
    required String startTime,
    required List<String> dueDate,
    required String? description,
  }) async {
    Response response = await request.post(
      Urls.setInstallmentUrl,
      options: await apiHeaders(session: user.session!),
      data: {
        'DisplayName': displayName.trim(),
        'Price': price,
        'StartTime': startTime,
        'DueDate': dueDate,
        if (description != null) 'Description': description.trim(),
      },
    );
    return response;
  }

  Future editInstallment({
    required int code,
    required String? displayName,
    required String? price,
    required String? startTime,
    required List<String>? dueDate,
    required String? description,
  }) async {
    Response response = await request.post(
      Urls.editInstallmentUrl,
      options: await apiHeaders(session: user.session!),
      data: {
        'Code': code,
        if (displayName != null) 'DisplayName': displayName.trim(),
        if (price != null) 'Price': price,
        if (startTime != null) 'StartTime': startTime,
        if (dueDate != null) 'DueDate': dueDate,
        if (description != null) 'Description': description.trim(),
      },
    );
    return response;
  }

  Future getInstallmentList({
    required int from,
    required int to,
    required String? phrase,
    required String? startTime,
    required String? price,
  }) async {
    Response response = await request.post(
      Urls.getInstallmentListUrl,
      options: await apiHeaders(session: user.session!),
      data: {
        'From': from,
        'To': to,
        if (phrase != null) 'Phrase': phrase.trim(),
        if (startTime != null) 'StartTime': startTime,
        if (price != null) 'Price': price,
      },
    );
    return response;
  }

  Future<Response> getInstallmentInfo({required int code}) async {
    Response response = await request.post(
      Urls.getInstallmentInfoUrl,
      options: await apiHeaders(session: user.session!),
      data: {'Code': code},
    );
    return response;
  }

  Future setEntry({
    required String displayName,
    required String price,
    required int typeCode,
    required String dueDateTime,
    required String? description,
    required File? file,
  }) async {
    FormData formData = FormData.fromMap({
      'DisplayName': displayName.trim(),
      'Price': price,
      'TypeCode': typeCode,
      if (description != null) 'Description': description.trim(),
      if (file != null)
        'File': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      'DueDateTime': dueDateTime,
    });
    Response response = await request.post(
      Urls.setEntryUrl,
      options: await apiHeaders(session: user.session!),
      data: formData,
    );
    return response;
  }

  Future editEntry({
    required int code,
    required String? displayName,
    required String? price,
    required int? typeCode,
    required String? description,
    required String dueDateTime,
    required File? file,
  }) async {
    FormData formData = FormData.fromMap({
      'Code': code,
      if (displayName != null) 'DisplayName': displayName.trim(),
      if (price != null) 'Price': price,
      if (typeCode != null) 'TypeCode': typeCode,
      if (description != null) 'Description': description.trim(),
      if (file != null)
        'File': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      'DueDateTime': dueDateTime,
    });
    Response response = await request.post(
      Urls.editEntryUrl,
      options: await apiHeaders(session: user.session!),
      data: formData,
    );
    return response;
  }

  Future deleteEntry({required int code}) async {
    Response response = await request.post(
      Urls.deleteEntryUrl,
      options: await apiHeaders(session: user.session!),
      data: {'Code': code},
    );
    return response;
  }

  Future getEntryList({
    required int from,
    required int to,
    required String? phrase,
    required int? typeEntry,
    required String? price,
  }) async {
    Response response = await request.post(
      Urls.getEntryListUrl,
      options: await apiHeaders(session: user.session!),
      data: {
        'From': from,
        'To': to,
        if (phrase != null) 'Phrase': phrase.trim(),
        if (typeEntry != null) 'TypeEntry': typeEntry,
        if (price != null) 'Price': price,
      },
    );
    return response;
  }

  Future getEntryInfo({required int code}) async {
    Response response = await request.post(
      Urls.getEntryInfoUrl,
      options: await apiHeaders(session: user.session!),
      data: {'Code': code},
    );
    return response;
  }

  Future setOutput({
    required String displayName,
    required String price,
    required int typeOutput,
    // required int reasonOutput,
    required String? description,
    required File? file,
    required String dueDateTime,
  }) async {
    FormData formData = FormData.fromMap({
      'DisplayName': displayName.trim(),
      'Price': price,
      'TypeOutput': typeOutput,
      // 'ReasonOutput': reasonOutput,
      if (description != null) 'Description': description.trim(),
      if (file != null)
        'File': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      'DueDateTime': dueDateTime,
    });
    Response response = await request.post(
      Urls.setOutputUrl,
      options: await apiHeaders(session: user.session!),
      data: formData,
    );
    return response;
  }

  Future editOutput({
    required int code,
    required String? displayName,
    required String? price,
    required int? typeOutput,
    // required int? reasonOutput,
    required String? description,
    required String dueDateTime,
    required File? file,
  }) async {
    FormData formData = FormData.fromMap({
      'Code': code,
      if (displayName != null) 'DisplayName': displayName.trim(),
      if (price != null) 'Price': price,
      if (typeOutput != null) 'TypeCode': typeOutput,
      // if (reasonOutput != null) 'ReasonOutput': reasonOutput,
      if (description != null) 'Description': description.trim(),
      if (file != null)
        'File': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      'DueDateTime': dueDateTime,
    });
    Response response = await request.post(
      Urls.editOutputUrl,
      options: await apiHeaders(session: user.session!),
      data: formData,
    );
    return response;
  }

  Future deleteOutput({required int code}) async {
    Response response = await request.post(
      Urls.deleteOutputUrl,
      options: await apiHeaders(session: user.session!),
      data: {'Code': code},
    );
    return response;
  }

  Future getOutputList({
    required int from,
    required int to,
    required String? phrase,
    required int? typeOutput,
    // required int? reasonOutput,
    required String? price,
  }) async {
    Response response = await request.post(
      Urls.getOutputListUrl,
      options: await apiHeaders(session: user.session!),
      data: {
        'From': from,
        'To': to,
        if (phrase != null) 'Phrase': phrase.trim(),
        if (typeOutput != null) 'TypeOutput': typeOutput,
        // if (reasonOutput != null) 'ReasonOutput': reasonOutput,
        if (price != null) 'Price': price,
      },
    );
    return response;
  }

  Future getOutputInfo({required int code}) async {
    Response response = await request.post(
      Urls.getOutputInfoUrl,
      options: await apiHeaders(session: user.session!),
      data: {'Code': code},
    );
    return response;
  }

  Future getTypeOfEntry() async {
    Response response = await request.get(
      Urls.getTypeOfEntryUrl,
      options: await apiHeaders(session: user.session!),
    );
    return response;
  }

  Future addTypeOfEntry({required String name}) async {
    Response response = await request.post(
      Urls.addTypeOfEntryUrl,
      options: await apiHeaders(session: user.session),
      data: {'Name': name},
    );
    return response;
  }

  Future editTypeOfEntry({required int code, required String name}) async {
    Response response = await request.post(
      Urls.editTypeOfEntryUrl,
      options: await apiHeaders(session: user.session),
      data: {'Code': code, 'Name': name},
    );
    return response;
  }

  Future deleteTypeOfEntry({required int code}) async {
    Response response = await request.post(
      Urls.deleteTypeOfEntryUrl,
      options: await apiHeaders(session: user.session),
      data: {'Code': code},
    );
    return response;
  }

  Future getTypeOfOutput() async {
    Response response = await request.get(
      Urls.getTypeOfOutputUrl,
      options: await apiHeaders(session: user.session!),
    );
    return response;
  }

  Future addTypeOfOutput({required String name}) async {
    Response response = await request.post(
      Urls.addTypeOfOutputUrl,
      options: await apiHeaders(session: user.session),
      data: {'Name': name},
    );
    return response;
  }

  Future editTypeOfOutput({required int code, required String name}) async {
    Response response = await request.post(
      Urls.editTypeOfOutputUrl,
      options: await apiHeaders(session: user.session),
      data: {'Code': code, 'Name': name},
    );
    return response;
  }

  Future deleteTypeOfOutput({required int code}) async {
    Response response = await request.post(
      Urls.deleteTypeOfOutputUrl,
      options: await apiHeaders(session: user.session),
      data: {'Code': code},
    );
    return response;
  }

  // Future getReasonOfOutput() async {
  //   Response response = await request.get(
  //     Urls.getReasonOfOutputUrl,
  //     options: await apiHeaders(session: user.session!),
  //   );
  //   return response;
  // }

  Future getReport({
    required String fromDate,
    required String toDate,
    required String? filterBy,
    required  List<int>? typeOfFilter,
  }) async {
    Response response = await request.post(
      Urls.getReportUrl,
      options: await apiHeaders(session: user.session!),
      data: {
        'FromDate': fromDate,
        'ToDate': toDate,
        if (filterBy != null) 'FilterBy': filterBy,
        if (typeOfFilter != null) 'TypeOfFilter': typeOfFilter,
      },
    );
    return response;
  }

  Future getResultLast7day() async {
    Response response = await request.get(
      Urls.getResultLast7dayUrl,
      options: await apiHeaders(session: user.session!),
    );
    return response;
  }

  Future getInfoHomePage() async {
    Response response = await request.get(
      Urls.getInfoHomePageUrl,
      options: await apiHeaders(session: user.session!),
    );
    return response;
  }

  Future getUpcomingEvent({required int? day}) async {
    Response response = await request.post(
      Urls.getUpcomingEventUrl,
      options: await apiHeaders(session: user.session!),
      data: (day != null) ? {'Day': day} : null,
    );
    return response;
  }

  Future getNotificationList({required int from, required int to}) async {
    Response response = await request.post(
      Urls.getNotificationListUrl,
      options: await apiHeaders(session: user.session!),
      data: {'From': from, 'To': to},
    );
    return response;
  }

  Future setAsReadNotification({required int code}) async {
    Response response = await request.post(
      Urls.setAsReadNotificationUrl,
      options: await apiHeaders(session: user.session!),
      data: {'Code': code},
    );
    return response;
  }

  Future checkVersion({required String appVersion}) async {
    Response response = await request.post(
      Urls.checkVersionUrl,
      data: {'App-Version': appVersion},
      options: await apiHeaders(session: user.session),
    );
    return response;
  }

  Future changeStatusIsPaidInstallment({required int code}) async {
    Response response = await request.post(
      Urls.changeStatusIsPaidInstallmentUrl,
      options: await apiHeaders(session: user.session!),
      data: {'Code': code},
    );
    return response;
  }



  //
}
