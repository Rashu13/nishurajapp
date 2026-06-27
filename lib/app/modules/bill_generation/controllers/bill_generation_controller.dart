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
  final RxString selectedBillTypeFilter = 'all'.obs; // all, restaurant, ncBilling, room

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
        print('📋 Bill ${bill.tableNumber}: billStatus=${bill.billStatus}, orderId=${bill.orderId}');
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
    // Filter by shift (3 AM to 3 AM)
    final now = DateTime.now();
    final shiftStartTime = DateTime(
      now.hour >= 3 ? now.year : now.subtract(const Duration(days: 1)).year,
      now.hour >= 3 ? now.month : now.subtract(const Duration(days: 1)).month,
      now.hour >= 3 ? now.day : now.subtract(const Duration(days: 1)).day,
      3, 0, 0, // 3 AM
    );
    final shiftEndTime = shiftStartTime.add(const Duration(hours: 24));
    
    print('🕐 Bill Gen Shift: ${shiftStartTime.toString()} to ${shiftEndTime.toString()}');
    
    // Filter by billStatus=false (active bills only), shift time, bill type, and search text
    List<Bill> filtered = billsList.where((bill) {
      // Must have billStatus == false (active/running)
      bool isActive = bill.billStatus == false;
      
      // Must be within current shift
      bool isInShift = bill.billDate.isAfter(shiftStartTime) && 
                       bill.billDate.isBefore(shiftEndTime);
      
      // Must match bill type filter
      bool matchesBillType = true;
      if (selectedBillTypeFilter.value != 'all') {
        switch (selectedBillTypeFilter.value) {
          case 'restaurant':
            matchesBillType = bill.billType == 1;
            break;
          case 'ncBilling':
            matchesBillType = bill.billType == 2;
            break;
          case 'room':
            matchesBillType = bill.billType >= 3;
            break;
        }
      }
      
      // Must match search text if provided
      bool matchesSearch = searchText.value.isEmpty 
        ? true
        : bill.tableNumber.toLowerCase().contains(searchText.value.toLowerCase());
      
      return isActive && isInShift && matchesBillType && matchesSearch;
    }).toList();
    
    print('📊 Bill Gen: Filtered ${filtered.length} bills from ${billsList.length} total');
    
    // Group bills by table number
    Map<String, List<Bill>> groupedByTable = {};
    for (var bill in filtered) {
      if (!groupedByTable.containsKey(bill.tableNumber)) {
        groupedByTable[bill.tableNumber] = [];
      }
      groupedByTable[bill.tableNumber]!.add(bill);
    }
    
    // Flatten grouped bills - each table's bills together
    List<Bill> result = [];
    groupedByTable.forEach((tableNumber, bills) {
      result.addAll(bills);
    });
    
    return result;
  }

  void selectBill(Bill bill) {
    Get.toNamed('/bill_detail', arguments: bill);
  }
  
  void selectBillTypeFilter(String filter) {
    selectedBillTypeFilter.value = filter;
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
