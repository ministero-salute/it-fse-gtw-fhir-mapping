/*
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request;

import lombok.Data;

@Data
public class FhirResourceDTO {

	private DocumentReferenceDTO documentReferenceDTO;
	
	private String cda;
}
