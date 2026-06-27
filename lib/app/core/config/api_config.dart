import '../services/encrypted_storage_service.dart';

/// Centralized API Configuration
/// This file contains all API endpoints to avoid URL repetition across the project
class ApiConfig {
  // Base URLs - Now loaded from encrypted storage
  static late String baseUrl;
  
  /// Initialize API config from encrypted storage
  static Future<void> initialize() async {
    baseUrl = EncryptedStorageService().getApiBaseUrl();
    print('🔧 ApiConfig initialized with baseUrl: $baseUrl');
  }
  
  static String get apiBaseUrl => '$baseUrl/api';
  
  // Authentication
  static String get loginEndpoint => '$apiBaseUrl/login';
  
  // KOT (Kitchen Order Ticket) APIs
  static String get kotBaseUrl => '$apiBaseUrl/kot';
  static String get activeTableItems => '$kotBaseUrl/active-table-items';
  static String get deleteSimpleItem => '$kotBaseUrl/item/delete-simple';
  static String get updateItemQty => '$kotBaseUrl/item/qty';
  static String get individualTableBills => '$kotBaseUrl/individual-table-bills';
  static String get resetTable => '$kotBaseUrl/table/reset';
  
  // Analytics APIs
  static String get analyticsSummary => '$kotBaseUrl/analytics/summary';
  static String get ordersServed => '$kotBaseUrl/analytics/orders-served';
  
  // Environment Configuration
  static bool get isDevelopment => baseUrl.contains('192.168');
  static bool get isProduction => !isDevelopment;
  
  // Helper method to build complete URLs
  static String buildUrl(String endpoint) {
    return endpoint.startsWith('http') ? endpoint : '$apiBaseUrl$endpoint';
  }
}
