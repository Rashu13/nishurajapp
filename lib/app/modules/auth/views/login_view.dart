import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serv/app/global/widgets/loader.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/hunger.svg',
              height: 120,
            ),
            SizedBox(height: 32),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            Obx(() => controller.isLoading.value
                ? LoaderCircle()
                : ElevatedButton(
                    onPressed: () async {
                      await controller.login(
                        usernameController.text,
                        passwordController.text,
                      );
                      if (controller.isLoggedIn.value) {
                        // Navigate to home or main screen
                        Get.offAllNamed('/home');
                      }
                    },
                    child: Text('Login'),
                  )),
            SizedBox(height: 16),
            Obx(() => Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: Colors.red),
                )),
          ],
      ),
    ));
  }
}
