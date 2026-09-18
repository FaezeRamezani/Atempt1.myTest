import 'dart:convert';

class Content {
  int? code;
  String? displayName;
  int? price;

  Content({this.code, this.displayName, this.price});

  factory Content.fromMap(Map<String, dynamic> data) => Content(
        code: data['Code'] as int?,
        displayName: data['DisplayName'] as String?,
        price: (data['Price']).toInt() as int?,
      );

  Map<String, dynamic> toMap() => {
        'Code': code,
        'DisplayName': displayName,
        'Price': price,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Content].
  factory Content.fromJson(String data) {
    return Content.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Content] to a JSON string.
  String toJson() => json.encode(toMap());
}
