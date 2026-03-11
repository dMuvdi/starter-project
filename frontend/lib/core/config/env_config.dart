/// Environment configuration for the app.
/// Values are injected at build time using --dart-define flags.
///
/// Usage:
/// ```bash
/// flutter run --dart-define=CLOUDINARY_CLOUD_NAME=your_name \
///             --dart-define=CLOUDINARY_UPLOAD_PRESET=your_preset \
///             --dart-define=ENV=development
/// ```
class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();

  // ============================================
  // ENVIRONMENT
  // ============================================

  /// Current environment (development, staging, production)
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  /// Whether the app is running in development mode
  static bool get isDevelopment => environment == 'development';

  /// Whether the app is running in production mode
  static bool get isProduction => environment == 'production';

  // ============================================
  // CLOUDINARY CONFIGURATION
  // ============================================

  /// Cloudinary cloud name for image uploads.
  /// Get this from your Cloudinary Dashboard.
  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );

  /// Cloudinary upload preset for unsigned uploads.
  /// Create this in Cloudinary Settings → Upload → Upload Presets.
  static const String cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'symmetry_news_unsigned',
  );

  // ============================================
  // FIREBASE CONFIGURATION (Optional overrides)
  // ============================================
  // Note: Firebase configuration is primarily handled by firebase_options.dart
  // generated via `flutterfire configure`. These are optional overrides.

  /// Firebase API Key (optional override)
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );

  /// Firebase Project ID (optional override)
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  /// Firebase Auth Domain (optional override)
  static const String firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: '',
  );

  /// Firebase Messaging Sender ID (optional override)
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '',
  );

  /// Firebase App ID (optional override)
  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '',
  );

  // ============================================
  // VALIDATION
  // ============================================

  /// Validates that all required environment variables are set.
  /// Call this at app startup to catch configuration errors early.
  ///
  /// Throws [Exception] if required variables are missing.
  static void validate() {
    final missingVars = <String>[];

    if (cloudinaryCloudName.isEmpty) {
      missingVars.add('CLOUDINARY_CLOUD_NAME');
    }

    if (missingVars.isNotEmpty) {
      throw Exception(
        'Missing required environment variables: ${missingVars.join(', ')}\n'
        'Run with: flutter run --dart-define=VARIABLE_NAME=value\n'
        'See docs/ENV_CONFIG.md for setup instructions.',
      );
    }
  }

  /// Returns a map of all environment variables for debugging.
  /// Only use in development mode.
  static Map<String, String> toDebugMap() {
    if (!isDevelopment) {
      return {'error': 'Debug map only available in development mode'};
    }

    return {
      'ENV': environment,
      'CLOUDINARY_CLOUD_NAME': cloudinaryCloudName.isNotEmpty
          ? '${cloudinaryCloudName.substring(0, 3)}***'
          : 'NOT SET',
      'CLOUDINARY_UPLOAD_PRESET': cloudinaryUploadPreset,
      'FIREBASE_PROJECT_ID': firebaseProjectId.isNotEmpty
          ? '${firebaseProjectId.substring(0, 3)}***'
          : 'NOT SET (using firebase_options.dart)',
    };
  }
}
