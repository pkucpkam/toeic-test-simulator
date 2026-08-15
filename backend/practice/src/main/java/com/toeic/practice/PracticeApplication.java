package com.toeic.practice;

import com.toeic.practice.entity.User;
import com.toeic.practice.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.TimeZone;

@SpringBootApplication
public class PracticeApplication {

	public static void main(String[] args) {
		TimeZone.setDefault(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
		loadDotEnv();
		SpringApplication.run(PracticeApplication.class, args);
	}

	private static void loadDotEnv() {
		try {
			Path envPath = Paths.get(".env");
			if (!Files.exists(envPath)) {
				envPath = Paths.get("backend/practice/.env");
			}
			if (Files.exists(envPath)) {
				List<String> lines = Files.readAllLines(envPath);
				for (String line : lines) {
					line = line.trim();
					if (line.isEmpty() || line.startsWith("#")) continue;
					int eqIdx = line.indexOf('=');
					if (eqIdx > 0) {
						String key = line.substring(0, eqIdx).trim();
						String val = line.substring(eqIdx + 1).trim();
						if ((val.startsWith("\"") && val.endsWith("\"")) || (val.startsWith("'") && val.endsWith("'"))) {
							val = val.substring(1, val.length() - 1);
						}
						System.setProperty(key, val);
					}
				}
				System.out.println("Loaded .env configuration. DB_URL: " + System.getProperty("DB_URL"));
			}
		} catch (Exception e) {
			System.err.println("Could not load .env file: " + e.getMessage());
		}
	}

	@Bean
	CommandLineRunner initUser(UserRepository userRepository, PasswordEncoder passwordEncoder) {
		return args -> {
			if (!userRepository.existsByEmail("phucpham.1803@gmail.com")) {
				User user = new User();
				user.setEmail("phucpham.1803@gmail.com");
				user.setFullName("pkucpkam");
				user.setPasswordHash(passwordEncoder.encode("123"));
				userRepository.save(user);
			}
		};
	}
}
