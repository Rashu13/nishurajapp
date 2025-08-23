import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:serv/app/global/widgets/loader.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/common_bottom_navigation_bar.dart';
import '../../../data/models/table_model.dart';
import '../../../core/utils/session_manager.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/bill_service.dart';

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
          // Debug Session Button
          IconButton(
            onPressed: () => _showSessionDebug(context),
            icon: const Icon(
              Icons.bug_report,
              color: Colors.purple,
            ),
            tooltip: 'Debug Session Data',
          ),
          // Refresh tables button
          IconButton(
            onPressed: () => controller.refreshTables(),
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFFFF6B35),
            ),
          ),
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
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.refreshTables();
                },
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

  void _showSessionDebug(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔍 Session Debug Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDebugInfo(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      try {
                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );
                        
                        // Test login with dummy data
                        final result = await AuthService.login('admin', 'admin123');
                        Get.back(); // Close loading dialog
                        
                        if (result != null) {
                          Get.snackbar(
                            'Test Login Success',
                            'User: ${result['User_Name']}\nCSession: ${result['CSession']}',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 5),
                          );
                        } else {
                          Get.snackbar(
                            'Test Login Failed',
                            'Invalid credentials or server error',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      } catch (e) {
                        Get.back(); // Close loading dialog
                        Get.snackbar(
                          'Login Error',
                          e.toString(),
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: const Text('Test Login'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await SessionManager.logout();
                      Get.snackbar(
                        'Logout Success',
                        'All session data cleared',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    },
                    child: const Text('Test Logout'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // KOT Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () async {
                  Get.back();
                  try {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );
                    
                    // Test KOT API
                    final billService = BillService();
                    final result = await billService.testKOTEndpoint();
                    Get.back(); // Close loading dialog
                    
                    if (result['success'] == true) {
                      Get.snackbar(
                        'KOT Test Success',
                        'API is working properly!\nStatus: ${result['statusCode']}',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 5),
                      );
                    } else {
                      Get.snackbar(
                        'KOT Test Failed',
                        'Error: ${result['error']}\nDetails: ${result['details'] ?? ''}',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 5),
                      );
                    }
                  } catch (e) {
                    Get.back(); // Close loading dialog
                    Get.snackbar(
                      'KOT Test Error',
                      e.toString(),
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: const Text('🧪 Test KOT API'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfo() {
    // GetStorage raw data
    final box = GetStorage();
    final userData = box.read('userData');
    final isLoggedIn = box.read('isLoggedIn');
    final userId = box.read('userId');
    final cSession = box.read('cSession');
    final userName = box.read('userName');
    final email = box.read('emailId');
    final accountType = box.read('accountType');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📱 GetStorage Raw Data:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('isLoggedIn: $isLoggedIn'),
          Text('userId: $userId'),
          Text('userName: $userName'),
          Text('emailId: $email'),
          Text('accountType: $accountType'),
          Text('cSession: $cSession'),
          const SizedBox(height: 12),
          Text('� SessionManager Data:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('isAuthenticated: ${SessionManager.isAuthenticated}'),
          Text('currentUserId: ${SessionManager.currentUserId}'),
          Text('displayName: ${SessionManager.displayName}'),
          Text('currentCSession: ${SessionManager.currentCSession}'),
          const SizedBox(height: 12),
          Text('🔐 AuthService Data:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('isUserLoggedIn: ${AuthService.isUserLoggedIn()}'),
          Text('getUserId: ${AuthService.getUserId()}'),
          Text('getUserName: ${AuthService.getUserName()}'),
          Text('getEmailId: ${AuthService.getEmailId()}'),
          Text('getCSession: ${AuthService.getCSession()}'),
          const SizedBox(height: 12),
          Text('�📦 Complete userData:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('$userData', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
