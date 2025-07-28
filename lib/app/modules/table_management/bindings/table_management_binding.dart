import 'package:get/get.dart';
import '../controllers/table_management_controller.dart';
import '../../../data/providers/table_api_provider.dart';
import '../../../data/repositories/table_repository.dart';

class TableManagementBinding extends Bindings {
  @override
  void dependencies() {
    // Register API provider first
    Get.put<TableApiProvider>(
      TableApiProvider(),
    );
    
    // Register repository (depends on API provider)
    Get.put<TableRepository>(
      TableRepository(),
    );
    
    // Register controller (depends on repository)
    Get.put<TableManagementController>(
      TableManagementController(),
    );
  }
}
