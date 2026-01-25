/// Centralized API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

  // Auth endpoints
  static const String login = '/couriers/login/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String forgotPasswordStart = '/couriers/forgot-password/';
  static const String forgotPasswordVerify = '/couriers/verify-otp/';

  // Courier endpoints
  static const String mainMenu = '/orders/kuryer/main-menu/';
  static const String setPinCode = '/couriers/set-pin-code/';
  static const String changePin = '/couriers/change-pin/';
  static const String changePassword = '/couriers/change-password/';
  static const String checkCourierParameter =
      '/couriers/check-courier-parametr/';
  static const String updateCourierData = '/couriers/update-courier-data/';
  static const String getCourierProfile = '/couriers/get-courier-parametr/';

  // Orders endpoints
  static const String pendingOrders = '/orders/pending-orders/';
  static const String markOnWay = '/orders/mark-on-way/';
  static const String completeOrder = '/orders/complete/';
  static const String deliveredToday = '/orders/delivered-today-for-courier/';
  static const String deliveredRange = '/orders/delivered-range-for-courier/';
  static const String orderPriceBrief = '/orders/order-price-brief/';
  static const String fetchOrdersForMap = '/orders/fetch-orders-for-map/';

  // Manager/Map endpoints
  static const String onWayOrderForMap =
      '/menegers/on-way-order-for-meneger-map/';
  static const String dispatcherMapData = '/boss/dispatcher-map-data/';

  // Bot/Notification endpoints
  static const String arrivedHint = '/bots/arrived-hint/';

  // Report endpoints
  static const String cashBalance = '/couriers/cash-balance/';
  static const String cashReport = '/couriers/cash-report/';
  static const String bottleBalance = '/couriers/bottle-balance/';
  static const String bottleReport = '/couriers/bottle-report/';
  static const String courierService = '/couriers/courier-service/';

  /// App identifier sent with requests
  static const String appIdentifier = 'courier_ilova';
}
