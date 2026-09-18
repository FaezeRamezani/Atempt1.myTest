import 'dart:convert';

import 'type.dart';

class Entry {
  int? code;
  String? displayName;
  int? price;
  Type? type;
  String? file;
  String? description;
  String? registerTime;

  Entry({
    this.code,
    this.displayName,
    this.price,
    this.type,
    this.file,
    this.description,
    this.registerTime,
  });

  factory Entry.fromMap(Map<String, dynamic> data) => Entry(
        code: data['Code'] as int?,
        displayName: data['DisplayName'] as String?,
        price: int.parse(data['Price']) as int?,
        type: data['Type'] == null
            ? null
            : Type.fromMap(data['Type'] as Map<String, dynamic>),
        file: data['File'] as String?,
        description: data['Description'] as String?,
        registerTime: data['RegisterTime'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'Code': code,
        'DisplayName': displayName,
        'Price': price,
        'Type': type?.toMap(),
        'File': file,
        'Description': description,
        'RegisterTime': registerTime,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Entry].
  factory Entry.fromJson(String data) {
    return Entry.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Entry] to a JSON string.
  String toJson() => json.encode(toMap());
}
