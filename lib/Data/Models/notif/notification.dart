import 'dart:convert';

import 'row_content.dart';

class Notification {
	int? code;
	String? displayName;
	String? description;
	int? forWhat;
	String? registerTime;
	RowContent? rowContent;

	Notification({
		this.code, 
		this.displayName, 
		this.description, 
		this.forWhat, 
		this.registerTime, 
		this.rowContent, 
	});

	factory Notification.fromMap(Map<String, dynamic> data) => Notification(
				code: data['Code'] as int?,
				displayName: data['DisplayName'] as String?,
				description: data['Description'] as String?,
				forWhat: data['ForWhat'] as int?,
				registerTime: data['RegisterTime'] as String?,
				rowContent: data['RowContent'] == null
						? null
						: RowContent.fromMap(data['RowContent'] as Map<String, dynamic>),
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'DisplayName': displayName,
				'Description': description,
				'ForWhat': forWhat,
				'RegisterTime': registerTime,
				'RowContent': rowContent?.toMap(),
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Notification].
	factory Notification.fromJson(String data) {
		return Notification.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Notification] to a JSON string.
	String toJson() => json.encode(toMap());
}
