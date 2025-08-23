import 'package:get/get.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../core/utils/session_manager.dart';
import '../../../data/services/auth_service.dart';

class ProfileController extends GetxController {
  var userName = ''.obs;
  var userEmail = ''.obs;
  var currentBalance = 240.50.obs;
  var totalEarned = 990.00.obs;
  
  // Notification settings
  var whenDishIsReady = true.obs;
  var whenChefStartsCooking = true.obs;
  var whenOrderIsCancelled = true.obs;
  var whenOrderIsDelivered = true.obs;
  var whenOrderAlert = true.obs;
  var twoStepVerification = true.obs;

  get waiterInfo => null;
  get performance => null;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    // Load actual user data from session
    userName.value = SessionManager.displayName;
    userEmail.value = AuthService.getEmailId() ?? 'No email available';
    
    // Print session data for debugging
    print('🔍 Profile Controller - Loading User Data:');
    print('👤 User ID: ${SessionManager.currentUserId}');
    print('📧 User Name: ${SessionManager.displayName}');
    print('💌 Email: ${AuthService.getEmailId()}');
    print('🏢 Account Type: ${AuthService.getAccountType()}');
    print('🔑 CSession: ${SessionManager.currentCSession}');
    print('✅ Is Authenticated: ${SessionManager.isAuthenticated}');
  }

  void refreshUserData() {
    _loadUserData();
  }
  
  void toggleNotification(String type, bool value) {
    switch (type) {
      case 'whenDishIsReady':
        whenDishIsReady.value = value;
        break;
      case 'whenChefStartsCooking':
        whenChefStartsCooking.value = value;
        break;
      case 'whenOrderIsCancelled':
        whenOrderIsCancelled.value = value;
        break;
      case 'whenOrderIsDelivered':
        whenOrderIsDelivered.value = value;
        break;
      case 'whenOrderAlert':
        whenOrderAlert.value = value;
        break;
      case 'twoStepVerification':
        twoStepVerification.value = value;
        break;
    }
  }
  
  void editProfile() {
    // Handle profile editing
    ToastHelper.showInfo('Edit profile functionality');
  }
  
  void changePassword() {
    // Handle password change
    ToastHelper.showInfo('Change password functionality');
  }

  void editPersonalInfo() {}

  void notificationSettings() {}

  void aboutApp() {}

  void helpSupport() {}

  void changeLanguage() {}

  void logout() async {
    try {
      await SessionManager.logout();
      ToastHelper.showSuccess('Logged out successfully');
      Get.offAllNamed('/login');
    } catch (e) {
      ToastHelper.showError('Logout failed: $e');
    }
  }
}
