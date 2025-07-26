import 'package:get/get.dart';
import '../../../data/models/menu_item.dart';

class CustomizationController extends GetxController {
  final MenuItem menuItem = Get.arguments as MenuItem;
  
  // Customization options
  var customizations = <String, bool>{
    'Less Oil': false,
    'Less Spicy': false,
    'Medium Spicy': false,
    'Spicy': false,
    'Boneless Chicken': false,
    '1/2': false,
    'Jain': false,
    'No Ajinomoto': false,
    'No Soya Sauce': false,
    'Less Salt': false,
  }.obs;
  
  var searchText = ''.obs;
  var quantity = 1.obs;
  
  void toggleCustomization(String key) {
    customizations[key] = !customizations[key]!;
  }
  
  void updateSearchText(String value) {
    searchText.value = value;
  }
  
  void incrementQuantity() {
    quantity.value++;
  }
  
  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }
  
  List<String> get filteredCustomizations {
    if (searchText.value.isEmpty) {
      return customizations.keys.toList();
    }
    return customizations.keys
        .where((key) => key.toLowerCase().contains(searchText.value.toLowerCase()))
        .toList();
  }
  
  void confirmCustomization() {
    // Get selected customizations
    List<String> selectedCustomizations = customizations.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    
    // Return to menu with customizations
    Get.back(result: {
      'item': menuItem,
      'quantity': quantity.value,
      'customizations': selectedCustomizations,
    });
  }
}
