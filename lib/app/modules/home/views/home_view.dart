import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/common_bottom_navigation_bar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Break time is: 03:20:15',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
            const Text(
              'Hi, Krishna Sahu',
              style: TextStyle(
                fontSize: 18,
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusTab('You\'re serving', true),
                  const SizedBox(width: 12),
                  _buildStatusTab('Check tables', false),
                  const SizedBox(width: 12),
                  _buildStatusTab('Other\'s serving', false),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
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
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final tableNumber = (index + 1).toString().padLeft(2, '0');
                  final isOccupied = [2, 7, 8].contains(index);
                  return _buildTableCard(tableNumber, isOccupied);
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Add table button
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.add,
                  color: Color(0xFFFF6B35),
                ),
                label: const Text(
                  'Add Table',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
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
          color: isActive ? Colors.white : Colors.grey[600],
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTableCard(String tableNumber, bool isOccupied) {
    return GestureDetector(
      onTap: () {
        if (isOccupied) {
          controller.navigateToMenu();
        } else {
          _showTableDialog(tableNumber);
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isOccupied ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  void _showTableDialog(String tableNumber) {
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
                'Table No: $tableNumber',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Guest counter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {},
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
                  
                  const Column(
                    children: [
                      Text(
                        '4',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      Text(
                        'Guest',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 32),
                  
                  GestureDetector(
                    onTap: () {},
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
              ),
              
              const SizedBox(height: 40),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.navigateToMenu();
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
