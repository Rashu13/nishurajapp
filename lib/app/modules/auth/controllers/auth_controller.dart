import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var errorMessage = ''.obs;
  Map<String, dynamic>? user;

  final box = GetStorage();

  Future<void> login(String username, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.login(username, password);
      if (result != null && result['Status'] == true) {
        user = result;
        // Store user data and login time in GetStorage
        box.write('user', result);
        box.write('loginTime', DateTime.now().toIso8601String());
        isLoggedIn.value = true;
      } else {
        errorMessage.value = 'Invalid credentials';
      }
    } catch (e) {
      errorMessage.value = 'Login failed: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
