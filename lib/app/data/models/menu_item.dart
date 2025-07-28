class MenuItem {
  final int itemId;
  final String itemName;
  final String restroRate;
  final bool status;
  
  // Optional fields for compatibility with existing dummy data
  final String? description;
  final String? image;
  final String? category;
  final bool? isVeg;
  final double? rating;
  final int? preparationTime;

  MenuItem({
    required this.itemId,
    required this.itemName,
    required this.restroRate,
    required this.status,
    this.description,
    this.image,
    this.category,
    this.isVeg,
    this.rating,
    this.preparationTime,
  });

  // Factory for API data
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemId: json['ItemID'] ?? 0,
      itemName: json['ItemName'] ?? '',
      restroRate: json['RestroRate'] ?? '0',
      status: json['Status'] ?? false,
    );
  }

  // Factory for dummy data compatibility
  factory MenuItem.fromDummyJson(Map<String, dynamic> json) {
    return MenuItem(
      itemId: int.tryParse(json['id'] ?? '0') ?? 0,
      itemName: json['name'] ?? '',
      restroRate: (json['price'] ?? 0).toString(),
      status: true,
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      isVeg: json['isVeg'] ?? true,
      rating: (json['rating'] ?? 0).toDouble(),
      preparationTime: json['preparationTime'] ?? 0,
    );
  }

  // Getter methods for backward compatibility
  String get id => itemId.toString();
  String get name => itemName;
  double get price => double.tryParse(restroRate) ?? 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'isVeg': isVeg,
      'rating': rating,
      'preparationTime': preparationTime,
    };
  }
}
