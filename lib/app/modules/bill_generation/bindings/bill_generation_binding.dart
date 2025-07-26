import 'package:get/get.dart';
import '../controllers/bill_generation_controller.dart';

class BillGenerationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillGenerationController>(() => BillGenerationController());
  }
}
