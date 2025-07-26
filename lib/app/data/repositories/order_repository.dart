import '../models/order.dart';
import '../providers/dummy_data_provider.dart';

class OrderRepository {
  Future<List<Order>> getOrders() async {
    try {
      return await DummyDataProvider.getOrders();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      return await DummyDataProvider.getOrderById(orderId);
    } catch (e) {
      throw Exception('Failed to load order: $e');
    }
  }

  Future<Order> createOrder(Order order) async {
    try {
      // In real app, this would make API call
      // For now, just return the order with generated ID
      return Order(
        id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
        items: order.items,
        totalAmount: order.totalAmount,
        status: 'preparing',
        orderTime: DateTime.now(),
        estimatedTime: 30,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
      );
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<Order> updateOrderStatus(String orderId, String status) async {
    try {
      // In real app, this would make API call
      final order = await getOrderById(orderId);
      if (order != null) {
        return Order(
          id: order.id,
          items: order.items,
          totalAmount: order.totalAmount,
          status: status,
          orderTime: order.orderTime,
          estimatedTime: order.estimatedTime,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
        );
      }
      throw 'Order not found';
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
