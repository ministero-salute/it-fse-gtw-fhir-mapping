package it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.impl;


import java.util.Map;
import java.util.Map.Entry;

import javax.xml.transform.Transformer;

import org.apache.commons.collections4.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper.FHIRR4Helper;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.IXslTransformRepo;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.repository.entity.XslTransformETY;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.IUpdateSingletonSRV;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.singleton.XslTransformSingleton;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class UpdateSingletonSRV implements IUpdateSingletonSRV {

	@Autowired
	private IXslTransformRepo xslTransformRepo;

	@Override
	public void updateSingletonInstance() {

		final Map<String, XslTransformSingleton> currentInstances = XslTransformSingleton.getMapInstance();

		if (!MapUtils.isEmpty(currentInstances)) {
			for (Entry<String, XslTransformSingleton> entry : currentInstances.entrySet()) {

				final String templateId = entry.getKey();
				final XslTransformSingleton singleton = entry.getValue();

				final XslTransformETY template = xslTransformRepo.getXsltByTemplateId(templateId);
				if (template == null) {
					log.info("The template with id {} has been removed from database", templateId);
					XslTransformSingleton.removeInstance(templateId);
				} else if (template.getLastUpdateDate().after(singleton.getDataUltimoAggiornamento())) {
					log.info("Updating singleton with a newer version");
					Transformer transform = FHIRR4Helper.compileXslt(template.getContentXslTransform().getData());
					XslTransformSingleton.updateInstance(templateId, transform);
				}
			}
		}
	}
}
