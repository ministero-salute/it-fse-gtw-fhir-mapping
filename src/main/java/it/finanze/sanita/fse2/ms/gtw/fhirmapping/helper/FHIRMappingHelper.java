/**
 * 
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper;

import java.io.Serializable;

import org.hl7.fhir.r4.context.IWorkerContext;
import org.hl7.fhir.r4.model.Base;
import org.hl7.fhir.r4.model.StructureMap;
import org.hl7.fhir.r4.utils.StructureMapUtilities;
import org.springframework.stereotype.Component;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
import lombok.extern.slf4j.Slf4j;

/**
 * @author AndreaPerquoti
 *
 */
@Slf4j
@Component
public class FHIRMappingHelper implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 6417647106178341654L;
	
	
	public void cdaToResources() {
		Base source = null;
		StructureMap map = null; 
		Base target = null;
		
		try {
			IWorkerContext worker = null;
			StructureMapUtilities smu = new StructureMapUtilities(worker);
			smu.transform(map, source, map, target);
			
		} catch (Exception e) {
			log.info("Errore durante il tentativo di trasformazione da CDA a FHIRresources.", e);
			throw new BusinessException("Errore durante il tentativo di trasformazione da CDA a FHIRresources.", e);
		}
		
	}

}
