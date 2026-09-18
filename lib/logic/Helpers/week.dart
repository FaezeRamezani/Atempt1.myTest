import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import 'date.dart';

const Map<int, String> weekDay = {
  6: 'جمعه',
  5: 'پنج شنبه',
  4: 'چهار شنبه',
  3: 'سه شنبه',
  2: 'دو شنبه',
  1: 'یک شنبه',
  0: 'شنبه',
};

Future<List> sortWeekDays(Map last7day) async {
  List indexedLast7day = [];

  double? min;
  double? max;

  weekDay.forEach((weekIndex, weekName) {
    last7day.forEach((weekDate, transactions) {
      Jalali jalali = strToJalaliDate(weekDate.toString().replaceAll('/', '-'));
      if (weekName == jalali.formatter.wN) {
        indexedLast7day.add(
          {
            'Index': weekIndex,
            'Date': weekDate,
            'WeekName': weekName,
            'Transactions': transactions,
          },
        );
      }
      if (min == null || max == null) {
        min = (transactions['Entry'] - transactions['Output']).toDouble();
        max = (transactions['Entry'] - transactions['Output']).toDouble();
      }
      if (transactions['Entry'] - transactions['Output'] < min) {
        min = (transactions['Entry'] - transactions['Output']).toDouble();
      }
      if (transactions['Entry'] - transactions['Output'] > max) {
        max = (transactions['Entry'] - transactions['Output']).toDouble();
      }
    });
  });

  if (min! < 0) {
    min = min! * -1;

    if (min! > max!) {
      max = min;
    }
  }

  if (max == 0) {
    max = 1;
  }


  return [indexedLast7day, max];
}
