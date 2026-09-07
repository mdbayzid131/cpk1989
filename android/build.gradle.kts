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
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val subproject = this
    if (subproject.name != "app") {
        subproject.afterEvaluate {
            subproject.extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
                compileSdkVersion(36)
                lintOptions {
                    isCheckReleaseBuilds = false
                    isAbortOnError = false
                }
            }
            subproject.extensions.findByType(com.android.build.api.dsl.LibraryExtension::class.java)?.apply {
                compileSdk = 36
                lint {
                    checkReleaseBuilds = false
                    abortOnError = false
                }
            }
        }
    }
    tasks.matching { it.name.startsWith("lintVital") }.configureEach {
        enabled = false
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
