import 'package:dio/dio.dart';

class AuthService {
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    final dio = Dio();
    final url = 'http://192.168.1.6:44351/api/login';
    try {
      final response = await dio.post(url, data: {
        'User_Name': username,
        'User_Password': password,
      });
      print('LOGIN RESPONSE: \\nStatus: \\${response.statusCode} \\nData: \\${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
