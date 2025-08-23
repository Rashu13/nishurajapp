import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/auth_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Use AuthService to check login status
    bool isLoggedIn = AuthService.isUserLoggedIn();
    
    if (isLoggedIn) {
      final userData = AuthService.getCurrentUser();
      print('🔄 User found in storage: ${userData?['User_Name']}');
      print('🔑 CSession: ${AuthService.getCSession()}');
      Get.offNamed(AppRoutes.HOME);
    } else {
      print('🚪 No user session found, redirecting to login');
      Get.offNamed('/login');
    }
  }
}
