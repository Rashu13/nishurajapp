import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/common_bottom_navigation_bar.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: CommonBottomNavigationBar(currentIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFFF6B35).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                              controller.waiterInfo.value.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            )),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                              controller.waiterInfo.value.position,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6C757D),
                              ),
                            )),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.editProfile(),
                    icon: const Icon(
                      Icons.edit,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Performance stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Performance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Orders',
                          controller.performance.value.ordersCompleted.toString(),
                          Icons.restaurant_menu,
                          const Color(0xFF28A745),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Tables',
                          controller.performance.value.tablesServed.toString(),
                          Icons.table_bar,
                          const Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Revenue',
                          '₹${controller.performance.value.totalRevenue.toStringAsFixed(0)}',
                          Icons.currency_rupee,
                          const Color(0xFF17A2B8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Rating',
                          '${controller.performance.value.averageRating.toStringAsFixed(1)}/5',
                          Icons.star,
                          const Color(0xFFFFC107),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  _buildProfileOption(
                    'Personal Information',
                    Icons.person_outline,
                    () => controller.editPersonalInfo(),
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    'Change Password',
                    Icons.lock_outline,
                    () => controller.changePassword(),
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    'Notification Settings',
                    Icons.notifications_outlined,
                    () => controller.notificationSettings(),
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    'Language',
                    Icons.language,
                    () => controller.changeLanguage(),
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    'Help & Support',
                    Icons.help_outline,
                    () => controller.helpSupport(),
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    'About App',
                    Icons.info_outline,
                    () => controller.aboutApp(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6C757D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6C757D)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2D3142),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF6C757D),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
      indent: 16,
      endIndent: 16,
    );
  }
}
