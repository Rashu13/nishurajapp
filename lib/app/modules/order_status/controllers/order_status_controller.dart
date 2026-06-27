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
  
  // Room type filter
  final RxString selectedRoomFilter = 'all'.obs; // all, restaurant, ncBilling, room



  @override
  void onInit() {
    super.onInit();
    loadOrderStatuses();
  }


  Future<void> loadOrderStatuses() async {
    try {
      isLoading.value = true;
      final statuses = await _repository.getOrderStatuses();
      
      // Filter orders from current shift (3 AM today to 3 AM tomorrow)
      final now = DateTime.now();
      final shiftStartTime = DateTime(
        now.hour >= 3 ? now.year : now.subtract(const Duration(days: 1)).year,
        now.hour >= 3 ? now.month : now.subtract(const Duration(days: 1)).month,
        now.hour >= 3 ? now.day : now.subtract(const Duration(days: 1)).day,
        3, 0, 0, // 3 AM
      );
      final shiftEndTime = shiftStartTime.add(const Duration(hours: 24));
      
      print('🕐 Current Shift: ${shiftStartTime.toString()} to ${shiftEndTime.toString()}');
      
      final filteredStatuses = statuses.where((order) {
        return order.createdAt.isAfter(shiftStartTime) && 
               order.createdAt.isBefore(shiftEndTime);
      }).toList();
      
      print('📊 Filtered ${filteredStatuses.length} orders from ${statuses.length} total');
      
      orderStatuses.assignAll(filteredStatuses);
    } catch (e) {
      ToastHelper.showError('Failed to load order statuses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<OrderStatus> get filteredOrderStatuses {
    List<OrderStatus> filtered = searchQuery.value.isEmpty
        ? orderStatuses.toList()
        : orderStatuses
            .where((order) => order.tableNumber
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()))
            .toList();
    
    // Apply room type filter based on BillType
    if (selectedRoomFilter.value != 'all') {
      print('🔍 Applying filter: ${selectedRoomFilter.value}');
      filtered = filtered.where((order) {
        print('  Table ${order.tableNumber}: BillType = ${order.billType}');
        switch (selectedRoomFilter.value) {
          case 'restaurant':
            return order.billType == 1;
          case 'ncBilling':
            return order.billType == 2;
          case 'room':
            return order.billType >= 3;
          default:
            return true;
        }
      }).toList();
      print('✅ Filtered to ${filtered.length} orders');
    }
    
    // Group by table number and sort
    Map<String, List<OrderStatus>> groupedByTable = {};
    for (var order in filtered) {
      if (!groupedByTable.containsKey(order.tableNumber)) {
        groupedByTable[order.tableNumber] = [];
      }
      groupedByTable[order.tableNumber]!.add(order);
    }
    
    // Sort table numbers
    final sortedTableNumbers = groupedByTable.keys.toList()
      ..sort((a, b) {
        // Try to parse as numbers for proper numeric sorting
        final aNum = int.tryParse(a);
        final bNum = int.tryParse(b);
        if (aNum != null && bNum != null) {
          return aNum.compareTo(bNum);
        }
        return a.compareTo(b);
      });
    
    // Flatten back to list with grouped orders
    List<OrderStatus> result = [];
    for (var tableNumber in sortedTableNumbers) {
      result.addAll(groupedByTable[tableNumber]!);
    }
    
    return result;
  }
  
  void selectRoomFilter(String filter) {
    selectedRoomFilter.value = filter;
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
              billType: order.billType,
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
            billType: order.billType,
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
