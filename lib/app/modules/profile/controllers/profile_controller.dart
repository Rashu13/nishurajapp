import 'package:get/get.dart';

class ProfileController extends GetxController {
  var userName = 'Krishna Sahu'.obs;
  var userEmail = 'krishnasahu@gmail.com'.obs;
  var currentBalance = 240.50.obs;
  var totalEarned = 990.00.obs;
  
  // Notification settings
  var whenDishIsReady = true.obs;
  var whenChefStartsCooking = true.obs;
  var whenOrderIsCancelled = true.obs;
  var whenOrderIsDelivered = true.obs;
  var whenOrderAlert = true.obs;
  var twoStepVerification = true.obs;
  
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
    Get.snackbar('Profile', 'Edit profile functionality');
  }
  
  void changePassword() {
    // Handle password change
    Get.snackbar('Password', 'Change password functionality');
  }
}
