import 'package:flutter/foundation.dart';

class AppConstants {
  // إعدادات واجهة البرمجة
  // استخدم 127.0.0.1 للمحاكي (مع adb reverse) و localhost للويب
  static String get baseUrl {
    // Allows setting URL at build time: flutter build web --dart-define=BASE_URL=https://...
    const String envUrl = String.fromEnvironment('BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (kReleaseMode) {
      return 'https://iraqi-exam-prep.onrender.com/api/v1';
    }
    
    // Unified Production Environment: All platforms point to Render by default
    // so they share the same live database (Neon).
    return 'https://iraqi-exam-prep.onrender.com/api/v1';

    /* 
    // Commented out for now to ensure all platforms are linked to Live Backend
    if (kIsWeb) {
      return 'http://192.168.0.108:3000/api/v1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/v1';
    } else {
      return 'http://192.168.0.108:3000/api/v1';
    }
    */
  }
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // مفاتيح التخزين الآمن
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';

  // إعدادات الامتحان
  static const int questionsPerExam = 50;
  static const int passingScore = 60;

  // بيانات التواصل عبر تيليغرام


  // أسماء المواد
  static const String arabicSubject = 'arabic';
  static const String englishSubject = 'english';
  static const String computerSubject = 'computer';

  // حالة الرموز
  static const String activeStatus = 'active';
  static const String expiredStatus = 'expired';
  static const String usedStatus = 'used';
  // Supabase Configuration (set via --dart-define at build time)
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
}

