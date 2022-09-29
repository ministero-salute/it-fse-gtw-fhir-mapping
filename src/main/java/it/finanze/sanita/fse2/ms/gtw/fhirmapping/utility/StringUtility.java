package it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility;

import java.util.UUID;

import org.hl7.fhir.r4.model.Identifier;

public final class StringUtility {

	/**
	 * Private constructor to avoid instantiation.
	 */
	private StringUtility() {
		// Constructor intentionally empty.
	}

	/**
	 * Returns {@code true} if the String passed as parameter is null or empty.
	 * 
	 * @param str	String to validate.
	 * @return		{@code true} if the String passed as parameter is null or empty.
	 */
	public static boolean isNullOrEmpty(final String str) {
		return str == null || str.isEmpty();
	}

	public static String generateUUID() {
	    return UUID.randomUUID().toString();
	}

	public static String getIdentifierAsString(final Identifier identifier) {
		if (identifier != null && identifier.getSystem() != null && identifier.getValue() != null) {
			return (identifier.getSystem() + "|" + identifier.getValue());
		} else {
			return null;
		}
	}
 }
