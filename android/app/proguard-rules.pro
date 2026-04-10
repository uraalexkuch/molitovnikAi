# Ігнорувати попередження для OkHttp та пов'язаних бібліотек
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Ігнорувати попередження для інструментів анотацій (AutoValue тощо)
-dontwarn javax.lang.model.**
-dontwarn com.google.auto.value.**

# Збереження класів, які можуть викликати помилки в рантаймі
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Спеціальні правила для background_downloader
-keep class com.bb_labs.background_downloader.** { *; }
-dontwarn com.bb_labs.background_downloader.**

# Спеціальні правила для flutter_gemma та sherpa_onnx
-dontwarn com.google.mediapipe.**
-dontwarn com.google.protobuf.**
-keep class com.google.mediapipe.** { *; }
-keep class com.k2fsa.sherpa.onnx.** { *; }

# Правила для path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Правила для local_auth
-keep class io.flutter.plugins.localauth.** { *; }
