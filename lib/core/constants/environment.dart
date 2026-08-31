/// Environment configuration for BellGo
/// 
/// Controls which implementations (Mock vs Firebase) are used for services.
/// Toggle USE_FIREBASE to switch between development and production.
class AppEnvironment {
  static const bool USE_FIREBASE = bool.fromEnvironment(
    'USE_FIREBASE',
    defaultValue: false,
  );

  static const bool IS_DEVELOPMENT = !USE_FIREBASE;
  static const bool IS_PRODUCTION = USE_FIREBASE;

  /// Firebase project configuration
  static const String FIREBASE_PROJECT_ID = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'bellgo-dev',
  );

  /// Twilio configuration (used in Cloud Functions)
  static const String TWILIO_ACCOUNT_SID = String.fromEnvironment(
    'TWILIO_ACCOUNT_SID',
    defaultValue: '',
  );
}
