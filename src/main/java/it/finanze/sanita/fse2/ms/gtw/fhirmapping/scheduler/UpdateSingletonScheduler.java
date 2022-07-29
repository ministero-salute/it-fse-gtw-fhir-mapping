package it.finanze.sanita.fse2.ms.gtw.fhirmapping.scheduler;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.service.IUpdateSingletonSRV;
import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class UpdateSingletonScheduler {

	@Autowired
	private IUpdateSingletonSRV updateSingletonSRV;
	
	/**
	 * Scheduler.
	 */
	@Scheduled(cron = "${scheduler.update-singleton.run}")
	public void schedulingTask() {
		log.info("Update singleton scheduler - START");
		updateSingletonSRV.updateSingletonInstance();
		log.info("Update singleton scheduler - END");
	}
}
