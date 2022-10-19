/*
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.response;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.AbstractDTO;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class LogTraceInfoDTO extends AbstractDTO {

	/**
	 * Serial version uid.
	 */
	private static final long serialVersionUID = -2079576276445110017L;

	/**
	 * Span.
	 */
	private final String spanID;
	
	/**
	 * Trace.
	 */
	private final String traceID;

}
