import org.gradle.api.JavaVersion
import org.gradle.api.ProjectEvaluationListener
import org.gradle.api.ProjectState
import org.gradle.api.tasks.compile.JavaCompile

pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// flutter_readium 0.6.2 declares Java 18 for its Android library. The app's
// configured Flutter toolchain uses JDK 17, and the plugin sources do not use
// Java 18 language features. Apply the compatible Android compile level after
// the library project is evaluated, before its compile task executes.
gradle.addProjectEvaluationListener(object : ProjectEvaluationListener {
    override fun beforeEvaluate(project: Project) = Unit

    override fun afterEvaluate(project: Project, state: ProjectState) {
        if (project.name != "flutter_readium") return

        project.tasks.withType(JavaCompile::class.java).configureEach {
            sourceCompatibility = JavaVersion.VERSION_17.toString()
            targetCompatibility = JavaVersion.VERSION_17.toString()
        }

        val androidExtension = project.extensions.findByName("android") ?: return
        val compileOptions = androidExtension.javaClass.methods
            .firstOrNull { it.name == "getCompileOptions" && it.parameterCount == 0 }
            ?.invoke(androidExtension)
            ?: return
        listOf("setSourceCompatibility", "setTargetCompatibility").forEach { methodName ->
            compileOptions.javaClass.methods
                .firstOrNull { it.name == methodName && it.parameterCount == 1 }
                ?.invoke(compileOptions, JavaVersion.VERSION_17)
        }
    }
})

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.21" apply false
}

include(":app")
