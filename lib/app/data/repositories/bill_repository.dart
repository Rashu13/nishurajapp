import '../models/bill.dart';
import '../providers/bill_api_provider.dart';

class BillRepository {
  Future<List<Bill>> getTableBills() async {
    try {
      final data = await BillApiProvider.fetchTableBillSummary();
      return _parseTableBillSummary(data);
    } catch (e) {
      throw Exception('Failed to load table bills: $e');
    }
  }

  List<Bill> _parseTableBillSummary(List<dynamic> data) {
    return data.map((item) {
      final map = Map<String, dynamic>.from(item);
      
      // Parse new individual bills API format
      String billId = map['BillID']?.toString() ?? 'BILL_${map['TableID']}_${map['KOTNumber']}';
      String orderId = 'KOT${map['KOTNumber']}'; // Short order ID
      String status = map['Status']?.toString() ?? 'Completed'; // Use backend status directly
      
      // Parse BillType from string to int
      int billType = 1; // Default to Restaurant
      final billTypeRaw = map['BillType'] ?? map['OrderType'];
      if (billTypeRaw != null) {
        if (billTypeRaw is int) {
          billType = billTypeRaw;
        } else if (billTypeRaw is String) {
          switch (billTypeRaw.toLowerCase().trim()) {
            case 'restaurant':
              billType = 1;
              break;
            case 'nc billing':
            case 'ncbilling':
              billType = 2;
              break;
            case 'room':
              billType = 3;
              break;
            default:
              billType = int.tryParse(billTypeRaw) ?? 1;
          }
        }
      }
      
      // Parse BillDate
      DateTime billDate = DateTime.tryParse(map['BillDate']?.toString() ?? '') ?? DateTime.now();
      
      return Bill(
        id: billId,
        tableNumber: map['TableName']?.toString() ?? '',
        personCount: map['ItemCount'] ?? 0,
        orderId: orderId,
        userName: map['UserName']?.toString() ?? 'Unknown',
        serverId: 'Server ${map['StewardID'] ?? '1'}',
        items: [],
        itemsTotal: (map['GrossAmount'] as num?)?.toDouble() ?? 0.0,
        gst: ((map['TotalAmount'] as num?)?.toDouble() ?? 0.0) - ((map['GrossAmount'] as num?)?.toDouble() ?? 0.0),
        total: (map['TotalAmount'] as num?)?.toDouble() ?? 0.0,
        createdAt: billDate,
        billDate: billDate,
        billType: billType,
        status: status, // Use status from backend as-is
      );
    }).toList();
  }

  Future<bool> resetTable(int tableId) async {
    try {
      return await BillApiProvider.resetTable(tableId);
    } catch (e) {
      throw Exception('Failed to reset table: $e');
    }
  }
}
