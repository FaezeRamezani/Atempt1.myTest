import 'dart:convert';

class Type {
	int? code;
	String? name;

	Type({this.code, this.name});

	factory Type.fromMap(Map<String, dynamic> data) => Type(
				code: data['Code'] as int?,
				name: data['Name'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'Name': name,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Type].
	factory Type.fromJson(String data) {
		return Type.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Type] to a JSON string.
	String toJson() => json.encode(toMap());
}
