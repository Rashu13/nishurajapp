import '../models/order_status.dart';
import '../providers/dummy_data_provider.dart';

class OrderStatusRepository {
  Future<List<OrderStatus>> getOrderStatuses() async {
    try {
      return await DummyDataProvider.getOrderStatuses();
    } catch (e) {
      throw Exception('Failed to load order statuses: $e');
    }
  }

  Future<OrderStatus> getOrderStatusById(String id) async {
    try {
      final orderStatuses = await DummyDataProvider.getOrderStatuses();
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
