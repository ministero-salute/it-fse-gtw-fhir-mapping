//package it.finanze.sanita.fse2.ms.gtw.fhirmapping;
//
//import it.finanze.sanita.fse2.ms.gtw.fhirmapping.config.Constants;
//import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.DocumentReferenceDTO;
//import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.FhirResourceDTO;
//import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.response.DocumentReferenceResDTO;
//import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
//import it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper.DocumentReferenceHelper;
//import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.FileUtility;
//import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.JsonUtility;
//import lombok.extern.slf4j.Slf4j;
//import org.junit.jupiter.api.DisplayName;
//import org.junit.jupiter.api.Test;
//import org.springframework.boot.test.context.SpringBootTest;
//import org.springframework.context.annotation.ComponentScan;
//import org.springframework.http.ResponseEntity;
//import org.springframework.test.context.ActiveProfiles;
//import org.springframework.web.client.HttpClientErrorException;
//
//import java.nio.charset.StandardCharsets;
//import java.util.Date;
//
//import static org.junit.jupiter.api.Assertions.*;
//
//@Slf4j
//@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
//@ComponentScan(basePackages = {Constants.ComponentScan.BASE})
//@ActiveProfiles(Constants.Profile.TEST)
//class FhirResourceTest extends AbstractTest {
//
//    private FhirResourceDTO prepareRequest(boolean toNullDTO, boolean toNullCda, boolean toNullDocumentReference) {
//        FhirResourceDTO fhirResourceDTO = null;
//
//        if (!toNullDTO) {
//            fhirResourceDTO = new FhirResourceDTO();
//        }
//
//        if (!toNullDTO && !toNullCda) {
//            final byte[] cda = FileUtility.getFileFromInternalResources("referto-medicina-laboratorio/example/CDA2_Referto_di_Medicina_di_Laboratorio1.0.xml");
//            fhirResourceDTO.setCda(new String(cda, StandardCharsets.UTF_8));
//        }
//
//        if (!toNullDTO && !toNullDocumentReference) {
//            String documentReference = "{\"size\":57590,\"hash\":\"ccd1a23b4a73c838e4dfc2a1948aaec8389ebd331cbaebc1b3144c74fca17da5\",\"facilityTypeCode\":\"Ospedale\",\"eventCode\":[\"P99\"],\"practiceSettingCode\":\"Allergologia\",\"patientID\":\"RSSMRA22A01A399Z\",\"tipoDocumentoLivAlto\":\"WOR\",\"repositoryUniqueID\":\"string\",\"serviceStartTime\":null,\"serviceStopTime\":null}";
//            fhirResourceDTO.setDocumentReferenceDTO(JsonUtility.jsonToObject(documentReference, DocumentReferenceDTO.class));
//        }
//
//        return fhirResourceDTO;
//    }
//
//    @Test
//    @DisplayName("successTest")
//    void successTest() {
//        prepareXsltCollection(true);
//        FhirResourceDTO fhirResourceDTO = this.prepareRequest(false, false, false);
//        assertNotNull(fhirResourceDTO);
//        assertNotNull(fhirResourceDTO.getCda());
//        assertNotNull(fhirResourceDTO.getDocumentReferenceDTO());
//        ResponseEntity<DocumentReferenceResDTO> response = callFhirMapping(fhirResourceDTO);
//        assertEquals(200, response.getStatusCodeValue());
//        assertNotNull(response.getBody());
//        assertNull(response.getBody().getErrorMessage());
//        assertNotNull(response.getBody().getJson());
//    }
//
//    @Test
//    @DisplayName("errorNullDTOTests")
//    void errorNullDTOTests() {
//        prepareXsltCollection(true);
//        ResponseEntity<DocumentReferenceResDTO> response;
//
//        // Null DTO
//        FhirResourceDTO fhirResourceDTO = this.prepareRequest(true, false, false);
//        assertNull(fhirResourceDTO);
//        assertThrows(HttpClientErrorException.BadRequest.class, () -> callFhirMapping(fhirResourceDTO));
//    }
//
//    @Test
//    @DisplayName("errorTestsNullCDA")
//    void errorNullCDATests() {
//        prepareXsltCollection(true);
//        ResponseEntity<DocumentReferenceResDTO> response;
//
//        // Null CDA
//        FhirResourceDTO fhirResourceDTO = this.prepareRequest(false, true, false);
//        assertNotNull(fhirResourceDTO);
//        assertNull(fhirResourceDTO.getCda());
//        response = callFhirMapping(fhirResourceDTO);
//        assertNotNull(response.getBody());
//        assertNotNull(response.getBody().getErrorMessage());
//        assertTrue(response.getBody().getErrorMessage().contains("Il campo document reference o il CDA non possono essere null"));
//    }
//
//    @Test
//    @DisplayName("errorTestsNullDocumentReference")
//    void errorTestsNullDocumentReference() {
//        prepareXsltCollection(true);
//        ResponseEntity<DocumentReferenceResDTO> response;
//
//        // Null DocumentReference
//        FhirResourceDTO fhirResourceDTO = this.prepareRequest(false, false, true);
//        assertNotNull(fhirResourceDTO);
//        assertNotNull(fhirResourceDTO.getCda());
//        assertNull(fhirResourceDTO.getDocumentReferenceDTO());
//        response = callFhirMapping(fhirResourceDTO);
//        assertNotNull(response.getBody());
//        assertNotNull(response.getBody().getErrorMessage());
//        assertTrue(response.getBody().getErrorMessage().contains("Il campo document reference o il CDA non possono essere null"));
//    }
//
//    @Test
//    @DisplayName("errorTestsXsltNotFound")
//    void errorTestsXsltNotFound() {
//        // XSLT not found
//        prepareXsltCollection(false);
//        ResponseEntity<DocumentReferenceResDTO> response;
//
//        FhirResourceDTO fhirResourceDTO = this.prepareRequest(false, false, false);
//        assertNotNull(fhirResourceDTO);
//        assertNotNull(fhirResourceDTO.getCda());
//        assertNotNull(fhirResourceDTO.getDocumentReferenceDTO());
//        response = callFhirMapping(fhirResourceDTO);
//        assertNotNull(response.getBody());
//        assertNotNull(response.getBody().getErrorMessage());
//    }
//
//    @Test
//    @DisplayName("errorInvalidCDATest")
//    void errorInvalidCDATest() {
//        prepareXsltCollection(false);
//        ResponseEntity<DocumentReferenceResDTO> response;
//
//        String invalidCDA = "invalid-cda";
//        FhirResourceDTO fhirResourceDTO = this.prepareRequest(false, false, false);
//        fhirResourceDTO.setCda(invalidCDA);
//        assertNotNull(fhirResourceDTO);
//        assertNotNull(fhirResourceDTO.getCda());
//        assertNotNull(fhirResourceDTO.getDocumentReferenceDTO());
//        response = callFhirMapping(fhirResourceDTO);
//        assertThrows(BusinessException.class, () -> DocumentReferenceHelper.createDocumentReference(
//                fhirResourceDTO.getDocumentReferenceDTO(),
//                invalidCDA,
//                new Date()));
//        assertNotNull(response.getBody());
//        assertNotNull(response.getBody().getErrorMessage());
//    }
//}
