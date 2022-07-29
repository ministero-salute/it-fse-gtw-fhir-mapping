package it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.config.Constants;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.ProfileUtility;

@Configuration
public class CollectionNaming {

    @Autowired
    private ProfileUtility profileUtility;

    @Bean("xslTransformBean")
    public String getXslTransformCollection() {
        if (profileUtility.isTestProfile()) {
            return Constants.Profile.TEST_PREFIX + Constants.ComponentScan.Collections.XSL_TRANSFORM;
        }
        return Constants.ComponentScan.Collections.XSL_TRANSFORM;
    }
}
