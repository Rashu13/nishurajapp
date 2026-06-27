class Bill {
  final String id;
  final String tableNumber;
  final int personCount;
  final String orderId;
  final String serverId;
  final String userName; // Added userId to track who generated the bill
  final List<BillItem> items;
  final double itemsTotal;
  final double discount;
  final double gst;
  final double total;
  final DateTime createdAt;
  final DateTime billDate; // Bill creation date from API
  final int billType; // 1=Restaurant, 2=NC Billing, 3+=Room
  final String status; // 'pending', 'paid', 'cancelled'
  final bool billStatus; // true = paid/completed, false = active/running

  Bill({
    required this.id,
    required this.tableNumber,
    required this.personCount,
    required this.orderId,
    required this.serverId,
    required this.userName,
    required this.items,
    required this.itemsTotal,
    this.discount = 0.0,
    this.gst = 0.0,
    required this.total,
    required this.createdAt,
    DateTime? billDate,
    this.billType = 1,
    this.status = 'pending',
    this.billStatus = false,
  }) : billDate = billDate ?? createdAt;

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      tableNumber: json['table_number'],
      personCount: json['person_count'],
      orderId: json['order_id'],
      serverId: json['server_id'],
      userName: json['user_name'],
      items: (json['items'] as List)
          .map((item) => BillItem.fromJson(item))
          .toList(),
      itemsTotal: json['items_total'].toDouble(),
      discount: json['discount']?.toDouble() ?? 0.0,
      gst: json['gst']?.toDouble() ?? 0.0,
      total: json['total'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      billDate: json['bill_date'] != null ? DateTime.parse(json['bill_date']) : null,
      billType: json['bill_type'] ?? 1,
      status: json['status'] ?? 'pending',
      billStatus: json['billStatus'] ?? json['bill_status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'person_count': personCount,
      'order_id': orderId,
      'server_id': serverId,
      'user_name': userName,
      'items': items.map((item) => item.toJson()).toList(),
      'items_total': itemsTotal,
      'discount': discount,
      'gst': gst,
      'total': total,
      'created_at': createdAt.toIso8601String(),
      'bill_date': billDate.toIso8601String(),
      'bill_type': billType,
      'status': status,
      'billStatus': billStatus,
    };
  }
}

class BillItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final double price;
  final double total;

  BillItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      total: json['total'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}
