import 'package:get/get.dart';
import '../../../data/models/menu_item.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../routes/app_routes.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();
  
  var cartItems = <MenuItem, int>{}.obs;
  var isLoading = false.obs;
  var customerName = ''.obs;
  var customerPhone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map<MenuItem, int>) {
      cartItems.value = arguments;
    }
  }

  double get subtotal {
    double total = 0;
    cartItems.forEach((item, quantity) {
      total += item.price * quantity;
    });
    return total;
  }

  double get deliveryFee => 40.0;
  double get taxes => subtotal * 0.05; // 5% tax
  double get totalAmount => subtotal + deliveryFee + taxes;

  void updateQuantity(MenuItem item, int quantity) {
    if (quantity <= 0) {
      cartItems.remove(item);
    } else {
      cartItems[item] = quantity;
    }
    cartItems.refresh();
  }

  void placeOrder() async {
    if (customerName.value.isEmpty || customerPhone.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in customer details');
      return;
    }

    try {
      isLoading.value = true;
      
      final orderItems = cartItems.entries.map((entry) {
        return OrderItem(
          menuItemId: entry.key.id,
          name: entry.key.name,
          quantity: entry.value,
          price: entry.key.price,
        );
      }).toList();

      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: orderItems,
        totalAmount: totalAmount,
        status: 'confirmed',
        orderTime: DateTime.now(),
        estimatedTime: 30,
        customerName: customerName.value,
        customerPhone: customerPhone.value,
      );

      await _orderRepository.createOrder(order);
      
      Get.offNamed(AppRoutes.ORDER_TRACK, arguments: order);
      Get.snackbar('Success', 'Order placed successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to place order');
    } finally {
      isLoading.value = false;
    }
  }
}
