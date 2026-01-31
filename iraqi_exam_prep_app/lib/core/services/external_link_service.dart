import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

/// Centralized service for handling external links with proper error handling
/// and cross-platform compatibility.
/// 
/// This service handles:
/// - Telegram deep links with direct app launch
/// - Android 11+ package visibility compliance
/// - Proper error handling with user feedback
class ExternalLinkService {
  ExternalLinkService._();

  /// Launch Telegram chat/bot directly in the Telegram app.
  /// 
  /// Uses `tg://` scheme first for direct app launch, falls back to 
  /// `https://t.me/` if the native scheme fails.
  /// 
  /// [username] - Telegram username without @ prefix
  /// [context] - Optional BuildContext for showing error messages
  /// 
  /// Returns `true` if launch was successful, `false` otherwise.
  static Future<bool> launchTelegram(String username, {BuildContext? context}) async {
    // Remove @ if present
    final cleanUsername = username.startsWith('@') ? username.substring(1) : username;
    
    // Try native Telegram scheme first (opens Telegram app directly)
    final telegramUri = Uri.parse('tg://resolve?domain=$cleanUsername');
    
    try {
      // On mobile, prefer direct app launch
      if (!kIsWeb) {
        final canLaunchTg = await canLaunchUrl(telegramUri);
        if (canLaunchTg) {
          final launched = await launchUrl(
            telegramUri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) return true;
        }
      }
      
      // Fallback to https://t.me/ URL (will open Telegram if installed)
      final httpsUri = Uri.parse('https://t.me/$cleanUsername');
      final launched = await launchUrl(
        httpsUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        _showError(context, 'تعذر فتح تيليغرام. تأكد من تثبيت التطبيق.');
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('ExternalLinkService: Failed to launch Telegram: $e');
      _showError(context, 'تعذر فتح تيليغرام. تأكد من تثبيت التطبيق.');
      return false;
    }
  }

  /// Launch a generic external URL.
  /// 
  /// [url] - Full URL to launch
  /// [context] - Optional BuildContext for showing error messages
  /// 
  /// Returns `true` if launch was successful, `false` otherwise.
  static Future<bool> launchExternalUrl(String url, {BuildContext? context}) async {
    try {
      final uri = Uri.parse(url);
      
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        _showError(context, 'تعذر فتح الرابط');
        return false;
      }
      
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        _showError(context, 'تعذر فتح الرابط');
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('ExternalLinkService: Failed to launch URL: $e');
      _showError(context, 'تعذر فتح الرابط');
      return false;
    }
  }

  /// Show error toast to user
  static void _showError(BuildContext? context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red.shade700,
      textColor: Colors.white,
    );
  }
}
