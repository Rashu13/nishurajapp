import 'package:get_storage/get_storage.dart';

/// Encrypted Storage Service using GetStorage
/// Stores sensitive data like API base URL in local device storage
class EncryptedStorageService {
  static final EncryptedStorageService _instance = EncryptedStorageService._internal();
  static final GetStorage _storage = GetStorage();
  
  // Storage keys
  static const String _apiBaseUrlKey = 'api_base_url';
  
  // Default values
  static const String defaultBaseUrl = 'http://192.168.1.238';
  
  factory EncryptedStorageService() {
    return _instance;
  }
  
  EncryptedStorageService._internal();
  
  /// Initialize storage - call this on app startup
  static Future<void> initialize() async {
    await GetStorage.init();
    print('✅ EncryptedStorageService initialized');
  }
  
  /// Save API Base URL to encrypted storage
  Future<void> saveApiBaseUrl(String url) async {
    try {
      // Validate URL format
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        throw Exception('Invalid URL format. Must start with http:// or https://');
      }
      
      await _storage.write(_apiBaseUrlKey, url);
      print('💾 API Base URL saved: $url');
    } catch (e) {
      print('❌ Error saving API Base URL: $e');
      rethrow;
    }
  }
  
  /// Get API Base URL from encrypted storage
  /// Returns saved URL or default if not set
  String getApiBaseUrl() {
    try {
      final savedUrl = _storage.read<String>(_apiBaseUrlKey);
      
      if (savedUrl != null && savedUrl.isNotEmpty) {
        print('📖 API Base URL loaded from storage: $savedUrl');
        return savedUrl;
      }
      
      print('📖 No saved API Base URL, using default: $defaultBaseUrl');
      return defaultBaseUrl;
    } catch (e) {
      print('❌ Error reading API Base URL: $e');
      return defaultBaseUrl;
    }
  }
  
  /// Reset API Base URL to default
  Future<void> resetApiBaseUrl() async {
    try {
      await _storage.remove(_apiBaseUrlKey);
      print('🔄 API Base URL reset to default');
    } catch (e) {
      print('❌ Error resetting API Base URL: $e');
      rethrow;
    }
  }
  
  /// Get all stored API configurations for debugging
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentApiBaseUrl': getApiBaseUrl(),
      'defaultApiBaseUrl': defaultBaseUrl,
      'isCustomUrl': getApiBaseUrl() != defaultBaseUrl,
    };
  }
  
  /// Clear all storage (use with caution)
  Future<void> clearAll() async {
    try {
      await _storage.erase();
      print('🗑️ All storage cleared');
    } catch (e) {
      print('❌ Error clearing storage: $e');
      rethrow;
    }
  }
}
