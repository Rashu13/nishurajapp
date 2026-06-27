import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/encrypted_storage_service.dart';
import '../../../core/config/api_config.dart';
import '../../../core/utils/toast_helper.dart';

class SettingsController extends GetxController {
  late TextEditingController baseUrlController;
  var currentBaseUrl = ''.obs;
  var isEditing = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadCurrentBaseUrl();
  }
  
  void _loadCurrentBaseUrl() {
    currentBaseUrl.value = ApiConfig.baseUrl;
    baseUrlController = TextEditingController(text: currentBaseUrl.value);
  }
  
  void toggleEdit() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      // Reset to current value if cancelled
      baseUrlController.text = currentBaseUrl.value;
    }
  }
  
  Future<void> saveBaseUrl() async {
    final newUrl = baseUrlController.text.trim();
    
    if (newUrl.isEmpty) {
      ToastHelper.showError('Base URL cannot be empty');
      return;
    }
    
    if (!newUrl.startsWith('http://') && !newUrl.startsWith('https://')) {
      ToastHelper.showError('URL must start with http:// or https://');
      return;
    }
    
    try {
      await EncryptedStorageService().saveApiBaseUrl(newUrl);
      // Update ApiConfig
      ApiConfig.baseUrl = newUrl;
      currentBaseUrl.value = newUrl;
      isEditing.value = false;
      ToastHelper.showSuccess('Base URL updated successfully');
      print('✅ Base URL changed to: $newUrl');
    } catch (e) {
      ToastHelper.showError('Failed to save Base URL: $e');
    }
  }
  
  Future<void> resetToDefault() async {
    try {
      await EncryptedStorageService().resetApiBaseUrl();
      ApiConfig.baseUrl = EncryptedStorageService.defaultBaseUrl;
      currentBaseUrl.value = ApiConfig.baseUrl;
      baseUrlController.text = currentBaseUrl.value;
      isEditing.value = false;
      ToastHelper.showSuccess('Base URL reset to default');
      print('🔄 Base URL reset to: ${ApiConfig.baseUrl}');
    } catch (e) {
      ToastHelper.showError('Failed to reset Base URL: $e');
    }
  }
  
  String getDebugInfo() {
    final info = EncryptedStorageService().getDebugInfo();
    return '''
Current Base URL: ${info['currentApiBaseUrl']}
Default Base URL: ${info['defaultApiBaseUrl']}
Is Custom URL: ${info['isCustomUrl']}
API Base URL: ${ApiConfig.apiBaseUrl}
    ''';
  }
  
  Future<void> downloadUpdate() async {
    // Direct download link from Google Drive
    const directDownloadUrl = 'https://drive.google.com/uc?export=download&id=1pz7390a_D7B9MrO1-tjU7MAW9o-yTe1T';
    
    try {
      ToastHelper.showInfo('Starting download...');
      
      // Try to launch URL directly
      final uri = Uri.parse(directDownloadUrl);
      
      try {
        final launched = await _launchUrl(uri);
        
        if (launched) {
          ToastHelper.showSuccess('Download started! Check your notifications.');
        } else {
          ToastHelper.showError('Failed to start download');
        }
      } catch (e) {
        print('Failed to launch download URL: $e');
        ToastHelper.showError('Failed to start download');
      }
    } catch (e) {
      print('Error starting download: $e');
      ToastHelper.showError('Failed to start download');
    }
  }
  
  Future<bool> _launchUrl(Uri uri) async {
    // Using canLaunchUrl and launchUrl pattern
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }
}
