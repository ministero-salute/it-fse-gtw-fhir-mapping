package it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class CDAHelper {
    
    public static String extractTemplateId(final String cda) {
		try {
            log.debug("Extracting template_id from cda");
			final Document docT = Jsoup.parse(cda);
			return docT.select("templateid").get(0).attr("root");
		} catch(final Exception ex) {
			log.error("Error while extracting template id from CDA", ex);
			throw new BusinessException("Error while extracting template id from CDA", ex);
		}
	}
}
