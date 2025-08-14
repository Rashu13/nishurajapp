import 'package:flutter/services.dart';
import '../models/bill.dart';

class ThermalPrintService {
  static const platform = MethodChannel('thermal_print');

  // Print bill on 2" thermal printer
  static Future<bool> printBill({
    required Bill bill,
    required List<Map<String, dynamic>> billItems,
    String? customerName,
    String? customerPhone,
  }) async {
    try {
      // Generate print data for 2" thermal printer (58mm width)
      final printData = _generateThermalPrintData(
        bill: bill,
        billItems: billItems,
        customerName: customerName,
        customerPhone: customerPhone,
      );

      // For now, we'll show the print preview in console
      print('=== THERMAL PRINT DATA ===');
      print(printData);
      print('==========================');

      // In real implementation, you would send this to thermal printer
      // final result = await platform.invokeMethod('printThermal', {
      //   'data': printData,
      //   'printerType': 'thermal_58mm'
      // });

      return true; // Simulate successful printing
    } catch (e) {
      print('Print error: $e');
      return false;
    }
  }

  static String _generateThermalPrintData({
    required Bill bill,
    required List<Map<String, dynamic>> billItems,
    String? customerName,
    String? customerPhone,
  }) {
    final buffer = StringBuffer();
    final DateTime now = DateTime.now();
    
    // Restaurant Header (Center aligned for 2" printer)
    buffer.writeln(_centerText('SERV RESTAURANT', 32));
    buffer.writeln(_centerText('Delicious Food & Service', 32));
    buffer.writeln(_centerText('📍 123 Food Street, City', 32));
    buffer.writeln(_centerText('📞 +91 98765 43210', 32));
    buffer.writeln(_printLine(32));
    
    // Bill Info
    buffer.writeln('Bill No: ${bill.id}');
    buffer.writeln('Table: ${bill.tableNumber}');
    buffer.writeln('Date: ${_formatDate(now)}');
    buffer.writeln('Time: ${_formatTime(now)}');
    
    if (customerName != null && customerName.isNotEmpty) {
      buffer.writeln('Customer: $customerName');
    }
    if (customerPhone != null && customerPhone.isNotEmpty) {
      buffer.writeln('Phone: $customerPhone');
    }
    
    buffer.writeln(_printLine(32));
    
    // Items Header
    buffer.writeln('ITEM${' ' * 16}QTY  RATE  AMT');
    buffer.writeln(_printLine(32));
    
    // Bill Items
    double totalAmount = 0;
    for (var item in billItems) {
      final name = (item['itemName'] ?? 'Unknown Item').toString();
      final quantity = (item['quantity'] ?? 0).toString();
      final rate = double.tryParse(item['rate']?.toString() ?? '0') ?? 0;
      final amount = double.tryParse(item['amount']?.toString() ?? '0') ?? 0;
      
      totalAmount += amount;
      
      // Truncate item name if too long for 2" printer
      final itemName = name.length > 16 ? name.substring(0, 16) : name;
      final itemLine = itemName.padRight(16);
      final qtyStr = quantity.padLeft(3);
      final rateStr = rate.toStringAsFixed(0).padLeft(5);
      final amtStr = amount.toStringAsFixed(0).padLeft(5);
      
      buffer.writeln('$itemLine$qtyStr $rateStr $amtStr');
    }
    
    buffer.writeln(_printLine(32));
    
    // Totals
    final subTotal = totalAmount;
    final tax = subTotal * 0.05; // 5% tax
    final grandTotal = subTotal + tax;
    
    buffer.writeln('Sub Total:${grandTotal.toStringAsFixed(2).padLeft(20)}');
    buffer.writeln('CGST 2.5%:${(tax / 2).toStringAsFixed(2).padLeft(20)}');
    buffer.writeln('SGST 2.5%:${(tax / 2).toStringAsFixed(2).padLeft(20)}');
    buffer.writeln(_printLine(32));
    buffer.writeln('GRAND TOTAL:${grandTotal.toStringAsFixed(2).padLeft(17)}');
    buffer.writeln(_printLine(32));
    
    // Payment Info
    buffer.writeln(_centerText('Payment Mode: Cash', 32));
    buffer.writeln(_centerText('Amount Paid: ₹${grandTotal.toStringAsFixed(2)}', 32));
    
    buffer.writeln(_printLine(32));
    
    // Footer
    buffer.writeln(_centerText('Thank You for Visiting!', 32));
    buffer.writeln(_centerText('Please Visit Again', 32));
    buffer.writeln(_centerText('⭐⭐⭐⭐⭐', 32));
    
    // QR Code placeholder
    buffer.writeln(_centerText('Scan for Review:', 32));
    buffer.writeln(_centerText('[QR CODE PLACEHOLDER]', 32));
    
    // Cut paper command for thermal printer
    buffer.writeln('\n\n\n');
    buffer.writeln('[CUT]');
    
    return buffer.toString();
  }

  static String _centerText(String text, int width) {
    if (text.length >= width) return text;
    final padding = (width - text.length) ~/ 2;
    return ' ' * padding + text;
  }

  static String _printLine(int width) {
    return '-' * width;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  // Get printer status
  static Future<Map<String, dynamic>> getPrinterStatus() async {
    try {
      // final result = await platform.invokeMethod('getPrinterStatus');
      // return Map<String, dynamic>.from(result);
      
      // Simulate printer status
      return {
        'isConnected': true,
        'paperStatus': 'OK',
        'batteryLevel': 85,
        'printerModel': 'Thermal 58mm'
      };
    } catch (e) {
      return {
        'isConnected': false,
        'error': e.toString()
      };
    }
  }

  // Print test page
  static Future<bool> printTestPage() async {
    try {
      final testData = _generateTestPrintData();
      print('=== TEST PRINT DATA ===');
      print(testData);
      print('=======================');
      return true;
    } catch (e) {
      print('Test print error: $e');
      return false;
    }
  }

  static String _generateTestPrintData() {
    final buffer = StringBuffer();
    
    buffer.writeln(_centerText('TEST PRINT', 32));
    buffer.writeln(_printLine(32));
    buffer.writeln('Printer: Thermal 58mm (2")');
    buffer.writeln('Date: ${_formatDate(DateTime.now())}');
    buffer.writeln('Time: ${_formatTime(DateTime.now())}');
    buffer.writeln(_printLine(32));
    buffer.writeln('Font Test:');
    buffer.writeln('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    buffer.writeln('abcdefghijklmnopqrstuvwxyz');
    buffer.writeln('0123456789 !@#\$%^&*()');
    buffer.writeln(_printLine(32));
    buffer.writeln('Special Characters:');
    buffer.writeln('₹ € \$ £ ¥ ¢');
    buffer.writeln('✓ ✗ ★ ☆ ♥ ♦ ♣ ♠');
    buffer.writeln(_printLine(32));
    buffer.writeln(_centerText('Test Completed ✓', 32));
    buffer.writeln('\n\n[CUT]');
    
    return buffer.toString();
  }
}
