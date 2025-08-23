import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var errorMessage = ''.obs;
  Map<String, dynamic>? user;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    isLoggedIn.value = AuthService.isUserLoggedIn();
    user = AuthService.getCurrentUser();
  }

  Future<void> login(String username, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.login(username, password);
      if (result != null && result['Status'] == true) {
        user = result;
        isLoggedIn.value = true;
        
        // Navigate to home screen after successful login
        Get.offAllNamed('/home');
        
        // Show success message
        Get.snackbar(
          'Success', 
          'Welcome ${result['User_Name']}!',
          backgroundColor: Get.theme.primaryColor,
          colorText: Get.theme.primaryColorLight,
        );
      } else {
        errorMessage.value = 'Invalid credentials or inactive account';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await AuthService.logout();
      user = null;
      isLoggedIn.value = false;
      
      // Navigate to login screen
      Get.offAllNamed('/login');
      
      // Show logout message
      Get.snackbar(
        'Logged Out', 
        'You have been logged out successfully',
        backgroundColor: Get.theme.cardColor,
        colorText: Get.theme.textTheme.bodyLarge?.color,
      );
    } catch (e) {
      errorMessage.value = 'Logout failed: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods to get user data
  String get userName => AuthService.getUserName() ?? 'Guest';
  String get userEmail => AuthService.getEmailId() ?? '';
  int get userId => AuthService.getUserId() ?? 0;
  int get cSession => AuthService.getCSession() ?? 0;
  String get accountType => AuthService.getAccountType() ?? '';
}
