import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/bill.dart';
import '../../../data/providers/bill_api_provider.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../data/services/thermal_print_service.dart';

class BillDetailController extends GetxController {
  late Bill bill;
  var billItems = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    bill = Get.arguments as Bill;
    loadBillItems();
  }

  Future<void> loadBillItems() async {
    try {
      isLoading.value = true;
      final items = await BillApiProvider.fetchTableBillItems(bill.tableNumber);
      billItems.assignAll(items.cast<Map<String, dynamic>>());
    } catch (e) {
      ToastHelper.showError('Failed to load bill items: $e');
    } finally {
      isLoading.value = false;
    }
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
                            fontSize: 12,
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
                        Text(
                          '================================',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Bill Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Table: ${bill.tableNumber}',
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Bill: ${bill.orderId}',
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date: $dateString',
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Time: $timeString',
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        
                        Text(
                          '================================',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Items Header
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'ITEM',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'QTY',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'AMOUNT',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        
                        Text(
                          '--------------------------------',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        // Items List
                        ...billItems.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Column(
                            children: [
                              // Item name (full width)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      (item['ItemName'] ?? 'Unknown Item').toString().toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 7,
                                        fontFamily: 'monospace',
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              // Quantity and amount
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      '@ ₹${(item['Rate'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(
                                        fontSize: 7,
                                        fontFamily: 'monospace',
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${(item['Qty'] as num?)?.toInt() ?? 0}',
                                      style: TextStyle(
                                        fontSize: 7,
                                        fontFamily: 'monospace',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '₹${(item['NetAmt'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(
                                        fontSize: 7,
                                        fontFamily: 'monospace',
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )).toList(),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          '--------------------------------',
                          style: TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        // Totals
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SUBTOTAL:',
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              '₹${bill.itemsTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GST (18%):',
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              '₹${bill.gst.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        
                        Text(
                          '================================',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GRAND TOTAL:',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              '₹${bill.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        
                        Text(
                          '================================',
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
                        foregroundColor: const Color(0xFF6C757D),
                        side: const BorderSide(color: Color(0xFF6C757D)),
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

  void proceedToPayment() {
    Get.toNamed('/payment_method', arguments: bill);
  }

  // Test print function
  void testPrint() async {
    try {
      isLoading.value = true;
      
      final success = await ThermalPrintService.printTestPage();
      
      if (success) {
        ToastHelper.showSuccess('Test print completed successfully');
      } else {
        ToastHelper.showError('Test print failed');
      }
    } catch (e) {
      ToastHelper.showError('Test print error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Get printer status
  void checkPrinterStatus() async {
    try {
      final status = await ThermalPrintService.getPrinterStatus();
      
      if (status['isConnected']) {
        ToastHelper.showSuccess('Printer connected - ${status['printerModel']}');
      } else {
        ToastHelper.showError('Printer not connected');
      }
    } catch (e) {
      ToastHelper.showError('Unable to check printer status');
    }
  }
}
