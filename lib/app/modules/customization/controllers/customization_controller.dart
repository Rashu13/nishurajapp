import 'package:get/get.dart';
import '../../../data/models/menu_model.dart';

class CustomizationController extends GetxController {
  final MenuModel menuItem = Get.arguments as MenuModel;
  
  // Customization options
var customizations = <String, bool>{
    // Spice Level Options
    'Less Oil': false,
    'Less Spicy': false,
    'Medium Spicy': false,
    'Spicy': false,
    'Extra Spicy': false,
    
    // Portion Options
    '1/2': false,
    'Full': false,
    
    // Dietary Preferences
    'Jain': false,
    'Vegan': false,
    'Gluten Free': false,
    
    // Ingredient Modifications
    'No Onion': false,
    'No Garlic': false,
    'No Ginger': false,
    'No Tomato': false,
    'Extra Cheese': false,
    'Less Cheese': false,
    'No Cheese': false,
    
    // Cooking Style
    'Dry': false,
    'Gravy': false,
    'Semi-Gravy': false,
    
    // Add-ons
    'Extra Paneer': false,
    'Extra Vegetables': false,
    'Extra Rice': false,
    'Extra Roti': false,
    
    // Common Restrictions
    'No Ajinomoto': false,
    'No Soya Sauce': false,
    'No Artificial Colors': false,
    'No Preservatives': false,
    
    // Taste Modifications
    'Less Salt': false,
    'Extra Salt': false,
    'Less Sugar': false,
    'Extra Sweet': false,
    
    // Texture Preferences
    'Soft': false,
    'Crispy': false,
    'Well Done': false,
    'Medium Done': false,
    
    // Regional Preferences
    'North Indian Style': false,
    'South Indian Style': false,
    'Punjabi Style': false,
    
    // Special Requests
    'Separate Gravy': false,
    'Mix Well': false,
    'Pack Separately': false,
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
