package it.finanze.sanita.fse2.ms.gtw.fhirmapping;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.config.Constants;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.FhirResourceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.response.DocumentReferenceResDTO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

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
        ResponseEntity<DocumentReferenceResDTO> response = callFhirMapping(fhirResourceDTO);
        assertEquals(200, response.getStatusCodeValue());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getErrorMessage());
        assertEquals("Il campo document reference o il CDA non possono essere null", response.getBody().getErrorMessage());
        assertNull(response.getBody().getJson());
    }

    @ParameterizedTest
    @CsvSource({"cda, false, docRef, false"})
    @DisplayName("successTest")
    void successTest(String cda, boolean brokenCda, String docRef, boolean brokenDocRef) {
        FhirResourceDTO fhirResourceDTO = new FhirResourceDTO();
        fhirResourceDTO.setCda(getTestCda(brokenCda));
        fhirResourceDTO.setDocumentReferenceDTO(getTestDocumentReference(brokenDocRef));
        ResponseEntity<DocumentReferenceResDTO> response = callFhirMapping(fhirResourceDTO);
        assertEquals(200, response.getStatusCodeValue());
        assertNotNull(response.getBody());
        assertNull(response.getBody().getErrorMessage());
        assertNotNull(response.getBody().getJson());
    }
}