# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep for HTTP client
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class com.google.gson.** { *; }

# Keep for shared preferences
-keep class android.content.SharedPreferences { *; }

# Keep for localization
-keep class java.util.Locale { *; }

# Keep for provider
-keep class **$$ViewBinder { *; }
-keep class **$$ViewInjector { *; }