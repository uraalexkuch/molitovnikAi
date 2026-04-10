plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.molitovnik"
    // Оновлено до вимог нових плагінів
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        // Оновлено до Java 17, щоб прибрати "source value 8 is obsolete"
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.molitovnik"
        // Мінімальна версія для роботи ШІ та мікрофона
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Підпис додатка тестовим ключем для збірки --release
            signingConfig = signingConfigs.getByName("debug")
            
            // Підключення правил оптимізації ProGuard/R8
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
