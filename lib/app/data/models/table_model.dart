import 'package:get/get.dart';

class TableModel {
  final int tableId;
  final int roomTypeId;
  final String tableName;
  bool status;
  final Rx<bool> _isSelected = false.obs;

  // Getter and setter for isSelected
  bool get isSelected => _isSelected.value;
  set isSelected(bool value) => _isSelected.value = value;

  TableModel({
    required this.tableId,
    required this.roomTypeId,
    required this.tableName,
    required this.status,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      tableId: json['TableID'] ?? 0,
      roomTypeId: json['RoomTypeID'] ?? 0,
      tableName: json['TableName'] ?? '',
      status: json['Status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TableID': tableId,
      'RoomTypeID': roomTypeId,
      'TableName': tableName,
      'Status': status,
    };
  }

  @override
  String toString() {
    return 'TableModel(tableId: $tableId, tableName: $tableName, status: $status)';
  }
}
