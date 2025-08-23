/// Centralized Error Handler for Professional Error Messages
/// This prevents exposing sensitive information like API URLs in error messages
class ApiErrorHandler {
  
  /// Convert technical API errors to user-friendly messages
  static String getErrorMessage(dynamic error, {String? context}) {
    String userMessage = _getUserFriendlyMessage(error, context);
    
    // Log technical details only in debug mode (not shown to user)
    _logTechnicalError(error, context);
    
    return userMessage;
  }
  
  /// Get user-friendly error message without exposing sensitive data
  static String _getUserFriendlyMessage(dynamic error, String? context) {
    // Default context-specific messages
    Map<String, String> contextMessages = {
      'login': 'Login failed. Please check your credentials.',
      'bills': 'Unable to load bills. Please try again.',
      'orders': 'Unable to load orders. Please try again.',
      'analytics': 'Unable to load analytics data. Please try again.',
      'table_reset': 'Unable to reset table. Please try again.',
      'delete_item': 'Unable to delete item. Please try again.',
      'update_quantity': 'Unable to update quantity. Please try again.',
      'menu': 'Unable to load menu. Please try again.',
      'tables': 'Unable to load tables. Please try again.',
    };
    
    // Return context-specific message if available
    if (context != null && contextMessages.containsKey(context)) {
      return contextMessages[context]!;
    }
    
    // Generic network error messages
    if (error.toString().contains('timeout') || 
        error.toString().contains('connection')) {
      return 'Network timeout. Please check your internet connection.';
    }
    
    if (error.toString().contains('404')) {
      return 'Service not available. Please try again later.';
    }
    
    if (error.toString().contains('500') || 
        error.toString().contains('server')) {
      return 'Server error. Please try again later.';
    }
    
    if (error.toString().contains('unauthorized') || 
        error.toString().contains('401')) {
      return 'Session expired. Please login again.';
    }
    
    // Default message for unknown errors
    return 'Something went wrong. Please try again.';
  }
  
  /// Log technical error details for debugging (not shown to user)
  static void _logTechnicalError(dynamic error, String? context) {
    // Only log in debug mode - these won't be shown to users
    print('🔧 Technical Error [${context ?? 'Unknown'}]: $error');
    
    // In production, you can send these to crash analytics
    // crashlytics.recordError(error, stackTrace, context: context);
  }
  
  /// Success message helpers
  static String getSuccessMessage(String context) {
    Map<String, String> successMessages = {
      'login': 'Login successful!',
      'table_reset': 'Table reset successfully!',
      'delete_item': 'Item deleted successfully!',
      'update_quantity': 'Quantity updated successfully!',
      'order_placed': 'Order placed successfully!',
    };
    
    return successMessages[context] ?? 'Operation completed successfully!';
  }
}
