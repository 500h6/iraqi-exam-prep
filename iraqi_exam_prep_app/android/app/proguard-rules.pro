# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep GeneratedPluginRegistrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Connectivity Plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# General Android
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Dont warn about missing classes generally (cleaner logs)
-dontwarn io.flutter.**
