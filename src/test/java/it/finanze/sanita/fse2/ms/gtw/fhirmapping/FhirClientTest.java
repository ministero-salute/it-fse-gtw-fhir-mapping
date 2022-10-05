package it.finanze.sanita.fse2.ms.gtw.fhirmapping;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.config.Constants;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.FhirResourceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.response.TransformResDTO;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ComponentScan(basePackages = {Constants.ComponentScan.BASE})
@ActiveProfiles(Constants.Profile.TEST)
class FhirClientTest extends AbstractTest {

    @BeforeEach
    void setup() {
        prepareXsltCollection(true);
    }

    @ParameterizedTest
    @CsvSource({
            "cda, true, docRef, false",
            "cda, false, docRef, true",
            "cda, true, docRef, true",
    })
    @DisplayName("allErrorTests")
    void allErrorTests(String cda, boolean brokenCda, String docRef, boolean brokenDocRef) {
        FhirResourceDTO fhirResourceDTO = new FhirResourceDTO();
        fhirResourceDTO.setCda(getTestCda(brokenCda));
        fhirResourceDTO.setDocumentReferenceDTO(getTestDocumentReference(brokenDocRef));
        ResponseEntity<TransformResDTO> response = callFhirMapping(fhirResourceDTO);
        assertEquals(200, response.getStatusCodeValue());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getErrorMessage());
        assertEquals("Il campo document reference o il CDA non possono essere null", response.getBody().getErrorMessage());
        assertNull(response.getBody().getJson());
    }

}
