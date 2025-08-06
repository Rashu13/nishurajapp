import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:serv/app/global/widgets/loader.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: SvgPicture.asset(
                'assets/images/hunger.svg',
                height: 150,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Food Delivery Service',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 50),
            const LoaderCircle(),
          ],
        ),
      ),
    );
  }
}
