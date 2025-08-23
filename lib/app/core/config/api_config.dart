/// Centralized API Configuration
/// This file contains all API endpoints to avoid URL repetition across the project
class ApiConfig {
  // Base URLs
  //static const String baseUrl = 'http://192.168.1.6:44351';
  static const String baseUrl = 'http://192.168.1.114';
  static const String apiBaseUrl = '$baseUrl/api';
  
  // Authentication
  static const String loginEndpoint = '$apiBaseUrl/login';
  
  // KOT (Kitchen Order Ticket) APIs
  static const String kotBaseUrl = '$apiBaseUrl/kot';
  static const String activeTableItems = '$kotBaseUrl/active-table-items';
  static const String deleteSimpleItem = '$kotBaseUrl/item/delete-simple';
  static const String updateItemQty = '$kotBaseUrl/item/qty';
  static const String individualTableBills = '$kotBaseUrl/individual-table-bills';
  static const String resetTable = '$kotBaseUrl/table/reset';
  
  // Analytics APIs
  static const String analyticsSummary = '$kotBaseUrl/analytics/summary';
  static const String ordersServed = '$kotBaseUrl/analytics/orders-served';
  
  // Environment Configuration
  static bool get isDevelopment => baseUrl.contains('192.168');
  static bool get isProduction => !isDevelopment;
  
  // Helper method to build complete URLs
  static String buildUrl(String endpoint) {
    return endpoint.startsWith('http') ? endpoint : '$apiBaseUrl$endpoint';
  }
}
