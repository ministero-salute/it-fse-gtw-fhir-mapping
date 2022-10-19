/*
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.singleton;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.xml.transform.Transformer;

import org.apache.commons.collections4.MapUtils;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class XslTransformSingleton {
    
	private static XslTransformSingleton instance;
    
    @Getter
	private final String typeIdExtension;
    
    @Getter
	private final Date dataUltimoAggiornamento;
    
    @Getter
    private static Map<String, XslTransformSingleton> mapInstance;
    
    @Getter
    private static Map<String, Transformer> transformerInstance;
    
    @Getter
	private final Transformer transformer;
    

	private XslTransformSingleton(final String inTypeIdExtension, final Date inDataUltimoAggiornamento,final Transformer inTransformer) {
		typeIdExtension = inTypeIdExtension;
		dataUltimoAggiornamento = inDataUltimoAggiornamento;
		transformer = inTransformer;
	}

	public static void removeInstance(final String typeIdExtension) {
		if (!MapUtils.isEmpty(mapInstance) && mapInstance.get(typeIdExtension) != null) {
			mapInstance.remove(typeIdExtension);
		}
	}

	public static XslTransformSingleton getInstance(final String typeIdExtension) {
		if(mapInstance != null) {
			instance = mapInstance.get(typeIdExtension);
		} else {
			mapInstance = new HashMap<>();
		}

		return instance;
	}

    public static void updateInstance(final String typeIdExtension,final Transformer transformer) {
		if(mapInstance == null) { 
			mapInstance = new HashMap<>();
		}
		
        synchronized(XslTransformSingleton.class) {
            try {
                instance = new XslTransformSingleton(typeIdExtension, new Date(),transformer);
                mapInstance.put(instance.getTypeIdExtension(), instance);
            } catch(final Exception ex) {
                log.error("Error while retrieving and updating Singleton for XSLT", ex);
                throw new BusinessException("Error while retrieving and updating Singleton for XSLT", ex);
            }
        }
	}
}
