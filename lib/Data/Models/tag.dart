import 'dart:convert';

class Tag {
	int? code;
	String? name;

	Tag({this.code, this.name});

	factory Tag.fromMap(Map<String, dynamic> data) => Tag(
				code: data['Code'] as int?,
				name: data['Name'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'Name': name,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Tag].
	factory Tag.fromJson(String data) {
		return Tag.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Tag] to a JSON string.
	String toJson() => json.encode(toMap());
}
