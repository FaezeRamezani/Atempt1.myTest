import 'dart:convert';

import 'due_date.dart';

class Installment {
  int? code;
  String? displayName;
  int? price;
  List<DueDate>? dueDate;
  dynamic description;
  String? startTime;
  String? registerTime;

  Installment({
    this.code,
    this.displayName,
    this.price,
    this.dueDate,
    this.description,
    this.startTime,
    this.registerTime,
  });

  factory Installment.fromMap(Map<String, dynamic> data) => Installment(
        code: data['Code'] as int?,
        displayName: data['DisplayName'] as String?,
        price: int.parse(data['Price']) as int?,
        dueDate: (data['DueDate'] as List<dynamic>?)
            ?.map((e) => DueDate.fromMap(e as Map<String, dynamic>))
            .toList(),
        description: data['Description'] as dynamic,
        startTime: data['StartTime'] as String?,
        registerTime: data['RegisterTime'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'Code': code,
        'DisplayName': displayName,
        'Price': price,
        'DueDate': dueDate?.map((e) => e.toMap()).toList(),
        'Description': description,
        'StartTime': startTime,
        'RegisterTime': registerTime,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Installment].
  factory Installment.fromJson(String data) {
    return Installment.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Installment] to a JSON string.
  String toJson() => json.encode(toMap());
}
