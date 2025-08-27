plugins {
    id("dev.nx.gradle.project-graph") version("0.1.0")
    java
    id("io.quarkus")
    id("org.sonarqube") version "4.3.0.3225"
}

repositories {
    mavenCentral()
    mavenLocal()
}

val quarkusPlatformGroupId: String by project
val quarkusPlatformArtifactId: String by project
val quarkusPlatformVersion: String by project

dependencies {
    implementation(enforcedPlatform("${quarkusPlatformGroupId}:${quarkusPlatformArtifactId}:${quarkusPlatformVersion}"))
    implementation("io.quarkus:quarkus-rest")
    implementation("io.quarkus:quarkus-rest-jackson")
    implementation("io.quarkus:quarkus-arc")
    implementation("io.quarkus:quarkus-micrometer-registry-prometheus")
    testImplementation("io.quarkus:quarkus-junit5")
    testImplementation("io.rest-assured:rest-assured")
}

group = "org.acme"
version = "0.0.1"

java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}

tasks.withType<Test> {
    systemProperty("java.util.logging.manager", "org.jboss.logmanager.LogManager")
}

tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"
    options.compilerArgs.add("-parameters")
}

sonarqube {
    properties {
        property("sonar.projectKey", "getting-started")
        property("sonar.projectName", "Getting Started Quarkus App")
        property("sonar.projectVersion", version)
        property("sonar.host.url", System.getenv("SONAR_URL") ?: "http://localhost:5002")
        property("sonar.login", System.getenv("SONAR_AUTH_TOKEN"))
    }
}

allprojects {
    apply {
        plugin("dev.nx.gradle.project-graph")
    }
}