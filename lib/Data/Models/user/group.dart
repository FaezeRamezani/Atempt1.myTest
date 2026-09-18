import 'dart:convert';

class Group {
	int? code;
	String? name;

	Group({this.code, this.name});

	factory Group.fromMap(Map<String, dynamic> data) => Group(
				code: data['Code'] as int?,
				name: data['Name'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'Name': name,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Group].
	factory Group.fromJson(String data) {
		return Group.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Group] to a JSON string.
	String toJson() => json.encode(toMap());
}
