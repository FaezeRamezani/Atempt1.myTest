import 'dart:convert';

import 'reason.dart';
import 'type.dart';

class Output {
  int? code;
  String? displayName;
  int? price;
  Type? type;
  Reason? reason;
  String? description;
  String? file;
  String? registerTime;

  Output({
    this.code,
    this.displayName,
    this.price,
    this.type,
    this.reason,
    this.description,
    this.file,
    this.registerTime,
  });

  factory Output.fromMap(Map<String, dynamic> data) => Output(
        code: data['Code'] as int?,
        displayName: data['DisplayName'] as String?,
        price: int.parse(data['Price']) as int?,
        type: data['Type'] == null
            ? null
            : Type.fromMap(data['Type'] as Map<String, dynamic>),
        reason: data['Reason'] == null
            ? null
            : Reason.fromMap(data['Reason'] as Map<String, dynamic>),
        description: data['Description'] as String?,
        file: data['File'] as String?,
        registerTime: data['RegisterTime'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'Code': code,
        'DisplayName': displayName,
        'Price': price,
        'Type': type?.toMap(),
        'Reason': reason?.toMap(),
        'Description': description,
        'File': file,
        'RegisterTime': registerTime,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Output].
  factory Output.fromJson(String data) {
    return Output.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Output] to a JSON string.
  String toJson() => json.encode(toMap());
}
