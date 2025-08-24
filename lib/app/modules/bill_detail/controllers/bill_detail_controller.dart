import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/bill.dart';
import '../../../data/providers/bill_api_provider.dart';
import '../../../core/utils/toast_helper.dart';

class BillDetailController extends GetxController {
  late Bill bill;
  var billItems = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  
  // Check if bill is completed/billed
  bool get isBillCompleted => bill.status.toLowerCase() == 'completed' || bill.status.toLowerCase() == 'billed';

  // Calculated values based on actual items (for active bills) or bill totals (for completed bills)
  double get calculatedSubtotal {
    if (isBillCompleted) {
      // For completed bills, use the bill's itemsTotal (Gross)
      return bill.itemsTotal;
    } else {
      // For active bills, calculate from items
      double subtotal = 0.0;
      for (var item in billItems) {
        double rate = (item['Rate'] as num?)?.toDouble() ?? 0.0;
        int qty = (item['Qty'] as num?)?.toInt() ?? 0;
        subtotal += (rate * qty);
      }
      return subtotal;
    }
  }

  double get calculatedGst {
    if (isBillCompleted) {
      // For completed bills, use the bill's GST
      return bill.gst;
    } else {
      // For active bills, calculate 5% GST
      return calculatedSubtotal * 0.05;
    }
  }

  double get calculatedTotal {
    if (isBillCompleted) {
      // For completed bills, use the bill's total
      return bill.total;
    } else {
      // For active bills, calculate total
      return calculatedSubtotal + calculatedGst;
    }
  }

  @override
  void onInit() {
    super.onInit();
    bill = Get.arguments as Bill;
    loadBillItems();
  }

  Future<void> loadBillItems() async {
    try {
      isLoading.value = true;
      
      if (isBillCompleted) {
        // For completed bills, create items based on bill info
        print('📋 Bill ${bill.tableNumber} is completed (${bill.orderId}). Creating item summary.');
        
        // Create a single summary item for completed bills
        Map<String, dynamic> summaryItem = {
          'ItemName': '${bill.orderId} Items Summary',
          'Qty': bill.personCount,
          'Rate': bill.itemsTotal / bill.personCount, // Average rate per item
          'NetAmt': bill.itemsTotal,
        };
        
        billItems.assignAll([summaryItem]);
        print('✅ Created summary for completed bill: ${bill.personCount} items, ₹${bill.itemsTotal}');
      } else {
        // For active bills, fetch actual items
        print('📋 Loading items for active bill: ${bill.tableNumber}');
        final items = await BillApiProvider.fetchTableBillItems(bill.tableNumber);
        billItems.assignAll(items.cast<Map<String, dynamic>>());
        print('✅ Loaded ${billItems.length} items for table ${bill.tableNumber}');
      }
    } catch (e) {
      print('❌ Failed to load bill items: $e');
      ToastHelper.showError('Failed to load bill items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void printKOT() {
    // Show KOT thermal print preview dialog directly
    _showKOTThermalPrintPreview();
  }

  void printBill() {
    // Show thermal print preview dialog directly
    _showThermalPrintPreview();
  }

  void _showThermalPrintPreview() {
    final currentTime = DateTime.now();
    final timeString = "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}";
    final dateString = "${currentTime.day.toString().padLeft(2, '0')}/${currentTime.month.toString().padLeft(2, '0')}/${currentTime.year}";
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          height: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '2" Thermal Print Preview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Thermal Print Preview Container (57mm width simulation)
              Expanded(
                child: Container(
                  width: 200, // Simulating 57mm thermal paper width
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // Restaurant Header
                        Text(
                          'SERV RESTAURANT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Food & Beverages',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '=============================',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Bill Details
                        Text(
                          'Table: ${bill.tableNumber}     Bill: ${bill.orderId}',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        Text(
                          'Date: $dateString  Time: $timeString',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 2),
                        Text(
                          '=============================',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Items Header
                        Text(
                          'ITEM                QTY   AMT',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        Text(
                          '-----------------------------',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        // Items List
                        ...billItems.map((item) => Column(
                          children: [
                            // Item name and price on first line
                            Text(
                              _formatItemLine(
                                (item['ItemName'] ?? 'Unknown Item').toString(),
                                (item['Qty'] as num?)?.toInt() ?? 0,
                                (item['NetAmt'] as num?)?.toStringAsFixed(2) ?? '0.00'
                              ),
                              style: TextStyle(
                                fontSize: 7,
                                fontFamily: 'monospace',
                              ),
                            ),
                            // Rate on second line
                            Text(
                              '  @ ₹${(item['Rate'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                fontSize: 7,
                                fontFamily: 'monospace',
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                        )),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          '-----------------------------',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        Text(
                          '*Prices inclusive of all taxes',
                          style: TextStyle(
                            fontSize: 6,
                            fontFamily: 'monospace',
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 2),
                        
                        // Totals
                        Text(
                          _formatTotalLine('SUBTOTAL:', calculatedSubtotal.toStringAsFixed(2)),
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        Text(
                          _formatTotalLine('GST (5%):', calculatedGst.toStringAsFixed(2)),
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        Text(
                          '=============================',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        Text(
                          _formatTotalLine('GRAND TOTAL:', calculatedTotal.toStringAsFixed(2)),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        Text(
                          '=============================',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'THANK YOU FOR VISITING!',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        Text(
                          'Please visit us again',
                          style: TextStyle(
                            fontSize: 7,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'GST No: 29ABCDE1234F1Z5',
                          style: TextStyle(
                            fontSize: 6,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        Text(
                          'Contact: +91 98765 43210',
                          style: TextStyle(
                            fontSize: 6,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2D3142),
                        side: const BorderSide(color: Color(0xFF2D3142)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        // Here you can add actual print functionality
                        ToastHelper.showSuccess('Bill sent to thermal printer!');
                      },
                      icon: const Icon(Icons.print, color: Colors.white, size: 18),
                      label: const Text(
                        'Print Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKOTThermalPrintPreview() {
    final currentTime = DateTime.now();
    final timeString = "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}";
    final dateString = "${currentTime.day.toString().padLeft(2, '0')}/${currentTime.month.toString().padLeft(2, '0')}/${currentTime.year}";
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          height: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'KOT - Kitchen Order Ticket',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Thermal Print Preview Container (57mm width simulation)
              Expanded(
                child: Container(
                  width: 200, // Simulating 57mm thermal paper width
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // Restaurant Header
                        Text(
                          'SERV RESTAURANT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '--- KITCHEN COPY ---',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '=============================',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // KOT Details
                        Text(
                          'Table: ${bill.tableNumber}     KOT: ${bill.orderId}',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        Text(
                          'Date: $dateString  Time: $timeString',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        Text(
                          'Waiter: ${bill.userName}',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 2),
                        Text(
                          '=============================',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Items Header (NO AMOUNT COLUMN)
                        Text(
                          'ITEM NAME              QTY',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        Text(
                          '-----------------------------',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        // Items List (NO RATES OR AMOUNTS)
                        ...billItems.map((item) => Text(
                          _formatKOTItemLine(
                            (item['ItemName'] ?? 'Unknown Item').toString(),
                            (item['Qty'] as num?)?.toInt() ?? 0,
                          ),
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        )),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          '-----------------------------',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        Text(
                          'Total Items: ${billItems.length}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Special Instructions:',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        Text(
                          '____________________________',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        Text(
                          '____________________________',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          '=============================',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        Text(
                          '** KITCHEN COPY **',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        Text(
                          'NO RATES - KITCHEN USE ONLY',
                          style: TextStyle(
                            fontSize: 7,
                            fontFamily: 'monospace',
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2D3142),
                        side: const BorderSide(color: Color(0xFF2D3142)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        ToastHelper.showSuccess('KOT sent to kitchen printer!');
                      },
                      icon: const Icon(Icons.print, color: Colors.white, size: 18),
                      label: const Text(
                        'Print KOT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void proceedToPayment() {
    Get.toNamed('/payment_method', arguments: bill);
  }

  // Helper function to format item line with proper alignment
  String _formatItemLine(String itemName, int qty, String amount) {
    // Truncate item name if too long (max 17 chars for proper alignment)
    String shortName = itemName.length > 17 ? 
      itemName.substring(0, 17) : itemName;
    
    // Pad the line to ensure proper alignment
    String qtyStr = qty.toString().padLeft(3);
    String amtStr = '₹$amount';
    
    // Calculate spacing
    int nameLength = shortName.length;
    int spacesNeeded = 29 - nameLength - qtyStr.length - amtStr.length;
    if (spacesNeeded < 1) spacesNeeded = 1;
    
    String spaces1 = ' ' * spacesNeeded;
    String spaces2 = ' ';
    
    return '$shortName$spaces1$qtyStr$spaces2$amtStr';
  }

  // Helper function to format total lines with proper alignment
  String _formatTotalLine(String label, String amount) {
    String amtStr = '₹$amount';
    int spacesNeeded = 29 - label.length - amtStr.length;
    if (spacesNeeded < 1) spacesNeeded = 1;
    String spaces = ' ' * spacesNeeded;
    return '$label$spaces$amtStr';
  }

  // Helper function to format KOT item line with only name and quantity (no amounts)
  String _formatKOTItemLine(String itemName, int qty) {
    // Truncate item name if too long (max 22 chars for KOT format)
    String shortName = itemName.length > 22 ? 
      itemName.substring(0, 22) : itemName;
    
    // Pad the line to ensure proper alignment
    String qtyStr = qty.toString().padLeft(3);
    
    // Calculate spacing
    int nameLength = shortName.length;
    int spacesNeeded = 29 - nameLength - qtyStr.length;
    if (spacesNeeded < 1) spacesNeeded = 1;
    
    String spaces = ' ' * spacesNeeded;
    
    return '$shortName$spaces$qtyStr';
  }
}
