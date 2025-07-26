import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/order_status.dart' as status;
import '../models/bill.dart';

class DummyDataProvider {
  static Future<List<MenuItem>> getMenuItems() async {
    final String response = await rootBundle.loadString('assets/data/menu_items.json');
    final Map<String, dynamic> data = json.decode(response);
    final List<dynamic> menuItemsJson = data['menu_items'];
    
    return menuItemsJson.map((json) => MenuItem.fromJson(json)).toList();
  }

  static Future<MenuItem?> getMenuItemById(String id) async {
    final items = await getMenuItems();
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Order>> getOrders() async {
    final String response = await rootBundle.loadString('assets/data/orders.json');
    final Map<String, dynamic> data = json.decode(response);
    final List<dynamic> ordersJson = data['orders'];
    
    return ordersJson.map((json) => Order.fromJson(json)).toList();
  }

  static Future<Order?> getOrderById(String id) async {
    final orders = await getOrders();
    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> getCategories() async {
    final items = await getMenuItems();
    final Set<String> categories = items.map((item) => item.category).toSet();
    return categories.toList();
  }

  static Future<List<MenuItem>> getMenuItemsByCategory(String category) async {
    final items = await getMenuItems();
    return items.where((item) => item.category == category).toList();
  }

  static Future<List<status.OrderStatus>> getOrderStatuses() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      status.OrderStatus(
        id: 'order_1',
        tableNumber: '01',
        items: [
          status.OrderItem(
            id: 'item_1',
            name: 'Paneer Tikka',
            quantity: 1,
            status: 'in_progress',
            isModified: true,
          ),
          status.OrderItem(
            id: 'item_2',
            name: 'Paneer Chilli',
            quantity: 1,
            status: 'not_prepared',
            isModified: true,
          ),
          status.OrderItem(
            id: 'item_3',
            name: 'Chicken Kabab',
            quantity: 1,
            status: 'not_prepared',
            isModified: true,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        status: 'pending',
      ),
      status.OrderStatus(
        id: 'order_2',
        tableNumber: '02',
        items: [
          status.OrderItem(
            id: 'item_4',
            name: 'Paneer Tikka',
            quantity: 1,
            status: 'served',
            isModified: true,
          ),
          status.OrderItem(
            id: 'item_5',
            name: 'Spring Roll',
            quantity: 2,
            status: 'served',
            isModified: true,
          ),
          status.OrderItem(
            id: 'item_6',
            name: 'Hakka noodles',
            quantity: 1,
            status: 'not_prepared',
            isModified: true,
          ),
          status.OrderItem(
            id: 'item_7',
            name: 'Fried Rice',
            quantity: 1,
            status: 'not_prepared',
            isModified: true,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        status: 'preparing',
      ),
    ];
  }

  static Future<Bill> generateBill(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return Bill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      tableNumber: '02',
      personCount: 2,
      orderId: orderId,
      serverId: '#4447',
      items: [
        BillItem(
          id: 'item_1',
          name: 'Chicken Tikka',
          category: 'Starter',
          quantity: 2,
          price: 350.0,
          total: 700.0,
        ),
        BillItem(
          id: 'item_2',
          name: 'Butter Chicken',
          category: 'Main',
          quantity: 1,
          price: 350.0,
          total: 350.0,
        ),
        BillItem(
          id: 'item_3',
          name: 'Paneer Masala',
          category: 'Main',
          quantity: 1,
          price: 250.0,
          total: 250.0,
        ),
        BillItem(
          id: 'item_4',
          name: 'Butter Naan',
          category: 'Breads',
          quantity: 10,
          price: 22.0,
          total: 220.0,
        ),
        BillItem(
          id: 'item_5',
          name: 'Chicken Dum Biryani',
          category: 'Rice',
          quantity: 1,
          price: 400.0,
          total: 400.0,
        ),
      ],
      itemsTotal: 1920.0,
      discount: 100.0,
      gst: 10.0,
      total: 1920.0,
      createdAt: DateTime.now(),
    );
  }

  static Future<Bill> getBillById(String billId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return generateBill('order_123');
  }
}
