import 'package:get/get.dart';
import '../controllers/order_status_controller.dart';

class OrderStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderStatusController>(() => OrderStatusController());
  }
}
