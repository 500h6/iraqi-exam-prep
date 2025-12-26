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
    
    if (kIsWeb) {
      // Use LAN IP for Web so it works on iPhone/Remote devices too
      // was: return 'http://localhost:3000/api/v1';
      return 'http://192.168.0.100:3000/api/v1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://127.0.0.1:3000/api/v1';
    } else {
      // للآيفون والأجهزة الحقيقية عبر الشبكة المحلية
      return 'http://192.168.0.100:3000/api/v1';
    }
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
  static const String telegramUsername = 'h500h5';
  static const String telegramUrl = 'https://t.me/h500h5';

  // أسماء المواد
  static const String arabicSubject = 'arabic';
  static const String englishSubject = 'english';
  static const String computerSubject = 'computer';

  // حالة الرموز
  static const String activeStatus = 'active';
  static const String expiredStatus = 'expired';
  static const String usedStatus = 'used';
}
