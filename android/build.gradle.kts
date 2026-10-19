allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// flutter_readium 0.6.2 declares Java 18 for its Android library, while the
// project is built with the JDK 17 bundled on this workstation. The plugin's
// Android sources are Kotlin-only, so compiling generated Java stubs as Java
// 17 keeps the app compatible without requiring every developer to install a
// second JDK.
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
