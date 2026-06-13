allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

afterEvaluate {
    subprojects.forEach { sub ->
        sub.plugins.withId("com.android.library") {
            val ns = sub.extensions
                .getByType(com.android.build.gradle.LibraryExtension::class.java)
                .namespace
            if (ns.isNullOrEmpty()) {
                val manifest = sub.file("src/main/AndroidManifest.xml")
                if (manifest.exists()) {
                    val pkg = Regex("""package="([^"]+)"""")
                        .find(manifest.readText())
                        ?.groupValues?.get(1)
                    if (pkg != null) {
                        sub.extensions
                            .getByType(com.android.build.gradle.LibraryExtension::class.java)
                            .namespace = pkg
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
