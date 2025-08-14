import 'package:get/get.dart';

class GlobalDataController extends GetxController {
  static GlobalDataController get instance => Get.find<GlobalDataController>();
  
  // Observable for triggering bill refresh
  var billDataUpdated = false.obs;
  
  // Observable for triggering table status refresh
  var tableDataUpdated = false.obs;
  
  // Observable for triggering order status refresh  
  var orderDataUpdated = false.obs;
  
  // Method to trigger bill refresh after item deletion
  void notifyBillUpdate() {
    billDataUpdated.toggle();
    print('🔄 Global: Bill data update notification sent');
  }
  
  // Method to trigger table status refresh
  void notifyTableUpdate() {
    tableDataUpdated.toggle();
    print('🔄 Global: Table data update notification sent');
  }
  
  // Method to trigger order status refresh
  void notifyOrderUpdate() {
    orderDataUpdated.toggle();
    print('🔄 Global: Order data update notification sent');
  }
  
  // Method to notify all data updates
  void notifyAllUpdates() {
    notifyBillUpdate();
    notifyTableUpdate();
    notifyOrderUpdate();
  }
}
