<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:strip-space elements="*" />
	<xsl:template match="/ClinicalDocument">
		<Bundle xmlns="http://hl7.org/fhir">
			<fullUrl value="https://example.com/base/Bundle/bundle" />
			<id value="father" />
			<language value="{languageCode/@code}" />
			<implicitRules value="{typeId/@root}" />
			<identifier>
				<system value="urn:oid:{id/@root}" />
				<value value="{id/@extension}" />
				<assigner>
					<display value="{id/@assigningAuthorityName}"></display>
				</assigner>
			</identifier>
			<type value="transaction" />

			<!-- Constante che definisce l'inizio e la fine della property "priority" -->
			<xsl:variable name="PRIOR_CONST" select="'###PRIOR###'" />

			<xsl:variable name="patientId" select="concat(recordTarget/patientRole/id/@root, '-', recordTarget/patientRole/id/@extension)" />
			<!-- COMPOSITION -->
			<entry>
				<fullUrl value="https://example.com/base/Composition/composition" />
				<resource>
					<Composition xmlns="http://hl7.org/fhir">
						<id value="composition" />

						<language value="{languageCode/@code}" />
						<type>
							<coding>
								<system value="urn:oid:{code/@codeSystem}" />
								<version value="{code/@codeSystemName}" />
								<code value="{code/@code}" />
								<display value="{code/@displayName}" />
							</coding>
							<xsl:if test="code/translation">
								<xsl:for-each select="code/translation">
									<coding>
										<system value="urn:oid:{./@codeSystem}" />
										<version value="{./@codeSystemName}" />
										<code value="{./@code}" />
									</coding>
								</xsl:for-each>
							</xsl:if>
						</type>

						<xsl:choose>
							<xsl:when test="title">
								<title value="{title}" />
							</xsl:when>
							<xsl:otherwise>
								<title value="{code/@displayName}" />
							</xsl:otherwise>
						</xsl:choose>

						<xsl:choose>
							<xsl:when test="statusCode/@code = 'active'">
								<status value="active" />
							</xsl:when>
							<xsl:otherwise>
								<status value="final" />
							</xsl:otherwise>
						</xsl:choose>

						<xsl:call-template name="show_date">
							<xsl:with-param name="cda_date" select="effectiveTime/@value" />
							<xsl:with-param name="tag" select="'date'" />
						</xsl:call-template>

						<confidentiality value="{confidentialityCode/@code}" />

						<identifier>
							<system value="urn:oid:{setId/@root}" />
							<value value="{setId/@extension}" />
							<assigner>
								<display value="{setId/@assigningAuthorityName}" />
							</assigner>
						</identifier>

						<extension url="http://hl7.org/fhir/StructureDefinition/composition-clinicaldocument-versionNumber">
							<valueString value="{versionNumber/@value}" />
						</extension>

						<subject>
							<reference value="Patient/{$patientId}" />
						</subject>

						<author>
							<reference value="Practitioner/{author/assignedAuthor/id/@root}-{author/assignedAuthor/id/@extension}" />
						</author>

						<xsl:call-template name="show_date">
							<xsl:with-param name="cda_date" select="author/time/@value" />
							<xsl:with-param name="tag" select="'date'" />
						</xsl:call-template>

						<xsl:if test="author/assignedAuthor/representedOrganization">
							<attester>
								<mode value="official" />
								<party>
									<xsl:variable name="sanitized-system">
										<xsl:call-template name="sanitize-oid">
											<xsl:with-param name="text" select="author/assignedAuthor/representedOrganization/id/@root" />
										</xsl:call-template>
									</xsl:variable>
									<reference value="Organization/{$sanitized-system}-{author/assignedAuthor/representedOrganization/id/@extension}" />
								</party>
							</attester>
						</xsl:if>

						<xsl:if test="dataEnterer">
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="dataEnterer/time/@value" />
								<xsl:with-param name="tag" select="'date'" />
							</xsl:call-template>
							<author>
								<reference value="Practitioner/{dataEnterer/assignedEntity/id/@root}-{dataEnterer/assignedEntity/id/@extension}" />
							</author>
						</xsl:if>

						<xsl:if test="custodian">
							<custodian>
								<xsl:variable name="sanitized-value">
									<xsl:call-template name="sanitize-oid">
										<xsl:with-param name="text" select="custodian/assignedCustodian/representedCustodianOrganization/id/@extension" />
									</xsl:call-template>
								</xsl:variable>
								<reference value="Organization/{custodian/assignedCustodian/representedCustodianOrganization/id/@root}-{$sanitized-value}" />
							</custodian>
						</xsl:if>

						<xsl:if test="informationRecipient">
							<attester>
								<xsl:choose>
									<xsl:when test="informationRecipient/intendedRecipient/informationRecipient">
										<mode value="professional" />
									</xsl:when>
									<xsl:when test="informationRecipient/intendedRecipient/receivedOrganization">
										<mode value="official" />
									</xsl:when>
								</xsl:choose>
								<party>
									<xsl:choose>
										<xsl:when test="informationRecipient/intendedRecipient/informationRecipient">
											<reference value="Practitioner/{informationRecipient/intendedRecipient/id/@root}-{informationRecipient/intendedRecipient/id/@extension}" />
										</xsl:when>
										<xsl:when test="informationRecipient/intendedRecipient/receivedOrganization">
											<reference value="Organization/{informationRecipient/intendedRecipient/receivedOrganization/id/@root}-{informationRecipient/intendedRecipient/receivedOrganization/id/@extension}" />
										</xsl:when>
									</xsl:choose>
								</party>
							</attester>
						</xsl:if>

						<attester>
							<mode value="legal" />
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="legalAuthenticator/time/@value" />
								<xsl:with-param name="tag" select="'time'" />
							</xsl:call-template>
							<party>
								<reference value="PractitionerRole/practitioner-role-legal-aut" />
							</party>
						</attester>

						<xsl:if test="authenticator">
							<attester>
								<mode value="professional" />
								<xsl:call-template name="show_date">
									<xsl:with-param name="cda_date" select="authenticator/time/@value" />
									<xsl:with-param name="tag" select="'time'" />
								</xsl:call-template>
								<party>
									<reference value="PractitionerRole/practitioner-role-authenticator" />
								</party>
							</attester>
						</xsl:if>

						<encounter>
							<reference value="Encounter/encounter" />
						</encounter>

						<xsl:if test="documentationOf">
							<event>
								<xsl:if test="documentationOf/serviceEvent">
									<coding>
										<xsl:if test="documentationOf/serviceEvent/code/@codeSystem">
											<system value="urn:oid:{documentationOf/serviceEvent/code/@codeSystem}" />
										</xsl:if>
										<code value="{documentationOf/serviceEvent/code/@code}" />
										<version value="{documentationOf/serviceEvent/code/@displaySystemVersion}" />
										<display value="{documentationOf/serviceEvent/code/@displayName}" />
									</coding>
								</xsl:if>
								<extension>
									<event>
										<id value="{documentationOf/serviceEvent/id}" />
									</event>
								</extension>

								<period>
									<xsl:call-template name="show_date">
										<xsl:with-param name="cda_date" select="documentationOf/serviceEvent/effectiveTime/@value" />
										<xsl:with-param name="tag" select="'start'" />
									</xsl:call-template>
								</period>
								<xsl:if test="documentationOf/serviceEvent/performer">
									<detail>
										<reference value="PractitionerRole/practitioner-role-performer" />
									</detail>
								</xsl:if>
							</event>

							<xsl:choose>
								<xsl:when test="documentationOf/serviceEvent/statusCode/@code = 'completed'">
									<status value="final" />
								</xsl:when>
								<xsl:otherwise>
									<status value="preliminary" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>

						<xsl:if test="relatedDocument">
							<relatesTo>
								<xsl:if test="relatedDocument/@typeCode  = 'APND'">
									<code value="appends" />
								</xsl:if>
								<xsl:if test="relatedDocument/@typeCode = 'RPLC'">
									<code value="replaces" />
								</xsl:if>
								<xsl:if test="relatedDocument/@typeCode = 'XFRM'">
									<code value="transforms" />
								</xsl:if>

								<target>
									<targetReference>
										<reference value="Composition/related-composition" />
									</targetReference>
								</target>
							</relatesTo>
						</xsl:if>

						<!-- BODY -->
						<section>
							<code>
								<coding>
									<code value="{component/structuredBody/component/section/code/@code}" />
									<system value="urn:oid:{component/structuredBody/component/section/code/@codeSystem}" />
									<version value="{component/structuredBody/component/section/code/@codeSystemName}" />
									<display value="{component/structuredBody/component/section/code/@displayName}" />
								</coding>

								<xsl:if test="component/structuredBody/component/section/code/translation">
									<xsl:for-each select="component/structuredBody/component/section/code/translation">
										<coding>
											<code value="{./@code}" />
											<system value="urn:oid:{./@codeSystem}" />
											<version value="{./@codeSystemName}" />
											<display value="{./@displayName}" />
										</coding>
									</xsl:for-each>
								</xsl:if>
							</code>

							<xsl:if test="component/structuredBody/component/section/title">
								<title value="{component/structuredBody/component/section/@title}" />
							</xsl:if>

							<xsl:if test="component/structuredBody/component/section/text">
								<text value="{component/structuredBody/component/section/text}" />
							</xsl:if>

							<xsl:if test="component/structuredBody/component/section/component">
								<xsl:for-each select="component/structuredBody/component/section/component">
									<section>
										<code>
											<coding>
												<code value="{./section/code/@code}" />
												<system value="urn:oid:{./section/code/@codeSystem}" />
												<version value="{./section/code/@version}" />
												<display value="{./section/code/@displayName}" />
											</coding>
										</code>

										<xsl:for-each select="./section/code/translation">
											<coding>
												<code value="{./@code}" />
												<system value="urn:oid:{./@codeSystem}" />
												<version value="{./@codeSystemName}" />
												<display value="{./@displayName}" />
											</coding>
										</xsl:for-each>

										<title value="{./section/title}" />
										<entry>
											<reference value="DiagnosticReport/diagnostic-report" />
										</entry>
									</section>
								</xsl:for-each>
							</xsl:if>
						</section>
					</Composition>
				</resource>
			</entry>

			<!-- RELATED COMPOSITION -->
			<xsl:if test="relatedDocument">
				<entry>
					<fullUrl value="https://example.com/base/Composition/related-composition" />
					<resource>
						<Composition xmlns="http://hl7.org/fhir">
							<id value="related-composition" />

							<identifier>
								<system value="urn:oid:{relatedDocument/parentDocument/id/@root}" />
								<value value="{relatedDocument/parentDocument/id/@extension}" />
							</identifier>
							<xsl:if test="relatedDocument/parentDocument/setId">
								<identifier>
									<system value="urn:oid:{relatedDocument/parentDocument/setId/@root}" />
									<value value="{relatedDocument/parentDocument/setId/@extension}" />
								</identifier>
							</xsl:if>
							<extension>
								<composition-clinicaldocument-versionNumber value="{relatedDocument/parentDocument/versionNumber/@value}" />
							</extension>
						</Composition>
					</resource>
				</entry>
			</xsl:if>


			<xsl:if test="componentOf/encompassingEncounter/location/healthCareFacility">
				<entry>
					<fullUrl value="https://example.com/base/Location/location-encompassing-encounter" />
					<resource>
						<Location xmlns="http://hl7.org/fhir">
							<id value="location-encompassing-encounter" />

							<identifier>
								<system value="urn:oid:{componentOf/encompassingEncounter/location/healthCareFacility/id/@root}" />
								<value value="{componentOf/encompassingEncounter/location/healthCareFacility/id/@extension}" />
								<assigner>
									<display value="{componentOf/encompassingEncounter/location/healthCareFacility/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>

							<partOf>
								<reference value="Location/facility-location" />
							</partOf>

							<managingOrganization>
								<reference value="Organization/{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@root}-{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@extension}" />
							</managingOrganization>
						</Location>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@root}-{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@root}-{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@extension}" />

							<identifier>
								<system value="urn:oid:{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@root}" />
								<value value="{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@extension}" />
								<assigner>
									<display value="{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@assigningAuthorityName}"></display>
								</assigner>
							</identifier>
							<name value="{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/name}" />

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/telecom" />
							</xsl:call-template>

							<xsl:if test="componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf">
								<partOf>
									<reference value="Organization/{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@root}-{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@extension}" />
								</partOf>
							</xsl:if>

							<name>
								<text value="{$PRIOR_CONST}HEALTHCAREFACILITY_SERVICEPROVIDERORGANIZATION{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@root}-{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@root}-{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@extension}" />

							<identifier>
								<system value="urn:oid:{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@root}" />
								<value value="{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@extension}" />
								<assigner>
									<display value="{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
							<name>
								<text value="{$PRIOR_CONST}HEALTHCAREFACILITY_SERVICEPROVIDERORGANIZATION_ASORGANIZATIONPARTOF{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="componentOf/encompassingEncounter/location/healthCareFacility">
				<entry>
					<fullUrl value="https://example.com/base/Location/facility-location" />
					<resource>
						<Location xmlns="http://hl7.org/fhir">
							<id value="facility-location" />

							<name value="{componentOf/encompassingEncounter/location/healthCareFacility/location/name}" />
							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="componentOf/encompassingEncounter/location/healthCareFacility/location/addr" />
							</xsl:call-template>
						</Location>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="componentOf/encompassingEncounter/responsibleParty">
				<entry>
					<fullUrl value="https://example.com/base/PractitionerRole/practitioner-role-responsible-party" />
					<resource>
						<PractitionerRole xmlns="http://hl7.org/fhir">
							<id value="practitioner-role-responsible-party" />

							<xsl:if test="componentOf/encompassingEncounter/responsibleParty/assignedEntity">
								<practitioner>
									<reference value="Practitioner/{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@root}-{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@extension}" />
								</practitioner>
							</xsl:if>

							<code value="{componentOf/encompassingEncounter/responsibleParty/assignedEntity/code/@code}" />

							<name>
								<text value="{$PRIOR_CONST}PRACTITIONER_ROLE_RESPONSIBLE_PARTY{$PRIOR_CONST}" />
							</name>
						</PractitionerRole>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="componentOf/encompassingEncounter/responsibleParty/assignedEntity">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@root}-{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@root}-{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@extension}" />

							<identifier>
								<system value="urn:oid:{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@root}" />
								<value value="{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@extension}" />
								<assigner>
									<display value="{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="componentOf/encompassingEncounter/responsibleParty/assignedEntity/addr" />
							</xsl:call-template>

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="componentOf/encompassingEncounter/responsibleParty/assignedEntity/telecom" />
							</xsl:call-template>

							<name>
								<family value="{componentOf/encompassingEncounter/responsibleParty/assignedEntity/assignedPerson/name/family}" />
								<given value="{componentOf/encompassingEncounter/responsibleParty/assignedEntity/assignedPerson/name/given}" />
							</name>

							<name>
								<text value="{$PRIOR_CONST}RESPONSIBLEPARTY_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
							</name>
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<!-- PATIENT -->
			<entry>
				<fullUrl value="https://example.com/base/Patient/{$patientId}" />
				<resource>
					<Patient xmlns="http://hl7.org/fhir">
						<id value="{$patientId}" />

						<identifier>
							<system value="urn:oid:{recordTarget/patientRole/id/@root}" />
							<value value="{recordTarget/patientRole/id/@extension}" />
							<assigner>
								<display value="{recordTarget/patientRole/id/@assigningAuthorityName}" />
							</assigner>
						</identifier>

						<xsl:call-template name="show_address">
							<xsl:with-param name="cda_address" select="recordTarget/patientRole/addr" />
						</xsl:call-template>

						<xsl:call-template name="show_telecom">
							<xsl:with-param name="cda_telecom" select="recordTarget/patientRole/telecom" />
						</xsl:call-template>

						<name>
							<family value="{recordTarget/patientRole/patient/name/family}" />
							<given value="{recordTarget/patientRole/patient/name/given}" />
						</name>

						<xsl:call-template name="show_gender">
							<xsl:with-param name="cda_gender" select="recordTarget/patientRole/patient/administrativeGenderCode/@code" />
						</xsl:call-template>

						<xsl:call-template name="show_birthDate">
							<xsl:with-param name="cda_birthDate" select="recordTarget/patientRole/patient/birthTime/@value" />
						</xsl:call-template>

						<extension url="http://hl7.org/fhir/StructureDefinition/patient-birthPlace">
							<valueAddress>
								<xsl:if test="recordTarget/patientRole/patient/birthPlace/place/addr/censusTract">
									<line>
										<extension url="http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-censusTract">
											<valueString value="{recordTarget/patientRole/patient/birthPlace/place/addr/censusTract}" />
										</extension>
									</line>
								</xsl:if>

								<use value="home" />
								<line value="{recordTarget/patientRole/patient/birthplace/place/addr/streetAddressLine}" />
								<city value="{recordTarget/patientRole/patient/birthplace/place/addr/city}" />
								<country value="{recordTarget/patientRole/patient/birthplace/place/addr/country}" />
								<postalCode value="{recordTarget/patientRole/patient/birthplace/place/addr/postalCode}" />
							</valueAddress>
						</extension>

						<xsl:if test="recordTarget/patientRole/patient/guardian">
							<contact>
								<name>
									<family value="{recordTarget/patientRole/patient/guardian/guardianPerson/name/family}"></family>
									<given value="{recordTarget/patientRole/patient/guardian/guardianPerson/name/given}"></given>
								</name>
								<xsl:if test="recordTarget/patientRole/patient/guardian/guardianOrganization">
									<organization>
										<reference value="Organization/{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@root}-{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@extension}" />
									</organization>
								</xsl:if>
							</contact>
							<xsl:if test="recordTarget/patientRole/providerOrganization">
								<managingOrganization>
									<reference value="Organization/{recordTarget/patientRole/providerOrganization/id/@root}-{recordTarget/patientRole/providerOrganization/id/@extension}" />
								</managingOrganization>
							</xsl:if>
						</xsl:if>
					</Patient>
				</resource>
			</entry>

			<!-- ATTESTER ORGANIZATION -->
			<xsl:if test="author/assignedAuthor/representedOrganization">
				<entry>
					<xsl:variable name="sanitized-system">
						<xsl:call-template name="sanitize-oid">
							<xsl:with-param name="text" select="author/assignedAuthor/representedOrganization/id/@root" />
						</xsl:call-template>
					</xsl:variable>

					<fullUrl value="https://example.com/base/Organization/{$sanitized-system}-{author/assignedAuthor/representedOrganization/id/@extension}" />
					<resource>
						<Organization xmlns="http://hl7.org/fhir">

							<id value="{$sanitized-system}-{author/assignedAuthor/representedOrganization/id/@extension}" />

							<identifier>
								<system value="urn:oid:{$sanitized-system}" />
								<value value="{author/assignedAuthor/representedOrganization/id/@extension}" />
								<assigner>
									<display value="{author/assignedAuthor/representedOrganization/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
							<name>
								<text value="{$PRIOR_CONST}AUTHOR_ASSIGNEDAUTHOR_REPRESENTEDORGANIZATION{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- DATA ENTERER -->
			<xsl:if test="dataEnterer/assignedEntity">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{dataEnterer/assignedEntity/id/@root}-{dataEnterer/assignedEntity/id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{dataEnterer/assignedEntity/id/@root}-{dataEnterer/assignedEntity/id/@extension}" />

							<identifier>
								<system value="urn:oid:{dataEnterer/assignedEntity/id/@root}" />
								<value value="{dataEnterer/assignedEntity/id/@extension}" />
								<assigner>
									<display value="{dataEnterer/assignedEntity/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="dataEnterer/assignedEntity/addr" />
							</xsl:call-template>
							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="dataEnterer/assignedEntity/telecom" />
							</xsl:call-template>
							<xsl:if test="dataEnterer/assignedEntity/assignedPerson">
								<name>
									<family value="{dataEnterer/assignedEntity/assignedPerson/name/family}" />
									<given value="{dataEnterer/assignedEntity/assignedPerson/name/given}" />
								</name>
							</xsl:if>

							<name>
								<text value="{$PRIOR_CONST}ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
							</name>
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<!-- PROVIDER ORGANIZATION -->
			<xsl:if test="recordTarget/patientRole/providerOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{recordTarget/patientRole/providerOrganization/id/@root}-{recordTarget/patientRole/providerOrganization/id/@extension}" />
					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{recordTarget/patientRole/providerOrganization/id/@root}-{recordTarget/patientRole/providerOrganization/id/@extension}" />

							<identifier>
								<system value="urn:oid:{recordTarget/patientRole/providerOrganization/id/@root}" />
								<value value="{recordTarget/patientRole/providerOrganization/id/@extension}" />
								<assigner>
									<display value="{recordTarget/patientRole/providerOrganization/id/@assigningAuthorityName}"></display>
								</assigner>
							</identifier>
							<name value="{recordTarget/patientRole/providerOrganization/name}" />
							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="recordTarget/patientRole/providerOrganization/telecom" />
							</xsl:call-template>
							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="recordTarget/patientRole/providerOrganization/addr" />
							</xsl:call-template>
							<name>
								<text value="{$PRIOR_CONST}PATIENTROLE_PROVIDERORGANIZATION{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- GUARDIAN ORGANIZATION -->
			<xsl:if test="recordTarget/patientRole/patient/guardian/guardianOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@root}-{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@root}-{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@extension}" />

							<identifier>
								<system value="urn:oid:{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@root}" />
								<value value="{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@extension}" />
								<assigner>
									<display value="{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@assigningAuthorityName}"></display>
								</assigner>
							</identifier>
							<name value="{recordTarget/patientRole/patient/guardian/guardianOrganization/@name}" />

							<name>
								<text value="{$PRIOR_CONST}PATIENT_GUARDIAN_GUARDIANORGANIZATION{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- PRACTITIONER INFORMATION RECIPIENT -->
			<xsl:if test="informationRecipient/intendedRecipient/informationRecipient">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{informationRecipient/intendedRecipient/id/@root}-{informationRecipient/intendedRecipient/id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{informationRecipient/intendedRecipient/id/@root}-{informationRecipient/intendedRecipient/id/@extension}" />

							<xsl:if test="informationRecipient/intendedRecipient/id">
								<identifier>
									<system value="urn:oid:{informationRecipient/intendedRecipient/id/@root}" />
									<value value="{informationRecipient/intendedRecipient/id/@extension}" />
									<assigner>
										<display value="{informationRecipient/intendedRecipient/id/@assigningAuthorityName}" />
									</assigner>
								</identifier>
							</xsl:if>
							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="informationRecipient/intendedRecipient/telecom" />
							</xsl:call-template>
							<name>
								<family value="{informationRecipient/intendedRecipient/informationRecipient/name/family}" />
								<given value="{informationRecipient/intendedRecipient/informationRecipient/name/given}" />
								<prefix value="{informationRecipient/intendedRecipient/informationRecipient/name/prefix}" />
							</name>

							<name>
								<text value="{$PRIOR_CONST}INTENDEDRECIPIENT_INFORMATIONRECIPIENT{$PRIOR_CONST}" />
							</name>
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<!-- RECEIVED ORGANIZATION -->
			<xsl:if test="informationRecipient/intendedRecipient/receivedOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{informationRecipient/intendedRecipient/receivedOrganization/id/@root}-{informationRecipient/intendedRecipient/receivedOrganization/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{informationRecipient/intendedRecipient/receivedOrganization/id/@root}-{informationRecipient/intendedRecipient/receivedOrganization/id/@extension}" />

							<identifier>
								<system value="urn:oid:{informationRecipient/intendedRecipient/receivedOrganization/id/@root}" />
								<value value="{informationRecipient/intendedRecipient/receivedOrganization/id/@extension}" />

								<assigner>
									<display value="{informationRecipient/intendedRecipient/receivedOrganization/id/@assigningAutorithyName}" />
								</assigner>
							</identifier>
							<name value="{informationRecipient/intendedRecipient/receivedOrganization/@name}" />

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="informationRecipient/intendedRecipient/receivedOrganization/telecom" />
							</xsl:call-template>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="informationRecipient/intendedRecipient/receivedOrganization/addr" />
							</xsl:call-template>
							<name>
								<text value="{$PRIOR_CONST}INTENDEDRECIPIENT_RECEIVEDORGANIZATION{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- AUTHOR -->
			<entry>
				<fullUrl value="https://example.com/base/Practitioner/{author/assignedAuthor/id/@root}-{author/assignedAuthor/id/@extension}" />
				<resource>
					<Practitioner xmlns="http://hl7.org/fhir">
						<id value="{author/assignedAuthor/id/@root}-{author/assignedAuthor/id/@extension}" />

						<identifier>
							<system value="urn:oid:{author/assignedAuthor/id/@root}" />
							<value value="{author/assignedAuthor/id/@extension}" />
							<assigner>
								<display value="{author/assignedAuthor/id/@assigningAuthorityName}" />
							</assigner>
						</identifier>

						<xsl:call-template name="show_address">
							<xsl:with-param name="cda_address" select="author/assignedAuthor/addr" />
						</xsl:call-template>

						<xsl:call-template name="show_telecom">
							<xsl:with-param name="cda_telecom" select="author/assignedAuthor/telecom" />
						</xsl:call-template>

						<name>
							<family value="{author/assignedAuthor/assignedPerson/name/family}" />
							<given value="{author/assignedAuthor/assignedPerson/name/given}" />
							<prefix value="{author/assignedAuthor/assignedPerson/name/prefix}" />
						</name>
						<name>
							<text value="{$PRIOR_CONST}ASSIGNEDAUTHOR_ASSIGNEDPERSON{$PRIOR_CONST}" />
						</name>
					</Practitioner>
				</resource>
			</entry>

			<!-- ENCOUNTER ORGANIZATION -->
			<xsl:for-each select="participant/associatedEntity/scopingOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{./id/@root}-{./id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{./id/@root}-{./id/@extension}" />

							<identifier>
								<system value="urn:oid:{./id/@root}" />
								<value value="{./id/@extension}" />
								<assigner>
									<display value="{./id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
							<name value="{./@name}" />

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="./telecom" />
							</xsl:call-template>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="./addr" />
							</xsl:call-template>
							<name>
								<text value="{$PRIOR_CONST}ASSOCIATEDENTITY_SCOPINGORGANIZATION{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:for-each>


			<!-- CUSTODIAN -->
			<xsl:if test="custodian">
				<xsl:variable name="sanitized-value">
					<xsl:call-template name="sanitize-oid">
						<xsl:with-param name="text" select="custodian/assignedCustodian/representedCustodianOrganization/id/@extension" />
					</xsl:call-template>
				</xsl:variable>
				<entry>
					<fullUrl value="https://example.com/base/Organization/{custodian/assignedCustodian/representedCustodianOrganization/id/@root}-{$sanitized-value}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{custodian/assignedCustodian/representedCustodianOrganization/id/@root}-{$sanitized-value}" />

							<identifier>
								<system value="urn:oid:{custodian/assignedCustodian/representedCustodianOrganization/id/@root}" />
								<value value="{$sanitized-value}" />
								<assigner>
									<display value="{custodian/assignedCustodian/representedCustodianOrganization/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
							<name value="{custodian/assignedCustodian/representedCustodianOrganization/name}" />

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="custodian/assignedCustodian/representedCustodianOrganization/telecom" />
							</xsl:call-template>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="custodian/assignedCustodian/representedCustodianOrganization/addr" />
							</xsl:call-template>
							<name>
								<text value="{$PRIOR_CONST}ASSIGNEDCUSTODIAN_REPRESENTEDCUSTODIANORGANIZATION{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- LEGAL AUTHENTICATOR PRACTITIONER -->
			<entry>
				<fullUrl value="https://example.com/base/PractitionerRole/practitioner-role-legal-aut" />
				<resource>
					<PractitionerRole xmlns="http://hl7.org/fhir">
						<id value="practitioner-role-legal-aut" />

						<practitioner>
							<xsl:variable name="sanitized-system">
								<xsl:call-template name="sanitize-oid">
									<xsl:with-param name="text" select="legalAuthenticator/assignedEntity/id/@root" />
								</xsl:call-template>
							</xsl:variable>
							<reference value="Practitioner/{$sanitized-system}-{legalAuthenticator/assignedEntity/id/@extension}" />
						</practitioner>
						<xsl:if test="legalAuthenticator/assignedEntity/representedOrganization">
							<organization>
								<xsl:variable name="sanitized-system">
									<xsl:call-template name="sanitize-oid">
										<xsl:with-param name="text" select="legalAuthenticator/assignedEntity/representedOrganization/id/@root" />
									</xsl:call-template>
								</xsl:variable>
								<reference value="Organization/{$sanitized-system}-{legalAuthenticator/assignedEntity/representedOrganization/id/@extension}" />
							</organization>
						</xsl:if>
						<name>
							<text value="{$PRIOR_CONST}PRACTITIONER_ROLE_LEGAL_AUT{$PRIOR_CONST}" />
						</name>
					</PractitionerRole>
				</resource>
			</entry>

			<!-- LEGAL AUTHOR ORGANIZATION -->
			<xsl:if test="legalAuthenticator/assignedEntity/representedOrganization">
				<xsl:variable name="sanitized-system">
					<xsl:call-template name="sanitize-oid">
						<xsl:with-param name="text" select="legalAuthenticator/assignedEntity/representedOrganization/id/@root" />
					</xsl:call-template>
				</xsl:variable>
				<entry>
					<fullUrl value="https://example.com/base/Organization/{$sanitized-system}-{legalAuthenticator/assignedEntity/representedOrganization/id/@extension}" />
					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{$sanitized-system}-{legalAuthenticator/assignedEntity/representedOrganization/id/@extension}" />

							<identifier>
								<system value="urn:oid:{$sanitized-system}" />
								<value value="{legalAuthenticator/assignedEntity/representedOrganization/id/@extension}" />
								<assigner>
									<display value="{legalAuthenticator/assignedEntity/representedOrganization/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
							<name value="{legalAuthenticator/assignedEntity/representedOrganization/id/@assigningAuthorityName}" />

							<name>
								<text value="{$PRIOR_CONST}LEGALAUTHENTICATOR_ASSIGNEDENTITY_REPRESENTEDORGANIZATION{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- AUTHENTICATOR PRACTITIONER ROLE -->
			<xsl:if test="authenticator">
				<entry>
					<fullUrl value="https://example.com/base/PractitionerRole/practitioner-role-authenticator" />
					<resource>
						<PractitionerRole xmlns="http://hl7.org/fhir">
							<id value="practitioner-role-authenticator" />

							<practitioner>
								<reference value="Practitioner/{authenticator/assignedEntity/id/@root}-{authenticator/assignedEntity/id/@extension}" />
							</practitioner>

							<xsl:if test="authenticator/assignedEntity/representedOrganization">
								<organization>
									<reference value="Organization/{authenticator/assignedEntity/representedOrganization/id/@root}-{authenticator/assignedEntity/representedOrganization/id/@extension}" />
								</organization>
							</xsl:if>
							<name>
								<text value="{$PRIOR_CONST}PRACTITIONER_ROLE_AUTHENTICATOR{$PRIOR_CONST}" />
							</name>
						</PractitionerRole>
					</resource>
				</entry>
			</xsl:if>

			<!-- PRACTITIONER ROLE PERFORMER -->
			<xsl:if test="documentationOf/serviceEvent/performer">
				<entry>
					<fullUrl value="https://example.com/base/PractitionerRole/practitioner-role-performer" />
					<resource>
						<PractitionerRole xmlns="http://hl7.org/fhir">
							<id value="practitioner-role-performer" />

							<practitioner>
								<xsl:variable name="sanitized-system">
									<xsl:call-template name="sanitize-oid">
										<xsl:with-param name="text" select="documentationOf/serviceEvent/performer/assignedEntity/id/@root" />
									</xsl:call-template>
								</xsl:variable>
								<reference value="Practitioner/{$sanitized-system}-{documentationOf/serviceEvent/performer/assignedEntity/id/@extension}" />
							</practitioner>

							<xsl:if test="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization">
								<organization>
									<xsl:variable name="sanitized-system">
										<xsl:call-template name="sanitize-oid">
											<xsl:with-param name="text" select="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@root" />
										</xsl:call-template>
									</xsl:variable>
									<reference value="Organization/{$sanitized-system}-{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@extension}" />
								</organization>
							</xsl:if>
							<name>
								<text value="{$PRIOR_CONST}PRACTITIONER_ROLE_PERFORMER{$PRIOR_CONST}" />
							</name>
						</PractitionerRole>
					</resource>
				</entry>

			</xsl:if>

			<!-- AUTHENTICATOR PRACTITIONER -->
			<xsl:if test="authenticator/assignedEntity/assignedPerson">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{authenticator/assignedEntity/id/@root}-{authenticator/assignedEntity/id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{authenticator/assignedEntity/id/@root}-{authenticator/assignedEntity/id/@extension}" />

							<identifier>
								<system value="urn:oid:{authenticator/assignedEntity/id/@root}" />
								<value value="{authenticator/assignedEntity/id/@extension}" />
								<assigner>
									<display value="{authenticator/assignedEntity/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="authenticator/assignedEntity/addr" />
							</xsl:call-template>

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="authenticator/assignedEntity/telecom" />
							</xsl:call-template>

							<name>
								<family value="{authenticator/assignedEntity/assignedPerson/name/family}" />
								<given value="{authenticator/assignedEntity/assignedPerson/name/given}" />
								<prefix value="{authenticator/assignedEntity/assignedPerson/name/prefix}" />
							</name>
							<name>
								<text value="{$PRIOR_CONST}AUTHENTICATOR_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
							</name>
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<!-- PERFORMER PRACTITIONER -->
			<xsl:if test="documentationOf/serviceEvent/performer">
				<xsl:variable name="sanitized-system">
					<xsl:call-template name="sanitize-oid">
						<xsl:with-param name="text" select="documentationOf/serviceEvent/performer/assignedEntity/id/@root" />
					</xsl:call-template>
				</xsl:variable>
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{$sanitized-system}-{documentationOf/serviceEvent/performer/assignedEntity/id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{$sanitized-system}-{documentationOf/serviceEvent/performer/assignedEntity/id/@extension}" />

							<identifier>
								<system value="urn:oid:{$sanitized-system}" />
								<value value="{documentationOf/serviceEvent/performer/assignedEntity/id/@extension}" />
								<assigner>
									<display value="{documentationOf/serviceEvent/performer/assignedEntity/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="documentationOf/serviceEvent/performer/assignedEntity/addr" />
							</xsl:call-template>

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="documentationOf/serviceEvent/performer/assignedEntity/telecom" />
							</xsl:call-template>

							<name>
								<family value="{documentationOf/serviceEvent/performer/assignedEntity/assignedPerson/name/family}" />
								<given value="{documentationOf/serviceEvent/performer/assignedEntity/assignedPerson/name/given}" />
							</name>
							<name>
								<text value="{$PRIOR_CONST}SERVICEEVENT_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
							</name>
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<!-- AUTHENTICATOR ORGANIZATION -->
			<xsl:if test="authenticator/assignedEntity/representedOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{authenticator/assignedEntity/representedOrganization/id/@root}-{authenticator/assignedEntity/representedOrganization/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{authenticator/assignedEntity/representedOrganization/id/@root}-{authenticator/assignedEntity/representedOrganization/id/@extension}" />

							<identifier>
								<system value="urn:oid:{authenticator/assignedEntity/representedOrganization/id/@root}" />
								<value value="{authenticator/assignedEntity/representedOrganization/id/@extension}" />
								<assigner>
									<display value="{authenticator/assignedEntity/representedOrganization/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
							<name value="{authenticator/assignedEntity/representedOrganization/id/@assigningAuthorityName}" />

							<name>
								<text value="{$PRIOR_CONST}AUTHENTICATOR_ASSIGNEDENTITY_REPRESENTEDORGANIZATION{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- REPRESENTED ORGANIZATION PERFORMER -->
			<xsl:if test="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization">
				<xsl:variable name="sanitized-system">
					<xsl:call-template name="sanitize-oid">
						<xsl:with-param name="text" select="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@root" />
					</xsl:call-template>
				</xsl:variable>
				<entry>
					<fullUrl value="https://example.com/base/Organization/{$sanitized-system}-{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@extension}" />
					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{$sanitized-system}-{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@extension}" />

							<identifier>
								<system value="urn:oid:{$sanitized-system}" />
								<value value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@extension}" />
								<assigner>
									<display value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
							<name value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/name}" />

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/telecom" />
							</xsl:call-template>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/addr" />
							</xsl:call-template>

							<xsl:if test="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf">
								<partOf>
									<reference value="Organization/{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@root}-{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@extension}" />
								</partOf>
							</xsl:if>
							<name>
								<text value="{$PRIOR_CONST}SERVICEEVENT_PERFORMER_ASSIGNEDENTITY_REPRESENTEDORGANIZATION{$PRIOR_CONST}" />
							</name>
						</Organization>

					</resource>
				</entry>
			</xsl:if>

			<!-- LEGAL AUTHOR PRACTITIONER -->
			<entry>
				<xsl:variable name="sanitized-system">
					<xsl:call-template name="sanitize-oid">
						<xsl:with-param name="text" select="legalAuthenticator/assignedEntity/id/@root" />
					</xsl:call-template>
				</xsl:variable>
				<fullUrl value="https://example.com/base/Practitioner/{$sanitized-system}-{legalAuthenticator/assignedEntity/id/@extension}" />
				<resource>
					<Practitioner xmlns="http://hl7.org/fhir">
						<id value="{$sanitized-system}-{legalAuthenticator/assignedEntity/id/@extension}" />

						<identifier>
							<system value="urn:oid:{legalAuthenticator/assignedEntity/id/@root}" />
							<value value="{legalAuthenticator/assignedEntity/id/@extension}" />
							<assigner>
								<display value="{legalAuthenticator/assignedEntity/id/@assigningAuthorityName}" />
							</assigner>
						</identifier>

						<xsl:call-template name="show_address">
							<xsl:with-param name="cda_address" select="legalAuthenticator/assignedEntity/addr" />
						</xsl:call-template>

						<xsl:call-template name="show_telecom">
							<xsl:with-param name="cda_telecom" select="legalAuthenticator/assignedEntity/telecom" />
						</xsl:call-template>

						<name>
							<family value="{legalAuthenticator/assignedEntity/assignedPerson/name/family}" />
							<given value="{legalAuthenticator/assignedEntity/assignedPerson/name/given}" />
							<prefix value="{legalAuthenticator/assignedEntity/assignedPerson/name/prefix}" />
						</name>
						<name>
							<text value="{$PRIOR_CONST}LEGALAUTHENTICATOR_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
						</name>
					</Practitioner>
				</resource>
			</entry>

			<!-- FULLFILLMENT ENCOUNTER -->
			<xsl:for-each select="inFulfillmentOf">
				<entry>
					<fullUrl value="https://example.com/base/ServiceRequest/service-request{position()}" />
					<resource>
						<ServiceRequest xmlns="http://hl7.org/fhir">
							<id value="service-request{position()}" />
							<xsl:variable name="sanitized-value">
								<xsl:call-template name="sanitize-oid">
									<xsl:with-param name="text" select="./order/id/@extension" />
								</xsl:call-template>
							</xsl:variable>

							<status value="active" />

							<identifier>
								<system value="urn:oid:{./order/id/@root}" />
								<value value="{$sanitized-value}" />
								<assigner>
									<display value="{./order/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
							<priority value="{./order/priorityCode/@displayName}" />

							<intent value="order" />
							<subject>
								<reference value="Patient/{$patientId}" />
							</subject>

							<encounter>
								<reference value="Encounter/encounter" />
							</encounter>
						</ServiceRequest>
					</resource>
				</entry>
			</xsl:for-each>

			<xsl:if test="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@root}-{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@root}-{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@extension}" />

							<identifier>
								<system value="urn:oid:{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@root}" />
								<value value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@extension}" />
								<assigner>
									<display value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>

							<xsl:if test="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization">
								<partOf>
									<reference value="Organization/{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@root}-{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@extension}" />
								</partOf>
							</xsl:if>

							<name>
								<text value="{$PRIOR_CONST}SERVICEEVENT_PERFORMER_ASSIGNEDENTITY_REPRESENTEDORGANIZATION_ASORGANIZATIONPARTOF{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@root}-{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@root}-{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@extension}" />

							<identifier>
								<system value="urn:oid:{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@root}" />
								<value value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@extension}" />
								<assigner>
									<display value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>

							<name value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/name}" />
							<name>
								<text value="{$PRIOR_CONST}REPRESENTEDORGANIZATION_ASORGANIZATIONPARTOF_WHOLEORGANIZATION{$PRIOR_CONST}" />
							</name>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- ENCOUNTER PRACTITIONER ROLE -->
			<xsl:for-each select="participant">
				<entry>
					<fullUrl value="https://example.com/base/PractitioneRole/practitioner-role-encounter{position()}" />
					<resource>
						<PractitionerRole xmlns="http://hl7.org/fhir">
							<id value="practitioner-role-encounter{position()}" />

							<code>
								<coding>
									<system value="urn:oid:{./functionCode/@codeSystem}" />
									<xsl:call-template name="code_enum">
										<xsl:with-param name="code" select="functionCode/@code" />
									</xsl:call-template>
									<version value="{./functionCode/@displaySystemVersion}" />
									<display value="{./functionCode/@displayName}" />
								</coding>
							</code>

							<xsl:if test="./associatedEntity/id">
								<practitioner>
									<reference value="Practitioner/{./associatedEntity/id/@root}-{./associatedEntity/id/@extension}" />
								</practitioner>
							</xsl:if>

							<xsl:if test="./associatedEntity/scopingOrganization">
								<organization>
									<reference value="Organization/{./associatedEntity/scopingOrganization/id/@root}-{./associatedEntity/scopingOrganization/id/@extension}" />
								</organization>
							</xsl:if>

							<name>
								<text value="{$PRIOR_CONST}PRACTITIONER_ROLE_ENCOUNTER{$PRIOR_CONST}" />
							</name>
						</PractitionerRole>
					</resource>
				</entry>
			</xsl:for-each>

			<!-- ENCOUNTER PRACTITIONER ROLE -->
			<entry>
				<fullUrl value="https://example.com/base/Encounter/encounter" />
				<resource>
					<Encounter xmlns="http://hl7.org/fhir">
						<id value="encounter" />

						<xsl:if test="componentOf/encompassingEncounter/id">
							<identifier>
								<system value="urn:oid:{componentOf/encompassingEncounter/id/@root}" />
								<value value="{componentOf/encompassingEncounter/id/@extension}" />
								<assigner>
									<display value="{componentOf/encompassingEncounter/id/@assiginingAuthorityName}" />
								</assigner>
							</identifier>
						</xsl:if>

						<xsl:if test="componentOf/encompassingEncounter/effectiveTime/@value">
							<period>
								<xsl:call-template name="show_date">
									<xsl:with-param name="cda_date" select="componentOf/encompassingEncounter/effectiveTime/@value" />
									<xsl:with-param name="tag" select="'start'" />
								</xsl:call-template>
							</period>
						</xsl:if>

						<xsl:for-each select="participant">
							<participant>
								<type>
									<coding>
										<code value="{./@typeCode}" />
										<system value="http://terminology.hl7.org/CodeSystem/v3-ParticipationType" />
										<display value="{./functionCode/@typeCode}" />
									</coding>
								</type>

								<individual>
									<reference value="PractitionerRole/practitioner-role-encounter{position()}" />
								</individual>
								<period>
									<xsl:if test="./time/@value">
										<xsl:call-template name="show_date">
											<xsl:with-param name="cda_date" select="./time/@value" />
											<xsl:with-param name="tag" select="'start'" />
										</xsl:call-template>
									</xsl:if>
									<xsl:if test="./time/low/@value">
										<xsl:call-template name="show_date">
											<xsl:with-param name="cda_date" select="./time/low/@value" />
											<xsl:with-param name="tag" select="'start'" />
										</xsl:call-template>
									</xsl:if>
									<xsl:if test="./time/high/@value">
										<xsl:call-template name="show_date">
											<xsl:with-param name="cda_date" select="./time/high/@value" />
											<xsl:with-param name="tag" select="'end'" />
										</xsl:call-template>
									</xsl:if>
								</period>
							</participant>
						</xsl:for-each>

						<xsl:if test="component/structuredBody/component/section/component/section/entry/act/participant">
							<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/participant">
								<participant>
									<type>
										<coding>
											<code value="{./@typeCode}" />
											<system value="http://terminology.hl7.org/CodeSystem/v3-ParticipationType" />
											<display value="{./functionCode/@typeCode}" />
										</coding>
									</type>

									<individual>
										<reference value="PractitionerRole/practitioner-role-performer" />
									</individual>
								</participant>
							</xsl:for-each>
						</xsl:if>

						<xsl:if test="componentOf/encompassingEncounter/responsibleParty">
							<participant>
								<individual>
									<reference value="PractitionerRole/practitioner-role-responsible-party" />
								</individual>
							</participant>
						</xsl:if>
						<basedOn>
							<xsl:for-each select="inFulfillmentOf">
								<reference value="ServiceRequest/service-request{position()}" />
							</xsl:for-each>
						</basedOn>

						<status value="unknown" />
						<!-- TODO - Rimuovere commenti quando capiamo l'obbligatorietà dei 
							campi -->
						<!-- <class> -->
						<!-- <coding> -->
						<!-- <code value="{componentOf/encompassingEncounter/code/@code}" /> -->
						<!-- <system value="urn:oid:{componentOf/encompassingEncounter/code/@codeSystem}" 
							/> -->
						<!-- <version value="{componentOf/encompassingEncounter/code/@displaySystemVersion}" 
							/> -->
						<!-- <display -->
						<!-- value="{componentOf/encompassingEncounter/code/@displayName}" 
							/> -->
						<!-- </coding> -->
						<!-- </class> -->
						<class>
							<system value="http://terminology.hl7.org/CodeSystem/v3-ActCode" />
							<code value="IMP" />
							<display value="inpatient encounter" />
						</class>

						<location>
							<xsl:if test="componentOf/encompassingEncounter/location/healthCareFacility">
								<location>
									<reference value="Location/location-encompassing-encounter" />
								</location>
							</xsl:if>
						</location>


						<subject>
							<reference value="Patient/{$patientId}" />
						</subject>
					</Encounter>
				</resource>
			</entry>

			<!-- ENCOUNTER PRACTITIONER -->
			<xsl:for-each select="participant/associatedEntity">
				<xsl:if test="./id">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/{./id/@root}-{./id/@extension}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="{./id/@root}-{./id/@extension}" />

								<identifier>
									<system value="urn:oid:{./id/@root}" />
									<value value="{./id/@extension}" />
									<assigner>
										<display value="{./id/@assigningAuthorityName}" />
									</assigner>
								</identifier>


								<xsl:call-template name="show_address">
									<xsl:with-param name="cda_address" select="./addr" />
								</xsl:call-template>

								<xsl:call-template name="show_telecom">
									<xsl:with-param name="cda_telecom" select="./telecom" />
								</xsl:call-template>

								<name>
									<family value="{./associatedPerson/name/family}"></family>
									<given value="{./associatedPerson/name/given}"></given>
									<prefix value="{./associatedPerson/name/prefix}"></prefix>
								</name>
								<name>
									<text value="{$PRIOR_CONST}PARTICIPANT_ASSOCIATEDENTITY{$PRIOR_CONST}" />
								</name>
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- DIAGNOSTIC REPORT ENTRY -->
			<entry>
				<fullUrl value="https://example.com/base/DiagnosticReport/diagnostic-report" />
				<resource>
					<DiagnosticReport xmlns="http://hl7.org/fhir">
						<id value="diagnostic-report" />

						<code>
							<coding>
								<code value="{component/structuredBody/component/section/component/section/entry/act/code/@code}" />
								<system value="urn:oid:{component/structuredBody/component/section/component/section/entry/act/code/@codeSystem}" />
								<version value="{component/structuredBody/component/section/component/section/entry/act/code/@version}" />
								<display value="{component/structuredBody/component/section/component/section/entry/act/code/@displayName}" />
							</coding>
						</code>

						<xsl:if test="component/structuredBody/component/section/component/section/entry/act/statusCode/@code = 'completed'">
							<status value="final" />
						</xsl:if>
						<xsl:if test="component/structuredBody/component/section/component/section/entry/act/statusCode/@code = 'active'">
							<status value="partial" />
						</xsl:if>
						<xsl:if test="component/structuredBody/component/section/component/section/entry/act/statusCode/@code = 'aborted'">
							<status value="canceled" />
						</xsl:if>

						<xsl:if test="component/structuredBody/component/section/component/section/entry/act/specimen/specimenRole">
							<specimen>
								<reference value="Specimen/specimen-diagnostic-entry" />
							</specimen>
						</xsl:if>

						<xsl:if test="component/structuredBody/component/section/component/section/component/section/entry/act/performer">
							<perfomer>
								<reference value="Practitioner/performer-sub-contractor" />
							</perfomer>
						</xsl:if>

						<xsl:if test="component/structuredBody/component/section/component/section/component/section/entry/act/author">
							<perfomer>
								<reference value="Practitioner/{component/structuredBody/component/section/component/section/component/section/entry/act/author/assignedEntity/id/@root}-{component/structuredBody/component/section/component/section/component/section/entry/act/author/assignedEntity/id/@extension}" />
							</perfomer>
						</xsl:if>

						<encounter>
							<reference value="Encounter/encounter" />
						</encounter>

						<subject>
							<reference value="Patient/{$patientId}" />
						</subject>

						<xsl:call-template name="show_date">
							<xsl:with-param name="cda_date" select="component/structuredBody/component/section/component/section/entry/act/effectiveTime/@value" />
							<xsl:with-param name="tag" select="'effectiveDateTime'" />
						</xsl:call-template>

						<!-- OSSERVAZIONE SINGOLA -->
						<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation">
							<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation">
								<result>
									<reference value="Observation/observation-act-section{position()}" />
								</result>
							</xsl:for-each>
						</xsl:if>

						<!-- OSSERVAZIONI MULTIPLE -->
						<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer">
							<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer">
								<result>
									<reference value="Observation/observation-entry{position()}" />
								</result>
							</xsl:for-each>
						</xsl:if>
					</DiagnosticReport>
				</resource>
			</entry>


			<!-- ACT AUTHOR -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/author">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/{./entry/act/author/assignedEntity/id/@root}-{./entry/act/author/assignedEntity/id/@extension}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="{./entry/act/author/assignedEntity/id/@root}-{./entry/act/author/assignedEntity/id/@extension}" />

								<identifier>
									<system value="urn:oid:{./entry/act/author/assignedEntity/id/@root}" />
									<value value="{./entry/act/author/assignedEntity/id/@extension}" />
									<assigner>
										<display value="{./entry/act/author/assignedEntity/id/@assigningAuthorityName}" />
									</assigner>
								</identifier>
								<xsl:call-template name="show_address">
									<xsl:with-param name="cda_address" select="./entry/act/author/assignedEntity/addr" />
								</xsl:call-template>

								<xsl:call-template name="show_telecom">
									<xsl:with-param name="cda_telecom" select="./entry/act/author/assignedEntity/telecom" />
								</xsl:call-template>

								<name>
									<family value="{./entry/act/author/assignedEntity/assignedPerson/name/family}" />
									<given value="{./entry/act/author/assignedEntity/assignedPerson/name/given}" />
								</name>
								<name>
									<text value="{$PRIOR_CONST}ACT_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
								</name>
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- PERFORMER OBSERVATION -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/observation/performer">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/{./entry/act/entryRelationship/observation/performer/assignedEntity/id/@root}-{./entry/act/entryRelationship/observation/performer/assignedEntity/id/@extension}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="{./entry/act/entryRelationship/observation/performer/assignedEntity/id/@root}-{./entry/act/entryRelationship/observation/performer/assignedEntity/id/@extension}{position()}" />

								<identifier>
									<system value="urn:oid:{./entry/act/entryRelationship/observation/performer/assignedEntity/id/@root}" />
									<value value="{./entry/act/entryRelationship/observation/performer/assignedEntity/id/@extension}" />
									<assigner>
										<display value="{./entry/act/entryRelationship/observation/performer/assignedEntity/id/@assigningAuthorityName}" />
									</assigner>
								</identifier>
								<xsl:call-template name="show_address">
									<xsl:with-param name="cda_address" select="./entry/act/entryRelationship/observation/performer/assignedEntity/addr" />
								</xsl:call-template>

								<xsl:call-template name="show_telecom">
									<xsl:with-param name="cda_telecom" select="./entry/act/entryRelationship/observation/performer/assignedEntity/telecom" />
								</xsl:call-template>

								<name>
									<family value="{./entry/act/entryRelationship/observation/performer/assignedEntity/assignedPerson/name/family}" />
									<given value="{./entry/act/entryRelationship/observation/performer/assignedEntity/assignedPerson/name/given}" />
								</name>
								<name>
									<text value="{$PRIOR_CONST}OBSERVATION_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
								</name>
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- PERFORMER ORGANIZER -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/organizer/performer">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/{./entry/act/entryRelationship/organizer/performer/assignedEntity/id/@root}-{./entry/act/entryRelationship/organizer/performer/assignedEntity/id/@extension}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="{./entry/act/entryRelationship/organizer/performer/assignedEntity/id/@root}-{./entry/act/entryRelationship/organizer/performer/assignedEntity/id/@extension}" />

								<identifier>
									<system value="urn:oid:{./entry/act/entryRelationship/organizer/performer/assignedEntity/id/@root}" />
									<value value="{./entry/act/entryRelationship/organizer/performer/assignedEntity/id/@extension}" />
									<assigner>
										<display value="{./entry/act/entryRelationship/organizer/performer/assignedEntity/id/@assigningAuthorityName}" />
									</assigner>
								</identifier>
								<xsl:call-template name="show_address">
									<xsl:with-param name="cda_address" select="./entry/act/entryRelationship/organizer/performer/assignedEntity/addr" />
								</xsl:call-template>

								<xsl:call-template name="show_telecom">
									<xsl:with-param name="cda_telecom" select="./entry/act/entryRelationship/organizer/performer/assignedEntity/telecom" />
								</xsl:call-template>

								<name>
									<family value="{./entry/act/entryRelationship/organizer/performer/assignedEntity/assignedPerson/name/family}" />
									<given value="{./entry/act/entryRelationship/organizer/performer/assignedEntity/assignedPerson/name/given}" />
								</name>
								<name>
									<text value="{$PRIOR_CONST}ORGANIZER_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
								</name>
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- AUTHOR OBSERVATION -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/observation/author">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/{./entry/act/entryRelationship/observation/author/assignedEntity/id/@root}-{./entry/act/entryRelationship/observation/author/assignedEntity/id/@extension}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="{./entry/act/entryRelationship/observation/author/assignedEntity/id/@root}-{./entry/act/entryRelationship/observation/author/assignedEntity/id/@extension}" />

								<identifier>
									<system value="urn:oid:{./entry/act/entryRelationship/observation/author/assignedEntity/id/@root}" />
									<value value="{./entry/act/entryRelationship/observation/author/assignedEntity/id/@extension}" />
									<assigner>
										<display value="{./entry/act/entryRelationship/observation/author/assignedEntity/id/@assigningAuthorityName}" />
									</assigner>
								</identifier>
								<xsl:call-template name="show_address">
									<xsl:with-param name="cda_address" select="./entry/act/entryRelationship/observation/author/assignedEntity/addr" />
								</xsl:call-template>

								<xsl:call-template name="show_telecom">
									<xsl:with-param name="cda_telecom" select="./entry/act/entryRelationship/observation/author/assignedEntity/telecom" />
								</xsl:call-template>

								<name>
									<family value="{./entry/act/entryRelationship/observation/author/assignedEntity/assignedPerson/name/family}" />
									<given value="{./entry/act/entryRelationship/observation/author/assignedEntity/assignedPerson/name/given}" />
								</name>
								<name>
									<text value="{$PRIOR_CONST}OBSERVATION_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
								</name>
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- AUTHOR ORGANIZER -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/organizer/author">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@root}-{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@extension}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@root}-{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@extension}" />

								<identifier>
									<system value="urn:oid:{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@root}" />
									<value value="{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@extension}" />
									<assigner>
										<display value="{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@assigningAuthorityName}" />
									</assigner>
								</identifier>
								<xsl:call-template name="show_address">
									<xsl:with-param name="cda_address" select="./entry/act/entryRelationship/organizer/author/assignedEntity/addr" />
								</xsl:call-template>

								<xsl:call-template name="show_telecom">
									<xsl:with-param name="cda_telecom" select="./entry/act/entryRelationship/organizer/author/assignedEntity/telecom" />
								</xsl:call-template>

								<name>
									<family value="{./entry/act/entryRelationship/organizer/author/assignedEntity/assignedPerson/name/family}" />
									<given value="{./entry/act/entryRelationship/organizer/author/assignedEntity/assignedPerson/name/given}" />
								</name>
								<name>
									<text value="{$PRIOR_CONST}ORGANIZER_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
								</name>
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- PERFORMER SUB-CONTRACTOR -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/performer">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/performer-sub-contractor" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="performer-sub-contractor" />

								<identifier>
									<system value="urn:oid:{./entry/act/performer/assignedEntity/id/@root}" />
									<value value="{./entry/act/performer/assignedEntity/id/@extension}" />
									<assigner>
										<display value="{./entry/act/performer/assignedEntity/id/@assigningAuthorityName}" />
									</assigner>
								</identifier>
								<xsl:call-template name="show_address">
									<xsl:with-param name="cda_address" select="./entry/act/performer/assignedEntity/addr" />
								</xsl:call-template>

								<xsl:call-template name="show_telecom">
									<xsl:with-param name="cda_telecom" select="./entry/act/performer/assignedEntity/telecom" />
								</xsl:call-template>

								<name>
									<family value="{./entry/act/performer/assignedEntity/assignedPerson/name/family}" />
									<given value="{./entry/act/performer/assignedEntity/assignedPerson/name/given}" />
								</name>
								<name>
									<text value="{$PRIOR_CONST}ACT_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
								</name>
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- SPECIMEN DIAGNOSTIC ENTRY -->
			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/specimen/specimenRole">
				<entry>
					<fullUrl value="https://example.com/base/Specimen/specimen-diagnostic-entry" />
					<resource>
						<Specimen xmlns="http://hl7.org/fhir">
							<id value="specimen-diagnostic-entry" />

							<identifier>
								<system value="urn:oid:{component/structuredBody/component/section/component/section/entry/act/specimen/specimenRole/id/@root}" />
								<value value="{component/structuredBody/component/section/component/section/entry/act/specimen/specimenRole/id/@extension}" />
							</identifier>

							<type>
								<coding>
									<code value="{component/structuredBody/component/section/component/section/entry/act/specimen/specimenRole/specimenPlayingEntity/code/@code}" />
									<system value="urn:oid:{component/structuredBody/component/section/component/section/entry/act/specimen/specimenRole/specimenPlayingEntity/code/@codeSystem}" />
									<version value="{component/structuredBody/component/section/component/section/entry/act/specimen/specimenRole/specimenPlayingEntity/code/@codeSystemName}" />
									<display value="{component/structuredBody/component/section/component/section/entry/act/specimen/specimenRole/specimenPlayingEntity/code/@displayName}" />
								</coding>

								<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/specimen/specimenRole/specimenPlayingEntity/code/translation">
									<coding>
										<code value="{./@code}" />
										<system value="urn:oid:{./@codeSystem}" />
										<version value="{./@codeSystemName}" />
										<display value="{./@displayName}" />
									</coding>
								</xsl:for-each>
							</type>

						</Specimen>
					</resource>
				</entry>
			</xsl:if>


			<!-- HAS-MEMBER-OBSERVATION -->
			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer">

				<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer">
					<xsl:variable name="currentObservationIndex" select="position()"></xsl:variable>
					<xsl:for-each select="./component/observation">
						<entry>
							<fullUrl value="https://example.com/base/Observation/has-member-observation{$currentObservationIndex}-{position()}" />
							<resource>
								<Observation xmlns="http://hl7.org/fhir">
									<id value="has-member-observation{$currentObservationIndex}-{position()}" />

									<code>
										<coding>
											<code value="{./code/@code}" />
											<system value="urn:oid:{./code/@codeSystem}" />
											<version value="{./code/@codeSystemName}" />
											<display value="{./code/@displayName}" />
										</coding>
									</code>

									<xsl:if test="./translation">
										<xsl:for-each select="./translation">
											<code>
												<coding>
													<code value="{./code/@code}" />
													<system value="urn:oid:{./code/@codeSystem}" />
													<version value="{./code/@codeSystemName}" />
													<display value="{./code/@displayName}" />
												</coding>
											</code>
										</xsl:for-each>
									</xsl:if>

									<xsl:choose>
										<xsl:when test="./statusCode/@code = 'completed'">
											<status value="final" />
										</xsl:when>
										<xsl:otherwise>
											<status value="canceled" />
										</xsl:otherwise>
									</xsl:choose>

									<xsl:call-template name="show_date">
										<xsl:with-param name="cda_date" select="./effectiveTime/@value" />
										<xsl:with-param name="tag" select="'effectiveDateTime'" />
									</xsl:call-template>

									<interpretation>
										<coding>
											<system value="urn:oid:{./interpretationCode/@codeSystem}" />
											<version value="{./interpretationCode/@codeSystemName}" />
											<code value="{./interpretationCode/@code}" />
											<display value="{./interpretationCode/@displayName}" />
										</coding>
									</interpretation>

									<xsl:if test="./methodCode">
										<method>
											<coding>
												<code value="{./methodCode/@code}" />
												<system value="urn:oid:{./methodCode/@codeSystem}" />
												<version value="{./methodCode/codeSystemVersion}" />
												<display value="{./methodCode/@displayName}" />
											</coding>
										</method>
									</xsl:if>

									<subject>
										<reference value="Patient/{$patientId}" />
									</subject>

									<xsl:if test="./specimen">
										<specimen>
											<reference value="Specimen/specimen-entry-organizer{position()}" />
										</specimen>
									</xsl:if>

									<xsl:if test="./performer">
										<perfomer>
											<reference value="Practitioner/performer-has-member-observation" />
										</perfomer>
									</xsl:if>

									<xsl:if test="./author">
										<perfomer>
											<reference value="Practitioner/author-has-member-observation" />
										</perfomer>
									</xsl:if>

									<xsl:if test="./participant">
										<encounter>
											<reference value="Encounter/encounter" />
										</encounter>
									</xsl:if>

									<referenceRange>
										<low>
											<value value="{translate(./entry/act/entryRelationship/organizer/component/observation/referenceRange/observationRange/value/low/@value, ' ', '')}" />
											<unit value="{./entry/act/entryRelationship/organizer/component/observation/referenceRange/observationRange/value/low/@unit}" />
										</low>
										<high>
											<value value="{translate(./entry/act/entryRelationship/organizer/component/observation/referenceRange/observationRange/value/high/@value, ' ', '')}" />
											<unit value="{./entry/act/entryRelationship/organizer/component/observation/referenceRange/observationRange/value/high/@unit}" />
										</high>

										<appliesTo value="{./entry/act/entryRelationship/organizer/component/observation/referenceRange/observationRange/precondition}" />
										<age value="{./entry/act/entryRelationship/organizer/component/observation/referenceRange/observationRange/precondition/criterion/value}" />
									</referenceRange>

									<note>
										<text value="{./entry/act/entryRelationship/organizer/component/observation/entryRelationship/act}" />
									</note>

									<xsl:if test="./entryRelationship/observationMedia">
										<derivedFrom>
											<reference value="Media/organizer-observation-media{$currentObservationIndex}-{position()}" />
										</derivedFrom>
									</xsl:if>

									<!-- <xsl:if TODO: Verificare l'utilità di questo blocco
											test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer">
											<xsl:for-each
												select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer">
												<hasMember>
													<reference
														value="Observation/has-member-has-member-observation{$currentObservationIndex}-{position()}" />
												</hasMember>
											</xsl:for-each>
										</xsl:if> -->
								</Observation>
							</resource>
						</entry>
					</xsl:for-each>

				</xsl:for-each>
			</xsl:if>


			<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer">
				<xsl:variable name="currentObservationIndex" select="position()" />
				<xsl:if test="./component/observation/entryRelationship/observationMedia">
					<xsl:for-each select="./component/observation/entryRelationship/observationMedia">
						<entry>
							<fullUrl value="https://example.com/base/Media/organizer-observation-media{$currentObservationIndex}-{position()}" />
							<resource>
								<Media xmlns="http://hl7.org/fhir">
									<id value="organizer-observation-media{$currentObservationIndex}-{position()}" />

									<subject>
										<reference value="Patient/{$patientId}" />
									</subject>

									<encounter>
										<reference value="Encounter/encounter" />
									</encounter>

									<content>
										<content value="{./value}" />
										<data value="{./value/representation/@value}" />
										<contentType value="{./value/mediaType/@value}" />
									</content>
								</Media>
							</resource>
						</entry>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/observation">
				<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/observation">
					<xsl:variable name="index" select="position()"></xsl:variable>

					<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer">
						<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer">
							<xsl:variable name="body_index" select="position()"></xsl:variable>

							<xsl:for-each select="./component/structuredBody/component/section/component/section">
								<entry>
									<fullUrl value="https://example.com/base/Observation/body-has-member-observation{index}-{body_index}-{position()}" />
									<resource>
										<Observation xmlns="http://hl7.org/fhir">
											<id value="body-has-member-observation{index}-{body_index}-{position()}" />

											<code>
												<coding>
													<code value="{./code/@code}" />
													<system value="urn:oid:{./code/@codeSystem}" />
													<version value="{./code/@codeSystemName}" />
													<display value="{./code/@displayName}" />
												</coding>
											</code>

											<xsl:if test="./translation">
												<xsl:for-each select="./translation">
													<code>
														<coding>
															<code value="{./code/@code}" />
															<system value="urn:oid:{./code/@codeSystem}" />
															<version value="{./code/@codeSystemName}" />
															<display value="{./code/@displayName}" />
														</coding>
													</code>
												</xsl:for-each>
											</xsl:if>

											<xsl:choose>
												<xsl:when test="./statusCode/@code = 'completed'">
													<status value="final" />
												</xsl:when>
												<xsl:otherwise>
													<status value="canceled" />
												</xsl:otherwise>
											</xsl:choose>

											<xsl:call-template name="show_date">
												<xsl:with-param name="cda_date" select="./effectiveTime/@value" />
												<xsl:with-param name="tag" select="'effectiveDateTime'" />
											</xsl:call-template>

											<interpretation>
												<coding>
													<system value="urn:oid:{./interpretationCode/@codeSystem}" />
													<version value="{./interpretationCode/@codeSystemName}" />
													<code value="{./interpretationCode/@code}" />
													<display value="{./interpretationCode/@displayName}" />
												</coding>
											</interpretation>

											<xsl:if test="./methodCode">
												<method>
													<coding>
														<code value="{./methodCode/@code}" />
														<system value="urn:oid:{./methodCode/@codeSystem}" />
														<version value="{./methodCode/codeSystemVersion}" />
														<display value="{./methodCode/@displayName}" />
													</coding>
												</method>
											</xsl:if>

											<note>
												<text value="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/component/act" />
											</note>

										</Observation>
									</resource>
								</entry>
							</xsl:for-each>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/author">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/body-author" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="body-author" />

							<identifier>
								<system value="urn:oid:{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/author/assignedAuthor/id/@root}" />
								<value value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/author/assignedAuthor/id/@extension}" />
								<assigner>
									<display value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/author/assignedAuthor/id/@assigningAutorithyName}" />
								</assigner>
							</identifier>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/author/assignedAuthor/addr" />
							</xsl:call-template>

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/author/assignedAuthor/telecom" />
							</xsl:call-template>

							<name>
								<family value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/author/assignedAuthor/assignedPerson/name/family}" />
								<given value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/author/assignedAuthor/assignedPerson/name/given}" />
								<prefix value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/author/assignedAuthor/assignedPerson/name/prefix}" />
							</name>
							<name>
								<text value="{$PRIOR_CONST}ORGANIZER_AUTHOR_ASSIGNEDAUTHOR_ASSIGNEDPERSON{$PRIOR_CONST}" />
							</name>
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/componentOf/encompassingEncounter/responsibleParty/assignedEntity">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/body-performer" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="body-performer" />

							<identifier>
								<system value="urn:oid:{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@root}" />
								<value value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@extension}" />
								<assigner>
									<display value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/componentOf/encompassingEncounter/responsibleParty/assignedEntity/addr" />
							</xsl:call-template>

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/componentOf/encompassingEncounter/responsibleParty/assignedEntity/telecom" />
							</xsl:call-template>

							<name>
								<family value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/componentOf/encompassingEncounter/responsibleParty/assignedEntity/assignedPerson/name/family}" />
								<given value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/componentOf/encompassingEncounter/responsibleParty/assignedEntity/assignedPerson/name/given}" />
							</name>
							<name>
								<text value="{$PRIOR_CONST}ORGANIZER_COMPONENTOF_ENCOMPASSINGENCOUNTER_RESPONSIBLEPARTY_ASSIGNEDENTITY{$PRIOR_CONST}" />
							</name>
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer">
				<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer">
					<xsl:variable name="index" select="position()"></xsl:variable>
					<xsl:for-each select="./specimen/specimenRole/specimenPlayingEntity">
						<entry>
							<fullUrl value="https://example.com/base/Specimen/body-specimen-entry-observation{$index}-{position()}" />
							<resource>
								<Specimen xmlns="http://hl7.org/fhir">
									<id value="body-specimen-entry-observation{$index}-{position()}" />

									<type>
										<coding>
											<system value="urn:oid:{./code/@codeSystem}" />
											<code value="{./code/@code}" />
											<display value="{./code/@displayName}" />
										</coding>
									</type>
								</Specimen>
							</resource>
						</entry>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:if>


			<!-- SPECIMEN ENTRY OBSERVATION -->
			<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/specimen/specimenRole/specimenPlayingEntity">
				<entry>
					<fullUrl value="https://example.com/base/Specimen/specimen-entry-observation{position()}" />
					<resource>
						<Specimen xmlns="http://hl7.org/fhir">
							<id value="specimen-entry-observation{position()}" />

							<type>
								<coding>
									<system value="urn:oid:{./code/@codeSystem}" />
									<code value="{./code/@code}" />
									<display value="{./code/@displayName}" />
								</coding>
							</type>

							<subject>
								<reference value="Patient/{$patientId}" />
							</subject>
						</Specimen>
					</resource>
				</entry>
			</xsl:for-each>

			<!-- SPECIMEN ENTRY ORGANIZER -->
			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer">
				<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer">
					<entry>
						<fullUrl value="https://example.com/base/Specimen/specimen-entry-organizer{position()}" />
						<resource>
							<Specimen xmlns="http://hl7.org/fhir">
								<id value="specimen-entry-organizer{position()}" />

								<type>
									<coding>
										<system value="urn:oid:{./specimen/specimenRole/specimenPlayingEntity/code/@codeSystem}" />
										<code value="{./specimen/specimenRole/specimenPlayingEntity/code/@code}" />
										<display value="{./specimen/specimenRole/specimenPlayingEntity/code/@displayName}" />
									</coding>
								</type>

								<subject>
									<reference value="Patient/{$patientId}" />
								</subject>
							</Specimen>
						</resource>
					</entry>
				</xsl:for-each>
			</xsl:if>
			<!-- HAS MEMBER OBSERVATION AUTHOR -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/organizer/author">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/author-has-member-observation{position()}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="author-has-member-observation{position()}" />

								<identifier>
									<system value="urn:oid:{./entry/act/entryRelationship/organizer/component/observation/author/assignedEntity/id/@root}" />
									<value value="{./entry/act/entryRelationship/organizer/component/observation/author/assignedEntity/id/@extension}" />
									<assigner>
										<display value="{./entry/act/entryRelationship/organizer/component/observation/author/assignedEntity/id/@assigningAuthorityName}" />
									</assigner>
								</identifier>
								<xsl:call-template name="show_address">
									<xsl:with-param name="cda_address" select="./entry/act/entryRelationship/organizer/component/observation/author/assignedEntity/addr" />
								</xsl:call-template>

								<xsl:call-template name="show_telecom">
									<xsl:with-param name="cda_telecom" select="./entry/act/entryRelationship/organizer/component/observation/author/assignedEntity/telecom" />
								</xsl:call-template>

								<name>
									<family value="{./entry/act/entryRelationship/organizer/component/observation/author/assignedEntity/assignedPerson/name/family}" />
									<given value="{./entry/act/entryRelationship/organizer/component/observation/author/assignedEntity/assignedPerson/name/given}" />
								</name>
								<name>
									<text value="{$PRIOR_CONST}COMPONENT_OBSERVATION_AUTHOR_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
								</name>
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- HAS MEMBER OBSERVATION PERFORMER -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/performer">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/performer-has-member-observation{position()}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="performer-has-member-observation{position()}" />

								<identifier>
									<system value="urn:oid:{./entry/act/entryRelationship/organizer/component/observation/performer/assignedEntity/id/@root}" />
									<value value="{./entry/act/entryRelationship/organizer/component/observation/performer/assignedEntity/id/@extension}" />
									<assigner>
										<display value="{./entry/act/entryRelationship/organizer/component/observation/performer/assignedEntity/id/@assigningAuthorityName}" />
									</assigner>
								</identifier>
								<xsl:call-template name="show_address">
									<xsl:with-param name="cda_address" select="../entry/act/entryRelationship/organizer/component/observation/performer/assignedEntity/addr" />
								</xsl:call-template>

								<xsl:call-template name="show_telecom">
									<xsl:with-param name="cda_telecom" select="./entry/act/entryRelationship/organizer/component/observation/performer/assignedEntity/telecom" />
								</xsl:call-template>

								<name>
									<family value="{./entry/act/entryRelationship/organizer/component/observation/performer/assignedEntity/assignedPerson/name/family}" />
									<given value="{./entry/act/entryRelationship/organizer/component/observation/performer/assignedEntity/assignedPerson/name/given}" />
								</name>
								<name>
									<text value="{$PRIOR_CONST}COMPONENT_OBSERVATION_PERFORMER_ASSIGNEDENTITY_ASSIGNEDPERSON{$PRIOR_CONST}" />
								</name>
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- OBSERVATION -->

			<!-- FOGLIA 1 -->
			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation">
				<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation">
					<entry>
						<fullUrl value="https://example.com/base/Observation/observation-act-section{position()}" />
						<resource>
							<Observation xmlns="http://hl7.org/fhir">
								<id value="observation-act-section{position()}" />

								<code>
									<coding>
										<code value="{./code/@code}" />
										<system value="urn:oid:{./code/@codeSystem}" />
										<version value="{./code/@codeSystemName}" />
										<display value="{./code/@displayName}" />
									</coding>
								</code>

								<xsl:if test="./code/translation">
									<xsl:for-each select="./code/translation">
										<coding>
											<system value="urn:oid:{./@codeSystem}" />
											<version value="{./@codeSystemName} V {./@codeSystemVersion}" />
											<code value="{./@code}" />
											<display value="{./@displayName}" />
										</coding>
									</xsl:for-each>
								</xsl:if>

								<subject>
									<reference value="Patient/{$patientId}" />
								</subject>

								<xsl:choose>
									<xsl:when test="./statusCode/@code = 'completed'">
										<status value="final" />
									</xsl:when>
									<xsl:otherwise>
										<status value="canceled" />
									</xsl:otherwise>
								</xsl:choose>

								<xsl:call-template name="show_date">
									<xsl:with-param name="cda_date" select="./effectiveTime/@value" />
									<xsl:with-param name="tag" select="'effectiveDateTime'" />
								</xsl:call-template>

								<valueQuantity>
									<value value="{./value/@value}" />
									<unit value="{./value/@unit}" />
								</valueQuantity>

								<xsl:if test="./interpretationCode">
									<interpretation>
										<coding>
											<code value="{./interpretationCode/@code}" />
											<system value="http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation" />
											<version value="{./interpretationCode/@codeSystemVersion}" />
										</coding>
									</interpretation>
								</xsl:if>

								<xsl:if test="./methodCode">
									<method>
										<coding>
											<code value="{./methodCode/@code}" />
											<system value="{./methodCode/@codeSystem}" />
											<version value=" {./methodCode/@codeSystemName} V {./methodCode/@codeSystemVersion}" />
											<display value="{./methodCode/@displayName}" />
										</coding>
									</method>
								</xsl:if>

								<xsl:if test="./specimen/specimenRole/specimenPlayingEntity">
									<specimen>
										<reference value="Specimen/specimen-entry-observation{position()}" />
									</specimen>
								</xsl:if>

								<xsl:if test="./performer">
									<perfomer>
										<reference value="Practitioner/{./performer/assignedEntity/id/@root}-{./performer/assignedEntity/id/@extension}{position()}" />
									</perfomer>
								</xsl:if>

								<xsl:if test="./author">
									<perfomer>
										<reference value="Practitioner/{./author/assignedEntity/id/@root}-{./author/assignedEntity/id/@extension}{position()}" />
									</perfomer>
								</xsl:if>

								<encounter>
									<reference value="Encounter/encounter" />
								</encounter>

								<note>
									<text value="{./entryRelationship/act/text}" />
								</note>

								<xsl:if test="./entryRelationship/observationMedia">
									<derivedFrom>
										<reference value="Media/observation-media" />
									</derivedFrom>
								</xsl:if>

								<xsl:if test="./referenceRange">
									<referenceRange>
										<low>
											<value value="{translate(./referenceRange/observationRange/value/low/@value, ' ', '')}" />
											<unit value="{./referenceRange/observationRange/value/low/@unit}" />
										</low>
										<high>
											<value value="{translate(./referenceRange/observationRange/value/high/@value, ' ', '')}" />
											<unit value="{./referenceRange/observationRange/value/high/@unit}" />
										</high>

										<appliesTo value="{./referenceRange/observationRange/precondition}" />
										<age value="{./referenceRange/observationRange/precondition/criterion/value}" />
									</referenceRange>
								</xsl:if>

							</Observation>
						</resource>
					</entry>
				</xsl:for-each>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/specimen">
				<specimen>
					<reference value="Specimen/entryRelationship-specimen" />
				</specimen>
			</xsl:if>
			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/procedure">
				<partOf>
					<reference value="Procedure/procedure" />
				</partOf>
			</xsl:if>

			<!-- FOGLIA 2 -->
			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer">

				<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer">
					<xsl:variable name="currentObservationIndex" select="position()" />
					<entry>
						<fullUrl value="https://example.com/base/Observation/observation-entry{$currentObservationIndex}" />
						<resource>
							<Observation xmlns="http://hl7.org/fhir">
								<id value="observation-entry{$currentObservationIndex}" />

								<code>
									<coding>
										<code value="{./code/@code}" />
										<system value="urn:oid:{./code/@codeSystem}" />
										<version value="{./code/@codeSystemName}" />
										<display value="{./code/@displayName}" />
									</coding>
								</code>

								<xsl:if test="./code/translation">
									<xsl:for-each select="./code/translation">
										<coding>
											<system value="urn:oid:{./@codeSystem}" />
											<version value="{./@codeSystemName} V {./@codeSystemVersion}" />
											<code value="{./@code}" />
											<display value="{./@displayName}" />
										</coding>
									</xsl:for-each>
								</xsl:if>

								<xsl:choose>
									<xsl:when test="./statusCode/@code = 'completed'">
										<status value="final" />
									</xsl:when>
									<xsl:otherwise>
										<status value="canceled" />
									</xsl:otherwise>
								</xsl:choose>

								<xsl:if test="./effectiveTime">
									<xsl:call-template name="show_date">
										<xsl:with-param name="cda_date" select="./effectiveTime/@value" />
										<xsl:with-param name="tag" select="'effectiveDateTime'" />
									</xsl:call-template>
								</xsl:if>

								<xsl:if test="./specimen/specimenRole">
									<specimen>
										<reference value="Specimen/specimen-entry-organizer{$currentObservationIndex}" />
									</specimen>
								</xsl:if>

								<xsl:if test="./performer">
									<perfomer>
										<reference value="Practitioner/{./assignedEntity/id/@root}-{./assignedEntity/id/@extension}" />
									</perfomer>
								</xsl:if>

								<xsl:if test="./author">
									<perfomer>
										<reference value="Practitioner/{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@root}-{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@extension}" />
									</perfomer>
								</xsl:if>

								<xsl:if test="./organizer/participant">
									<encounter>
										<reference value="Encounter/encounter" />
									</encounter>
								</xsl:if>

								<xsl:if test="./component/observation">
									<xsl:for-each select="./component/observation">
										<hasMember>
											<reference value="Observation/has-member-observation{$currentObservationIndex}-{position()}" />
										</hasMember>
									</xsl:for-each>
								</xsl:if>
							</Observation>
						</resource>
					</entry>
				</xsl:for-each>

			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/specimen">
				<xsl:variable name="object" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship"></xsl:variable>
				<entry>
					<fullUrl value="https://example.com/base/Specimen/entryRelationship-specimen" />
					<resource>
						<Specimen xmlns="http://hl7.org/fhir">
							<id value="entryRelationship-specimen" />

							<collection>
								<coding>
									<code value="{$object/code/@code}" />
									<system value="urn:oid:{$object/code/@codeSystem}" />
									<display value="{$object/code/@displayName}" />
									<version value="{$object/code/@codeSystemVersion}" />
								</coding>

								<identifier value="{./act/specimen/specimenRole/id}" />
								<collected>
									<xsl:call-template name="show_date">
										<xsl:with-param name="cda_date" select="$object/act/effectiveTime/@value" />
										<xsl:with-param name="tag" select="'effectiveDateTime'" />
									</xsl:call-template>
								</collected>

								<xsl:if test="$object/act/participant">
									<collector>
										<reference value="Practitioner/{$object/act/participant/assignedEntity/id/@root}-{$object/act/participant/assignedEntity/id/@extension}" />
									</collector>
								</xsl:if>
							</collection>
						</Specimen>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/act/participant">
				<xsl:variable name="participant" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/act/participant" />
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{$participant/assignedEntity/id/@root}-{$participant/assignedEntity/id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{$participant/assignedEntity/id/@root}-{$participant/assignedEntity/id/@extension}" />

							<identifier>
								<system value="urn:oid:{$participant/assignedEntity/id/@root}" />
								<value value="{$participant/assignedEntity/id/@extension}" />
								<assigner>
									<display value="{$participant/assignedEntity/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="$participant/assignedEntity/addr" />
							</xsl:call-template>

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="$participant/assignedEntity/telecom" />
							</xsl:call-template>

							<name>
								<family value="{$participant/assignedPerson/name/family}" />
								<given value="{$participant/assignedPerson/name/given}" />
							</name>
							<name>
								<text value="{$PRIOR_CONST}ACT_ENTRYRELATIONSHIP_ACT_PARTICIPANT_ASSIGNEDPERSON{$PRIOR_CONST}" />
							</name>
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/entryRelationship/observationMedia">
				<xsl:variable name="object" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/entryRelationship/observationMedia"></xsl:variable>
				<entry>
					<fullUrl value="https://example.com/base/Media/observation-media" />
					<resource>
						<Media xmlns="http://hl7.org/fhir">
							<id value="observation-media" />

							<content>
								<content value="{$object/value}" />
								<data value="{$object/value/representation/@value}" />
								<contentType value="{$object/value/mediaType/@value}" />
							</content>
						</Media>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/procedure">
				<xsl:variable name="object" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/procedure"></xsl:variable>
				<entry>
					<fullUrl value="https://example.com/base/Procedure/procedure" />
					<resource>
						<Procedure xmlns="http://hl7.org/fhir">
							<id value="procedure" />

							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="$object/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'performedDateTime'" />
							</xsl:call-template>

							<bodySite>
								<coding>
									<code value="{$object/targetSiteCode/@code}" />
									<system value="urn:oid:{$object/targetSiteCode/@codeSystem}" />
									<version value="{$object/targetSiteCode/@codeSystemVersion}" />
									<display value="{$object/targetSiteCode/@displayName}" />
								</coding>
							</bodySite>
						</Procedure>
					</resource>
				</entry>
			</xsl:if>

			<entry>
				<fullUrl value="https://example.com/base/DocumentReference/document-reference" />
				<resource>
					<DocumentReference xmlns="http://hl7.org/fhir">
						<id value="document-reference" />

						<masterIdentifier>
							<system value="urn:oid{id/@root}" />
							<value value="{id/@extension}" />
						</masterIdentifier>

						<securityLabel>
							<coding>
								<system value="http://terminology.hl7.org/CodeSystem/v3-Confidentiality" />
								<code value="{confidentialityCode/@code}" />
							</coding>
						</securityLabel>

						<subject>
							<reference value="Patient/{$patientId}" />
						</subject>

						<type>
							<coding>
								<system value="urn:oid:{code/@codeSystem}" />
								<code value="{code/@code}" />
							</coding>
						</type>

						<author>
							<reference value="Practitioner/{author/assignedAuthor/id/@root}-{author/assignedAuthor/id/@extension}" />
						</author>

						<xsl:if test="legalAuthenticator/assignedEntity/representedOrganization">
							<organization>
								<reference value="Organization/{legalAuthenticator/assignedEntity/representedOrganization/id/@root}-{legalAuthenticator/assignedEntity/representedOrganization/id/@extension}" />
							</organization>
						</xsl:if>

						<xsl:if test="custodian">
							<custodian>
								<xsl:variable name="sanitized-value">
									<xsl:call-template name="sanitize-oid">
										<xsl:with-param name="text" select="custodian/assignedCustodian/representedCustodianOrganization/id/@extension" />
									</xsl:call-template>
								</xsl:variable>
								<reference value="Organization/{custodian/assignedCustodian/representedCustodianOrganization/id/@root}-{$sanitized-value}" />
							</custodian>
						</xsl:if>

						<content>
							<format>
								<system value="urn:oid:{templateId/@root}" />
								<code value="{templateId/@extension}" />
							</format>
						</content>

						<context>
							<sourcePatientInfo>
								<reference value="Patient/{recordTarget/patientRole/id/@root}-{recordTarget/patientRole/id/@extension}" />
							</sourcePatientInfo>
							<related>
								<reference value="Composition/composition" />
							</related>
						</context>
					</DocumentReference>
				</resource>
			</entry>

		</Bundle>

	</xsl:template>

	<xsl:template name="code_enum">
		<xsl:param name="code" />

		<xsl:choose>
			<xsl:when test="$code = 'PRE'">
				<code value="{$code}"></code>
				<display value="Prenotatore"></display>
			</xsl:when>

			<xsl:when test="$code = 'RIC'">
				<code value="{$code}"></code>
				<display value="Richiedente"></display>
			</xsl:when>

			<xsl:when test="$code = 'PCP'">
				<code value="{$code}"></code>
				<display value="primary care physician"></display>
			</xsl:when>

			<xsl:when test="$code = 'ATTPHYS'">
				<code value="{$code}"></code>
				<display value="attending physician"></display>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="sanitize-oid">
		<xsl:param name="text" />
		<xsl:choose>
			<xsl:when test="contains($text, '@')">
				<xsl:value-of select="substring-before($text,'@')" />
				<xsl:value-of select="''" />
				<xsl:call-template name="sanitize-oid">
					<xsl:with-param name="text" select="substring-after($text,'@')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="show_date">
		<xsl:param name="cda_date" />
		<xsl:param name="tag" />

		<xsl:variable name="fhir_date">
			<xsl:choose>
				<xsl:when test="substring($cda_date, 18, 2)">
					<xsl:value-of select="concat(substring($cda_date, 1, 4), '-', substring($cda_date, 5, 2), '-', substring($cda_date, 7, 2), 'T', substring($cda_date, 9, 2), ':', substring($cda_date, 11, 2), ':', substring($cda_date, 13, 2), substring($cda_date, 15, 3), ':', substring($cda_date, 18, 2))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat(substring($cda_date, 1, 4), '-', substring($cda_date, 5, 2), '-', substring($cda_date, 7, 2), 'T', substring($cda_date, 9, 2), ':', substring($cda_date, 11, 2), ':', substring($cda_date, 13, 2), substring($cda_date, 15, 3))" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$tag='lastUpdated'">
			<lastUpdated value="{$fhir_date}" />
		</xsl:if>

		<xsl:if test="$tag='start'">
			<start value="{$fhir_date}" />
		</xsl:if>

		<xsl:if test="$tag='performedDateTime'">
			<performedDateTime value="{$fhir_date}" />
		</xsl:if>

		<xsl:if test="$tag='effectiveDateTime'">
			<effectiveDateTime value="{$fhir_date}" />
		</xsl:if>

		<xsl:if test="$tag='time'">
			<time value="{$fhir_date}" />
		</xsl:if>

		<xsl:if test="$tag='date'">
			<date value="{$fhir_date}" />
		</xsl:if>

		<xsl:if test="$tag='timestamp'">
			<timestamp value="{$fhir_date}" />
		</xsl:if>

	</xsl:template>

	<xsl:template name="show_telecom">
		<xsl:param name="cda_telecom" />

		<xsl:for-each select="$cda_telecom">
			<telecom>
				<xsl:if test="starts-with(./@value, 'tel')">
					<system value="phone" />
					<value value="{substring-after(./@value, ':')}" />
					<xsl:if test="./@use='HP'">
						<use value="home" />
					</xsl:if>
					<xsl:if test="./@use='WP'">
						<use value="work" />
					</xsl:if>
					<xsl:if test="./@use='MC'">
						<use value="mobile" />
					</xsl:if>
				</xsl:if>
				<xsl:if test="starts-with(./@value, 'mail')">
					<system value="email" />
					<value value="{substring-after(./@value, ':')}" />
					<xsl:if test="./@use='HP'">
						<use value="home" />
					</xsl:if>
					<xsl:if test="./@use='WP'">
						<use value="work" />
					</xsl:if>
					<xsl:if test="./@use='MC'">
						<use value="mobile" />
					</xsl:if>
				</xsl:if>
			</telecom>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="show_address">
		<xsl:param name="cda_address" />

		<xsl:for-each select="$cda_address">
			<address>
				<xsl:if test="./country">
					<country value="{./country}" />
				</xsl:if>

				<xsl:if test="./state">
					<state value="{./state}" />
				</xsl:if>

				<xsl:if test="./county">
					<district value="{./county}" />
				</xsl:if>

				<xsl:if test="./city">
					<city value="{./city}" />
				</xsl:if>

				<xsl:if test="./censusTract">
					<extension>
						<address>
							<line value="{./censusTract}" />
						</address>
					</extension>
				</xsl:if>

				<xsl:if test="./postalCode">
					<postalCode value="{./postalCode}" />
				</xsl:if>

				<xsl:if test="./streetAddressLine">
					<line value="{./streetAddressLine}" />
				</xsl:if>

				<xsl:if test="./@use='HP'">
					<use value="home" />
				</xsl:if>
				<xsl:if test="./@use='H'">
					<use value="home" />
				</xsl:if>
			</address>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="show_gender">
		<xsl:param name="cda_gender" />
		<xsl:if test="$cda_gender = 'M'">
			<gender value="male" />
		</xsl:if>
		<xsl:if test="$cda_gender = 'F'">
			<gender value="female" />
		</xsl:if>
		<xsl:if test="$cda_gender = 'UN'">
			<gender value="unknown" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="show_birthDate">
		<xsl:param name="cda_birthDate" />
		<birthDate value="{concat(substring($cda_birthDate, 1, 4), '-', substring($cda_birthDate, 5, 2), '-', substring($cda_birthDate, 7, 2))}" />
	</xsl:template>

	<!-- Trim both sides of the String -->
	<xsl:variable name="whitespaceCharacters" select="'&#09;&#10;&#13; '" />

	<!-- Trim Right side of the String -->
	<xsl:template name="TrimRight">
		<xsl:param name="input" />
		<xsl:param name="trim" select="$whitespaceCharacters" />

		<xsl:variable name="length" select="string-length($input)" />
		<xsl:if test="string-length($input) &gt; 0">
			<xsl:choose>
				<xsl:when test="contains($trim, substring($input, $length, 1))">
					<xsl:call-template name="TrimRight">
						<xsl:with-param name="input" select="substring($input, 1, $length - 1)" />
						<xsl:with-param name="trim" select="$trim" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$input" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- Trim Left side of the String -->
	<xsl:template name="TrimLeft">
		<xsl:param name="input" />
		<xsl:param name="trim" select="$whitespaceCharacters" />

		<xsl:if test="string-length($input) &gt; 0">
			<xsl:choose>
				<xsl:when test="contains($trim, substring($input, 1, 1))">
					<xsl:call-template name="TrimLeft">
						<xsl:with-param name="input" select="substring($input, 2)" />
						<xsl:with-param name="trim" select="$trim" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$input" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- Trim both sides of the String -->
	<xsl:template name="Trim">
		<xsl:param name="input" />
		<xsl:param name="trim" select="$whitespaceCharacters" />
		<xsl:call-template name="TrimRight">
			<xsl:with-param name="input">
				<xsl:call-template name="TrimLeft">
					<xsl:with-param name="input" select="$input" />
					<xsl:with-param name="trim" select="$trim" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="trim" select="$trim" />
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>