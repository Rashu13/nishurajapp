import 'package:get/get.dart';
import '../../../data/models/bill.dart';

class BillGenerationController extends GetxController {
  var billsList = <Bill>[].obs;
  var isLoading = false.obs;
  var searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBills();
  }

  void loadBills() {
    isLoading.value = true;
    
    // Dummy bill data for different tables
    billsList.value = [
      Bill(
        id: 'BILL003',
        tableNumber: '03',
        personCount: 4,
        orderId: 'ORD003',
        serverId: 'SERV001',
        items: [],
        itemsTotal: 2100.0,
        gst: 140.0,
        total: 2240.0,
        createdAt: DateTime.now(),
        status: 'pending',
      ),
      Bill(
        id: 'BILL001',
        tableNumber: '01',
        personCount: 2,
        orderId: 'ORD001',
        serverId: 'SERV001',
        items: [],
        itemsTotal: 1600.0,
        gst: 110.0,
        total: 1710.0,
        createdAt: DateTime.now(),
        status: 'pending',
      ),
      Bill(
        id: 'BILL004',
        tableNumber: '04',
        personCount: 3,
        orderId: 'ORD004',
        serverId: 'SERV001',
        items: [],
        itemsTotal: 1680.0,
        gst: 112.0,
        total: 1792.0,
        createdAt: DateTime.now(),
        status: 'pending',
      ),
      Bill(
        id: 'BILL002',
        tableNumber: '02',
        personCount: 2,
        orderId: 'ORD002',
        serverId: 'SERV001',
        items: [],
        itemsTotal: 1180.0,
        gst: 82.0,
        total: 1262.0,
        createdAt: DateTime.now(),
        status: 'pending',
      ),
    ];
    
    isLoading.value = false;
  }

  void updateSearchText(String text) {
    searchText.value = text;
  }

  List<Bill> get filteredBills {
    if (searchText.value.isEmpty) {
      return billsList;
    }
    return billsList.where((bill) => 
      bill.tableNumber.toLowerCase().contains(searchText.value.toLowerCase())
    ).toList();
  }

  void selectBill(Bill bill) {
    Get.toNamed('/payment_method', arguments: bill);
  }
}
