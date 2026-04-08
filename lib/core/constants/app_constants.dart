class AppConstants {
  // App info
  static const String appName = 'Kossti';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'https://gocritserver-production.up.railway.app';

  // API endpoints
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String brandsEndpoint = '/brands';
  static const String reviewsEndpoint = '/product-reviews';
  static const String authLoginEndpoint = '/api/login';
  static const String authRegisterEndpoint = '/api/register';
  static const String authLogoutEndpoint = '/api/v1/logout';
  static const String profileEndpoint = '/users';
  static const String popularProductsEndpoint = '/popular-products';
  static const String specificationsEndpoint = '/specifications';
  static const String publicSpecEndpoint = '/get-public-spec';
  static const String publicReviewsEndpoint = '/public-reviews';

  // Shared preferences keys
  static const String prefToken = 'auth_token';
  static const String prefUser = 'current_user';
  static const String prefLocale = 'app_locale';
  static const String prefTheme = 'app_theme';

  // Supported locales
  static const String localeEnglish = 'en';
  static const String localeBengali = 'bn';

  // Pagination
  static const int pageSize = 20;

  // Cache duration
  static const int cacheDurationMinutes = 30;

  // Admin role
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';
}
