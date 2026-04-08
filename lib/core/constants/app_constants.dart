class AppConstants {
  // App info
  static const String appName = 'Kossti';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'https://kossti.com/api';

  // API endpoints
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String brandsEndpoint = '/brands';
  static const String reviewsEndpoint = '/reviews';
  static const String authLoginEndpoint = '/auth/login';
  static const String authRegisterEndpoint = '/auth/register';
  static const String authLogoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/profile';

  // Shared preferences keys
  static const String prefToken = 'auth_token';
  static const String prefUser = 'current_user';
  static const String prefLocale = 'app_locale';
  static const String prefTheme = 'app_theme';

  // Supported locales
  static const String localeEnglish = 'en';
  static const String localeArabic = 'ar';

  // Pagination
  static const int pageSize = 20;

  // Cache duration
  static const int cacheDurationMinutes = 30;

  // Admin role
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';
}
