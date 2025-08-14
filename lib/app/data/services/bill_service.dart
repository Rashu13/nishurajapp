import 'package:get_storage/get_storage.dart';

import '../../core/services/api_service.dart';
import '../models/menu_model.dart';

class BillService {
  final ApiService _apiService = ApiService();
  
  // KOT Management Methods
  Future<Map<String, dynamic>> sendKOTToKitchen({
    required int tableId,
    required List<Map<String, dynamic>> orderItems,
    required String remarks,
  }) async {
    try {
      // Generate unique KOT and Order numbers
      final kotNumber = DateTime.now().millisecondsSinceEpoch % 100000;
      final orderNo = DateTime.now().millisecondsSinceEpoch % 100000;
      
      // Calculate totals
      double totalGrossAmt = 0.0;
      double totalGst = 0.0;
      double totalTaxAmt = 0.0;
      double totalAmt = 0.0;
      
      List<Map<String, dynamic>> kotDetails = [];
      
      for (int i = 0; i < orderItems.length; i++) {
        final item = orderItems[i];
        final MenuModel menuItem = item['item'] as MenuModel;
        final quantity = item['quantity'] as int;
        final customizations = item['customizations'] as List<String>? ?? [];

        final rate = double.tryParse(menuItem.restrorate) ?? 0.0;
        final amt = double.parse((rate * quantity).toStringAsFixed(2));
        final itemGst = double.parse((amt * 0.05).toStringAsFixed(2)); // 5% GST
        final itemTaxAmt = itemGst;
        final itemNetAmt = double.parse((amt + itemTaxAmt).toStringAsFixed(2));

        totalGrossAmt = double.parse((totalGrossAmt + amt).toStringAsFixed(2));
        totalGst = double.parse((totalGst + itemGst).toStringAsFixed(2));
        totalTaxAmt = double.parse((totalTaxAmt + itemTaxAmt).toStringAsFixed(2));
        totalAmt = double.parse((totalAmt + itemNetAmt).toStringAsFixed(2));

        kotDetails.add({
          "KOTDID": 0,
          "KotNumber": kotNumber,
          "OrderNo": orderNo,
          "ItemID": menuItem.itemId,
          "Rate": double.parse(rate.toStringAsFixed(2)),
          "Qty": quantity.toDouble(),
          "Amt": double.parse(amt.toStringAsFixed(2)),
          "GST": double.parse(itemGst.toStringAsFixed(2)),
          "TaxAmt": double.parse(itemTaxAmt.toStringAsFixed(2)),
          "NetAmt": double.parse(itemNetAmt.toStringAsFixed(2)),
          "Remarks": customizations.isEmpty ? "sample string 2" : customizations.join(', '),
            "UserID": GetStorage().read('userId') ?? 1, // Use user ID from storage  
          "SessionID": 1,
          "Status": false,
          "OrderStatus": false
        });
      }
      
      // Generate unique KOT and Order numbers
      
      // Create KOT request
      Map<String, dynamic> kotRequest = {
        "OP": 1,
        "KOTMaster": {
          "KOTMID": 0,
          "KotNumber": kotNumber,
          "OrderNo": orderNo,
          "TableID": tableId,
          "PaxNo": 1,
          "Date": DateTime.now().toIso8601String(),
          "Time": "sample string 2",
          "StewardID": 1,
          "GrossAmt": totalGrossAmt,
          "Gst": totalGst, // sum of all items GST
          "TaxAmt": totalTaxAmt, // sum of all items TaxAmt
          "TotalAmt": totalAmt,
          "UserID": GetStorage().read('userId') ?? 1, // Use user ID from storage
          "SessionID": 1,
          "Status": false,
          "RemarksMaster": remarks.isEmpty ? "sample string 3" : remarks,
          "BillStatus": false
        },
        "KOTDetails": kotDetails
      };
      
      // Send KOT to API
      print('Sending KOT Request: ${kotRequest.toString()}');
      final response = await _apiService.post('/api/kot', kotRequest);
      print('KOT Response Status: ${response.statusCode}');
      print('KOT Response Data: ${response.data}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to send KOT to kitchen: ${response.statusCode} - ${response.data}');
      }
      
      final responseData = response.data;
      return {
        'success': true,
        'kotNumber': kotNumber, // Use app-generated number
        'kotMasterID': responseData['KOTMID'] ?? 0,
        'totalAmount': totalAmt,
        'message': responseData['Message'] ?? 'KOT sent to kitchen successfully'
      };
      
    } catch (e) {
      print('Error sending KOT to kitchen: $e');
      rethrow;
    }
  }
  
  // Add single item to existing KOT
  Future<Map<String, dynamic>> addItemToKOT({
    required int kotNumber,
    required int orderNo,
    required MenuModel menuItem,
    required int quantity,
    required List<String> customizations,
  }) async {
    try {
      final rate = double.tryParse(menuItem.restrorate) ?? 0.0;
      final amt = double.parse((rate * quantity).toStringAsFixed(2));
      final itemGst = double.parse((amt * 0.05).toStringAsFixed(2));
      final itemTaxAmt = itemGst;
      final itemNetAmt = double.parse((amt + itemTaxAmt).toStringAsFixed(2));
      
      Map<String, dynamic> kotItemRequest = {
        "OP": 1,
        "KOTDetail": {
          "KOTDID": 0,
          "KotNumber": kotNumber,
          "OrderNo": orderNo,
          "ItemID": menuItem.itemId,
          "Rate": double.parse(rate.toStringAsFixed(2)),
          "Qty": quantity.toDouble(),
          "Amt": double.parse(amt.toStringAsFixed(2)),
          "GST": double.parse(itemGst.toStringAsFixed(2)),
          "TaxAmt": double.parse(itemTaxAmt.toStringAsFixed(2)),
          "NetAmt": double.parse(itemNetAmt.toStringAsFixed(2)),
          "Remarks": customizations.join(', '),
          "UserID": GetStorage().read('userId') ?? 1,
          "SessionID": 1, // Set to 1 instead of null
          "Status": false,
          "OrderStatus": false
        }
      };
      
      final response = await _apiService.post('/api/kot/item', kotItemRequest);
      if (response.statusCode != 200) {
        throw Exception('Failed to add item to KOT');
      }
      
      return {
        'success': true,
        'message': response.data['Message'] ?? 'Item added to KOT successfully'
      };
      
    } catch (e) {
      print('Error adding item to KOT: $e');
      rethrow;
    }
  }
  
  // Get KOT by number
  Future<Map<String, dynamic>> getKOT(int kotNumber) async {
    try {
      final response = await _apiService.get('/api/kot/$kotNumber');
      if (response.statusCode != 200) {
        throw Exception('Failed to get KOT');
      }
      
      return {
        'success': true,
        'kotMaster': response.data['KOTMaster'],
        'kotDetails': response.data['KOTDetails']
      };
      
    } catch (e) {
      print('Error getting KOT: $e');
      rethrow;
    }
  }
  
  // Get all KOTs
  Future<Map<String, dynamic>> getAllKOTs() async {
    try {
      final response = await _apiService.get('/api/kot/list');
      if (response.statusCode != 200) {
        throw Exception('Failed to get KOTs');
      }
      
      return {
        'success': true,
        'kots': response.data['KOTs']
      };
      
    } catch (e) {
      print('Error getting KOTs: $e');
      rethrow;
    }
  }
  
  // Get KOTs by table
  Future<Map<String, dynamic>> getKOTsByTable(int tableId) async {
    try {
      final response = await _apiService.get('/api/kot/table/$tableId');
      if (response.statusCode != 200) {
        throw Exception('Failed to get KOTs for table');
      }
      
      return {
        'success': true,
        'kots': response.data['KOTs']
      };
      
    } catch (e) {
      print('Error getting KOTs by table: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> sendBillToKitchen({
    required int tableId,
    required List<Map<String, dynamic>> orderItems,
    required String remarks,
  }) async {
    try {
      // Generate unique KOT and Order numbers
      final kotNumber = DateTime.now().millisecondsSinceEpoch % 100000;
      final orderNo = DateTime.now().millisecondsSinceEpoch % 100000;
      
      print('DEBUG: Generated KOT Number: $kotNumber');
      print('DEBUG: Generated Order Number: $orderNo');
      
      // Calculate totals
      double totalGrossAmt = 0.0;
      double totalGst = 0.0;
      double totalTaxAmt = 0.0;
      double totalAmt = 0.0;
      
      List<Map<String, dynamic>> kotDetails = [];
      
      for (int i = 0; i < orderItems.length; i++) {
        final item = orderItems[i];
        final MenuModel menuItem = item['item'] as MenuModel;
        final quantity = item['quantity'] as int;
        final customizations = item['customizations'] as List<String>? ?? [];
        
        final rate = double.tryParse(menuItem.restrorate) ?? 0.0;
        final amt = double.parse((rate * quantity).toStringAsFixed(2));
        final itemGst = double.parse((amt * 0.05).toStringAsFixed(2)); // 5% GST
        final itemTaxAmt = itemGst;
        final itemNetAmt = double.parse((amt + itemTaxAmt).toStringAsFixed(2));
        
        totalGrossAmt = double.parse((totalGrossAmt + amt).toStringAsFixed(2));
        totalGst = double.parse((totalGst + itemGst).toStringAsFixed(2));
        totalTaxAmt = double.parse((totalTaxAmt + itemTaxAmt).toStringAsFixed(2));
        totalAmt = double.parse((totalAmt + itemNetAmt).toStringAsFixed(2));
        
        kotDetails.add({
          "KOTDID": 0,
          "KotNumber": kotNumber, // Use generated number
          "OrderNo": orderNo,     // Use generated number
          "ItemID": menuItem.itemId,
          "Rate": double.parse(rate.toStringAsFixed(2)),
          "Qty": quantity.toDouble(),
          "Amt": double.parse(amt.toStringAsFixed(2)),
          "GST": double.parse(itemGst.toStringAsFixed(2)),
          "TaxAmt": double.parse(itemTaxAmt.toStringAsFixed(2)),
          "NetAmt": double.parse(itemNetAmt.toStringAsFixed(2)),
          "Remarks": customizations.isEmpty ? "" : customizations.join(', '),
          "UserID": GetStorage().read('userId') ?? 0, // Use user ID from storage
          "SessionID": 1, // Set to 1 instead of null - CONSISTENT
          "Status": false,
          "OrderStatus": false
        });
      }
      
      // Create KOT request (using KOT API for everything)
      Map<String, dynamic> kotRequest = {
        "OP": 1,
        "KOTMaster": {
          "KOTMID": 0,
          "KotNumber": kotNumber, // Use generated number
          "OrderNo": orderNo,     // Use generated number
          "TableID": tableId,
          "PaxNo": 1,
          "Date": DateTime.now().toIso8601String(),
          "Time": DateTime.now().toString().substring(11, 19),
          "StewardID": 1,
          "GrossAmt": totalGrossAmt,
          "Gst": totalGst, // sum of all items GST
          "TaxAmt": totalTaxAmt, // sum of all items TaxAmt
          "TotalAmt": totalAmt,
          "UserID": GetStorage().read('userId') ?? 1,
          "SessionID": 1, // Set to 1 instead of null
          "Status": false,
          "RemarksMaster": remarks.isEmpty ? "" : remarks,
          "BillStatus": false
        },
        "KOTDetails": kotDetails
      };
      
      // Send to KOT API
      print('Sending Order via KOT API: ${kotRequest.toString()}');
      final response = await _apiService.post('/api/kot', kotRequest);
      print('KOT Response Status: ${response.statusCode}');
      print('KOT Response Data: ${response.data}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to send order to kitchen: ${response.statusCode} - ${response.data}');
      }
      
      final responseData = response.data;
      return {
        'success': true,
        'kotNumber': kotNumber, // Use app-generated number
        'kotMasterID': responseData['KOTMID'] ?? 0,
        'billNumber': 0, // No bill number from KOT
        'totalAmount': totalAmt,
        'message': responseData['Message'] ?? 'Order sent to kitchen successfully'
      };
      
    } catch (e) {
      print('Error sending order to kitchen: $e');
      rethrow;
    }
  }
}
