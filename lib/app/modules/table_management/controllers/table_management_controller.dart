import 'package:get/get.dart';

class TableManagementController extends GetxController {
  var selectedTab = 0.obs;
  var tables = <TableAssignment>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTableAssignments();
  }

  void loadTableAssignments() {
    tables.value = [
      TableAssignment(
        tableNumber: '05',
        waiterName: 'Raman Shetty',
        guests: 4,
        time: '2:00 pm',
        status: TableStatus.occupied,
      ),
      TableAssignment(
        tableNumber: '06',
        waiterName: 'Hari Sahu',
        guests: 2,
        time: '12:30 pm',
        status: TableStatus.occupied,
      ),
      TableAssignment(
        tableNumber: '04',
        waiterName: 'Aaron Michelle',
        guests: 2,
        time: '2:00 pm',
        status: TableStatus.available,
      ),
      TableAssignment(
        tableNumber: '08',
        waiterName: 'Veda Shrinivas',
        guests: 4,
        time: '1:00 pm',
        status: TableStatus.available,
      ),
      TableAssignment(
        tableNumber: '09',
        waiterName: 'Shreya pillai',
        guests: 3,
        time: '1:30 pm',
        status: TableStatus.available,
      ),
      TableAssignment(
        tableNumber: '10',
        waiterName: 'Tanya Soni',
        guests: 4,
        time: '2:00 pm',
        status: TableStatus.available,
      ),
    ];
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }
}

class TableAssignment {
  final String tableNumber;
  final String waiterName;
  final int guests;
  final String time;
  final TableStatus status;

  TableAssignment({
    required this.tableNumber,
    required this.waiterName,
    required this.guests,
    required this.time,
    required this.status,
  });
}

enum TableStatus {
  occupied,
  available,
}
