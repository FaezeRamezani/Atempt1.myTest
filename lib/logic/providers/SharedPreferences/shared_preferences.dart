import 'package:shared_preferences/shared_preferences.dart';

import '../../../Data/App/dynamic_data.dart';

Future saveSession({required String session}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('session', session);
  return true;
}

Future getSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  user.session = prefs.getString('session');
  return user.session;
}

Future saveFingerPermission({required bool permissionState}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('fingerPermission', permissionState);
  return permissionState;
}

Future getFingerPermission() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('fingerPermission') ?? false;
}

Future resetSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.clear();
}
