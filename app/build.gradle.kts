plugins {
    id("com.android.application")
}

android {
    namespace = "com.luckyzyx.luckytool.vivoscreenshot"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.luckyzyx.luckytool.vivoscreenshot"
        minSdk = 30
        targetSdk = 35
        versionCode = 1
        versionName = "0.1-vivo-test"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    compileOnly("de.robv.android.xposed:api:82")
}
