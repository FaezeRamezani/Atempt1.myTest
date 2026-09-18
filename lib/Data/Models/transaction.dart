import 'dart:convert';

class Transaction {
	int? code;
	String? operation;
	String? displayName;
	String? type;
	String? price;
	String? registerTime;

	Transaction({
		this.code, 
		this.operation, 
		this.displayName, 
		this.type, 
		this.price, 
		this.registerTime, 
	});

	factory Transaction.fromMap(Map<String, dynamic> data) => Transaction(
				code: data['Code'] as int?,
				operation: data['Operation'] as String?,
				displayName: data['DisplayName'] as String?,
				type: data['Type'] as String?,
				price: data['Price'] as String?,
				registerTime: data['RegisterTime'] as String?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'Operation': operation,
				'DisplayName': displayName,
				'Type': type,
				'Price': price,
				'RegisterTime': registerTime,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Transaction].
	factory Transaction.fromJson(String data) {
		return Transaction.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [Transaction] to a JSON string.
	String toJson() => json.encode(toMap());
}
