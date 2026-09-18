import 'dart:convert';

class User {
	int? code;
	String? sirName;

	User({this.code, this.sirName});

	factory User.fromMap(Map<String, dynamic> data) => User(
				code: data['Code'] as int?,
				sirName: data['SirName'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'SirName': sirName,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [User].
	factory User.fromJson(String data) {
		return User.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [User] to a JSON string.
	String toJson() => json.encode(toMap());
}
