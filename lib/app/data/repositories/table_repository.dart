import 'package:get/get.dart';
import '../models/table_model.dart';
import '../providers/table_api_provider.dart';

class TableRepository {
  late final TableApiProvider _apiProvider;
  
  // Cache for tables
  final RxList<TableModel> _tablesCache = <TableModel>[].obs;
  final RxBool _hasMoreData = true.obs;
  final RxInt _currentPage = 1.obs;
  final int _pageSize = 12;
  
  // Constructor - initialize api provider
  TableRepository() {
    _apiProvider = Get.find<TableApiProvider>();
  }
  
  // Getters
  List<TableModel> get tables => _tablesCache;
  bool get hasMoreData => _hasMoreData.value;
  int get currentPage => _currentPage.value;
  
  // Load initial tables
  Future<List<TableModel>> loadTables() async {
    try {
      _currentPage.value = 1;
      final tables = await _apiProvider.getTables(
        page: _currentPage.value, 
        pageSize: _pageSize
      );
      
      _tablesCache.assignAll(tables);
      _hasMoreData.value = tables.length >= _pageSize;
      
      return _tablesCache;
    } catch (e) {
      print('Error in repository loadTables: ${e.toString()}');
      rethrow;
    }
  }
  
  // Load more tables (pagination)
  Future<List<TableModel>> loadMoreTables() async {
    if (!_hasMoreData.value) return _tablesCache;
    
    try {
      _currentPage.value++;
      final moreTables = await _apiProvider.getTables(
        page: _currentPage.value, 
        pageSize: _pageSize
      );
      
      if (moreTables.isNotEmpty) {
        _tablesCache.addAll(moreTables);
        _hasMoreData.value = moreTables.length >= _pageSize;
      } else {
        _hasMoreData.value = false;
      }
      
      return _tablesCache;
    } catch (e) {
      // Revert page increment on error
      _currentPage.value--;
      print('Error in repository loadMoreTables: ${e.toString()}');
      rethrow;
    }
  }
  
  // Get table by ID
  Future<TableModel?> getTableById(int tableId) async {
    // First check cache
    final cachedTable = _tablesCache.firstWhereOrNull((t) => t.tableId == tableId);
    if (cachedTable != null) return cachedTable;
    
    // If not in cache, fetch from API
    return await _apiProvider.getTableById(tableId);
  }
  
  // Update table selection status locally
  void updateTableSelection(int tableId, bool isSelected) {
    final index = _tablesCache.indexWhere((table) => table.tableId == tableId);
    if (index != -1) {
      final table = _tablesCache[index];
      table.isSelected = isSelected;
      _tablesCache[index] = table;
    }
  }
  
  // Update table status on server
  Future<bool> updateTableStatus(int tableId, bool status) async {
    final result = await _apiProvider.updateTableStatus(tableId, status);
    if (result) {
      // Update local cache if server update was successful
      final index = _tablesCache.indexWhere((table) => table.tableId == tableId);
      if (index != -1) {
        final table = _tablesCache[index];
        table.status = status;
        _tablesCache[index] = table;
      }
    }
    return result;
  }
  
  // Clear cache
  void clearCache() {
    _tablesCache.clear();
    _currentPage.value = 1;
    _hasMoreData.value = true;
  }
}
