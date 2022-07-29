package it.finanze.sanita.fse2.ms.gtw.fhirmapping.controller.impl;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.controller.IDocumentReferenceCTL;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.FhirResourceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.response.DocumentReferenceResDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.InvalidRequestException;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.IFhirResourceSRV;
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

	@Autowired
	private IFhirResourceSRV fhirResourceSRV;

	@Override
	public DocumentReferenceResDTO generateDocumentReference(FhirResourceDTO fhirResourceDTO, HttpServletRequest request) {
		log.info("Generate document reference - START");
		DocumentReferenceResDTO output = new DocumentReferenceResDTO();
		try {
			boolean isFhirResourceNull = fhirResourceDTO == null;
			boolean isDocumentReferenceNull = !isFhirResourceNull && fhirResourceDTO.getDocumentReferenceDTO() == null;
			boolean isCdaNull = !isFhirResourceNull && (fhirResourceDTO.getCda() == null || fhirResourceDTO.getCda().isEmpty());
			if (isFhirResourceNull || isDocumentReferenceNull || isCdaNull) {
				throw new InvalidRequestException("Il campo document reference o il CDA non possono essere null");
			}

			if (StringUtility.isNullOrEmpty(output.getErrorMessage())) {
				String bundleJson = fhirResourceSRV.fromCdaToJson(fhirResourceDTO.getCda(), fhirResourceDTO.getDocumentReferenceDTO());
				output.setJson(bundleJson);
			}
			log.info("Generate document reference - END");
		} catch(Exception ex) {
			output.setErrorMessage(ex.getMessage());
		}
		return output;
	}



}