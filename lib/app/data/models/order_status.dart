class OrderStatus {
  final String id;
  final String tableNumber;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String status; // 'pending', 'in_progress', 'served', 'not_prepared'

  OrderStatus({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.createdAt,
    required this.status,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      id: json['id'],
      tableNumber: json['table_number'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
}

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final String status; // 'in_progress', 'served', 'not_prepared'
  final bool isModified;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.status,
    this.isModified = false,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      status: json['status'],
      isModified: json['is_modified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'status': status,
      'is_modified': isModified,
    };
  }
}
