import 'package:get/get.dart';
import '../controllers/payment_successful_controller.dart';

class PaymentSuccessfulBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentSuccessfulController>(() => PaymentSuccessfulController());
  }
}
