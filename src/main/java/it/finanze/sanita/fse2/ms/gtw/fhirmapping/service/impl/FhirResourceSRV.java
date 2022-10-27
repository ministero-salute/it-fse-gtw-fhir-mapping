/*
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.impl;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.transform.Transformer;

import org.hl7.fhir.r4.model.Base;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Bundle.BundleEntryComponent;
import org.hl7.fhir.r4.model.Bundle.HTTPVerb;
import org.hl7.fhir.r4.model.DocumentReference;
import org.hl7.fhir.r4.model.HumanName;
import org.hl7.fhir.r4.model.Identifier;
import org.hl7.fhir.r4.model.Organization;
import org.hl7.fhir.r4.model.Patient;
import org.hl7.fhir.r4.model.Practitioner;
import org.hl7.fhir.r4.model.PractitionerRole;
import org.hl7.fhir.r4.model.Property;
import org.hl7.fhir.r4.model.Reference;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.ResourceType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.gson.Gson;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.config.Constants;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.config.FhirTransformCFG;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.InfoResourceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.DocumentReferenceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.enums.TransformALGEnum;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.enums.WeightFhirResEnum;
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
    
    @Autowired
    private FhirTransformCFG fhirTransformCFG;
 

    @Override
    public String fromCdaToJson(String cda, final DocumentReferenceDTO documentReferenceDTO, String transformId) {
        try {
            //final String templateId = CDAHelper.extractTemplateId(cda);
            log.debug("Executing transformation of CDA with template id: {}", transformId);
            
			final Transformer transform = getXsltTransform(transformId);

            if (transform != null) {
            	cda = cda.replace("xmlns=\"urn:hl7-org:v3\"", "").replace("xmlns:mif=\"urn:hl7-org:v3/mif\"", "");
            	
                log.debug("XSLT found on database, executing transformation");
                
                final String fhirXML = FHIRR4Helper.trasform(transform, cda.getBytes(StandardCharsets.UTF_8));
                final Bundle bundle = FHIRR4Helper.deserializeResource(Bundle.class, fhirXML, false);

                log.debug("Bundle start entry size : {}", bundle.getEntry().size());
                if(TransformALGEnum.KEEP_FIRST.equals(fhirTransformCFG.getAlgToRemoveDuplicate())) {
                	bundle.getEntry().removeAll(chooseFirstBetweenDuplicate(bundle.getEntry()));
                } else {
                	bundle.setEntry(chooseMajorSize(bundle.getEntry(), fhirTransformCFG.getAlgToRemoveDuplicate()));
                } 
                
                log.debug("Bundle end entry size : {}", bundle.getEntry().size());
				for(BundleEntryComponent entry : bundle.getEntry()) {
					Resource resource = entry.getResource();
					InfoResourceDTO info = null;

					if (ResourceType.DocumentReference.equals(resource.getResourceType())){
						DocumentReference documentReferenceXslt = (DocumentReference) resource;
						DocumentReferenceHelper.createDocumentReference(documentReferenceDTO, documentReferenceXslt);
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
								String system = "urn:"+practPR.getIdentifierFirstRep().getSystem().replace("urn:oid:", "") + organizationPR.getIdentifierFirstRep().getSystem().replace("urn:oid:", "-");
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
                throw new MissingXsltException(String.format("Xslt for cda with template id %s not found in database", transformId));
            }
        } catch (Exception e) {
            log.error("Error while executing transformation of CDA in fhir resource.", e);
            throw new BusinessException("Error while executing transformation of CDA in fhir resource.", e);
        }
    }

	private Transformer getXsltTransform(String id) {
		final XslTransformSingleton singleton = XslTransformSingleton.getInstance(id);
		Transformer transformer = null;
		if (singleton != null) {
			transformer = singleton.getTransformer();
		} else {
			final XslTransformETY xslEntity = xsltRepo.getById(id); // Singleton is empty
			if (xslEntity != null) {
				transformer = FHIRR4Helper.compileXslt(xslEntity.getContentXslTransform().getData());
				XslTransformSingleton.updateInstance(id,transformer);
			} else {
				throw new BusinessException("Attention , xslt not found with Mongo id : " + id);
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
		info.setUrl(resource.getClass().getSimpleName());
		info.setIdentifier(getIdentifier(resource));

		if(info.getIdentifier() != null && StringUtility.getIdentifierAsString(info.getIdentifier())!=null){
			info.setMethod(HTTPVerb.PUT);
			info.setUrl(resource.getResourceType() + "?identifier=" + StringUtility.getIdentifierAsString(info.getIdentifier()));
		}

		return info;
	}
	
	private List<BundleEntryComponent> chooseFirstBetweenDuplicate(List<BundleEntryComponent> entryComponent){
		List<BundleEntryComponent> listToRemove = new ArrayList<>();
		
		Map<String,BundleEntryComponent> tempMap = new HashMap<>();
		for(BundleEntryComponent entry : entryComponent) {
			if(!tempMap.containsKey(entry.getResource().getId())){
				tempMap.put(entry.getResource().getId(), entry);
			} else {
				listToRemove.add(entry);
			}
		}
		return listToRemove;
	} 
	
	private List<BundleEntryComponent> chooseMajorSize(List<BundleEntryComponent> entries,final TransformALGEnum transfAlg) {

        Map<String, BundleEntryComponent> toKeep = new HashMap<>();;

        for (BundleEntryComponent resourceEntry : entries) {
            if (!toKeep.containsKey(resourceEntry.getResource().getId())) {
                toKeep.put(resourceEntry.getResource().getId(), resourceEntry);
            } else {
                // Calculate weight and compare each other
                final long newEntryWeight = calculateWeight(resourceEntry,transfAlg);
                final long oldEntryWeight = calculateWeight(toKeep.get(resourceEntry.getResource().getId()),transfAlg);

                if ((oldEntryWeight < newEntryWeight) || 
                		(oldEntryWeight == newEntryWeight  && TransformALGEnum.KEEP_RICHER_DOWN.equals(transfAlg))) {
                    // Must override entry with a richer one
                    toKeep.put(resourceEntry.getResource().getId(), resourceEntry);
                }
            }
        }
        
        return new ArrayList<>(toKeep.values());
    }

    private long calculateWeight(final BundleEntryComponent bundleEntryComponent,final TransformALGEnum transfAlg) {
    	long output = 0L;
    	if(TransformALGEnum.KEEP_LONGER.equals(transfAlg)) {
    		output = new Gson().toJson(bundleEntryComponent.getResource()).length();	
    	} else if(TransformALGEnum.KEEP_RICHER_UP.equals(transfAlg) || TransformALGEnum.KEEP_RICHER_DOWN.equals(transfAlg)) {
    		output = bundleEntryComponent.getResource().listChildrenByName("*").size();
    	} else if(TransformALGEnum.KEEP_PRIOR.equals(transfAlg)){
    		Property prop =  bundleEntryComponent.getResource().getChildByName("name");
    		for(Base entry : prop.getValues()) {
    			if(entry instanceof HumanName) {
    				HumanName human = (HumanName)entry;
    				if(human.getText()!=null && human.getText().contains(Constants.XSLT.PRIORITY_CONST)) {
    					String text = human.getText().replace(Constants.XSLT.PRIORITY_CONST, "");
    					WeightFhirResEnum val = WeightFhirResEnum.valueOf(text);
    					if(val!=null) {
    						output = val.getWeight();
    					}
    				}
    			}
    		}
    	}
    	return output;
    }
    
   
}
