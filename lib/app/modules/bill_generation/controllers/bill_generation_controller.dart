import 'package:get/get.dart';
import '../../../data/models/bill.dart';
import '../../../data/repositories/bill_repository.dart';

class BillGenerationController extends GetxController {
  final BillRepository _repository = BillRepository();
  
  var billsList = <Bill>[].obs;
  var isLoading = false.obs;
  var searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBills();
  }

  Future<void> loadBills() async {
    try {
      isLoading.value = true;
      final bills = await _repository.getTableBills();
      billsList.assignAll(bills);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load bills: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
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
    Get.toNamed('/bill_detail', arguments: bill);
  }
}
