/*
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.StringUtility;

public final class Validation {
	
	/**
	 * Costruttore.
	 */
	private Validation() {
	}

	/**
	 * Metodo per la verifica del non null di una lista di oggetti.
	 * 
	 * @param objs	lista oggetti
	 */
	public static void notNull(final Object... objs) {
		Boolean notValid = false;
		for (final Object obj:objs) {
			if (obj == null) {
				notValid = true;
			} else if (obj instanceof String) {
				String checkString = (String)obj;
				checkString = checkString.trim();
				if(StringUtility.isNullOrEmpty(checkString)) {
					notValid = true;
				}
			}
			if (notValid) {
				throw new RuntimeException("Violazione vincolo not null.");
			}
		}
	}

	public static void atLeastOne(final Object... objs) {
		Boolean notValid = true;
		for (final Object obj:objs) {
			if (obj != null) {
				notValid = false;
			} else if (obj instanceof String) {
				String checkString = (String)obj;
				checkString = checkString.trim();
				if(!StringUtility.isNullOrEmpty(checkString)) {
					notValid = false;
				}
			}
			if (!notValid) {
				break;
			}
		}
		if (notValid) {
			throw new RuntimeException("Violazione vincolo not null.");
		}
	}

	public static void mustBeTrue(boolean b, String msg) {
		if (!b) {
			throw new RuntimeException(msg);
		}
	}

}
