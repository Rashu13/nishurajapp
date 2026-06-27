import '../models/order_status.dart';
import '../providers/order_status_api_provider.dart';
import '../providers/bill_api_provider.dart';

class OrderStatusRepository {
  Future<List<OrderStatus>> getOrderStatuses() async {
    try {
      // First get individual bills to identify running orders
      final billsData = await BillApiProvider.fetchTableBillSummary();
      final runningBills = billsData.where((bill) {
        // Match bill generation logic: billStatus == false means active/running
        final billStatus = bill['billStatus'] ?? bill['bill_status'] ?? false;
        final statusStr = bill['Status']?.toString().toLowerCase() ?? '';
        return billStatus == false || statusStr == 'running';
      }).toList();
      
      if (runningBills.isEmpty) {
        return []; // No running orders
      }
      
      // Get active table items for running bills only
      final activeItemsData = await OrderStatusApiProvider.fetchActiveTableItems();
      
      // Convert API response to OrderStatus list for running bills only
      return _parseOrderStatusList(activeItemsData, runningBills);
    } catch (e) {
      throw Exception('Failed to load order statuses: $e');
    }
  }

  List<OrderStatus> _parseOrderStatusList(List<dynamic> itemsData, List<dynamic> runningBills) {
    // Get table names of running bills and create a map of TableName -> BillType
    final runningTableNames = <String>{};
    final tableBillTypeMap = <String, String>{}; // Map TableName to BillType
    
    for (var bill in runningBills) {
      final tableName = bill['TableName']?.toString().trim();
      if (tableName == null || tableName.isEmpty) continue;
      final billType = bill['BillType'] ?? bill['OrderType'];
      runningTableNames.add(tableName.toLowerCase());
      if (billType != null) {
        tableBillTypeMap[tableName.toLowerCase()] = billType.toString();
      }
    }
    
    // Filter items to only include those from running tables
    final runningItemsData = itemsData.where((item) {
      final map = Map<String, dynamic>.from(item);
      final tableName = map['TableName']?.toString().trim();
      final kotStatus = map['KOTStatus'] ?? '';
      
      // Include items from running tables that are not already billed
      return tableName != null && 
             tableName.isNotEmpty && 
             runningTableNames.contains(tableName.toLowerCase()) && 
             kotStatus != 'Billed';
    }).toList();
    
    // Group items by TableID+OrderNo to create OrderStatus objects
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in runningItemsData) {
      final map = Map<String, dynamic>.from(item);
      final key = '${map['TableID']}_${map['OrderNo']}';
      grouped.putIfAbsent(key, () => []).add(map);
    }
    
    return grouped.entries.map((entry) {
      final items = entry.value;
      final first = items.first;
      final tableName = first['TableName']?.toString().trim();
      
      // Get BillType from the bills data using TableName
      final billTypeRaw = (tableName != null && tableName.isNotEmpty) 
          ? tableBillTypeMap[tableName.toLowerCase()] 
          : null;
      print('🏠 Table: ${first['TableName']}, BillType from bills: $billTypeRaw');
      
      // Convert BillType to int
      int billType = 1; // Default to Restaurant
      if (billTypeRaw != null) {
        // Map string values to integer codes
        switch (billTypeRaw.toLowerCase().trim()) {
          case 'restaurant':
            billType = 1;
            break;
          case 'nc billing':
          case 'ncbilling':
            billType = 2;
            break;
          case 'room':
            billType = 3;
            break;
          default:
            // Try to parse as number if it's a numeric string
            billType = int.tryParse(billTypeRaw) ?? 1;
        }
      }
      
      print('  → Mapped to billType: $billType');
      
      return OrderStatus(
        id: entry.key,
        tableNumber: first['TableName'] ?? '',
        billType: billType,
        items: items.map((i) => OrderItem(
          id: i['KOTDID'].toString(), // Use KOTDID instead of ItemID for delete operations
          name: i['ItemName'] ?? '',
          quantity: (i['Qty'] as num?)?.toInt() ?? 1,
          status: i['OrderStatus'] == true ? 'served' : 'in_progress',
          isModified: false,
        )).toList(),
        createdAt: DateTime.now(),
        status: 'in_progress',
      );
    }).toList();
  }

  Future<OrderStatus> getOrderStatusById(String id) async {
    try {
      final orderStatuses = await getOrderStatuses();
      return orderStatuses.firstWhere((order) => order.id == id);
    } catch (e) {
      throw Exception('Failed to load order status: $e');
    }
  }

  Future<void> updateOrderItemStatus(String orderId, String itemId, String status) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // In real implementation, this would call API
      // await _apiProvider.updateOrderItemStatus(orderId, itemId, status);
    } catch (e) {
      throw Exception('Failed to update order item status: $e');
    }
  }

  Future<void> sendBill(String orderId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // In real implementation, this would call API
      // await _apiProvider.sendBill(orderId);
    } catch (e) {
      throw Exception('Failed to send bill: $e');
    }
  }

  Future<void> addDishesToOrder(String orderId, List<OrderItem> items) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // In real implementation, this would call API
      // await _apiProvider.addDishesToOrder(orderId, items);
    } catch (e) {
      throw Exception('Failed to add dishes to order: $e');
    }
  }

  Future<bool> deleteOrderItem(String itemId) async {
    try {
      return await OrderStatusApiProvider.deleteKOTItem(itemId);
    } catch (e) {
      throw Exception('Failed to delete order item: $e');
    }
  }

  Future<bool> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      return await OrderStatusApiProvider.updateKOTItemQuantity(itemId, newQuantity.toDouble());
    } catch (e) {
      throw Exception('Failed to update item quantity: $e');
    }
  }
}
