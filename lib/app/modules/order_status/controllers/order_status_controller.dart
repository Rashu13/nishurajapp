// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/order_status.dart';
import '../../../data/repositories/order_status_repository.dart';

class OrderStatusController extends GetxController {
  final OrderStatusRepository _repository = OrderStatusRepository();
  
  final RxList<OrderStatus> orderStatuses = <OrderStatus>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;



  @override
  void onInit() {
    super.onInit();
    loadOrderStatuses();
  }


  Future<void> loadOrderStatuses() async {
    try {
      isLoading.value = true;
      final statuses = await _repository.getOrderStatuses();
      orderStatuses.assignAll(statuses);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load order statuses: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<OrderStatus> get filteredOrderStatuses {
    if (searchQuery.value.isEmpty) {
      return orderStatuses;
    }
    return orderStatuses
        .where((order) => order.tableNumber
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  void searchTable(String query) {
    searchQuery.value = query;
  }

  Future<void> updateOrderItemStatus(String orderId, String itemId, String status) async {
    try {
      await _repository.updateOrderItemStatus(orderId, itemId, status);
      
      // Update local state
      final orderIndex = orderStatuses.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final itemIndex = orderStatuses[orderIndex].items
            .indexWhere((item) => item.id == itemId);
        if (itemIndex != -1) {
          orderStatuses[orderIndex].items[itemIndex] = OrderItem(
            id: orderStatuses[orderIndex].items[itemIndex].id,
            name: orderStatuses[orderIndex].items[itemIndex].name,
            quantity: orderStatuses[orderIndex].items[itemIndex].quantity,
            status: status,
            isModified: orderStatuses[orderIndex].items[itemIndex].isModified,
          );
          orderStatuses.refresh();
        }
      }
      
      Get.snackbar(
        'Success',
        'Order item status updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> sendBill(String orderId) async {
    try {
      await _repository.sendBill(orderId);
      Get.snackbar(
        'Success',
        'Bill sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send bill: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addDishes() async {
    Get.toNamed('/home');
    }
  

  void deleteOrderItem(String orderId, String itemId) {
    final orderIndex = orderStatuses.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      orderStatuses[orderIndex].items.removeWhere((item) => item.id == itemId);
      orderStatuses.refresh();
      
      Get.snackbar(
        'Success',
        'Item removed from order',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    }
  }

  String getStatusDisplayText(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'served':
        return 'Served';
      case 'not_prepared':
        return 'Not Prepared';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'in_progress':
        return const Color(0xFFFFA726); // Orange
      case 'served':
        return const Color(0xFF66BB6A); // Green
      case 'not_prepared':
        return const Color(0xFFEF5350); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}
