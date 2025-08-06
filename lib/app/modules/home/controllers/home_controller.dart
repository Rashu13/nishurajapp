import 'package:get/get.dart';
import 'package:serv/app/data/models/menu_model.dart';
import '../../../data/models/table_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../data/repositories/table_repository.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final MenuRepository _menuRepository = MenuRepository();
  late final TableRepository _tableRepository;
  
  var isLoading = false.obs;
  var isTablesLoading = false.obs;
  var menuItems = <MenuModel>[].obs;
  var tables = <TableModel>[].obs;
  var selectedCategory = 'All'.obs;
  var categories = <String>['All', 'Starter', 'Main Course', 'Dessert', 'Drinks'].obs;
  var guestCount = 4.obs;
  var selectedTable = Rxn<TableModel>();

  @override
  void onInit() {
    super.onInit();
    _tableRepository = Get.find<TableRepository>();
    loadMenuItems();
    loadTables();
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

  void loadTables() async {
    try {
      isTablesLoading.value = true;
      await _tableRepository.loadTables();
      tables.value = _tableRepository.tables;
      print('Home: Loaded ${tables.length} tables');
      // Print first few table names for debugging
      if (tables.isNotEmpty) {
        final firstFew = tables.take(5).map((t) => '${t.tableName}(${t.status ? "Available" : "Occupied"})').join(', ');
        print('Home: First few tables: $firstFew');
      }
    } catch (e) {
      print('Error loading tables in home: ${e.toString()}');
      // Fallback to empty list if API fails
      tables.value = [];
    } finally {
      isTablesLoading.value = false;
    }
  }

  void incrementGuest() {
    if (guestCount.value < 12) {
      guestCount.value++;
    }
  }

  void decrementGuest() {
    if (guestCount.value > 1) {
      guestCount.value--;
    }
  }

  List<MenuModel> get filteredMenuItems {
    if (selectedCategory.value == 'All') {
      return menuItems;
    }
    return menuItems.where((item) => item.itemName == selectedCategory.value).toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void navigateToMenu([TableModel? table]) {
    if (table != null) {
      selectedTable.value = table;
      print('HomeController: Navigating to menu with table: ${table.tableName}');
    } else {
      print('HomeController: Navigating to menu without table argument');
    }
    Get.toNamed(AppRoutes.MENU, arguments: selectedTable.value);
  }

  void navigateToMenuItem(MenuModel item) {
    Get.toNamed(AppRoutes.MENU_DETAIL, arguments: item);
  }
}
