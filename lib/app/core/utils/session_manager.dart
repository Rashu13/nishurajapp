import '../../data/services/auth_service.dart';

class SessionManager {
  // Get current CSession for API calls
  static int? get currentCSession => AuthService.getCSession();
  
  // Get current user ID
  static String? get currentUserId {
    final userId = AuthService.getUserId();
    print('📊 SessionManager - Getting User ID: $userId');
    return userId?.toString();
  }
  
  // Get current user details
  static Map<String, String> get currentUserDetails => {
    'userId': AuthService.getUserId()?.toString() ?? '',
    'userName': AuthService.getUserName() ?? '',
    'email': AuthService.getEmailId() ?? '',
    'accountType': AuthService.getAccountType() ?? '',
    'cSession': AuthService.getCSession()?.toString() ?? '',
  };
  
  // Check if user is authenticated
  static bool get isAuthenticated => AuthService.isUserLoggedIn();
  
  // Get user name for display
  static String get displayName => AuthService.getUserName() ?? 'Guest';
  
  // Get formatted user info for headers or display
  static String get userInfo => 
    '${AuthService.getUserName()} (${AuthService.getEmailId()})';
  
  // Check if user has specific account type
  static bool hasAccountType(String type) {
    return AuthService.getAccountType()?.toLowerCase() == type.toLowerCase();
  }
  
  // Get headers for API calls that require authentication
  static Map<String, dynamic> get authHeaders => {
    'Content-Type': 'application/json',
    if (currentCSession != null) 'CSession': currentCSession.toString(),
    if (currentUserId != null) 'UserId': currentUserId.toString(),
  };
  
  // Logout user
  static Future<void> logout() async {
    await AuthService.logout();
  }
}
