package it.finanze.sanita.fse2.ms.gtw.fhirmapping.controller;

import javax.servlet.http.HttpServletRequest;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request.DocumentReferenceDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.response.DocumentReferenceResDTO;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.response.ErrorResponseDTO;

/**
 * 
 * @author vincenzoingenito
 *
 *	Controller document reference.
 */
@RequestMapping(path = "/v1")
@Tag(name = "Servizio generazione document reference")
public interface IDocumentReferenceCTL {
  
	@PostMapping("/document_reference")
	@Operation(summary = "Generazione document reference", description = "Generazione document reference.")
	@ApiResponse(content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = String.class)))
	@ApiResponses(value = { @ApiResponse(responseCode = "200", description = "Validazione eseguita senza inserimento in cache", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = DocumentReferenceResDTO.class))),
			@ApiResponse(responseCode = "201", description = "Presa in carico eseguita con successo", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = DocumentReferenceResDTO.class))),
			@ApiResponse(responseCode = "400", description = "Bad Request", content = @Content(mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE, schema = @Schema(implementation = ErrorResponseDTO.class))),
			@ApiResponse(responseCode = "500", description = "Internal Server Error", content = @Content(mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE, schema = @Schema(implementation = ErrorResponseDTO.class))) })
	DocumentReferenceResDTO generateDocumentReference(@RequestBody DocumentReferenceDTO documentReferenceDTO,HttpServletRequest request);

}
