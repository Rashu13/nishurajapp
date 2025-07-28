import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/providers/table_api_provider.dart';
import '../../../data/repositories/table_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register API provider if not already registered
    if (!Get.isRegistered<TableApiProvider>()) {
      Get.put<TableApiProvider>(TableApiProvider());
    }
    
    // Register repository if not already registered  
    if (!Get.isRegistered<TableRepository>()) {
      Get.put<TableRepository>(TableRepository());
    }
    
    // Register controller
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
