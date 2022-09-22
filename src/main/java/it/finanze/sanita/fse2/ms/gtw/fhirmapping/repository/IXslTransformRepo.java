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
}