package it.finanze.sanita.fse2.ms.gtw.fhirmapping.service;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.DocumentReferenceDTO;

/**
 * Interface of fhir resource service.
 * 
 * @author Simone Lungarella
 */
public interface IFhirResourceSRV {
    
    /**
     * Returns the json Fhir resource created starting from a CDA document.
     * 
     * @param cda Cda to transform into Fhir resource.
     * @return Json Fhir resource.
     */
	String fromCdaToJson(String cda, DocumentReferenceDTO documentReferenceDTO);
}
