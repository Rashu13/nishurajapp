import 'package:get/get.dart';
import '../../../data/models/menu_item.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final MenuRepository _menuRepository = MenuRepository();
  
  var isLoading = false.obs;
  var menuItems = <MenuItem>[].obs;
  var selectedCategory = 'All'.obs;
  var categories = <String>['All', 'Starter', 'Main Course', 'Dessert', 'Drinks'].obs;

  @override
  void onInit() {
    super.onInit();
    loadMenuItems();
  }

  void loadMenuItems() async {
    try {
      isLoading.value = true;
      final items = await _menuRepository.getMenuItems();
      menuItems.value = items;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load menu items');
    } finally {
      isLoading.value = false;
    }
  }

  List<MenuItem> get filteredMenuItems {
    if (selectedCategory.value == 'All') {
      return menuItems;
    }
    return menuItems.where((item) => item.category == selectedCategory.value).toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void navigateToMenu() {
    Get.toNamed(AppRoutes.MENU);
  }

  void navigateToMenuItem(MenuItem item) {
    Get.toNamed(AppRoutes.MENU_DETAIL, arguments: item);
  }
}
