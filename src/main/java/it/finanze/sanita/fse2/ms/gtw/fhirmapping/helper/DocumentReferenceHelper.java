package it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.hl7.fhir.r4.model.Attachment;
import org.hl7.fhir.r4.model.CodeableConcept;
import org.hl7.fhir.r4.model.Coding;
import org.hl7.fhir.r4.model.DocumentReference;
import org.hl7.fhir.r4.model.DocumentReference.DocumentReferenceContextComponent;
import org.hl7.fhir.r4.model.Enumerations.DocumentReferenceStatus;
import org.hl7.fhir.r4.model.Identifier;
import org.hl7.fhir.r4.model.Period;
import org.hl7.fhir.r4.model.Reference;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.ContextDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.DocumentReferenceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class DocumentReferenceHelper {

	private DocumentReferenceHelper() {}

	//https://1up.health/dev/fhir/resource/DocumentReference/stu3
	
	public static void addCustodian(DocumentReference dr, String custodian) {
		dr.setCustodian(new Reference(custodian));
	}

	public static void addStatus(DocumentReference dr, DocumentReferenceStatus status) {
		dr.setStatus(status);
	}
	

	public static void addCreationTime(DocumentReference dr, Date creationTime) {
		dr.setDate(creationTime);
	}
	
	public static void addIdentifier(DocumentReference dr, String indentifier) {
		Identifier id = new Identifier();
		id.setId(indentifier); 
		dr.getIdentifier().add(id);
	}
	
	public static void addCategory(DocumentReference dr, String tipoDocumentoLivAlto) {
		if(dr.getCategory()!=null) {
			dr.getCategory().add(new CodeableConcept(new Coding("http://terminology.hl7.org/CodeSystem/media-category", tipoDocumentoLivAlto , null)));
		}
	}
	 
 
	public static void addContext(DocumentReference dr, ContextDTO contextDTO) {
		try {
			DocumentReferenceContextComponent drcc = dr.getContext();
			Coding codeFT = new Coding("http://example.org", contextDTO.getFacilityTypeCode() , null);
			CodeableConcept ccFacilityType = new CodeableConcept(codeFT);
			drcc.setFacilityType(ccFacilityType);
	
			List<CodeableConcept> events = new ArrayList<>();
			
			for(String eventCode : contextDTO.getEventsCode()) {
				CodeableConcept ccEvent = new CodeableConcept(new Coding(null, eventCode , null));
				events.add(ccEvent);
			}
			drcc.setEvent(events);
			
			drcc.setPracticeSetting(new CodeableConcept(new Coding("http://example.org", contextDTO.getPracticeSettingCode() , null)));
			
			SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
			Period period = new Period();
			if(contextDTO.getServiceStartTime() != null) {
				period.setStart(sdf.parse(contextDTO.getServiceStartTime()));
			}
			
			if(contextDTO.getServiceStopTime() != null) {
				period.setEnd(sdf.parse(contextDTO.getServiceStopTime()));
			}
			drcc.setPeriod(period);
	
		} catch (Exception ex) {
			log.error("Error while running add context : " , ex);
			throw new BusinessException("Error while running add context : " , ex);
		}

	}
 

	public static void addContent(DocumentReference dr,  String repositoryUniqueID, String mimeType, String hash, int size, String languageCode) {
		Attachment attachment = new Attachment();
		attachment.setUrl(repositoryUniqueID);
		attachment.setContentType(mimeType);
		attachment.setHash(hash.getBytes());
		attachment.setSize(size);
		attachment.setLanguage(languageCode);
		dr.getContent().get(0).setAttachment(attachment);
	}

	public static void addMasterIdentifier(DocumentReference dr, String masterIdentifier) {
		Identifier mid = new Identifier();
		mid.setId(masterIdentifier);
		dr.setMasterIdentifier(mid);
	}

	/**
	 * create document reference from DTO and CDA
	 * @param documentReferenceDTO
	 * @param dr
	 * @param dataValidazione
	 * @return
	 */
	public static DocumentReference createDocumentReference(final DocumentReferenceDTO documentReferenceDTO, final DocumentReference dr, final Date dataValidazione) {
		try {
			String language = "it-IT";
			String mimeType = "application/pdf";
			String entryUUID = "Document00";
			DocumentReferenceStatus status = DocumentReferenceStatus.CURRENT;
			
			ContextDTO contextDTO = ContextDTO.builder()
					.facilityTypeCode(documentReferenceDTO.getFacilityTypeCode())
					.eventsCode(documentReferenceDTO.getEventCode())
					.practiceSettingCode(documentReferenceDTO.getPracticeSettingCode())
					.serviceStartTime(documentReferenceDTO.getServiceStartTime())
					.serviceStopTime(documentReferenceDTO.getServiceStopTime())
					.build();

			addContext(dr, contextDTO);
			addContent(dr, documentReferenceDTO.getRepositoryUniqueID(), mimeType, documentReferenceDTO.getHash(), documentReferenceDTO.getSize(), language);
			addCategory(dr, documentReferenceDTO.getTipoDocumentoLivAlto());
			addIdentifier(dr, entryUUID);
			addCreationTime(dr, dataValidazione);
			addStatus(dr, status);
			addMasterIdentifier(dr, documentReferenceDTO.getIdentificativoDoc());
			return dr;
		} catch (Exception ex) {
			log.error("Error while create document reference : {}" , ex.getMessage());
			throw new BusinessException("Error while create document reference : " + ex.getMessage());
		}
	}
 
	 
}
