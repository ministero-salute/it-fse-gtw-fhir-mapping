package it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.impl;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.xml.transform.Transformer;

import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Bundle.BundleEntryComponent;
import org.hl7.fhir.r4.model.Bundle.HTTPVerb;
import org.hl7.fhir.r4.model.DocumentReference;
import org.hl7.fhir.r4.model.Identifier;
import org.hl7.fhir.r4.model.Organization;
import org.hl7.fhir.r4.model.Patient;
import org.hl7.fhir.r4.model.Practitioner;
import org.hl7.fhir.r4.model.PractitionerRole;
import org.hl7.fhir.r4.model.Reference;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.ResourceType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.InfoResourceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.DocumentReferenceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.MissingXsltException;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper.CDAHelper;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper.DocumentReferenceHelper;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper.FHIRR4Helper;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.IXslTransformRepo;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.entity.XslTransformETY;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.IFhirResourceSRV;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.singleton.XslTransformSingleton;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.StringUtility;
import lombok.extern.slf4j.Slf4j;

/**
 * Service that handle json Fhir resources.
 * 
 * @author Simone Lungarella
 */
@Slf4j
@Service
public class FhirResourceSRV implements IFhirResourceSRV {

    @Autowired
    private IXslTransformRepo xsltRepo;

    @Override
    public String fromCdaToJson(String cda, final DocumentReferenceDTO documentReferenceDTO) {
        try {
            final String templateId = CDAHelper.extractTemplateId(cda);
            log.info("Executing transformation of CDA with template id: {}", templateId);
            
			final Transformer transform = getXsltTransform(templateId);

            if (transform != null) {
            	cda = cda.replace("xmlns=\"urn:hl7-org:v3\"", "").replace("xmlns:mif=\"urn:hl7-org:v3/mif\"", "");
            	
                log.debug("XSLT found on database, executing transformation");
                
                final String fhirXML = FHIRR4Helper.trasform(transform, cda.getBytes(StandardCharsets.UTF_8));
                final Bundle bundle = FHIRR4Helper.deserializeResource(Bundle.class, fhirXML, false);
                 
				for(BundleEntryComponent entry : bundle.getEntry()) { 
					Resource resource = entry.getResource(); 
					InfoResourceDTO info = null;

					if (ResourceType.DocumentReference.equals(resource.getResourceType())){
						DocumentReference documentReferenceXslt = (DocumentReference)resource;
						DocumentReferenceHelper.createDocumentReference(documentReferenceDTO, documentReferenceXslt, new Date());
					} else if (ResourceType.PractitionerRole.equals(resource.getResourceType())) {
						PractitionerRole practitionerRole = (PractitionerRole)resource;
						if(practitionerRole.getIdentifier()==null || practitionerRole.getIdentifier().isEmpty()) {
							Reference practOfPR = practitionerRole.getPractitioner();
							Practitioner practPR = (Practitioner)practOfPR.getResource();
							
							Reference orgOfPR = practitionerRole.getOrganization();
							Organization organizationPR = (Organization)orgOfPR.getResource();
							
							List<Identifier> list = new ArrayList<>();
							Identifier identifier = new Identifier();
							
							if(practPR!=null && practPR.getIdentifierFirstRep()!=null && organizationPR!=null && organizationPR.getIdentifierFirstRep()!=null) {
								String system = practPR.getIdentifierFirstRep().getSystem() + organizationPR.getIdentifierFirstRep().getSystem();
								String value  = practPR.getIdentifierFirstRep().getValue()  + organizationPR.getIdentifierFirstRep().getValue();
								identifier.setSystem(system);
								identifier.setValue(value);
								
								list.add(identifier);
								practitionerRole.setIdentifier(list);
								info = new InfoResourceDTO();
								info.setIdentifier(identifier);
								entry.getRequest().setUrl(resource.getResourceType() + "?identifier=" + StringUtility.getIdentifierAsString(info.getIdentifier()));
								entry.getRequest().setMethod(HTTPVerb.PUT);
							} 
						} 
					}
					
					if(info==null) {
						info = getInfoResource(resource);
						entry.getRequest().setMethod(info.getMethod());
						if (!StringUtility.isNullOrEmpty(info.getUrl())) {
							entry.getRequest().setUrl(info.getUrl());
						}
					}
				}
                
                return FHIRR4Helper.serializeResource(bundle, true, false, false);
            } else {
                throw new MissingXsltException(String.format("Xslt for cda with template id %s not found in database", templateId));
            }
        } catch (Exception e) {
            log.error("Error while executing transformation of CDA in fhir resource.", e);
            throw new BusinessException("Error while executing transformation of CDA in fhir resource.", e);
        }
    }

	private Transformer getXsltTransform(String templateId) {
		final XslTransformSingleton singleton = XslTransformSingleton.getInstance(templateId);
		Transformer transformer = null;
		if (singleton != null) {
			transformer = singleton.getTransformer();
		} else {
			final XslTransformETY xslEntity = xsltRepo.getXsltByTemplateId(templateId); // Singleton is empty
			if (xslEntity != null) {
				transformer = FHIRR4Helper.compileXslt(xslEntity.getContentXslTransform().getData());
				XslTransformSingleton.updateInstance(templateId,transformer);
			} else {
				throw new BusinessException("Attention , xslt not found with template id : " + templateId);
			}
		}

		return transformer;
	}

	private Identifier getIdentifier(final Resource resource) {
		Identifier identifier = null;
    	
		if(ResourceType.Patient.equals(resource.getResourceType())) {
    		Patient patient = (Patient)resource;
    		identifier = patient.getIdentifierFirstRep();
    	} else if(ResourceType.Practitioner.equals(resource.getResourceType())) {
    		Practitioner practitioner = (Practitioner)resource;
    		identifier = practitioner.getIdentifierFirstRep();
    	} else if(ResourceType.Organization.equals(resource.getResourceType())) {
    		Organization organization = (Organization)resource;
    		identifier = organization.getIdentifierFirstRep();
    	}  

		return identifier;
	}
	
	private InfoResourceDTO getInfoResource(final Resource resource) {
		InfoResourceDTO info = new InfoResourceDTO();
		info.setMethod(HTTPVerb.POST);
		info.setIdentifier(getIdentifier(resource));

		if(info.getIdentifier() != null && StringUtility.getIdentifierAsString(info.getIdentifier())!=null){
			info.setMethod(HTTPVerb.PUT);
			info.setUrl(resource.getResourceType() + "?identifier=" + StringUtility.getIdentifierAsString(info.getIdentifier()));
		}

		return info;
	}
}
