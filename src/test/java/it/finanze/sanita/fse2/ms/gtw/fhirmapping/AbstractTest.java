package it.finanze.sanita.fse2.ms.gtw.fhirmapping;

import static it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.FileUtility.getFileFromInternalResources;
import static org.junit.jupiter.api.Assumptions.assumeFalse;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.util.Date;

import org.bson.types.Binary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.DocumentReferenceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.FhirResourceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.response.TransformResDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.entity.XslTransformETY;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.impl.XslTransformRepo;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.JsonUtility;
public abstract class AbstractTest {

    @MockBean
    private XslTransformRepo xslTransformRepo;

    @Autowired
    private ServletWebServerApplicationContext webServerAppCtxt;

    @Autowired
    RestTemplate restTemplate;

    private static String DOC_REF = "{\"size\":16407,\"hash\":\"4d3e19c3c6601147b44b151325222bcc7f509db5b9f9886837f8d577da95f173\",\"facilityTypeCode\":\"Ospedale\",\"eventCode\":[\"P99\"],\"practiceSettingCode\":\"Allergologia\",\"patientID\":\"RSSMRA22A01A399Z\",\"tipoDocumentoLivAlto\":\"WOR\",\"repositoryUniqueID\":\"string\",\"serviceStartTime\":null,\"serviceStopTime\":null,\"identificativoDoc\":\"string\"}";

    void prepareXsltCollection(boolean found) {
        if (found) {
            final byte[] xslt = getFileFromInternalResources("referto-medicina-laboratorio/example/ref_med_lab.xsl");
            assumeFalse(xslt == null, "XSLT file is required for the purpose of the test");
            XslTransformETY xslEntity = new XslTransformETY();
            xslEntity.setContentXslTransform(new Binary(xslt));
            xslEntity.setLastUpdateDate(new Date());
            given(xslTransformRepo.getXsltByTemplateId(anyString())).willReturn(xslEntity);
        } else {
            given(xslTransformRepo.getXsltByTemplateId(anyString())).willReturn(null);
        }
    }

    ResponseEntity<TransformResDTO> callFhirMapping(FhirResourceDTO fhirResourceDTO) {
        String url = "http://localhost:" +
                webServerAppCtxt.getWebServer().getPort() +
                webServerAppCtxt.getServletContext().getContextPath() +
                "/v1/documents/transform";

        HttpHeaders headers = new HttpHeaders();
        headers.set("Content-Type", "application/json");

        HttpEntity<?> entity = new HttpEntity<>(fhirResourceDTO, headers);

        return restTemplate.postForEntity(url, entity, TransformResDTO.class);
    }

    protected String getTestCda(boolean broken) {
        if (broken) {
            // get invalid cda
            return null;
        } else {
            // get good cda
            return new String(getFileFromInternalResources("referto-medicina-laboratorio" + File.separator + "example" + File.separator + "CDA2_Referto_di_Medicina_di_Laboratorio1.0.xml"), StandardCharsets.UTF_8);
        }
    }

    protected DocumentReferenceDTO getTestDocumentReference(boolean broken) {
        if (broken) {
            // get invalid document reference
            return null;
        } else {
            // get good document reference
            return JsonUtility.jsonToObject(DOC_REF, DocumentReferenceDTO.class);
        }
    }
}
