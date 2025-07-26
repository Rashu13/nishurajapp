class Bill {
  final String id;
  final String tableNumber;
  final int personCount;
  final String orderId;
  final String serverId;
  final List<BillItem> items;
  final double itemsTotal;
  final double discount;
  final double gst;
  final double total;
  final DateTime createdAt;
  final String status; // 'pending', 'paid', 'cancelled'

  Bill({
    required this.id,
    required this.tableNumber,
    required this.personCount,
    required this.orderId,
    required this.serverId,
    required this.items,
    required this.itemsTotal,
    this.discount = 0.0,
    this.gst = 0.0,
    required this.total,
    required this.createdAt,
    this.status = 'pending',
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      tableNumber: json['table_number'],
      personCount: json['person_count'],
      orderId: json['order_id'],
      serverId: json['server_id'],
      items: (json['items'] as List)
          .map((item) => BillItem.fromJson(item))
          .toList(),
      itemsTotal: json['items_total'].toDouble(),
      discount: json['discount']?.toDouble() ?? 0.0,
      gst: json['gst']?.toDouble() ?? 0.0,
      total: json['total'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'person_count': personCount,
      'order_id': orderId,
      'server_id': serverId,
      'items': items.map((item) => item.toJson()).toList(),
      'items_total': itemsTotal,
      'discount': discount,
      'gst': gst,
      'total': total,
      'created_at': createdAt.toIso8601String(),
      'status': status,
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
