import 'package:get/get.dart';
import 'package:serv/app/data/models/menu_model.dart';
import '../../../data/models/table_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../data/repositories/table_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../core/controllers/global_data_controller.dart';
import '../../../core/utils/toast_helper.dart';

enum RoomTypeFilter { restaurant, ncBilling, rest }

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
  var selectedRoomFilter = RoomTypeFilter.restaurant.obs;

  @override
  void onInit() {
    super.onInit();
    _tableRepository = Get.find<TableRepository>();
    loadMenuItems();
    loadTables();
    
    // Listen for global data updates to refresh table status
    try {
      ever(GlobalDataController.instance.tableDataUpdated, (_) {
        print('🔄 Home Controller: Received table data update notification');
        // Defer the table reload to avoid setState during build
        Future.delayed(Duration.zero, () {
          loadTables();
        });
      });
    } catch (e) {
      print('Global controller not found, continuing without listener');
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh tables when view becomes ready/visible again
    loadTables();
  }

  void loadMenuItems() async {
    try {
      isLoading.value = true;
      final items = await _menuRepository.getMenuItems();
      menuItems.value = items;
    } catch (e) {
      ToastHelper.showError('Failed to load menu items');
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

  // Add refresh method for external calls
  Future<void> refreshTables() async {
    loadTables();
  }

  List<TableModel> get filteredTables {
    switch (selectedRoomFilter.value) {
      case RoomTypeFilter.restaurant:
        return tables.where((table) => table.roomTypeId == 1).toList();
      case RoomTypeFilter.ncBilling:
        return tables.where((table) => table.roomTypeId == 2).toList();
      case RoomTypeFilter.rest:
        return tables.where((table) => table.roomTypeId != 1 && table.roomTypeId != 2).toList();
    }
  }

  void selectRoomFilter(RoomTypeFilter filter) {
    selectedRoomFilter.value = filter;
  }

  void incrementGuest() {
    if (guestCount.value < 60) {
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

  // void navigateToMenu([TableModel? table]) {
  //   if (table != null) {
  //     selectedTable.value = table;
  //     print('HomeController: Navigating to menu with table: ${table.tableName}');
  //   } else {
  //     print('HomeController: Navigating to menu without table argument');
  //   }
  //   Get.toNamed(AppRoutes.MENU, arguments: {
  //     'table': table,
  //     'guestCount': guestCount.value,
  //   });
    
  // }
  // Update navigateToMenu method to pass guest count
void navigateToMenu([TableModel? table]) {
  if (table != null) {
    // Pass guest count to menu controller
    Get.toNamed(AppRoutes.MENU, arguments: {
      'table': table,
      'guestCount': guestCount.value, // Pass current guest count
    });
  } else {
    // For new table selection, pass guest count
    Get.toNamed(AppRoutes.MENU, arguments: {
      'guestCount': guestCount.value,
    });
  }
}

  void navigateToMenuItem(MenuModel item) {
    Get.toNamed(AppRoutes.MENU_DETAIL, arguments: item);
  }
}
