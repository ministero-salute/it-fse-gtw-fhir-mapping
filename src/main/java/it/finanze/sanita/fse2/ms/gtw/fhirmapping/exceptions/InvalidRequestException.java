/*
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions;

public class InvalidRequestException extends RuntimeException {

	/**
	 * Message constructor.
	 *
	 * @param msg Message to be shown.
	 */
	public InvalidRequestException(final String msg) {
		super(msg);
	}

	/**
	 * Complete constructor.
	 *
	 * @param msg	Message to be shown.
	 * @param e		Exception to be shown.
	 */
	public InvalidRequestException(final String msg, final Exception e) {
		super(msg, e);
	}

	/**
	 * Exception constructor.
	 *
	 * @param e	Exception to be shown.
	 */
	public InvalidRequestException(final Exception e) {
		super(e);
	}
	
}
