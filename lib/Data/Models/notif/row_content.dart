import 'dart:convert';

class RowContent {
	int? code;
	String? displayName;
	int? type;
	int? price;
	dynamic image;
	String? whatAbout;
	String? from;
	String? to;
	String? startTime;
	int? duration;
	int? period;

	RowContent({
		this.code, 
		this.displayName, 
		this.type, 
		this.price, 
		this.image, 
		this.whatAbout, 
		this.from, 
		this.to, 
		this.startTime, 
		this.duration, 
		this.period, 
	});

	factory RowContent.fromMap(Map<String, dynamic> data) => RowContent(
				code: data['Code'] as int?,
				displayName: data['DisplayName'] as String?,
				type: data['Type'] as int?,
				price: data['Price'] as int?,
				image: data['Image'] as dynamic,
				whatAbout: data['WhatAbout'] as String?,
				from: data['From'] as String?,
				to: data['To'] as String?,
				startTime: data['StartTime'] as String?,
				duration: data['Duration'] as int?,
				period: data['Period'] as int?,
			);

	Map<String, dynamic> toMap() => {
				'Code': code,
				'DisplayName': displayName,
				'Type': type,
				'Price': price,
				'Image': image,
				'WhatAbout': whatAbout,
				'From': from,
				'To': to,
				'StartTime': startTime,
				'Duration': duration,
				'Period': period,
			};

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [RowContent].
	factory RowContent.fromJson(String data) {
		return RowContent.fromMap(json.decode(data) as Map<String, dynamic>);
	}
  /// `dart:convert`
  ///
  /// Converts [RowContent] to a JSON string.
	String toJson() => json.encode(toMap());
}
