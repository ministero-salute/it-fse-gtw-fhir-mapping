package it.finanze.sanita.fse2.ms.gtw.fhirmapping.dto.request;

import java.util.List;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class DocumentReferenceDTO {

	private Integer size;

	private byte[] hash;

	private String formatCode;

	private String referencedID;

	private String securityLabel;

	private String masterIdentifier;

	private String typeCode;

	private String author;

	private String authenticator;

	private String custodian;

	private String facilityTypeCode;

	private List<String> eventCode;

	private String practiceSettingCode;

	private String patientID;

	private String tipoDocumentoLivAlto;

	private String repositoryUniqueID;

	private String serviceStartTime;

	private String serviceStopTime;
}
