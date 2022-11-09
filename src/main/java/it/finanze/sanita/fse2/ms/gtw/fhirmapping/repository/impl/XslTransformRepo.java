/*
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.impl;

import java.util.Date;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.IXslTransformRepo;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.entity.XslTransformETY;
import lombok.extern.slf4j.Slf4j;

/**
 * Repository used to retrieve xslt data to execute transformation of cda documents.
 * 
 */
@Slf4j
@Repository
public class XslTransformRepo implements IXslTransformRepo {

    @Autowired
    private MongoTemplate mongoTemplate;
    
    @Override
    public XslTransformETY getXsltByTemplateId(final String templateId) {
        
        XslTransformETY xslt = null;
        try {
            final Query query = new Query();
            query.addCriteria(Criteria.where("template_id_root").is(templateId).and("deleted").is(false));
            query.with(Sort.by(Direction.DESC, "template_id_extension"));

            xslt = mongoTemplate.findOne(query, XslTransformETY.class);
        } catch (final Exception e) {
            log.error(String.format("Error while retrieving xslt with template id: %s", templateId), e);
            throw new BusinessException(String.format("Error while retrieving xslt with template id: %s", templateId), e);
        }
        return xslt;
    } 
    
    @Override
    public XslTransformETY getById(final String id, final Date fiveDayAgo) {
        
        XslTransformETY xslt = null;
        try {
            final Query query = new Query();
            Criteria criteria = new Criteria();
            criteria.orOperator(Criteria.where("_id").is(new ObjectId(id)).and("deleted").is(false),
            		Criteria.where("_id").is(new ObjectId(id)).and("deleted").is(true).and("last_update_date").gt(fiveDayAgo));
            query.addCriteria(criteria);
            xslt = mongoTemplate.findOne(query, XslTransformETY.class);
        } catch (final Exception e) {
            log.error(String.format("Error while retrieving xslt with Mongo Id: %s", id), e);
            throw new BusinessException(String.format("Error while retrieving xslt with Mongo ID: %s", id), e);
        }
        return xslt;
    }
    
}
