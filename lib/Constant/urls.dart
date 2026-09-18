import 'package:flutter_dotenv/flutter_dotenv.dart';

class Urls {
  // static String hostIp = 'http://${dotenv.env['IP']}:${dotenv.env['PORT']}';
  static String domain = '${dotenv.env['DOMAIN']}';
  static String hostUrl = 'https://${dotenv.env['DOMAIN']}';

  static String headUrl = '$hostUrl/${dotenv.env['API_ROUTE']}';

  // App Api Urls

  //******************************************************

  static String checkSessionUrl = '$headUrl/checkSession/';
  static String loginUrl = '$headUrl/login/';

  //******************************************************

  static String getGroupMateUrl = '$headUrl/getGroupMate/';
  static String getSmsPanelInfoUrl = '$headUrl/getSmsPanelInfo/';
  static String getServerInfoUrl = '$headUrl/getServerInfo/';

  //******************************************************

  static String getLogListUrl = '$headUrl/getLogList/';
  static String getLogInfoUrl = '$headUrl/getLogInfo/';

  //******************************************************

  static String getProfileInfoUrl = '$headUrl/getProfileInfo/';
  static String editProfileUrl = '$headUrl/editProfile/';

  //******************************************************

  static String setInstallmentUrl = '$headUrl/setInstallment/';
  static String editInstallmentUrl = '$headUrl/editInstallment/';
  static String getInstallmentListUrl = '$headUrl/getInstallmentList/';
  static String getInstallmentInfoUrl = '$headUrl/getInstallmentInfo/';
  static String changeStatusIsPaidInstallmentUrl = '$headUrl/changeStatusIsPaidInstallment/';

  //******************************************************

  static String setChequeUrl = '$headUrl/setCheque/';
  static String editChequeUrl = '$headUrl/editCheque/';
  static String getChequeListUrl = '$headUrl/getChequeList/';
  static String getChequeInfoUrl = '$headUrl/getChequeInfo/';

  //******************************************************

  static String getNotificationListUrl = '$headUrl/getNotificationList/';
  static String setAsReadNotificationUrl = '$headUrl/setAsReadNotification/';

  //******************************************************

  static String setEntryUrl = '$headUrl/setEntry/';
  static String editEntryUrl = '$headUrl/editEntry/';
  static String deleteEntryUrl = '$headUrl/deleteEntry/';
  static String getEntryListUrl = '$headUrl/getEntryList/';
  static String getEntryInfoUrl = '$headUrl/getEntryInfo/';

  //******************************************************

  static String setOutputUrl = '$headUrl/setOutput/';
  static String editOutputUrl = '$headUrl/editOutput/';
  static String deleteOutputUrl = '$headUrl/deleteOutput/';
  static String getOutputListUrl = '$headUrl/getOutputList/';
  static String getOutputInfoUrl = '$headUrl/getOutputInfo/';

  //******************************************************

  static String getTypeOfEntryUrl = '$headUrl/getTypeOfEntry/';
  static String addTypeOfEntryUrl = '$headUrl/addTypeOfEntry/';
  static String editTypeOfEntryUrl = '$headUrl/editTypeOfEntry/';
  static String deleteTypeOfEntryUrl = '$headUrl/deleteTypeOfEntry/';
  static String getTypeOfOutputUrl = '$headUrl/getTypeOfOutput/';
  static String addTypeOfOutputUrl = '$headUrl/addTypeOfOutput/';
  static String editTypeOfOutputUrl = '$headUrl/editTypeOfOutput/';
  static String deleteTypeOfOutputUrl = '$headUrl/deleteTypeOfOutput/';
  // static String getReasonOfOutputUrl = '$headUrl/getReasonOfOutput/';

  //******************************************************

  static String getReportUrl = '$headUrl/getReport/';
  static String getResultLast7dayUrl = '$headUrl/getResultLast7day/';
  static String getInfoHomePageUrl = '$headUrl/getInfoHomePage/';
  static String getUpcomingEventUrl = '$headUrl/getUpcomingEvent/';

  //******************************************************

  static String checkVersionUrl = '$headUrl/checkVersion/';

//******************************************************
}
