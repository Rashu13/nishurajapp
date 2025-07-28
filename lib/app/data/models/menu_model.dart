import 'package:get/get.dart';

class MenuModel {
  final int itemId;
  final String restrorate;
  final String itemName;
  bool status;
  final Rx<bool> _isSelected = false.obs;

  // Getter and setter for isSelected
  bool get isSelected => _isSelected.value;
  set isSelected(bool value) => _isSelected.value = value;

  MenuModel({
    required this.itemId,
    required this.restrorate,
    required this.itemName,
    required this.status,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      itemId: json['ItemID'] ?? 0,
      restrorate: json['RestroRate'] ?? '',
      itemName: json['ItemName'] ?? '',
      status: json['Status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemID': itemId,
      'RestroRate': restrorate,
      'ItemName': itemName,
      'Status': status,
    };
  }

  @override
  String toString() {
    return 'MenuModel(itemId: $itemId, restrorate: $restrorate, itemName: $itemName, status: $status)';
  }
}
