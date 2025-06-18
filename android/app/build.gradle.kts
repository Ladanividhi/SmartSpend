import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}


        android {
            namespace = "com.example.smartspend"
            compileSdk = flutter.compileSdkVersion
            ndkVersion = "27.0.12077973"

            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_11
                targetCompatibility = JavaVersion.VERSION_11
            }

            kotlinOptions {
                jvmTarget = JavaVersion.VERSION_11.toString()
            }

            defaultConfig {
                applicationId = "com.example.smartspend"
                minSdk = 23
                targetSdk = flutter.targetSdkVersion
                versionCode = flutter.versionCode
                versionName = flutter.versionName
            }

            // Load key.properties for signing
            val keystoreProperties = Properties()
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            }

            signingConfigs {
                create("release") {
                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                    storeFile = file(keystoreProperties["storeFile"] as String)
                    storePassword = keystoreProperties["storePassword"] as String
                }
            }

            buildTypes {
                getByName("debug") {
                    isMinifyEnabled = false
                    // DO NOT put shrinkResources here
                }

                getByName("release") {
                    isMinifyEnabled = true
                    // DO NOT put shrinkResources here
                    signingConfig = signingConfigs.getByName("release")
                }
            }
        }

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.14.0"))
    implementation("com.google.firebase:firebase-analytics")
}
