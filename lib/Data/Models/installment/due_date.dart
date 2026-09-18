import 'dart:convert';

class DueDate {
	int? code;
	String? dueDate;
	bool? isPaid;

	DueDate({this.code, this.dueDate, this.isPaid});

	factory DueDate.fromMap(Map<String, dynamic> data) => DueDate(
				code: data['Code'] as int?,
				dueDate: data['DueDate'] as String?,
				isPaid: data['isPaid'] as bool?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'DueDate': dueDate,
				'isPaid': isPaid,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [DueDate].
	factory DueDate.fromJson(String data) {
		return DueDate.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [DueDate] to a JSON string.
	String toJson() => json.encode(toMap());
}
