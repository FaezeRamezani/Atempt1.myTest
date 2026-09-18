import 'package:flutter_dotenv/flutter_dotenv.dart';

class Keys {
  // App
  static String apiKey = '${dotenv.env['API_X_KEY']}';
}
