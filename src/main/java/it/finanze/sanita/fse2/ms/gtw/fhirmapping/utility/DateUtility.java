package it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility;

import java.util.Calendar;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class DateUtility {

	
	public static long getDifferenceDays(Date d1, Date d2) {
	    long diff = d2.getTime() - d1.getTime();
	    return TimeUnit.DAYS.convert(diff, TimeUnit.MILLISECONDS);
	}
	
	public static Date addDay(final Date date, final Integer nDays) {
		Calendar c = Calendar.getInstance();
		try {
			c.setTime(date);
			c.add(Calendar.DATE, nDays);
		} catch(Exception ex) {
			log.error("Error while perform addDay : " , ex);
			throw new BusinessException("Error while perform addDay : " , ex);
		}
		return c.getTime();
		
	}
 
	 
}
