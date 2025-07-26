import 'package:get/get.dart';
import '../controllers/table_management_controller.dart';

class TableManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TableManagementController>(
      () => TableManagementController(),
    );
  }
}
