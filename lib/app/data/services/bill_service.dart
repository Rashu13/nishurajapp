import '../../core/services/api_service.dart';
import '../../core/utils/session_manager.dart';
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
      // Validation checks
      if (orderItems.isEmpty) {
        throw Exception('No items to send to kitchen');
      }

      // Check session data
      final userId = SessionManager.currentUserId;
      final cSession = SessionManager.currentCSession;
      
      print('🔍 Session Check: UserID=$userId, CSession=$cSession');
      
      if (userId == null || cSession == null) {
        throw Exception('User session not found. Please login again.');
      }

      // Generate unique KOT and Order numbers
      final kotNumber = DateTime.now().millisecondsSinceEpoch % 100000;
      final orderNo = DateTime.now().millisecondsSinceEpoch % 100000;
      
      print('📊 Generated: KOTNumber=$kotNumber, OrderNo=$orderNo, TableId=$tableId');
      
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

        print('🍽️ Processing Item: ${menuItem.itemName}, Qty: $quantity, Rate: ${menuItem.restrorate}');

        final rate = double.tryParse(menuItem.restrorate) ?? 0.0;
        if (rate <= 0) {
          print('⚠️ Warning: Item ${menuItem.itemName} has invalid rate: ${menuItem.restrorate}');
        }
        
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
          "UserID": userId,
          "SessionID": cSession,
          "Status": false,
          "OrderStatus": false,
          "TableID": tableId,
           // Add PrintStatus field
        });
      }
      
      print('💰 Calculated Totals: Gross=$totalGrossAmt, GST=$totalGst, Total=$totalAmt');
      print('💰 Calculated Totals: Gross=$totalGrossAmt, GST=$totalGst, Total=$totalAmt');
      
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
          "UserID": userId,
          "SessionID": cSession,
          "Status": false,
          "RemarksMaster": remarks.isEmpty ? "sample string 3" : remarks,
          "BillStatus": false,
          // Add PrintStatus field to KOTMaster
        },
        "KOTDetails": kotDetails
      };
      
      // Send KOT to API
      print('📤 Sending KOT Request to /api/kot');
      print('📋 Request Data: ${kotRequest.toString()}');
      
      final response = await _apiService.post('/api/kot', kotRequest);
      
      print('📥 KOT Response Status: ${response.statusCode}');
      print('📄 KOT Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ KOT Success: $responseData');
        
        return {
          'success': true,
          'kotNumber': kotNumber,
          'kotMasterID': responseData['KOTMID'] ?? 0,
          'totalAmount': totalAmt,
          'message': responseData['Message'] ?? 'KOT sent to kitchen successfully'
        };
      } else {
        print('❌ KOT Failed: Status ${response.statusCode}');
        print('❌ Error Details: ${response.data}');
        print('❌ Full Response: ${response.toString()}');
        
        // Try to extract specific error
        String errorMessage = 'KOT API Error';
        if (response.data != null) {
          if (response.data is Map && response.data['Message'] != null) {
            errorMessage = response.data['Message'];
          } else if (response.data is String) {
            errorMessage = response.data;
          }
        }
        
        throw Exception('KOT API Error: ${response.statusCode} - $errorMessage');
      }
      
    } catch (e) {
      print('🚨 KOT Exception: $e');
      
      // Parse server error details
      String errorDetails = e.toString();
      
      // Check if it's a DioException and extract server response
      if (e.toString().contains('DioException')) {
        try {
          // Extract status code from error message
          RegExp statusCodeRegex = RegExp(r'status code of (\d+)');
          Match? statusMatch = statusCodeRegex.firstMatch(e.toString());
          
          if (statusMatch != null) {
            String statusCode = statusMatch.group(1)!;
            print('🚨 Server returned error code: $statusCode');
            
            if (statusCode == '500') {
              errorDetails = 'Server Error (500): There is an issue with the KOT API on the server. Please contact technical support.';
            } else if (statusCode == '400') {
              errorDetails = 'Bad Request (400): The order data format is incorrect.';
            } else {
              errorDetails = 'Server Error ($statusCode): Unable to process KOT request.';
            }
          }
        } catch (parseError) {
          print('🚨 Error parsing DioException: $parseError');
        }
      }
      
      // More specific error handling
      if (e.toString().contains('SocketException') || e.toString().contains('timeout')) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e.toString().contains('session')) {
        throw Exception('Session expired: Please login again');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid data format: Please check item details');
      } else {
        throw Exception(errorDetails);
      }
    }
  }
  
  // Add single item to existing KOT
  Future<Map<String, dynamic>> addItemToKOT({
    required int kotNumber,
    required int orderNo,
    required MenuModel menuItem,
    required int quantity,
    required int tableId,
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
          "UserID": SessionManager.currentUserId ?? 1,
          "SessionID": SessionManager.currentCSession ?? 1,
          "Status": true,
          "OrderStatus": true,
          "TableID": tableId,
      
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
          "UserID": SessionManager.currentUserId ?? 1, // Use SessionManager for UserID
          "SessionID": SessionManager.currentCSession ?? 1, // Use CSession from SessionManager
          "Status": false,
          "OrderStatus": false,
          "TableID": tableId,
         // Add PrintStatus field
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
          "UserID": SessionManager.currentUserId ?? 1, // Use SessionManager for UserID
          "SessionID": SessionManager.currentCSession ?? 1, // Use CSession from SessionManager
          "Status": false,
          "RemarksMaster": remarks.isEmpty ? "" : remarks,
          "BillStatus": false,
        // Add PrintStatus field to KOTMaster
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
  
  // Test method to generate sample KOT exactly as provided in sample
  Future<Map<String, dynamic>> generateSampleKOT() async {
    try {
      Map<String, dynamic> sampleKOTRequest = {
        "OP": 1,
        "KOTMaster": {
          "KOTMID": 1,
          "KotNumber": 1,
          "OrderNo": 1,
          "TableID": 1,
          "PaxNo": 1,
          "Date": DateTime.now().toIso8601String(),
          "Time": "sample string 2",
          "StewardID": 1,
          "GrossAmt": 1.1,
          "Gst": 1.1,
          "TaxAmt": 1.1,
          "TotalAmt": 1.1,
          "UserID": SessionManager.currentUserId ?? 1,
          "SessionID": SessionManager.currentCSession ?? 1,
          "Status": false,
          "RemarksMaster": "sample string 3",
          "BillStatus": false
        },
        "KOTDetails": [
          {
            "KOTDID": 1,
            "KotNumber": 1,
            "OrderNo": 1,
            "ItemID": 1,
            "Rate": 1.1,
            "Qty": 1.1,
            "Amt": 1.1,
            "GST": 1.1,
            "TaxAmt": 1.1,
            "NetAmt": 1.1,
            "Remarks": "sample string 2",
            "UserID": SessionManager.currentUserId ?? 1,
            "SessionID": SessionManager.currentCSession ?? 1,
            "Status": true,
            "OrderStatus": true,
            "TableID": 1
          },
          {
            "KOTDID": 1,
            "KotNumber": 1,
            "OrderNo": 1,
            "ItemID": 1,
            "Rate": 1.1,
            "Qty": 1.1,
            "Amt": 1.1,
            "GST": 1.1,
            "TaxAmt": 1.1,
            "NetAmt": 1.1,
            "Remarks": "sample string 2",
            "UserID": SessionManager.currentUserId ?? 1,
            "SessionID": SessionManager.currentCSession ?? 1,
            "Status": true,
            "OrderStatus": true,
            "TableID": 1
          }
        ]
      };
      
      print('Sample KOT Request: ${sampleKOTRequest.toString()}');
      return {
        'success': true,
        'sampleData': sampleKOTRequest,
        'message': 'Sample KOT structure generated successfully'
      };
      
    } catch (e) {
      print('Error generating sample KOT: $e');
      rethrow;
    }
  }
  
  // Test method to validate KOT API endpoint
  Future<Map<String, dynamic>> testKOTEndpoint() async {
    try {
      print('🧪 Testing KOT API endpoint...');
      
      // Check session
      final userId = SessionManager.currentUserId;
      final cSession = SessionManager.currentCSession;
      
      if (userId == null || cSession == null) {
        return {
          'success': false,
          'error': 'Session not found',
          'details': 'UserID: $userId, CSession: $cSession'
        };
      }
      
      // Simple test request
      Map<String, dynamic> testRequest = {
        "OP": 1,
        "KOTMaster": {
          "KOTMID": 0,
          "KotNumber": 99999,
          "OrderNo": 99999,
          "TableID": 1,
          "PaxNo": 1,
          "Date": DateTime.now().toIso8601String(),
          "Time": "test",
          "StewardID": 1,
          "GrossAmt": 1.0,
          "Gst": 0.05,
          "TaxAmt": 0.05,
          "TotalAmt": 1.05,
          "UserID": userId,
          "SessionID": cSession,
          "Status": false,
          "RemarksMaster": "API Test",
          "BillStatus": false,
          // Add PrintStatus field to KOTMaster
        },
        "KOTDetails": [
          {
            "KOTDID": 0,
            "KotNumber": 99999,
            "OrderNo": 99999,
            "ItemID": 1,
            "Rate": 1.0,
            "Qty": 1.0,
            "Amt": 1.0,
            "GST": 0.05,
            "TaxAmt": 0.05,
            "NetAmt": 1.05,
            "Remarks": "test item",
            "UserID": userId,
            "SessionID": cSession,
            "Status": true,
            "OrderStatus": true,
            "TableID": 1,
            // Add PrintStatus field
          }
        ]
      };
      
      print('📤 Sending test request to /api/kot');
      final response = await _apiService.post('/api/kot', testRequest);
      
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'response': response.data,
        'message': 'Test completed'
      };
      
    } catch (e) {
      print('🚨 Test failed: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Test failed'
      };
    }
  }

  // Switch table functionality
  Future<Map<String, dynamic>> switchTable({
    required int oldTableId,
    required int newTableId,
  }) async {
    try {
      print('🔄 Switching table from $oldTableId to $newTableId');
      
      // Validate session
      final userId = SessionManager.currentUserId;
      final cSession = SessionManager.currentCSession;
      
      if (userId == null || cSession == null) {
        throw Exception('Session expired. Please login again.');
      }
      
      // Validate table IDs
      if (oldTableId == newTableId) {
        throw Exception('Cannot switch to the same table');
      }
      
      if (oldTableId <= 0 || newTableId <= 0) {
        throw Exception('Invalid table selection');
      }
      
      final requestData = {
        'OldTableID': oldTableId,
        'NewTableID': newTableId,
      };
      
      print('📤 Sending table switch request: $requestData');
      
      final response = await _apiService.post('/api/kot/table/switch', requestData);
      
      print('📥 Table Switch Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        return {
          'success': true,
          'message': responseData['Message'] ?? 'Table switched successfully',
          'data': responseData
        };
      } else {
        print('❌ Table Switch Failed: Status ${response.statusCode}');
        print('❌ Error Details: ${response.data}');
        
        String errorMessage = 'Table switch failed';
        if (response.data != null) {
          if (response.data is Map && response.data['Message'] != null) {
            errorMessage = response.data['Message'];
          } else if (response.data is String) {
            errorMessage = response.data;
          }
        }
        
        throw Exception('Table Switch Error: ${response.statusCode} - $errorMessage');
      }
      
    } catch (e) {
      print('🚨 Table Switch Exception: $e');
      
      // Parse server error details
      String errorDetails = e.toString();
      
      if (e.toString().contains('DioException')) {
        try {
          RegExp statusCodeRegex = RegExp(r'status code of (\d+)');
          Match? statusMatch = statusCodeRegex.firstMatch(e.toString());
          
          if (statusMatch != null) {
            String statusCode = statusMatch.group(1)!;
            print('🚨 Server returned error code: $statusCode');
            
            if (statusCode == '500') {
              errorDetails = 'Server Error: Unable to switch table. Please try again.';
            } else if (statusCode == '400') {
              errorDetails = 'Bad Request: Invalid table switch request.';
            } else if (statusCode == '404') {
              errorDetails = 'Table not found. Please refresh and try again.';
            } else {
              errorDetails = 'Server Error ($statusCode): Unable to switch table.';
            }
          }
        } catch (parseError) {
          print('🚨 Error parsing DioException: $parseError');
        }
      }
      
      if (e.toString().contains('SocketException') || e.toString().contains('timeout')) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e.toString().contains('session')) {
        throw Exception('Session expired: Please login again');
      } else {
        throw Exception(errorDetails);
      }
    }
  }

  // Update Print Status for KOT
  Future<Map<String, dynamic>> updateKOTPrintStatus({
    required int kotNumber,
    required bool printStatus,
  }) async {
    try {
      print('🖨️ Updating KOT Print Status: KOT $kotNumber -> $printStatus');
      
      // Validate session
      final userId = SessionManager.currentUserId;
      final cSession = SessionManager.currentCSession;
      
      if (userId == null || cSession == null) {
        throw Exception('Session expired. Please login again.');
      }
      
      final requestData = {
        'KotNumber': kotNumber,
        'PrintStatus': printStatus,
        'UserID': userId,
        'SessionID': cSession,
      };
      
      print('📤 Sending print status update request: $requestData');
      
      final response = await _apiService.post('/api/kot/printstatus', requestData);
      
      print('📥 Print Status Update Response: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        return {
          'success': true,
          'message': responseData['Message'] ?? 'Print status updated successfully',
          'data': responseData
        };
      } else {
        print('❌ Print Status Update Failed: Status ${response.statusCode}');
        print('❌ Error Details: ${response.data}');
        
        String errorMessage = 'Print status update failed';
        if (response.data != null) {
          if (response.data is Map && response.data['Message'] != null) {
            errorMessage = response.data['Message'];
          } else if (response.data is String) {
            errorMessage = response.data;
          }
        }
        
        throw Exception('Print Status Update Error: ${response.statusCode} - $errorMessage');
      }
      
    } catch (e) {
      print('🚨 Print Status Update Exception: $e');
      
      // Parse server error details
      String errorDetails = e.toString();
      
      if (e.toString().contains('DioException')) {
        try {
          RegExp statusCodeRegex = RegExp(r'status code of (\d+)');
          Match? statusMatch = statusCodeRegex.firstMatch(e.toString());
          
          if (statusMatch != null) {
            String statusCode = statusMatch.group(1)!;
            print('🚨 Server returned error code: $statusCode');
            
            if (statusCode == '500') {
              errorDetails = 'Server Error: Unable to update print status. Please try again.';
            } else if (statusCode == '400') {
              errorDetails = 'Bad Request: Invalid print status update request.';
            } else if (statusCode == '404') {
              errorDetails = 'KOT not found. Please refresh and try again.';
            } else {
              errorDetails = 'Server Error ($statusCode): Unable to update print status.';
            }
          }
        } catch (parseError) {
          print('🚨 Error parsing DioException: $parseError');
        }
      }
      
      if (e.toString().contains('SocketException') || e.toString().contains('timeout')) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e.toString().contains('session')) {
        throw Exception('Session expired: Please login again');
      } else {
        throw Exception(errorDetails);
      }
    }
  }
}
