import 'dart:convert';

class Cheque {
  int? code;
  String? displayName;
  int? type;
  int? price;
  dynamic image;
  String? whatAbout;
  String? from;
  String? to;
  String? description;
  String? dueDate;
  String? warningDate;
  String? registerTime;

  Cheque({
    this.code,
    this.displayName,
    this.type,
    this.price,
    this.image,
    this.whatAbout,
    this.from,
    this.to,
    this.description,
    this.dueDate,
    this.warningDate,
    this.registerTime,
  });

  factory Cheque.fromMap(Map<String, dynamic> data) => Cheque(
        code: data['Code'] as int?,
        displayName: data['DisplayName'] as String?,
        type: data['Type'] as int?,
        price: int.parse(data['Price']) as int?,
        image: data['Image'] as dynamic,
        whatAbout: data['WhatAbout'] as String?,
        from: data['From'] as String?,
        to: data['To'] as String?,
        description: data['Description'] as String?,
        dueDate: data['DueDate'] as String?,
        warningDate: data['WarningDate'] as String?,
        registerTime: data['RegisterTime'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'Code': code,
        'DisplayName': displayName,
        'Type': type,
        'Price': price,
        'Image': image,
        'WhatAbout': whatAbout,
        'From': from,
        'To': to,
        'Description': description,
        'DueDate': dueDate,
        'WarningDate': warningDate,
        'RegisterTime': registerTime,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Cheque].
  factory Cheque.fromJson(String data) {
    return Cheque.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Cheque] to a JSON string.
  String toJson() => json.encode(toMap());
}
