import 'package:get/get.dart';
import '../../../data/models/bill.dart';
import '../../../data/providers/bill_api_provider.dart';

class BillDetailController extends GetxController {
  late Bill bill;
  var billItems = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    bill = Get.arguments as Bill;
    loadBillItems();
  }

  Future<void> loadBillItems() async {
    try {
      isLoading.value = true;
      final items = await BillApiProvider.fetchTableBillItems(bill.tableNumber);
      billItems.assignAll(items.cast<Map<String, dynamic>>());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load bill items: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void printBill() {
    Get.snackbar(
      'Print',
      'Bill printed successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void proceedToPayment() {
    Get.toNamed('/payment_method', arguments: bill);
  }
}
