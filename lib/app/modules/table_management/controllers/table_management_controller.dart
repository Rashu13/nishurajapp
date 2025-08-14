import 'package:get/get.dart';
import '../../../data/models/table_model.dart';
import '../../../data/repositories/table_repository.dart';
import '../../../core/controllers/global_data_controller.dart';
import '../../../core/utils/toast_helper.dart';

class TableManagementController extends GetxController {
  final TableRepository _tableRepository = Get.find<TableRepository>();
  
  // Observables
  final RxInt selectedTab = 0.obs;
  final RxList<TableModel> tables = <TableModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Pagination
  bool get hasMoreData => _tableRepository.hasMoreData;
  
  @override
  void onInit() {
    super.onInit();
    loadTables();
    
    // Listen for global table data updates
    try {
      ever(GlobalDataController.instance.tableDataUpdated, (_) {
        print('🔄 Table Management: Received table data update notification');
        loadTables();
      });
    } catch (e) {
      print('Global controller not found, continuing without listener');
    }
  }
  
  // Load initial tables
  Future<void> loadTables() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    
    try {
      await _tableRepository.loadTables();
      
      // Apply filter based on current tab
      _applyTabFilter(selectedTab.value);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load tables: ${e.toString()}';
      print('Error loading tables: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Apply filtering based on selected tab
  void _applyTabFilter(int tabIndex) {
    if (tabIndex == 0) {
      // All tables
      tables.value = _tableRepository.tables;
    } else if (tabIndex == 1) {
      // Available tables only (status = true)
      tables.value = _tableRepository.tables.where((table) => table.status).toList();
    } else if (tabIndex == 2) {
      // Occupied tables only (status = false)
      tables.value = _tableRepository.tables.where((table) => !table.status).toList();
    }
  }
  
  // Load more tables (pagination)
  Future<void> loadMoreTables() async {
    if (isLoadingMore.value || !hasMoreData) return;
    
    isLoadingMore.value = true;
    
    try {
      await _tableRepository.loadMoreTables();
      // Update the tables list from the repository
      tables.value = _tableRepository.tables;
    } catch (e) {
      print('Error loading more tables: ${e.toString()}');
      // Show a toast but don't set hasError since we still show existing tables
      ToastHelper.showError('Failed to load more tables');
    } finally {
      isLoadingMore.value = false;
    }
  }
  
  // Refresh tables
  Future<void> refreshTables() async {
    _tableRepository.clearCache();
    await loadTables();
    // _applyTabFilter is already called in loadTables
  }
  
  // Select/deselect table
  void toggleTableSelection(TableModel table) {
    _tableRepository.updateTableSelection(table.tableId, !table.isSelected);
    update(); // Force UI update
  }
  
  // Update table status (occupied/available)
  Future<void> updateTableStatus(TableModel table, bool newStatus) async {
    try {
      final success = await _tableRepository.updateTableStatus(table.tableId, newStatus);
      if (success) {
        ToastHelper.showSuccess('Table ${table.tableName} status updated');
      } else {
        ToastHelper.showError('Failed to update table status');
      }
    } catch (e) {
      ToastHelper.showError('An error occurred: ${e.toString()}');
    }
  }
  
  // Change selected tab
  void selectTab(int index) {
    selectedTab.value = index;
    _applyTabFilter(index);
  }
  
  @override
  void onClose() {
    // Clear any resources if needed
    super.onClose();
  }
}
