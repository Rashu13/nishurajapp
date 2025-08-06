import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    final box = GetStorage();
    final user = box.read('user');
    final loginTime = box.read('loginTime');
    bool isLoggedIn = false;
    if (user != null && loginTime != null) {
      final loginDate = DateTime.tryParse(loginTime.toString());
      if (loginDate != null) {
        final now = DateTime.now();
        if (now.difference(loginDate).inDays < 3) {
          isLoggedIn = true;
        }
      }
    }
    if (isLoggedIn) {
      Get.offNamed(AppRoutes.HOME);
    } else {
      Get.offNamed('/login');
    }
  }
}
