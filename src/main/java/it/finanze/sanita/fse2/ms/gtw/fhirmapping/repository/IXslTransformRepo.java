/*
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.entity.XslTransformETY;

/**
 * Interface of repository that consent to fetch and elaborate data from xsl_transform.
 * 
 * @author Simone Lungarella 
 */
public interface IXslTransformRepo {
    
    /**
     * Returns the xslt file saved with {@code templateId}.
     * 
     * @param templateId Identifier of xslt file.
     * @return The xslt file to execute transformations.
     */
    XslTransformETY getXsltByTemplateId(String templateId);
    
    /**
     * Returns the XSLT file given its Mongo ID 
     * @param id  The Mongo ID 
     * @return XslTransformETY  The entity saved in the database 
     */
    XslTransformETY getById(final String id); 
    
}
