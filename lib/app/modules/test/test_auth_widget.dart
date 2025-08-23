import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/session_manager.dart';
import '../../data/services/auth_service.dart';

class TestAuthWidget extends StatelessWidget {
  const TestAuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Auth & Session'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Login Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Is Logged In: ${AuthService.isUserLoggedIn()}'),
                    Text('Is Authenticated: ${SessionManager.isAuthenticated}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // User Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('User ID: ${SessionManager.currentUserId ?? 'Not logged in'}'),
                    Text('User Name: ${SessionManager.displayName}'),
                    Text('Email: ${AuthService.getEmailId() ?? 'Not available'}'),
                    Text('Account Type: ${AuthService.getAccountType() ?? 'Not available'}'),
                    Text('CSession: ${SessionManager.currentCSession ?? 'Not available'}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Session Manager Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Manager Info',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Display Name: ${SessionManager.displayName}'),
                    Text('User Info: ${SessionManager.userInfo}'),
                    const SizedBox(height: 8),
                    Text(
                      'Auth Headers:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ...SessionManager.authHeaders.entries.map(
                      (entry) => Text('${entry.key}: ${entry.value}'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // Test login with dummy data
                        final result = await AuthService.login('test', 'test123');
                        Get.snackbar(
                          'Test Login',
                          result != null ? 'Login attempt completed' : 'Login failed',
                          backgroundColor: result != null ? Colors.green : Colors.red,
                          colorText: Colors.white,
                        );
                        // Rebuild the page
                        (context as Element).markNeedsBuild();
                      } catch (e) {
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
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await SessionManager.logout();
                      Get.snackbar(
                        'Logout',
                        'Logged out successfully',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                      // Rebuild the page
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Test Logout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
