package it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.response;

import javax.validation.constraints.Size;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.AbstractDTO;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 
 * @author vincenzoingenito
 *
 *	DTO used to return document reference creation result.
 */
@Data
@NoArgsConstructor
public class DocumentReferenceResDTO extends AbstractDTO {

	/**
	 * Serial version uid.
	 */
	private static final long serialVersionUID = -2618965716083072681L;
	
	@Size(min = 0, max = 1000)
	private String errorMessage;
	
	@Size(min = 0, max = 1000)
	private String json;
	
}
