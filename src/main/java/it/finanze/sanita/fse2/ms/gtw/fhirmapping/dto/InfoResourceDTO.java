package it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto;

import org.hl7.fhir.r4.model.Bundle.HTTPVerb;
import org.hl7.fhir.r4.model.Identifier;

import lombok.Data;

@Data
public class InfoResourceDTO {
    
    private HTTPVerb method;

    private Identifier identifier;

    private String url;
}
