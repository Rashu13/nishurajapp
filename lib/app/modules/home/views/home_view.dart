import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:serv/app/global/widgets/loader.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/common_bottom_navigation_bar.dart';
import '../../../data/models/table_model.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final user = box.read('user');
    final email = user != null && user['EmailID'] != null ? user['EmailID'] : '';
    final name = user != null && user['Name'] != null ? user['Name'] : '';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, $name',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              '$email',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2D3142),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Analytics/Dashboard button
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.ANALYTICS),
            icon: const Icon(
              Icons.analytics,
              color: Color(0xFFFF6B35),
            ),
          ),
          // Bill Generation button
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.BILL_GENERATION),
            icon: const Icon(
              Icons.receipt_long,
              color: Color(0xFFFF6B35),
            ),
          ),
          // Profile button
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.PROFILE),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status tabs
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     children: [
            //       _buildStatusTab('You\'re serving', true),
            //       const SizedBox(width: 12),
            //       _buildStatusTab('Check tables', false),
            //       const SizedBox(width: 12),
            //       _buildStatusTab('Other\'s serving', false),
            //     ],
            //   ),
            // ),
            
            //const SizedBox(height: 24),
            
            // Table grid
            const Text(
              'Select Table',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: Obx(() {
                if (controller.isTablesLoading.value) {
                  return const Center(
                    child: LoaderCircle(),
                  );
                }
                
                if (controller.tables.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tables available',
                      style: TextStyle(
                        color: Color(0xFF6C757D),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                
                // Display all available tables for home view
                final displayTables = controller.tables;
                
                return Column(
                  children: [
                    // Show table count info
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Total Tables: ${displayTables.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ),
                    
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: displayTables.length,
                        itemBuilder: (context, index) {
                          final table = displayTables[index];
                          // Show table name instead of numbers, and use actual status
                          return _buildTableCard(table.tableName, !table.status, table);
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
            
            const SizedBox(height: 16),
            
            // Add table button
            
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigationBar(
        currentIndex: 0, // Home tab
      ),
    );
  }

  Widget _buildStatusTab(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF6B35) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        title,
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          color: isActive ? Colors.white : Colors.grey[600],
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTableCard(String tableNumber, bool isOccupied, [TableModel? table]) {
    return GestureDetector(
      onTap: () {
        if (isOccupied) {
          controller.navigateToMenu(table);
        } else {
          _showTableDialog(tableNumber, table);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isOccupied ? const Color(0xFFFF6B35) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOccupied ? const Color(0xFFFF6B35) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            tableNumber,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isOccupied ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  void _showTableDialog(String tableNumber, [TableModel? table]) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Number of Guest',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Table: $tableNumber',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Guest counter
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => controller.decrementGuest(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.remove, color: Colors.grey),
                    ),
                  ),
                  
                  const SizedBox(width: 32),
                  
                  Column(
                    children: [
                      Text(
                        '${controller.guestCount.value}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const Text(
                        'Guests',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 32),
                  
                  GestureDetector(
                    onTap: () => controller.incrementGuest(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              )),
              
              const SizedBox(height: 40),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.navigateToMenu(table);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
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
    );
  }
}
