package it.finanze.sanita.fse2.ms.gtw.fhirmapping.controller.impl;

import java.util.Date;

import javax.servlet.http.HttpServletRequest;

import org.hl7.fhir.r4.model.DocumentReference;
import org.springframework.web.bind.annotation.RestController;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.controller.IDocumentReferenceCTL;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.DocumentReferenceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.response.DocumentReferenceResDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper.DocumentReferenceHelper;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper.FHIRR4Helper;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.StringUtility;
import lombok.extern.slf4j.Slf4j;


/**
 * 
 * @author vincenzoingenito
 *
 *	Document reference controller.
 */
@Slf4j
@RestController
public class DocumentReferenceCTL implements IDocumentReferenceCTL {
	
	
	@Override
	public DocumentReferenceResDTO generateDocumentReference(DocumentReferenceDTO documentReferenceDTO,HttpServletRequest request) {
		log.info("Generate document reference - START");
		DocumentReferenceResDTO output = new DocumentReferenceResDTO();
		try {
			
			if(documentReferenceDTO == null) {
				output.setErrorMessage("Il campo document reference non può essere null");
			}
			
			if(StringUtility.isNullOrEmpty(output.getErrorMessage())) {
				Date dataValidazione = new Date();
				if(documentReferenceDTO!=null) {
					DocumentReference documentReference = DocumentReferenceHelper.createDocumentReference(documentReferenceDTO.getSize(), documentReferenceDTO.getHash(), documentReferenceDTO.getFormatCode(), 
							documentReferenceDTO.getFacilityTypeCode(), documentReferenceDTO.getPatientID(), documentReferenceDTO.getRepositoryUniqueID(),
							documentReferenceDTO.getEventCode(), documentReferenceDTO.getPracticeSettingCode(), documentReferenceDTO.getServiceStartTime(), 
							documentReferenceDTO.getServiceStopTime(), documentReferenceDTO.getReferencedID(),documentReferenceDTO.getSecurityLabel(), documentReferenceDTO.getMasterIdentifier(), 
							documentReferenceDTO.getTipoDocumentoLivAlto(), documentReferenceDTO.getTypeCode(), dataValidazione, documentReferenceDTO.getAuthor(), documentReferenceDTO.getAuthenticator(), 
							documentReferenceDTO.getCustodian());
					
					String json = FHIRR4Helper.serializeResource(documentReference, true, false, false);
					output.setJson(json);
				}
			}
			log.info("Generate document reference - END");
		} catch(Exception ex) {
			String cause = ""+ex.getCause().getCause();
			output.setErrorMessage(cause);
		}
		return output;
	}
	
	
}