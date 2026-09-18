import 'dart:convert';

import 'group.dart';

class User {
	int? code;
	String? sirName;
	String? phone;
	String? username;
	Group? group;
	String? profile;
	String? session;
	String? registerTime;

	User({
		this.code, 
		this.sirName, 
		this.phone, 
		this.username, 
		this.group, 
		this.profile, 
		this.session, 
		this.registerTime, 
	});

	factory User.fromMap(Map<String, dynamic> data) => User(
				code: data['Code'] as int?,
				sirName: data['SirName'] as String?,
				phone: data['Phone'] as String?,
				username: data['Username'] as String?,
				group: data['Group'] == null
						? null
						: Group.fromMap(data['Group'] as Map<String, dynamic>),
				profile: data['Profile'] as String?,
				session: data['Session'] as String?,
				registerTime: data['RegisterTime'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'SirName': sirName,
				'Phone': phone,
				'Username': username,
				'Group': group?.toMap(),
				'Profile': profile,
				'Session': session,
				'RegisterTime': registerTime,
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
