// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/order_status.dart';
import '../../../data/repositories/order_status_repository.dart';
import '../../../core/controllers/global_data_controller.dart';
import '../../../core/utils/toast_helper.dart';

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
      ToastHelper.showError('Failed to load order statuses: $e');
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
      
      ToastHelper.showSuccess('Order item status updated');
    } catch (e) {
      ToastHelper.showError('Failed to update status: $e');
    }
  }

  Future<void> sendBill(String orderId) async {
    try {
      await _repository.sendBill(orderId);
      ToastHelper.showSuccess('Bill sent successfully');
    } catch (e) {
      ToastHelper.showError('Failed to send bill: $e');
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
        
        ToastHelper.showSuccess('Item deleted successfully');
        
        // Notify global controller to refresh bill data
        try {
          GlobalDataController.instance.notifyAllUpdates();
        } catch (e) {
          print('Global controller not found, skipping notification');
        }
      } else {
        ToastHelper.showError('Cannot delete item. Order may be billed or item already processed.');
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
      
      ToastHelper.showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItemQuantity(String orderId, String itemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        // If quantity is 0 or less, delete the item
        await deleteOrderItem(orderId, itemId);
        return;
      }

      isLoading.value = true;
      
      // Update quantity in local state first for immediate UI feedback
      final orderIndex = orderStatuses.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final order = orderStatuses[orderIndex];
        final itemIndex = order.items.indexWhere((item) => item.id == itemId);
        if (itemIndex != -1) {
          final oldItem = order.items[itemIndex];
          final updatedItems = List<OrderItem>.from(order.items);
          updatedItems[itemIndex] = OrderItem(
            id: oldItem.id,
            name: oldItem.name,
            quantity: newQuantity,
            status: oldItem.status,
            isModified: true, // Mark as modified
          );
          
          orderStatuses[orderIndex] = OrderStatus(
            id: order.id,
            tableNumber: order.tableNumber,
            items: updatedItems,
            createdAt: order.createdAt,
            status: order.status,
          );
          orderStatuses.refresh();
        }
      }

      // Call API to update quantity on backend
      final success = await _repository.updateItemQuantity(itemId, newQuantity);
      
      if (success) {
        ToastHelper.showSuccess('Quantity updated successfully');
        
        // Notify global controller to refresh bill data
        try {
          GlobalDataController.instance.notifyAllUpdates();
        } catch (e) {
          print('Global controller not found, skipping notification');
        }
      } else {
        // Revert local changes if API call failed
        await loadOrderStatuses();
        ToastHelper.showError('Failed to update quantity on server. Changes reverted.');
      }
      
    } catch (e) {
      print('🔥 Update quantity failed: $e');
      ToastHelper.showError('Failed to update quantity. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void incrementQuantity(String orderId, String itemId) {
    final orderIndex = orderStatuses.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final order = orderStatuses[orderIndex];
      final itemIndex = order.items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final currentQuantity = order.items[itemIndex].quantity;
        updateItemQuantity(orderId, itemId, currentQuantity + 1);
      }
    }
  }

  void decrementQuantity(String orderId, String itemId) {
    final orderIndex = orderStatuses.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final order = orderStatuses[orderIndex];
      final itemIndex = order.items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final currentQuantity = order.items[itemIndex].quantity;
        if (currentQuantity > 1) {
          updateItemQuantity(orderId, itemId, currentQuantity - 1);
        } else {
          // If quantity becomes 0, delete the item
          deleteOrderItem(orderId, itemId);
        }
      }
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
