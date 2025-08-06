import '../models/order_status.dart';
import '../providers/order_status_api_provider.dart';

class OrderStatusRepository {
  Future<List<OrderStatus>> getOrderStatuses() async {
    try {
      final data = await OrderStatusApiProvider.fetchActiveTableItems();
      // Convert API response to OrderStatus list
      return _parseOrderStatusList(data);
    } catch (e) {
      throw Exception('Failed to load order statuses: $e');
    }
  }

  List<OrderStatus> _parseOrderStatusList(List<dynamic> data) {
    // Group items by TableID+OrderNo to create OrderStatus objects
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in data) {
      final map = Map<String, dynamic>.from(item);
      final key = '${map['TableID']}_${map['OrderNo']}';
      grouped.putIfAbsent(key, () => []).add(map);
    }
    return grouped.entries.map((entry) {
      final items = entry.value;
      final first = items.first;
      return OrderStatus(
        id: entry.key,
        tableNumber: first['TableName'] ?? '',
        items: items.map((i) => OrderItem(
          id: i['ItemID'].toString(),
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
}
