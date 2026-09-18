import 'dart:convert';

import 'content.dart';
import 'user.dart';

class Log {
	int? code;
	int? operation;
	Content? content;
	String? description;
	User? user;
	String? registerTime;

	Log({
		this.code, 
		this.operation, 
		this.content, 
		this.description, 
		this.user, 
		this.registerTime, 
	});

	factory Log.fromMap(Map<String, dynamic> data) => Log(
				code: data['Code'] as int?,
				operation: data['Operation'] as int?,
				content: data['Content'] == null
						? null
						: Content.fromMap(data['Content'] as Map<String, dynamic>),
				description: data['Description'] as String?,
				user: data['User'] == null
						? null
						: User.fromMap(data['User'] as Map<String, dynamic>),
				registerTime: data['RegisterTime'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'Operation': operation,
				'Content': content?.toMap(),
				'Description': description,
				'User': user?.toMap(),
				'RegisterTime': registerTime,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Log].
	factory Log.fromJson(String data) {
		return Log.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Log] to a JSON string.
	String toJson() => json.encode(toMap());
}
