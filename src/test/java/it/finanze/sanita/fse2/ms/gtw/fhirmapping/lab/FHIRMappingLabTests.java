/**
 * 
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.lab;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assumptions.assumeFalse;
import static org.mockito.BDDMockito.given;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.apache.commons.io.FileUtils;
import org.bson.BsonBinarySubType;
import org.bson.types.Binary;
import org.hl7.fhir.common.hapi.validation.support.CommonCodeSystemsTerminologyService;
import org.hl7.fhir.common.hapi.validation.support.InMemoryTerminologyServerValidationSupport;
import org.hl7.fhir.common.hapi.validation.support.NpmPackageValidationSupport;
import org.hl7.fhir.common.hapi.validation.support.ValidationSupportChain;
import org.hl7.fhir.common.hapi.validation.validator.FhirInstanceValidator;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.parser.Parser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvFileSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import com.opencsv.CSVReader;
import com.opencsv.CSVReaderBuilder;

import ca.uhn.fhir.context.support.DefaultProfileValidationSupport;
import ca.uhn.fhir.validation.FhirValidator;
import ca.uhn.fhir.validation.IValidatorModule;
import ca.uhn.fhir.validation.ResultSeverityEnum;
import ca.uhn.fhir.validation.SingleValidationMessage;
import ca.uhn.fhir.validation.ValidationResult;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.config.Constants;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.config.FhirTransformCFG;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.DocumentReferenceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.enums.TransformALGEnum;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper.FHIRR4Helper;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.IXslTransformRepo;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.entity.XslTransformETY;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.scheduler.UpdateSingletonScheduler;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.IFhirResourceSRV;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.singleton.XslTransformSingleton;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.FileUtility;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.StringUtility;
import lombok.extern.slf4j.Slf4j;

@SpringBootTest
@ExtendWith(SpringExtension.class)
@ActiveProfiles(Constants.Profile.TEST)
@Slf4j
class FHIRMappingLabTests {

	private static final String TEMPLATE_ID_ROOT = "2.16.840.1.113883.2.9.10.1.1";

	@Autowired
	IFhirResourceSRV fhirResourceSRV;

	@Autowired
	UpdateSingletonScheduler scheduler;

	@MockBean
    private FhirTransformCFG fhirTransformCFG;

	@Autowired
	MongoTemplate mongoTemplate;
	
	@SpyBean
	IXslTransformRepo xslTransformRepo; 
	

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
	@ValueSource(strings = {"RefertoDiLaboratorioNonITI.json"})
	void completeTransformation(final String outputFilePath) throws IOException {
		final String jsonFhir = transformAndGet();
		assertNotNull(jsonFhir, "Transformation not handled correctly");

		try (FileWriter fw = new FileWriter(new File("src//test//resources//fhirBundle", outputFilePath), false)) {
			fw.write(jsonFhir);
		} catch (Exception e) {
			log.error("Error: ", e);
		}
	}

	@ParameterizedTest
	@ValueSource(strings = "RefertoDiLaboratorio.json")
	void customCdaTest(final String outputFilePath) {

		XslTransformETY ety = xslTransformRepo.getXsltByTemplateId("2.16.840.1.113883.2.9.10.1.1"); 
		
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
				1000, UUID.randomUUID().toString(), "facilityTypeCode", new ArrayList<>(), "practiceSettingCode", "tipoDocumentoLivAlto", "repositoryUniqueID", null, null, "identificativoDoc");
		final String jsonFhir = fhirResourceSRV.fromCdaToJson(new String(cda, StandardCharsets.UTF_8), documentReferenceDTO, ety.getId()); 
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
		
		String transformId = xslTransformRepo.getXsltByTemplateId("2.16.840.1.113883.2.9.10.1.1").getId(); 

		final byte[] cda = FileUtility.getFileFromInternalResources("referto-medicina-laboratorio/example/CDA_Referto_di _Medicina_di_Laboratorio_ES2_Complesso.xml");
		final DocumentReferenceDTO documentReferenceDTO = new DocumentReferenceDTO(1000, UUID.randomUUID().toString(), "facilityTypeCode", new ArrayList<>(), "practiceSettingCode", "tipoDocumentoLivAlto", "repositoryUniqueID", null, null, "identificativoDoc");
		fhirResourceSRV.fromCdaToJson(new String(cda, StandardCharsets.UTF_8), documentReferenceDTO, transformId); 

		log.info("Transformation complete");

		XslTransformSingleton instance = XslTransformSingleton.getInstance(transformId);

		assertNotNull(instance);
		assertNotNull(instance.getTransformer());
		assertEquals(transformId, instance.getTypeIdExtension());
		final Date lastUpdate = instance.getDataUltimoAggiornamento();
		assertNotNull(lastUpdate);

		scheduler.schedulingTask();
		instance = XslTransformSingleton.getInstance(transformId);

		// Executing scheduler when no update has been made to persistence should not have updated singleton
		assertEquals(lastUpdate, instance.getDataUltimoAggiornamento());

		Query query = new Query();
		query.addCriteria(Criteria.where("template_id_root").is(typeIdExtension));

		Update update = new Update();
		update.set("last_update_date", new Date());
		mongoTemplate.updateFirst(query, update, XslTransformETY.class);

		scheduler.schedulingTask();
		instance = XslTransformSingleton.getInstance(transformId);
		assertTrue(instance.getDataUltimoAggiornamento().after(lastUpdate));
	}

	@Test
	@Disabled
	void validateWithProfile() throws IOException {
		NpmPackageValidationSupport validation = new NpmPackageValidationSupport(FHIRR4Helper.getContext());
		validation.loadPackageFromClasspath("fhirBundle/ihe.iti.mhd-4.1.0.tgz");
		String json = transformAndGet();

		ValidationSupportChain validationSupportChain = new ValidationSupportChain(
				new DefaultProfileValidationSupport(FHIRR4Helper.getContext()),
				new InMemoryTerminologyServerValidationSupport(FHIRR4Helper.getContext()),
				new CommonCodeSystemsTerminologyService(FHIRR4Helper.getContext()), validation);

		FhirValidator validator = FHIRR4Helper.getContext().newValidator();
		IValidatorModule module = new FhirInstanceValidator(validationSupportChain);
		validator.registerValidatorModule(module);
		ca.uhn.fhir.validation.ValidationResult result = validator.validateWithResult(json);
		assertTrue(result.isSuccessful(), "Validation of CDA should have been successful");
		assertTrue(result.getMessages().stream().noneMatch(msg -> !ResultSeverityEnum.INFORMATION.equals(msg.getSeverity())), "No errors or warnings should have been found");
	}

	@ParameterizedTest(name = "Validate CDA removing dups with all configurations")
	@ValueSource(strings = {"KEEP_FIRST", /*"KEEP_LONGER",*/ "KEEP_RICHER_UP", "KEEP_RICHER_DOWN", "KEEP_PRIOR"})
	void transformAndValidate(final String configuration) {
		
		final TransformALGEnum config = TransformALGEnum.valueOf(configuration);
		given(fhirTransformCFG.getAlgToRemoveDuplicate()).willReturn(config);

		final String jsonFhir = transformAndGet();

		ValidationSupportChain validationSupportChain = new ValidationSupportChain(
				new DefaultProfileValidationSupport(FHIRR4Helper.getContext()),
				new InMemoryTerminologyServerValidationSupport(FHIRR4Helper.getContext()),
				new CommonCodeSystemsTerminologyService(FHIRR4Helper.getContext()));

		FhirValidator validator = FHIRR4Helper.getContext().newValidator();
		IValidatorModule module = new FhirInstanceValidator(validationSupportChain);
		validator.registerValidatorModule(module);

		final long start = System.currentTimeMillis();
		ValidationResult result = validator.validateWithResult(jsonFhir);
		for(SingleValidationMessage msg : result.getMessages()) {
			System.out.println("SEVERITY:" + msg.getSeverity() + " MESSAGE:" + msg.getMessage()); 
		}
		final long end = System.currentTimeMillis();

		log.info("{} - Validation time: {} ms", configuration, end - start);
		log.info("---------------------------------------");
		result.getMessages().stream().filter(msg -> !ResultSeverityEnum.INFORMATION.equals(msg.getSeverity())).forEach(msg -> log.error("{} - {}", msg.getSeverity(), msg.getMessage()));
		// assertTrue(result.isSuccessful(), "Validation of CDA should have been successful");
		// assertTrue(result.getMessages().stream().noneMatch(msg -> !ResultSeverityEnum.INFORMATION.equals(msg.getSeverity())), "No errors or warnings should have been found");
	}

	private String transformAndGet() {
		final byte[] xslt = FileUtility.getFileFromInternalResources("referto-medicina-laboratorio/example/ref_med_lab.xsl");
		assertNotNull(xslt, "XSLT file is required for the purpose of the test");
		XslTransformETY xslEntity = new XslTransformETY();
		xslEntity.setContentXslTransform(new Binary(xslt));
		xslEntity.setLastUpdateDate(new Date());
		
		String transformId = xslTransformRepo.getXsltByTemplateId("2.16.840.1.113883.2.9.10.1.1").getId(); 
		
		
		final byte[] cda = FileUtility.getFileFromInternalResources("referto-medicina-laboratorio/example/CDA2_Referto_di_Medicina_di_Laboratorio_ES1_complesso.xml");
		assertNotNull(cda, "Cda file is required for the purpose of the test");

		DocumentReferenceDTO documentReferenceDTO = new DocumentReferenceDTO(1000, UUID.randomUUID().toString(), "facilityTypeCode", new ArrayList<>(), "practiceSettingCode", "tipoDocumentoLivAlto", "repositoryUniqueID", null, null, "identificativoDoc");

		//when(xslTransformRepo.getById(anyString())).thenReturn()
		final String jsonFhir = fhirResourceSRV.fromCdaToJson(new String(cda, StandardCharsets.UTF_8), documentReferenceDTO, transformId); 
		assertNotNull(jsonFhir, "Transformation not handled correctly");
		return jsonFhir;
	}

}
