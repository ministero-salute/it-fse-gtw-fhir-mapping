/**
 * 
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.lab;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assumptions.assumeFalse;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.apache.commons.io.FileUtils;
import org.bson.BsonBinarySubType;
import org.bson.types.Binary;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.parser.Parser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvFileSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import com.opencsv.CSVReader;
import com.opencsv.CSVReaderBuilder;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.DocumentReferenceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.entity.XslTransformETY;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.scheduler.UpdateSingletonScheduler;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.IFhirResourceSRV;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.singleton.XslTransformSingleton;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.FileUtility;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.StringUtility;
import lombok.extern.slf4j.Slf4j;

@SpringBootTest
@ExtendWith(SpringExtension.class)
@ActiveProfiles("test")
@Slf4j
class FHIRMappingLabTests {

	private static final String TEMPLATE_ID_ROOT = "2.16.840.1.113883.2.9.10.1.1";
	
	@Autowired
	IFhirResourceSRV fhirResourceSRV;

	@Autowired
	UpdateSingletonScheduler scheduler;

	@Autowired
	MongoTemplate mongoTemplate;

	
	@BeforeEach
	void setup() {
		String nomeFile = "ref_med_lab.xsl";
		removeByFilename(nomeFile);
		XslTransformETY transformETY = buildXslETY(nomeFile, TEMPLATE_ID_ROOT);
		mongoTemplate.save(transformETY);
	}

	private void removeByFilename(String nomeFile) {
		Query query = new Query();
		query.addCriteria(Criteria.where("name_xsl_transform").is(nomeFile));
		mongoTemplate.remove(query, XslTransformETY.class);
	}
	private XslTransformETY buildXslETY(String nomeFile,String templateIdRoot) {
		byte[] content = FileUtility.getFileFromInternalResources("referto-medicina-laboratorio/example/"+nomeFile);
		XslTransformETY transformETY = new XslTransformETY();
		transformETY.setLastUpdateDate(new Date());
		transformETY.setNameXslTransform(nomeFile);
		transformETY.setTemplateIdRoot(templateIdRoot);
		transformETY.setTemplateIdExtension("1.0");
		transformETY.setContentXslTransform(new Binary(BsonBinarySubType.BINARY, content));
		return transformETY;
	}


	@ParameterizedTest
	@ValueSource(strings = {"RefertoDiLaboratorio.json"})
	void completeTransformation(final String outputFilePath) {

		final byte[] xslt = FileUtility.getFileFromInternalResources("referto-medicina-laboratorio/example/ref_med_lab.xsl");
		assumeFalse(xslt == null, "XSLT file is required for the purpose of the test");

		XslTransformETY xslEntity = new XslTransformETY();
		xslEntity.setContentXslTransform(new Binary(xslt));
		xslEntity.setLastUpdateDate(new Date());
		// given(xsltRepo.getXsltByTemplateId(anyString())).willReturn(xslEntity);

		final byte[] cda = FileUtility.getFileFromInternalResources(
				"referto-medicina-laboratorio/example/CDA_Referto_di _Medicina_di_Laboratorio_ES2_Complesso.xml");
		assumeFalse(cda == null, "Cda file is required for the purpose of the test");


		DocumentReferenceDTO documentReferenceDTO = new DocumentReferenceDTO(
				1000, UUID.randomUUID().toString(), "facilityTypeCode", new ArrayList<>(), "practiceSettingCode", "patientID", "tipoDocumentoLivAlto", "repositoryUniqueID", null, null, "identificativoDoc");

		final String jsonFhir = fhirResourceSRV.fromCdaToJson(new String(cda, StandardCharsets.UTF_8), documentReferenceDTO);
		assertNotNull(jsonFhir, "Transformation not handled correctly");

		try (FileWriter fw = new FileWriter(outputFilePath, false)) {
			fw.write(jsonFhir);
		} catch (Exception e) {
			log.error("Error: ", e);
		}
	}

	@ParameterizedTest
	@ValueSource(strings = "RefertoDiLaboratorio.json")
	void customCdaTest(final String outputFilePath) {

		final byte[] xslt = FileUtility.getFileFromInternalResources("referto-medicina-laboratorio/example/ref_med_lab.xsl");
		assumeFalse(xslt == null, "XSLT file is required for the purpose of the test");

		byte[] cda = FileUtility.getFileFromInternalResources("referto-medicina-laboratorio/example/CDA_Referto_di _Medicina_di_Laboratorio_ES2_Complesso.xml");
		assumeFalse(cda == null, "Cda file is required for the purpose of the test");

		cda = replaceExtension(cda, "assignedAuthor", StringUtility.generateUUID());
		cda = replaceExtension(cda, "patientRole", StringUtility.generateUUID());
		cda = replaceExtension(cda, "legalAuthenticator", StringUtility.generateUUID());
		cda = replaceExtension(cda, "intendedRecipient", StringUtility.generateUUID());
		cda = replaceExtension(cda, "documentationOf>serviceEvent>performer>assignedEntity>representedOrganization", StringUtility.generateUUID());
		cda = replaceExtension(cda, "author>assignedAuthor>representedOrganization", StringUtility.generateUUID());
		cda = replaceExtension(cda, "legalAuthenticator>assignedEntity>representedOrganization", StringUtility.generateUUID());
		cda = replaceExtension(cda, "documentationOf>serviceEvent>performer>assignedEntity", StringUtility.generateUUID());
		cda = replaceExtension(cda, "representedCustodianOrganization", StringUtility.generateUUID());
		cda = replaceExtension(cda, "componentOf>encompassingEncounter>location>healthCareFacility>serviceProviderOrganization", StringUtility.generateUUID());
		cda = replaceExtension(cda, "componentOf>encompassingEncounter>location>healthCareFacility>serviceProviderOrganization>asOrganizationPartOf", StringUtility.generateUUID());
		cda = replaceExtension(cda, "componentOf>encompassingEncounter>responsibleParty>assignedEntity", StringUtility.generateUUID());
		cda = replaceExtension(cda, "dataEnterer>assignedEntity", StringUtility.generateUUID());
		cda = replaceExtension(cda, "participant>associatedEntity>scopingOrganization", StringUtility.generateUUID());
		cda = replaceExtension(cda, "authenticator>assignedEntity", StringUtility.generateUUID());
		cda = replaceExtension(cda, "documentationOf>serviceEvent>performer>assignedEntity>representedOrganization>asOrganizationPartOf", StringUtility.generateUUID());
		cda = replaceExtension(cda, "participant>associatedEntity", StringUtility.generateUUID());


		DocumentReferenceDTO documentReferenceDTO = new DocumentReferenceDTO(
				1000, UUID.randomUUID().toString(), "facilityTypeCode", new ArrayList<>(), "practiceSettingCode", "patientID", "tipoDocumentoLivAlto", "repositoryUniqueID", null, null, "identificativoDoc");
		final String jsonFhir = fhirResourceSRV.fromCdaToJson(new String(cda, StandardCharsets.UTF_8), documentReferenceDTO);
		assertNotNull(jsonFhir, "Transformation not handled correctly");

		try (FileWriter fw = new FileWriter(outputFilePath, false)) {
			fw.write(jsonFhir);
		} catch (Exception e) {
			log.error("Error: ", e);
		}
	}

	@ParameterizedTest
	@CsvFileSource(resources = "/cdaCustomization.csv", delimiter = ',', numLinesToSkip = 1)
	void replacementTest(final String attrName, final String replacement) {
		byte[] cda = FileUtility.getFileFromInternalResources(
				"referto-medicina-laboratorio/example/CDA2_Referto_di_Medicina_di_Laboratorio1.0.xml");
		cda = replaceExtension(cda, attrName, replacement);
		final Document docT = Jsoup.parse(new String(cda, StandardCharsets.UTF_8));
		final String actualExt = docT.select(attrName).get(0).select("id").get(0).attr("extension");

		log.info("The updated extension on {} is: {}", attrName, actualExt);
		assertEquals(replacement, actualExt);
	}

	Map<String, String> readReplacementsFromFile() {
		Map<String, String> replacements = new HashMap<>();
		try {
			final File csvReplacement = File.createTempFile("replacements", "temp");
			final byte[] replaces = FileUtility.getFileFromInternalResources("cdaCustomization.csv");
			FileUtils.writeByteArrayToFile(csvReplacement, replaces);
			try (CSVReader reader = new CSVReaderBuilder(
					new FileReader(csvReplacement))
					.withSkipLines(1)
					.build()) {
				String[] lineInArray;
				while ((lineInArray = reader.readNext()) != null) {
					replacements.put(lineInArray[0], lineInArray[1]);
				}
			}
		} catch (Exception e) {
			log.error("Error while parsing csv file", e);
			throw new BusinessException(e);
		}
		return replacements;
	}

	byte[] replaceExtension(final byte[] cda, final String attrName, final String replacement) {
		byte[] out = cda;
		try {
			Document docT = Jsoup.parse(new String(cda, StandardCharsets.UTF_8), "", Parser.xmlParser());
			docT.outputSettings().syntax(Document.OutputSettings.Syntax.xml);

			Element elem = docT.select(attrName).get(0).select("id").get(0);
			elem.attributes().remove("extension");
			elem.attributes().add("extension", replacement);
			docT.select(attrName).get(0).select("id").set(0, elem);
			out = docT.toString().getBytes(StandardCharsets.UTF_8);
		} catch(Exception ex) {
			log.error("Tag non trovato");
		}
		return out;
	}

	@Test
    void updateTest() {

        final String typeIdExtension = TEMPLATE_ID_ROOT;
		XslTransformSingleton.removeInstance(typeIdExtension);
    
        log.info("Execution transformation to populate singleton");
		 
		final byte[] cda = FileUtility.getFileFromInternalResources("referto-medicina-laboratorio/example/CDA_Referto_di _Medicina_di_Laboratorio_ES2_Complesso.xml");
		final DocumentReferenceDTO documentReferenceDTO = new DocumentReferenceDTO(1000, UUID.randomUUID().toString(), "facilityTypeCode", new ArrayList<>(), "practiceSettingCode", "patientID", "tipoDocumentoLivAlto", "repositoryUniqueID", null, null, "identificativoDoc");
		fhirResourceSRV.fromCdaToJson(new String(cda, StandardCharsets.UTF_8), documentReferenceDTO);

		log.info("Transformation complete");

        XslTransformSingleton instance = XslTransformSingleton.getInstance(typeIdExtension);

        assertNotNull(instance);
        assertNotNull(instance.getTransformer());
        assertEquals(typeIdExtension, instance.getTypeIdExtension());
		final Date lastUpdate = instance.getDataUltimoAggiornamento();
		assertNotNull(lastUpdate);

		scheduler.schedulingTask();
		instance = XslTransformSingleton.getInstance(typeIdExtension);

		// Executing scheduler when no update has been made to persistence should not have updated singleton
		assertEquals(lastUpdate, instance.getDataUltimoAggiornamento());

		Query query = new Query();
		query.addCriteria(Criteria.where("template_id_root").is(typeIdExtension));

		Update update = new Update();
		update.set("last_update_date", new Date());
		mongoTemplate.updateFirst(query, update, XslTransformETY.class);

		scheduler.schedulingTask();
		instance = XslTransformSingleton.getInstance(typeIdExtension);
		assertTrue(instance.getDataUltimoAggiornamento().after(lastUpdate));
    }
}
