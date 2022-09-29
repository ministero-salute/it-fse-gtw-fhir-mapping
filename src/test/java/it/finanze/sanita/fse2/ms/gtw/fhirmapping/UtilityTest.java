package it.finanze.sanita.fse2.ms.gtw.fhirmapping;

import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.test.context.ActiveProfiles;
import org.thymeleaf.util.StringUtils;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.config.Constants;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.enums.WeightFhirResEnum;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ComponentScan(basePackages = {Constants.ComponentScan.BASE})
@ActiveProfiles(Constants.Profile.TEST)
public class UtilityTest {
    
    @Test
    public void testWeightFhirResEnum() {
        for (WeightFhirResEnum weightFhirResEnum : WeightFhirResEnum.values()) {
            assertTrue(weightFhirResEnum.getName().equals(StringUtils.trim(weightFhirResEnum)));
        }
    }
}
