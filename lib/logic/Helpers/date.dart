import 'package:persian_datetime_picker/persian_datetime_picker.dart';

Jalali strToJalaliDate(String str) {
  Jalali jalalDate = Jalali.now();

  if (str.length > 15) {
    var date = str.substring(0, 10).split('-');
    var time = str.split('T')[1].substring(0, 8).split(':');

    jalalDate = Jalali(
      int.parse(date[0]),
      int.parse(date[1]),
      int.parse(date[2]),
      int.parse(time[0]),
      int.parse(time[1]),
      int.parse(time[2]),
    );
  } else {
    var date = str.substring(0, 10).split('-');

    jalalDate = Jalali(
      int.parse(date[0]),
      int.parse(date[1]),
      int.parse(date[2]),
    );
  }
  return jalalDate;
}
