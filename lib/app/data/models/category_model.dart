import 'package:get/get.dart';

class CategoryModel {
  final int categoryId;
  final String categoryName;
  bool status;
  final Rx<bool> _isSelected = false.obs;

  // Getter and setter for isSelected
  bool get isSelected => _isSelected.value;
  set isSelected(bool value) => _isSelected.value = value;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['CategoryID'] ?? 0,
      categoryName: json['CategoryName'] ?? '',
      status: json['Status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CategoryID': categoryId,
      'CategoryName': categoryName,
      'Status': status,
    };
  }

  @override
  String toString() {
    return 'CategoryModel(categoryId: $categoryId, categoryName: $categoryName, status: $status)';
  }
}
