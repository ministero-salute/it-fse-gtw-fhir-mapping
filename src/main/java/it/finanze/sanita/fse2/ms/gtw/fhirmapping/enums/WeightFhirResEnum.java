package it.finanze.sanita.fse2.ms.gtw.fhirmapping.enums;

import lombok.Getter;

public enum WeightFhirResEnum {

	HEALTHCAREFACILITY_SERVICEPROVIDERORGANIZATION("HEALTHCAREFACILITY_SERVICEPROVIDERORGANIZATION", 1),
	HEALTHCAREFACILITY_SERVICEPROVIDERORGANIZATION_ASORGANIZATIONPARTOF("HEALTHCAREFACILITY_SERVICEPROVIDERORGANIZATION_ASORGANIZATIONPARTOF", 0),
	PRACTITIONER_ROLE_RESPONSIBLE_PARTY("PRACTITIONER_ROLE_RESPONSIBLE_PARTY", 1),
	RESPONSIBLEPARTY_ASSIGNEDENTITY_ASSIGNEDPERSON("RESPONSIBLEPARTY_ASSIGNEDENTITY_ASSIGNEDPERSON", 1),
	AUTHOR_ASSIGNEDAUTHOR_REPRESENTEDORGANIZATION("AUTHOR_ASSIGNEDAUTHOR_REPRESENTEDORGANIZATION", 2),
	ASSIGNEDENTITY_ASSIGNEDPERSON("ASSIGNEDENTITY_ASSIGNEDPERSON", 1),
	PATIENTROLE_PROVIDERORGANIZATION("PATIENTROLE_PROVIDERORGANIZATION", 2),
	PATIENT_GUARDIAN_GUARDIANORGANIZATION("PATIENT_GUARDIAN_GUARDIANORGANIZATION", 0),
	INTENDEDRECIPIENT_INFORMATIONRECIPIENT("INTENDEDRECIPIENT_INFORMATIONRECIPIENT", 1),
	INTENDEDRECIPIENT_RECEIVEDORGANIZATION("INTENDEDRECIPIENT_RECEIVEDORGANIZATION", 0),
	ASSIGNEDAUTHOR_ASSIGNEDPERSON("ASSIGNEDAUTHOR_ASSIGNEDPERSON", 2),
	ASSOCIATEDENTITY_SCOPINGORGANIZATION("ASSOCIATEDENTITY_SCOPINGORGANIZATION", 0),
	ASSIGNEDCUSTODIAN_REPRESENTEDCUSTODIANORGANIZATION("ASSIGNEDCUSTODIAN_REPRESENTEDCUSTODIANORGANIZATION", 0),
	PRACTITIONER_ROLE_LEGAL_AUT("PRACTITIONER_ROLE_LEGAL_AUT", 2),
	LEGALAUTHENTICATOR_ASSIGNEDENTITY_REPRESENTEDORGANIZATION("LEGALAUTHENTICATOR_ASSIGNEDENTITY_REPRESENTEDORGANIZATION", 1),
	PRACTITIONER_ROLE_AUTHENTICATOR("PRACTITIONER_ROLE_AUTHENTICATOR", 1),
	PRACTITIONER_ROLE_PERFORMER("PRACTITIONER_ROLE_PERFORMER", 1),
	AUTHENTICATOR_ASSIGNEDENTITY_ASSIGNEDPERSON("AUTHENTICATOR_ASSIGNEDENTITY_ASSIGNEDPERSON", 1),
	SERVICEEVENT_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON("SERVICEEVENT_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON", 2),
	AUTHENTICATOR_ASSIGNEDENTITY_REPRESENTEDORGANIZATION("AUTHENTICATOR_ASSIGNEDENTITY_REPRESENTEDORGANIZATION", 1),
	SERVICEEVENT_PERFORMER_ASSIGNEDENTITY_REPRESENTEDORGANIZATION("SERVICEEVENT_PERFORMER_ASSIGNEDENTITY_REPRESENTEDORGANIZATION", 2),
	LEGALAUTHENTICATOR_ASSIGNEDENTITY_ASSIGNEDPERSON("LEGALAUTHENTICATOR_ASSIGNEDENTITY_ASSIGNEDPERSON", 1),
	SERVICEEVENT_PERFORMER_ASSIGNEDENTITY_REPRESENTEDORGANIZATION_ASORGANIZATIONPARTOF("SERVICEEVENT_PERFORMER_ASSIGNEDENTITY_REPRESENTEDORGANIZATION_ASORGANIZATIONPARTOF", 0),
	REPRESENTEDORGANIZATION_ASORGANIZATIONPARTOF_WHOLEORGANIZATION("REPRESENTEDORGANIZATION_ASORGANIZATIONPARTOF_WHOLEORGANIZATION", 0),
	PRACTITIONER_ROLE_ENCOUNTER("PRACTITIONER_ROLE_ENCOUNTER", 2),
	PARTICIPANT_ASSOCIATEDENTITY("PARTICIPANT_ASSOCIATEDENTITY", 2),
	ACT_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON("ACT_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON", 1),
	OBSERVATION_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON("OBSERVATION_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON", 0),
	ORGANIZER_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON("ORGANIZER_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON", 0),
	OBSERVATION_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON("OBSERVATION_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON", 0),
	ORGANIZER_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON("ORGANIZER_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON", 0),
	ACT_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON("ACT_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON", 1),
	ORGANIZER_AUTHOR_ASSIGNEDAUTHOR_ASSIGNEDPERSON("ORGANIZER_AUTHOR_ASSIGNEDAUTHOR_ASSIGNEDPERSON", 1),
	ORGANIZER_COMPONENTOF_ENCOMPASSINGENCOUNTER_RESPONSIBLEPARTY_ASSIGNEDENTITY("ORGANIZER_COMPONENTOF_ENCOMPASSINGENCOUNTER_RESPONSIBLEPARTY_ASSIGNEDENTITY", 0),
	COMPONENT_OBSERVATION_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON("COMPONENT_OBSERVATION_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON", 0),
	COMPONENT_OBSERVATION_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON("COMPONENT_OBSERVATION_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON", 0),
	ACT_ENTRYRELATIONSHIP_ACT_PARTICIPANT_ASSIGNEDPERSON("ACT_ENTRYRELATIONSHIP_ACT_PARTICIPANT_ASSIGNEDPERSON", 1);
	
	@Getter
	private String name;
		
	@Getter
	private Integer weight;

	private WeightFhirResEnum(String inName, Integer inWeight) {
		name = inName;
		weight = inWeight;
	}

}
