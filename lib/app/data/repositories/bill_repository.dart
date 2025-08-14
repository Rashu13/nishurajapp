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
      return Bill(
        id: 'BILL_${map['TableID']}',
        tableNumber: map['TableName'] ?? '',
        personCount: map['ItemCount'] ?? 0, // Using ItemCount as person count for now
        orderId: 'ORD_${map['TableID']}',
        serverId: map['UserName'] ?? 'Unknown',
        items: [], // We'll populate this when user clicks on bill
        itemsTotal: (map['Gross'] as num?)?.toDouble() ?? 0.0,
        gst: (map['GST'] as num?)?.toDouble() ?? 0.0,
        total: (map['GrandTotal'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.now(),
        status: map['KOTStatus'] ?? 'pending',
      );
    }).toList();
  }
}
