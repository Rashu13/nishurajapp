import 'package:get/get.dart';
import '../../../data/models/menu_model.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../core/controllers/global_data_controller.dart';
import '../../../core/utils/toast_helper.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();
  
  var cartItems = <MenuModel, int>{}.obs;
  var isLoading = false.obs;
  var customerName = ''.obs;
  var customerPhone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map<MenuModel, int>) {
      cartItems.value = arguments;
    }
  }

  double get subtotal {
    double total = 0;
    cartItems.forEach((item, quantity) {
      total += (double.tryParse(item.restrorate) ?? 0.0) * quantity;
    });
    return total;
  }

  double get deliveryFee => 40.0;
  double get taxes => subtotal * 0.05; // 5% tax
  double get totalAmount => subtotal + deliveryFee + taxes;

  void updateQuantity(MenuModel item, int quantity) {
    if (quantity <= 0) {
      cartItems.remove(item);
    } else {
      cartItems[item] = quantity;
    }
    cartItems.refresh();
  }

  void placeOrder() async {
    if (customerName.value.isEmpty || customerPhone.value.isEmpty) {
      ToastHelper.showError('Please fill in customer details');
      return;
    }

    try {
      isLoading.value = true;
      
      final orderItems = cartItems.entries.map((entry) {
        return OrderItem(
          menuItemId: entry.key.itemId.toString(),
          name: entry.key.itemName,
          quantity: entry.value,
          price: double.tryParse(entry.key.restrorate) ?? 0.0,
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
      
      // Notify global controller about new order (affects table status)
      try {
        GlobalDataController.instance.notifyAllUpdates();
      } catch (e) {
        print('Global controller not found, skipping notification');
      }
      
      Get.offNamed(AppRoutes.ORDER_TRACK, arguments: order);
      ToastHelper.showSuccess('Order placed successfully!');
    } catch (e) {
      ToastHelper.showError('Failed to place order');
    } finally {
      isLoading.value = false;
    }
  }
}
