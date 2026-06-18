package com.toeic.practice;

import com.toeic.practice.entity.User;
import com.toeic.practice.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.TimeZone;

@SpringBootApplication
public class PracticeApplication {

	public static void main(String[] args) {
		TimeZone.setDefault(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
		SpringApplication.run(PracticeApplication.class, args);
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

	@org.springframework.context.event.EventListener(org.springframework.boot.context.event.ApplicationReadyEvent.class)
	public void openBrowser() {
		try {
			String os = System.getProperty("os.name").toLowerCase();
			if (os.contains("win")) {
				Runtime.getRuntime().exec("rundll32 url.dll,FileProtocolHandler http://localhost:8080");
			} else if (os.contains("mac")) {
				Runtime.getRuntime().exec("open http://localhost:8080");
			} else if (os.contains("nix") || os.contains("nux")) {
				Runtime.getRuntime().exec("xdg-open http://localhost:8080");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
