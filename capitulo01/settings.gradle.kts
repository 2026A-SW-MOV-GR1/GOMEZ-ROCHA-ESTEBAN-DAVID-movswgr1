pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Repositorio local del módulo Flutter
        maven {
            url = uri("C:/Users/Esteban/Documents/SOFTWARE/7MO SEMESTRE/APLICACIONES MOVILES/GOMEZ-ROCHA-ESTEBAN-DAVID-movswgr1/flutter_module/build/host/outputs/repo")
        }
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

rootProject.name = "My Application"
include(":app")