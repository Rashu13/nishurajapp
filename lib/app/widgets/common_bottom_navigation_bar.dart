import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class CommonBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  
  const CommonBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFFFF6B35),
      unselectedItemColor: Colors.grey[600],
      elevation: 8,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.table_restaurant),
          label: 'Tables',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Bills',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.track_changes),
          label: 'Status',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        // Prevent navigation if already on the same page
        if (index == currentIndex) return;
        
        switch (index) {
          case 0:
            Get.offAllNamed(AppRoutes.HOME);
            break;
          case 1:
            Get.offAndToNamed(AppRoutes.TABLE_MANAGEMENT);
            break;
          case 2:
            Get.offAndToNamed(AppRoutes.BILL_GENERATION);
            break;
          case 3:
            Get.offAndToNamed(AppRoutes.ORDER_STATUS);
            break;
          case 4:
            Get.offAndToNamed(AppRoutes.PROFILE);
            break;
        }
      },
    );
  }
}
