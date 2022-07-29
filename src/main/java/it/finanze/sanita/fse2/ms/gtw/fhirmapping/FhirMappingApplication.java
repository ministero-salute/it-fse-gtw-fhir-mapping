package it.finanze.sanita.fse2.ms.gtw.fhirmapping;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
@EnableScheduling
public class FhirMappingApplication {

	public static void main(String[] args) {
		SpringApplication.run(FhirMappingApplication.class, args);
	}

	/**
	 * Definizione rest template.
	 *
	 * @return	rest template
	 */
	@Bean
	@Qualifier("restTemplate")
	public RestTemplate restTemplate() {
		return new RestTemplate();
	}
}
