class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.smrtscrub.app/api/v1';
  // static const String baseUrl = 'https://nayem5001.binarybards.online/api/v1';
  // static const String apiVersion = '';
  //
  // Auth Endpoints
    static const String changePassword = '/auth/change-password';
  static const String login = '/auth/login';
  static const String signup = '/users';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';

  // User Endpoints
  static const String completeOnboarding = '/users/complete-onboarding';
  static const String resendVerifyEmail = '/auth/resend-otp';
  static const String verifyEmail = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  //  Endpoints
  static const String getSuppliesList = '/supplies';
  static const String getSuturesList = '/sutures';

  static const String profile = '/users/profile';
  static const String getSpecialties = '/specialties';
  static const String getLegalPages = '/legal';
  static const String getLegalPageDetails = '/legal/{slug}';
  static const String getCardCount = '/preference-cards/stats';
  static const String getAllCard = '/preference-card';
  static const String getAllCardsList = '/preference-cards';

  static const String getMyCards = '/preference-cards/my-cards';
  static const String getCardDetails = '/preference-cards/{id}';
  static const String downloadCard = '/preference-cards/{id}/download';
  static const String addToFavoriteList =
      '/preference-cards/favorites/cards/{id}';
  static const String removeFromFavoriteList =
      '/preference-cards/favorites/cards/{id}';
  // static const String getFavoriteCard = '/preference-card/favorite';
  static const String getFavoriteCard = '/users/me/favorites';

  // Event Endpoints
  static const String getCalendarHighlights = '/events/calendar-highlights';
  static const String getEventsList = '/events';
  static const String getEventDetailById = '/events/{id}';
  static const String postEvent = '/events';
  static const String patchEvent = '/events/{id}';
  static const String deleteEvent = '/events/{id}';

  // Google Sign In
  static const String googleSignIn = '/auth/google';
  static const String appleSignIn = '/auth/apple';
  static const String socialLogin = '/auth/social-login';

  // Subscription Endpoints
  static const String subscriptionBaseUrl = '/subscriptions';
  static const String getMySubscription = '/subscriptions/me';
  static const String verifyApplePurchase = '/subscriptions/apple/verify';
  static const String verifyGooglePurchase = '/subscriptions/google/verify';
  static const String chooseFreePlan = '/subscriptions/choose/free';

  // Notification Endpoints
  static const String notifications = '/notifications/me';
  static const String readNotification = '/notifications/{id}/read';
  static const String readAllNotifications = '/notifications/read-all';
  static const String deleteNotification = '/notifications/{id}';
}
