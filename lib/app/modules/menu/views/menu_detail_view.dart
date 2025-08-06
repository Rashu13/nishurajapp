import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/menu_model.dart';
import '../controllers/menu_controller.dart';

class MenuDetailView extends StatelessWidget {
  const MenuDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final MenuModel item = Get.arguments as MenuModel;
    final MenuPageController menuController = Get.find<MenuPageController>();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFF8F9FA),
                child: const Center(
                  child: Icon(
                    Icons.fastfood,
                    size: 120,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table number section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.table_restaurant,
                          color: const Color(0xFFFF6B35),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Table No: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Obx(() => Text(
                          menuController.tableNumber.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B35),
                          ),
                        )),
                      ],
                    ),
                  ),
                  
                  // Name and veg indicator
                  Row(
                    children: [
                      Icon(
                        Icons.circle, // Default to veg since MenuModel doesn't have isVeg
                        size: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Rating and time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              "4.5", // Default rating since MenuModel doesn't have rating
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '15 mins', // Default time since MenuModel doesn't have preparationTime
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Price
                  Text(
                    '₹${(double.tryParse(item.restrorate) ?? 0.0).toInt()}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    "This delicious item is prepared with finest ingredients and served fresh.", // Default description since MenuModel doesn't have description
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        menuController.addToCart(item);
                        Get.back(); // Go back to menu after adding to cart
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
