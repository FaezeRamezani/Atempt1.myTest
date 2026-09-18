import 'dart:convert';

class Server {
	int? code;
	String? displayName;
	int? price;
	String? expireTime;
	String? lastUpdate;

	Server({
		this.code, 
		this.displayName, 
		this.price, 
		this.expireTime, 
		this.lastUpdate, 
	});

	factory Server.fromMap(Map<String, dynamic> data) => Server(
				code: data['Code'] as int?,
				displayName: data['DisplayName'] as String?,
				price: data['Price'] as int?,
				expireTime: data['ExpireTime'] as String?,
				lastUpdate: data['LastUpdate'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'DisplayName': displayName,
				'Price': price,
				'ExpireTime': expireTime,
				'LastUpdate': lastUpdate,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Server].
	factory Server.fromJson(String data) {
		return Server.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Server] to a JSON string.
	String toJson() => json.encode(toMap());
}
