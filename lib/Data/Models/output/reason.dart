import 'dart:convert';

class Reason {
	int? code;
	String? name;

	Reason({this.code, this.name});

	factory Reason.fromMap(Map<String, dynamic> data) => Reason(
				code: data['Code'] as int?,
				name: data['Name'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'Name': name,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Reason].
	factory Reason.fromJson(String data) {
		return Reason.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Reason] to a JSON string.
	String toJson() => json.encode(toMap());
}
