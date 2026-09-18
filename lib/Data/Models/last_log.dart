import 'dart:convert';

class LastLog {
	int? code;
	int? operation;
	String? registerTime;

	LastLog({this.code, this.operation, this.registerTime});

	factory LastLog.fromMap(Map<String, dynamic> data) => LastLog(
				code: data['Code'] as int?,
				operation: data['Operation'] as int?,
				registerTime: data['RegisterTime'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'Operation': operation,
				'RegisterTime': registerTime,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [LastLog].
	factory LastLog.fromJson(String data) {
		return LastLog.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [LastLog] to a JSON string.
	String toJson() => json.encode(toMap());
}
