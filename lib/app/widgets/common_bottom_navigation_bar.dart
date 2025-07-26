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
        switch (index) {
          case 0:
            if (Get.currentRoute != AppRoutes.HOME) {
              Get.offAllNamed(AppRoutes.HOME);
            }
            break;
          case 1:
            if (Get.currentRoute != AppRoutes.TABLE_MANAGEMENT) {
              Get.toNamed(AppRoutes.TABLE_MANAGEMENT);
            }
            break;
          case 2:
            if (Get.currentRoute != AppRoutes.BILL_GENERATION) {
              Get.toNamed(AppRoutes.BILL_GENERATION);
            }
            break;
          case 3:
            if (Get.currentRoute != AppRoutes.ORDER_STATUS) {
              Get.toNamed(AppRoutes.ORDER_STATUS);
            }
            break;
          case 4:
            if (Get.currentRoute != AppRoutes.PROFILE) {
              Get.toNamed(AppRoutes.PROFILE);
            }
            break;
        }
      },
    );
  }
}
