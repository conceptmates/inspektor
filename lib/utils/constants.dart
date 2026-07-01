/// App-wide constants. Storage keys, timeouts, pagination.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Certifide Inspektor';

  // Secure storage keys (centralized — old app hardcoded these in 6 places)
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_data';
  static const String lastProfileUpdateKey = 'last_profile_update';

  // Network
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 10;

  // Inspection
  static const int maxMultiImages = 11;
}
