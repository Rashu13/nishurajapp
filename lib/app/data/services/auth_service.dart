import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/api_error_handler.dart';

class AuthService {
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    final dio = Dio();
    final url = ApiConfig.loginEndpoint;
    try {
      final response = await dio.post(url, data: {
        'User_Name': username,
        'User_Password': password,
      });
      
      if (response.statusCode == 200 && response.data != null) {
        final userData = Map<String, dynamic>.from(response.data);
        
        // Save user data to local storage
        await _saveUserData(userData);
        
        return userData;
      }
      return null;
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e, context: 'login'));
    }
  }

  // Save user data to local storage
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final storage = GetStorage();
    
    // Save individual fields
    await storage.write('userId', userData['UserId']);
    await storage.write('accountType', userData['AccountType']);
    await storage.write('userName', userData['User_Name']);
    await storage.write('emailId', userData['EmailID']);
    await storage.write('userStatus', userData['Status']);
    await storage.write('cSession', userData['CSession']);
    
    // Save complete user object for easy access
    await storage.write('userData', userData);
    
    // Mark user as logged in
    await storage.write('isLoggedIn', true);
    
    print('✅ User data saved to local storage');
    print('👤 UserId: ${userData['UserId']}');
    print('📧 Email: ${userData['EmailID']}');
    print('🔑 CSession: ${userData['CSession']}');
  }

  // Get current user data from storage
  static Map<String, dynamic>? getCurrentUser() {
    final storage = GetStorage();
    return storage.read('userData');
  }

  // Get specific user fields
  static int? getUserId() {
    final storage = GetStorage();
    return storage.read('userId');
  }

  static String? getUserName() {
    final storage = GetStorage();
    return storage.read('userName');
  }

  static String? getEmailId() {
    final storage = GetStorage();
    return storage.read('emailId');
  }

  static int? getCSession() {
    final storage = GetStorage();
    return storage.read('cSession');
  }

  static String? getAccountType() {
    final storage = GetStorage();
    return storage.read('accountType');
  }

  static bool isUserLoggedIn() {
    final storage = GetStorage();
    return storage.read('isLoggedIn') ?? false;
  }

  // Logout and clear storage
  static Future<void> logout() async {
    final storage = GetStorage();
    await storage.remove('userId');
    await storage.remove('accountType');
    await storage.remove('userName');
    await storage.remove('emailId');
    await storage.remove('userStatus');
    await storage.remove('cSession');
    await storage.remove('userData');
    await storage.write('isLoggedIn', false);
    
    print('🚪 User logged out and data cleared');
  }
}
