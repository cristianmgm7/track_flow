class ErrorMessages {
  static String getUserFriendlyMessage(String code, [String? message]) {
    switch (code) {
      case 'NETWORK_ERROR':
        return 'Please check your internet connection and try again';
      case 'SERVER_ERROR':
        return 'We\'re experiencing technical difficulties. Please try again later';
      case 'AUTH_ERROR':
        return message ?? 'Authentication failed. Please try again';
      case 'VALIDATION_ERROR':
        return message ?? 'Please check your input and try again';
      case 'DATABASE_ERROR':
        return 'Unable to complete operation. Please try again';
      case 'PERMISSION_DENIED':
        return 'You don\'t have permission to perform this action';
      default:
        return message ?? 'An unexpected error occurred. Please try again';
    }
  }

  static String getNetworkErrorMessage(String? statusCode) {
    switch (statusCode) {
      case '404':
        return 'The requested resource was not found';
      case '401':
        return 'Please login again to continue';
      case '403':
        return 'You don\'t have permission to access this resource';
      case '500':
        return 'We\'re experiencing server issues. Please try again later';
      case '503':
        return 'Service temporarily unavailable. Please try again later';
      default:
        return 'A network error occurred. Please try again';
    }
  }
}
