buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        project.extensions.findByType<JavaCompile>()?.let {
            it.sourceCompatibility = JavaVersion.VERSION_17.toString()
            it.targetCompatibility = JavaVersion.VERSION_17.toString()
        }
        project.extensions.findByType<org.jetbrains.kotlin.gradle.dsl.KotlinJvmOptions>()?.let {
            it.jvmTarget = JavaVersion.VERSION_17.toString()
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
