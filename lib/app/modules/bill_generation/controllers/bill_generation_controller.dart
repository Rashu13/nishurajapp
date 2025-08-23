import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/bill.dart';
import '../../../data/repositories/bill_repository.dart';
import '../../../core/controllers/global_data_controller.dart';
import '../../../core/utils/toast_helper.dart';

class BillGenerationController extends GetxController {
  final BillRepository _repository = BillRepository();
  
  var billsList = <Bill>[].obs;
  var isLoading = false.obs;
  var searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBills();
    
    // Listen for global data updates
    try {
      ever(GlobalDataController.instance.billDataUpdated, (_) {
        print('🔄 Bill Controller: Received data update notification');
        loadBills();
      });
    } catch (e) {
      print('Global controller not found, continuing without listener');
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh bills when view becomes ready/visible again
    loadBills();
  }

  Future<void> loadBills() async {
    try {
      isLoading.value = true;
      print('🔄 Loading bills...');
      final bills = await _repository.getTableBills();
      billsList.assignAll(bills);
      print('✅ Bills loaded: ${bills.length} bills');
      
      // Debug each bill's status
      for (var bill in bills) {
        print('📋 Bill ${bill.tableNumber}: status="${bill.status}", orderId=${bill.orderId}');
      }
      
    } catch (e) {
      print('❌ Failed to load bills: $e');
      ToastHelper.showError('Failed to load bills: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchText(String text) {
    searchText.value = text;
  }

  List<Bill> get filteredBills {
    if (searchText.value.isEmpty) {
      return billsList;
    }
    return billsList.where((bill) => 
      bill.tableNumber.toLowerCase().contains(searchText.value.toLowerCase())
    ).toList();
  }

  void selectBill(Bill bill) {
    Get.toNamed('/bill_detail', arguments: bill);
  }

  Future<void> resetTable(Bill bill) async {
    try {
      // Parse table number to int
      int tableId = int.tryParse(bill.tableNumber.toString()) ?? 0;
      
      if (tableId <= 0) {
        ToastHelper.showError('Invalid table number');
        return;
      }

      // Show confirmation dialog
      bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Reset Table'),
          content: Text('Are you sure you want to reset Table $tableId? This will clear all completed orders for this table.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Get.back(result: true),
              child: const Text('Reset'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final success = await _repository.resetTable(tableId);
      
      if (success) {
        ToastHelper.showSuccess('Table $tableId reset successfully');
        // Refresh the bills list
        loadBills();
      } else {
        ToastHelper.showError('Failed to reset table');
      }
    } catch (e) {
      print('❌ Failed to reset table: $e');
      ToastHelper.showError('Failed to reset table: $e');
    }
  }
}
