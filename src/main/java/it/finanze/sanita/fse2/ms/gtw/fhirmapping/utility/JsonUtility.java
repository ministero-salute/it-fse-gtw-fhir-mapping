/*
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;

/**
 * @author AndreaPerquoti
 *
 */
@Slf4j
public class JsonUtility {

	/**
	 * Private constructor to avoid instantiation.
	 * 
	 * @throws IllegalStateException
	 */
	private JsonUtility() {
		// Empty constructor.
	}

	private static final ObjectMapper mapper = new ObjectMapper();

	/**
	 * Methods that converts an Object to a JSON string.
	 * 
	 * @param obj Object to convert.
	 * @return JSON String representation of the Object.
	 */
	public static <T> String objectToJson(T obj) {
		String jsonString = "";

		try {
			jsonString = mapper.writeValueAsString(obj);
		} catch (Exception e) {
			log.error("Errore durante la conversione da oggetto {} a string json: {}", obj.getClass(), e.getMessage());
		}

		return jsonString;
	}

	/**
	 * Methods that converts a JSON String to a Class of a defined type.
	 * 
	 * @param jsonString JSON String representation of the Object.
	 * @return Object created from the JSON String or {@code null} if the conversion
	 *         fails.
	 */
	public static <T> T jsonToObject(String jsonString, Class<T> clazz) {
		T obj = null;
		try {
			obj = mapper.readValue(jsonString, clazz);
		} catch (Exception e) {
			log.error("Errore durante la conversione da stringa json a oggetto: {}", e.getMessage());
		}

		return obj;
	}
}
