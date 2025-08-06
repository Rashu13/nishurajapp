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
  

  Future<void> deleteOrderItem(String orderId, String itemId) async {
    try {
      isLoading.value = true;
      
      // Call API to delete item
      final success = await _repository.deleteOrderItem(itemId);
      
      if (success) {
        // Remove item from local state after successful API call
        final orderIndex = orderStatuses.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          final order = orderStatuses[orderIndex];
          final updatedItems = order.items.where((item) => item.id != itemId).toList();
          
          if (updatedItems.isEmpty) {
            // Remove entire order if no items left
            orderStatuses.removeAt(orderIndex);
          } else {
            // Update order with remaining items
            orderStatuses[orderIndex] = OrderStatus(
              id: order.id,
              tableNumber: order.tableNumber,
              items: updatedItems,
              createdAt: order.createdAt,
              status: order.status,
            );
          }
        }
        
        Get.snackbar(
          'Success',
          'Item deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Cannot delete item. Order may be billed or item already processed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('🔥 Delete operation failed: $e');
      
      String errorMessage;
      if (e.toString().contains('Backend server error')) {
        errorMessage = 'Delete feature temporarily unavailable. Please contact support.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred. Please try again later.';
      } else {
        errorMessage = 'Failed to delete item. Please try again.';
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
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
