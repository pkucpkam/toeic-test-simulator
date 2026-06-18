plugins {
	java
	id("org.springframework.boot") version "4.1.0"
	id("io.spring.dependency-management") version "1.1.7"
}

group = "com.toeic"
version = "0.0.1-SNAPSHOT"

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(17)
	}
}

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-data-jpa")
	implementation("org.springframework.boot:spring-boot-starter-security")
	implementation("org.springframework.boot:spring-boot-starter-validation")
	implementation("org.springframework.boot:spring-boot-starter-webmvc")
	implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.8.4")
	compileOnly("org.projectlombok:lombok")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	implementation("org.xerial:sqlite-jdbc:3.45.1.0")
	implementation("org.hibernate.orm:hibernate-community-dialects:6.5.0.Final")
	implementation("org.flywaydb:flyway-core")
	annotationProcessor("org.projectlombok:lombok")
	implementation("io.jsonwebtoken:jjwt-api:0.12.5")
	runtimeOnly("io.jsonwebtoken:jjwt-impl:0.12.5")
	runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.12.5")
	testImplementation("org.springframework.boot:spring-boot-starter-data-jpa-test")
	testImplementation("org.springframework.boot:spring-boot-starter-security-test")
	testImplementation("org.springframework.boot:spring-boot-starter-validation-test")
	testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
	testCompileOnly("org.projectlombok:lombok")
	testRuntimeOnly("org.junit.platform:junit-platform-launcher")
	testAnnotationProcessor("org.projectlombok:lombok")
}

tasks.withType<Test> {
	useJUnitPlatform()
}

val isWindows = System.getProperty("os.name").lowercase().contains("windows")

tasks.register<Exec>("buildFrontend") {
	workingDir = file("../../frontend")
	commandLine = if (isWindows) {
		listOf("cmd", "/c", "npm install && npm run build")
	} else {
		listOf("sh", "-c", "npm install && npm run build")
	}
}

tasks.register<Copy>("copyFrontendToStatic") {
	dependsOn("buildFrontend")
	from("../../frontend/out")
	into("src/main/resources/static")
}

tasks.named("processResources") {
	dependsOn("copyFrontendToStatic")
}

