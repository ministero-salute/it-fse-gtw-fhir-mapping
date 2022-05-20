package it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.hl7.fhir.r4.model.Attachment;
import org.hl7.fhir.r4.model.CodeableConcept;
import org.hl7.fhir.r4.model.Coding;
import org.hl7.fhir.r4.model.DocumentReference;
import org.hl7.fhir.r4.model.DocumentReference.DocumentReferenceContentComponent;
import org.hl7.fhir.r4.model.DocumentReference.DocumentReferenceContextComponent;
import org.hl7.fhir.r4.model.Enumerations.DocumentReferenceStatus;
import org.hl7.fhir.r4.model.Identifier;
import org.hl7.fhir.r4.model.Period;
import org.hl7.fhir.r4.model.Reference;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class DocumentReferenceHelper {

	
	//https://1up.health/dev/fhir/resource/DocumentReference/stu3
	
	public static void addCustodian(DocumentReference dr, String custodian) {
		dr.setCustodian(new Reference(custodian));
	}

	public static void addStatus(DocumentReference dr, DocumentReferenceStatus status) {
		dr.setStatus(status);
	}
	
	public static void addLegalAuthenticator(DocumentReference dr, String authenticator) {
		dr.setAuthenticator(new Reference(authenticator));
	}
	
	
	public static void addAuthor(DocumentReference dr, String author) {
		List<Reference> authors = new ArrayList<>();
		authors.add(new Reference(author));
		dr.setAuthor(authors);
	}

	public static void addCreationTime(DocumentReference dr, Date creationTime) {
		dr.setDate(creationTime);
	}
	
	public static void addIdentifier(DocumentReference dr, String indentifier) {
		List<Identifier> ids = new ArrayList<>();
		Identifier id = new Identifier();
		id.setId(indentifier);
		ids.add(id);
		dr.setIdentifier(ids);
	}
	
	public static void addType(DocumentReference dr, String typeCode) {
		dr.setType(new CodeableConcept(new Coding(null, typeCode, null)));
	}
	
	public static void addCategory(DocumentReference dr, String tipoDocumentoLivAlto) {
		List<CodeableConcept> categories = new ArrayList<>();
		categories.add(new CodeableConcept(new Coding(null, tipoDocumentoLivAlto , null)));
		dr.setCategory(categories);
	}
	
	public static void addMasterIdentifier(DocumentReference dr, String masterIdentifier) {
		Identifier id = new Identifier();
		id.setId(masterIdentifier);
		dr.setMasterIdentifier(id);
	}

	public static void addSecurityLabel(DocumentReference dr, String confidentialityCode) {
		List<CodeableConcept> securityLabels = new ArrayList<>();
		securityLabels.add(new CodeableConcept(new Coding(null, confidentialityCode, null)));
		dr.setSecurityLabel(securityLabels);
	}

	public static void addContext(DocumentReference dr, String facilityTypeCode, List<String> eventsCode, 
			String practiceSettingCode, String serviceStartTime, String serviceStopTime, String referenceId, String patientID) {
		try {
			DocumentReferenceContextComponent drcc = new DocumentReferenceContextComponent();
			Coding codeFT = new Coding(null, facilityTypeCode , null);
			CodeableConcept ccFacilityType = new CodeableConcept(codeFT);
			drcc.setFacilityType(ccFacilityType);
	
			List<CodeableConcept> events = new ArrayList<CodeableConcept>();
			
			for(String eventCode : eventsCode) {
				CodeableConcept ccEvent = new CodeableConcept(new Coding(null, eventCode , null));
				events.add(ccEvent);
			}
			drcc.setEvent(events);
			
			drcc.setPracticeSetting(new CodeableConcept(new Coding(null, practiceSettingCode , null)));
			
			drcc.setSourcePatientInfo(new Reference(patientID));
			
			SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
			Period period = new Period();
			period.setStart(sdf.parse(serviceStartTime));
			period.setEnd(sdf.parse(serviceStopTime));
			drcc.setPeriod(period);
			
			List<Reference> relateds = new ArrayList<>();
			relateds.add(new Reference(referenceId));
			drcc.setRelated(relateds);
	
			dr.setContext(drcc);
		} catch (Exception ex) {
			log.error("Error while running add context : " , ex);
			throw new BusinessException("Error while running add context : " , ex);
		}

	}

	public static void addPatientID(DocumentReference dr, String patientID) {
		Reference ref = new Reference(patientID);
		dr.setSubject(ref);
	}

	public static void addContent(DocumentReference dr, String formatCode, String repositoryUniqueID, String mimeType, byte[] hash, int size, String languageCode) {
		List<DocumentReferenceContentComponent> contents = new ArrayList<DocumentReference.DocumentReferenceContentComponent>();
		DocumentReferenceContentComponent content = new DocumentReferenceContentComponent();
		content.setFormat(new Coding(null, formatCode, null));
		Attachment attachment = new Attachment();
		attachment.setUrl(repositoryUniqueID);
		attachment.setContentType(mimeType);
		attachment.setHash(hash);
		attachment.setSize(size);
		attachment.setLanguage(languageCode);
		content.setAttachment(attachment);
		contents.add(content);
		dr.setContent(contents);
	}

	/**
	 * 
	 * @param formatCode			CDA:/ClinicalDocument/templateId/@root
	 * @param referencedID 			CDA:/ClinicalDocument/inFulfillmentOf/order/id/@extension
	 * @param securityLabel 		CDA:/ClinicalDocument/confidentialityCode/@code
	 * @param masterIdentifier		CDA:/ClinicalDocument/id/@extension
	 * @param typeCode				CDA:/ClinicalDocument/code/@code
	 * @param author				CDA:/ClinicalDocument/author/
	 * @param authenticator			CDA:/ClinicalDocument/legalAuthenticator/assignedEntity/id/@extension
	 * @param custodian				CDA:/ClinicalDocument/assignedCustodian/id/@extension
	 * @param facilityTypeCode		input:tipologiaStruttura
	 * @param content				input:file
	 * @param repositoryUniqueID	input:identificativoRep
	 * @param eventCode				input:regoleAccesso
	 * @param practiceSettingCode	input:assettoOrganizzativo
	 * @param serviceStartTime		input:dataInizioPrestazione
	 * @param serviceStopTime		input:dataFinePrestazione
	 * @param categoryCode			input:tipoDocumentoLivAlto
	 * @param dataValidazione		data di validazione del documento
	 * @return
	 */
	public static DocumentReference createDocumentReference(Integer size, byte[] hash, String formatCode, 
			String facilityTypeCode, String patientID, String repositoryUniqueID, List<String> eventCode, 
			String practiceSettingCode, String serviceStartTime, String serviceStopTime, String referencedID, String securityLabel, String masterIdentifier, 
			String tipoDocumentoLivAlto, String typeCode, Date dataValidazione, String author, String authenticator, String custodian) {
		try {
			String language = "it-IT";
			String mimeType = "application/pdf";
			String entryUUID = "Document00";
			DocumentReferenceStatus status = DocumentReferenceStatus.CURRENT;
			
			DocumentReference dr = new DocumentReference();
			addContext(dr, facilityTypeCode, eventCode, practiceSettingCode, serviceStartTime, serviceStopTime, referencedID, patientID);
			addPatientID(dr, patientID);
			addContent(dr, formatCode, repositoryUniqueID, mimeType, hash, size, language);
			addSecurityLabel(dr, securityLabel);
			addMasterIdentifier(dr, masterIdentifier);
			addCategory(dr, tipoDocumentoLivAlto);
			addType(dr, typeCode);
			addIdentifier(dr, entryUUID);
			addCreationTime(dr, dataValidazione);
			addAuthor(dr, author);
			addLegalAuthenticator(dr, authenticator);
			addStatus(dr, status);
			addCustodian(dr, custodian);
			return dr;
		} catch (Exception ex) {
			log.error("Error while create document reference : " , ex);
			throw new BusinessException("Error while create document reference : " , ex);
		}
	}
 
	 
}
