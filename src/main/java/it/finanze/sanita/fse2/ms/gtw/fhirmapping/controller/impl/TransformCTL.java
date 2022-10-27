/*
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.controller.impl;

import javax.servlet.http.HttpServletRequest;

import org.bson.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.controller.ITransformCTL;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.FhirResourceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.response.TransformResDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.InvalidRequestException;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.IFhirResourceSRV;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.StringUtility;
import lombok.extern.slf4j.Slf4j;


/**
 *
 * @author vincenzoingenito
 *
 *	Transform controller.
 */
@Slf4j
@RestController
public class TransformCTL implements ITransformCTL {

	@Autowired
	private IFhirResourceSRV fhirResourceSRV;

	@Override
	public TransformResDTO convertCDAToBundle(FhirResourceDTO fhirResourceDTO, HttpServletRequest request) {
		log.debug("Generate document reference - START");
		TransformResDTO output = new TransformResDTO();
		try {
			boolean isFhirResourceNull = fhirResourceDTO == null;
			boolean isDocumentReferenceNull = !isFhirResourceNull && fhirResourceDTO.getDocumentReferenceDTO() == null;
			boolean isCdaNull = !isFhirResourceNull && (fhirResourceDTO.getCda() == null || fhirResourceDTO.getCda().isEmpty());
			if (isFhirResourceNull || isDocumentReferenceNull || isCdaNull) {
				throw new InvalidRequestException("Il campo document reference o il CDA non possono essere null");
			}

			if (StringUtility.isNullOrEmpty(output.getErrorMessage())) {
				String bundleJson = fhirResourceSRV.fromCdaToJson(fhirResourceDTO.getCda(), 
						fhirResourceDTO.getDocumentReferenceDTO(), fhirResourceDTO.getObjectId()); 
				output.setJson(Document.parse(bundleJson));
			}
			log.debug("Generate document reference - END");
		} catch(Exception ex) {
			output.setErrorMessage(ex.getMessage());
		}
		return output;
	}



}