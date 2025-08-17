import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.trackflow"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        // Default config - will be overridden by flavors
        applicationId = "com.trackflow"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    
    productFlavors {
        create("development") {
            dimension = "environment"
            applicationId = "com.trackflow.dev"
            manifestPlaceholders["appName"] = "TrackFlow Dev"
            buildConfigField("String", "FLAVOR", "\"development\"")
            resValue("string", "app_name", "TrackFlow Dev")
        }
        
        create("staging") {
            dimension = "environment"
            applicationId = "com.trackflow.staging"
            manifestPlaceholders["appName"] = "TrackFlow Staging"
            buildConfigField("String", "FLAVOR", "\"staging\"")
            resValue("string", "app_name", "TrackFlow Staging")
        }
        
        create("production") {
            dimension = "environment"
            applicationId = "com.trackflow"
            manifestPlaceholders["appName"] = "TrackFlow"
            buildConfigField("String", "FLAVOR", "\"production\"")
            resValue("string", "app_name", "TrackFlow")
        }
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("android/key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        debug {
            isDebuggable = true
            // Removed applicationIdSuffix to match Firebase registration
        }
        
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
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

dependencies {
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}
