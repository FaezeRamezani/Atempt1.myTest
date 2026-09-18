import 'dart:convert';

import 'notification.dart';

class Notif {
	int? code;
	Notification? notification;
	bool? isRead;

	Notif({this.code, this.notification, this.isRead});

	factory Notif.fromMap(Map<String, dynamic> data) => Notif(
				code: data['Code'] as int?,
				notification: data['Notification'] == null
						? null
						: Notification.fromMap(data['Notification'] as Map<String, dynamic>),
				isRead: data['isRead'] as bool?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'Notification': notification?.toMap(),
				'isRead': isRead,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Notif].
	factory Notif.fromJson(String data) {
		return Notif.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Notif] to a JSON string.
	String toJson() => json.encode(toMap());
}
