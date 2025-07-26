import 'package:get/get.dart';
import '../../../data/models/bill.dart';

class PaymentSuccessfulController extends GetxController {
  late Bill processedBill;
  var transactionId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    processedBill = Get.arguments as Bill;
    generateTransactionId();
  }

  void generateTransactionId() {
    // Generate a random transaction ID
    transactionId.value = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  void backToHomepage() {
    Get.offAllNamed('/home');
  }
}
