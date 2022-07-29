<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:strip-space elements="*" />
	<xsl:template match="/ClinicalDocument">
		<Bundle xmlns="http://hl7.org/fhir">
			<id value="father" />
			<meta>
				<profile value="http://ihe.net/fhir/tag/iti-65" />
			</meta>
			<language value="{realmCode/@code}" />
			<implicitRules value="{typeId/@root}" />
			<identifier>
				<system value="urn:oid:{id/@root}" />
				<value value="{id/@extension}" />
				<assigner>
					<display value="{id/@assigningAuthorityName}"></display>
				</assigner>
			</identifier>
			<type value="transaction" />

			<!-- COMPOSITION -->
			<entry>
				<resource>
					<Composition xmlns="http://hl7.org/fhir">
						<id value="composition" />
 
						<type>
							<coding>
								<system value="urn:oid:{code/@codeSystem}" />
								<version value="{code/@codeSystemName} V {code/@codeSystemVersion}" />
								<code value="{code/@code}" />
								<display value="{code/@displayName}" />
							</coding>
							<xsl:if test="code/translation">
								<xsl:for-each select="code/translation">
									<coding>
										<system value="urn:oid:{./@codeSystem}" />
										<version value="{./@codeSystemName} V {./@codeSystemVersion}" />
										<code value="{./@code}" />
									</coding>
								</xsl:for-each>
							</xsl:if>
						</type>
						
						<title value="{title}" />
						<language value="{languageCode/@code}" />
						
						<xsl:choose>
							<xsl:when test="statusCode/@code = 'completed'">
								<status value="final" />
							</xsl:when>
							<xsl:otherwise>
								<status value="preliminary" />
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
							<reference value="Patient/{recordTarget/patientRole/id/@root}|{recordTarget/patientRole/id/@extension}" />
						</subject>

						<author>
							<reference value="Practitioner/{author/assignedAuthor/id/@root}|{author/assignedAuthor/id/@extension}" />
						</author>

						<xsl:call-template name="show_date">
							<xsl:with-param name="cda_date" select="author/time/@value" />
							<xsl:with-param name="tag" select="'date'" />
						</xsl:call-template>

						<xsl:if test="author/assignedAuthor/representedOrganization">
							<attester>
								<party>
									<reference value="Organization/{author/assignedAuthor/representedOrganization/id/@root}|{author/assignedAuthor/representedOrganization/id/@extension}" />
								</party>
							</attester>
						</xsl:if>

						<xsl:if test="dataEnterer">
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="dataEnterer/time/@value" />
								<xsl:with-param name="tag" select="'date'" />
							</xsl:call-template>
							<author>
								<reference value="Practitioner/{dataEnterer/assignedEntity/id/@root}|{dataEnterer/assignedEntity/id/@extension}" />
							</author>
						</xsl:if>

						<xsl:if test="custodian">
							<custodian>
								<reference value="Organization/{custodian/assignedCustodian/representedCustodianOrganization/id/@root}|{custodian/assignedCustodian/representedCustodianOrganization/id/@extension}" />
							</custodian>
						</xsl:if>

						<xsl:if test="informationRecipient">
							<attester>
								<party>
									<xsl:choose>
										<xsl:when test="informationRecipient/intendedRecipient/informationRecipient">
											<reference value="Practitioner/{informationRecipient/intendedRecipient/id/@root}|{informationRecipient/intendedRecipient/id/@extension}" />
										</xsl:when>
										<xsl:when test="informationRecipient/intendedRecipient/receivedOrganization">
											<reference value="Organization/{informationRecipient/intendedRecipient/receivedOrganization/id/@root}|{informationRecipient/intendedRecipient/receivedOrganization/id/@extension}" />
										</xsl:when>
									</xsl:choose>
								</party>
							</attester>
						</xsl:if>

						<attester>
							<xsl:if test="legalAuthenticator/signatureCode/@code='S'">
								<mode value="legal" />
							</xsl:if>
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
								<xsl:if test="authenticator/signatureCode/@code='S'">
									<mode value="professional" />
								</xsl:if>
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
											<system value="urn:oid:{documentationOf/serviceEvent/code/@codeSystem}"/>
										</xsl:if>
										<code value="{documentationOf/serviceEvent/code/@code}"/>
										<version value="{documentationOf/serviceEvent/code/@displaySystemVersion}"/>
										<display value="{documentationOf/serviceEvent/code/@displayName}"/>
									</coding>
								</xsl:if>
								<extension>
									<event>
										<id value="{documentationOf/serviceEvent/id}"/>
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

						<xsl:if test="componentOf/encompassingEncounter">
							<encounter>
								<reference value="Encounter/encompassing-encounter" />
							</encounter>
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
								<title value="{component/structuredBody/component/section/title}" />
							</xsl:if>

							<xsl:if test="component/structuredBody/component/section/text">
								<text value="{component/structuredBody/component/section/text}" />
							</xsl:if>

							<xsl:choose>
								<xsl:when test="component/structuredBody/component/section/component/section">
									<xsl:for-each select="component/structuredBody/component/section/component/section">
										<code>
											<coding>
												<code value="{./code/@code}" />
												<system value="urn:oid:{./code/@codeSystem}" />
												<version value="{./code/@version}" />
												<display value="{./code/@displayName}" />
											</coding>
										</code>
			
										<xsl:for-each select="./code/translation">
											<coding>
												<code value="{./@code}" />
												<system value="urn:oid:{./@codeSystem}" />
												<version value="{./@codeSystemName}" />
												<display value="{./@displayName}" />
											</coding>
										</xsl:for-each>

										<title value="./title" />
										<text value="./text"/>
										<entry>
											<reference value="DiagnosticReport/diagnostic-report-entry{position()}" />
										</entry>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<entry>

									</entry>
								</xsl:otherwise>
							</xsl:choose>
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
								<value value="{relatedDocument/parentDocument/id/@extension}"/>
							</identifier>
							<xsl:if test="relatedDocument/parentDocument/setId">
								<identifier>
									<system value="urn:oid:{relatedDocument/parentDocument/setId/@root}"/>
									<value value="{relatedDocument/parentDocument/setId/@extension}"/>
								</identifier>
							</xsl:if>
							<extension>
								<composition-clinicaldocument-versionNumber value="{relatedDocument/parentDocument/versionNumber/@value}" />
							</extension>
						</Composition>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="componentOf/encompassingEncounter">
				<entry>
					<resource>
						<Encounter xmlns="http://hl7.org/fhir">
							<id value="encompassing-encounter" />

							<xsl:if test="componentOf/encompassingEncounter/id">
								<identifier>
									<system value="urn:oid:{componentOf/encompassingEncounter/id/@root}" />
									<value value="{componentOf/encompassingEncounter/id/@extension}" />
									<assigner>
										<display value="{componentOf/encompassingEncounter/id/@assiginingAuthorityName}" />
									</assigner>
								</identifier>
							</xsl:if>

							<class>
								<coding>
									<code value="{componentOf/encompassingEncounter/code/@code}" />
									<system value="urn:oid:{componentOf/encompassingEncounter/code/@codeSystem}" />
									<version value="{componentOf/encompassingEncounter/code/@displaySystemVersion}" />
									<display value="{componentOf/encompassingEncounter/code/@displayName}" />
								</coding>
							</class>

							<period>
								<xsl:call-template name="show_date">
									<xsl:with-param name="cda_date" select="componentOf/encompassingEncounter/effectiveTime/@value" />
									<xsl:with-param name="tag" select="'start'" />
								</xsl:call-template>
							</period>

							<xsl:if test="componentOf/encompassingEncounter/responsibleParty">
								<participant>
									<individual>
										<reference value="PractitionerRole/practitioner-role-responsible-party" />
									</individual>
								</participant>
							</xsl:if>

							<xsl:if test="componentOf/encompassingEncounter/location">
								<location>
									<reference value="Location/location-encompassing-encounter" />
								</location>
							</xsl:if>
						</Encounter>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="componentOf/encompassingEncounter/location/healthCareFacility">
				<entry>
					<resource>
						<Location xmlns="http://hl7.org/fhir">
							<id value="location-encompassing-encounter" />
 
							<identifier>
								<system value="urn:oid:{componentOf/encompassingEncounter/location/healthCareFacility/id/@root}" />
								<value value="{componentOf/encompassingEncounter/location/healthCareFacility/id/@extension}" />
							</identifier>

							<partOf>
								<reference value="Location/facility-location" />
							</partOf>

							<managingOrganization>
								<reference value="Organization/{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@root}|{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@extension}" />
							</managingOrganization>
						</Location>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@root}|{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@root}|{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/id/@extension}" />
							 
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
									<reference value="Organization/{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@root}|{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@extension}" />
								</partOf>
							</xsl:if>

						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@root}|{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@root}|{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@extension}" />
							 
							<identifier>
								<system value="urn:oid:{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@root}" />
								<value value="{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@extension}" />
								<assigner>
									<display value="{componentOf/encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/asOrganizationPartOf/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="componentOf/encompassingEncounter/location/healthCareFacility">
				<entry>
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
					<resource>
						<PractitionerRole xmlns="http://hl7.org/fhir">
							<id value="practitioner-role-responsible-party" />
 	
							<xsl:if test="componentOf/encompassingEncounter/responsibleParty/assignedEntity">
								<practitioner>
									<reference value="Practitioner/{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@root}|{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@extension}" />
								</practitioner>
							</xsl:if>

							<code value="{componentOf/encompassingEncounter/responsibleParty/assignedEntity/code/@code}" />
						</PractitionerRole>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="componentOf/encompassingEncounter/responsibleParty/assignedEntity">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@root}|{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@root}|{componentOf/encompassingEncounter/responsibleParty/assignedEntity/id/@extension}" />
							 
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
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<!-- PATIENT -->
			<xsl:variable name="patientId" select="concat(recordTarget/patientRole/id/@root, '|', recordTarget/patientRole/id/@extension)" />
			<entry>
				<fullUrl value="https://example.com/base/Patient/{recordTarget/patientRole/id/@root}|{recordTarget/patientRole/id/@extension}" />
				<resource>
					<Patient xmlns="http://hl7.org/fhir">
						<id value="{recordTarget/patientRole/id/@root}|{recordTarget/patientRole/id/@extension}" />
						 
						<identifier>
							<system value="urn:oid:{recordTarget/patientRole/id/@root}" />
							<value value="{recordTarget/patientRole/id/@extension}" />
							<assigner>
								<display value="{recordTarget/patientRole/id/@assigingAuthorityName}" />
							</assigner>
						</identifier>

						<xsl:call-template name="show_address">
							<xsl:with-param name="cda_address" select="recordTarget/patientRole/addr" />
						</xsl:call-template>

						<xsl:for-each select="recordTarget/patientRole/telecom">
							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="./telecom" />
							</xsl:call-template>
						</xsl:for-each>

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
							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="recordTarget/patientRole/patient/birthplace/place/addr" />
							</xsl:call-template>
						</extension>

						<xsl:if test="recordTarget/patientRole/patient/guardian">
							<contact>
								<name>
									<family value="{recordTarget/patientRole/patient/guardian/guardianPerson/name/family}"></family>
									<given value="{recordTarget/patientRole/patient/guardian/guardianPerson/name/given}"></given>
								</name>
								<xsl:if test="recordTarget/patientRole/patient/guardian/guardianOrganization">
									<organization>
										<reference value="Organization/{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@root}|{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@extension}" />
									</organization>
								</xsl:if>
							</contact>
							<xsl:if test="recordTarget/patientRole/providerOrganization">
								<managingOrganization>
									<reference value="Organization/{recordTarget/patientRole/providerOrganization/id/@root}|{recordTarget/patientRole/providerOrganization/id/@extension}" />
								</managingOrganization>
							</xsl:if>
						</xsl:if>
					</Patient>
				</resource>
			</entry>

			<!-- ATTESTER ORGANIZATION -->
			<xsl:if test="author/assignedAuthor/representedOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{author/assignedAuthor/representedOrganization/id/@root}|{author/assignedAuthor/representedOrganization/id/@extension}" />
					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{author/assignedAuthor/representedOrganization/id/@root}|{author/assignedAuthor/representedOrganization/id/@extension}" />
							
							<identifier>
								<system value="urn:oid:{author/assignedAuthor/representedOrganization/id/@root}" />
								<value value="{author/assignedAuthor/representedOrganization/id/@extension}" />
							</identifier>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- DATA ENTERER -->
			<xsl:if test="dataEnterer/assignedEntity">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{dataEnterer/assignedEntity/id/@root}|{dataEnterer/assignedEntity/id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{dataEnterer/assignedEntity/id/@root}|{dataEnterer/assignedEntity/id/@extension}" />
							 
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
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<!-- PROVIDER ORGANIZATION -->
			<xsl:if test="recordTarget/patientRole/providerOrganization">
				<entry>
					
					<fullUrl value="https://example.com/base/Organization/{recordTarget/patientRole/providerOrganization/id/@root}|{recordTarget/patientRole/providerOrganization/id/@extension}" />
					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{recordTarget/patientRole/providerOrganization/id/@root}|{recordTarget/patientRole/providerOrganization/id/@extension}" />
							 
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
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- GUARDIAN ORGANIZATION -->
			<xsl:if test="recordTarget/patientRole/patient/guardian/guardianOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@root}|{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@root}|{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@extension}" />
 
							<identifier>
								<system value="urn:oid:{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@root}" />
								<value value="{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@extension}" />
								<assigner>
									<display value="{recordTarget/patientRole/patient/guardian/guardianOrganization/id/@assigningAuthorityName}"></display>
								</assigner>
							</identifier>
							<name value="{recordTarget/patientRole/patient/guardian/guardianOrganization/@name}" />
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- PRACTITIONER INFORMATION RECIPIENT -->
			<xsl:if test="informationRecipient/intendedRecipient/informationRecipient">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{informationRecipient/intendedRecipient/id/@root}|{informationRecipient/intendedRecipient/id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{informationRecipient/intendedRecipient/id/@root}|{informationRecipient/intendedRecipient/id/@extension}" />
							 
							<xsl:if test="informationRecipient/intendedRecipient/id">
								<identifier>
									<system value="urn:oid:{informationRecipient/intendedRecipient/id/@root}" />
									<value value="{informationRecipient/intendedRecipient/id/@extension}" />
									<assigner>
										<display value="{informationRecipient/intendedRecipient/informationRecipient/id/@assigningAuthorityName}" />
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
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<!-- RECEIVED ORGANIZATION -->
			<xsl:if test="informationRecipient/intendedRecipient/receivedOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{informationRecipient/intendedRecipient/receivedOrganization/id/@root}|{informationRecipient/intendedRecipient/receivedOrganization/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{informationRecipient/intendedRecipient/receivedOrganization/id/@root}|{informationRecipient/intendedRecipient/receivedOrganization/id/@extension}" />
							 
							<identifier>
								<system value="urn:oid:{informationRecipient/intendedRecipient/receivedOrganization/id/@root}" />
								<value value="{informationRecipient/intendedRecipient/receivedOrganization/id/@extension}" />
							</identifier>
							<name value="{informationRecipient/intendedRecipient/receivedOrganization/@name}" />

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="informationRecipient/intendedRecipient/receivedOrganization/telecom" />
							</xsl:call-template>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="informationRecipient/intendedRecipient/receivedOrganization/addr" />
							</xsl:call-template>

						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- AUTHOR -->
			<entry>
				<fullUrl value="https://example.com/base/Practitioner/{author/assignedAuthor/id/@root}|{author/assignedAuthor/id/@extension}" />
				<resource>
					<Practitioner xmlns="http://hl7.org/fhir">
						<id value="{author/assignedAuthor/id/@root}|{author/assignedAuthor/id/@extension}" />
 
						<identifier>
							<system value="urn:oid:{author/assignedAuthor/id/@root}" />
							<value value="{author/assignedAuthor/id/@extension}" />
							<assigner>
								<display value="{author/assignedAuthor/id/@assigningAutorithyName}" />
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

					</Practitioner>
				</resource>
			</entry>
 
 			<!-- ENCOUNTER ORGANIZATION -->
			<xsl:for-each select="participant/associatedEntity/scopingOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{./id/@root}|{./id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{./id/@root}|{./id/@extension}" />

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
						</Organization>
					</resource>
				</entry>
			</xsl:for-each>
 

			<!-- CUSTODIAN -->
			<xsl:if test="custodian">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{custodian/assignedCustodian/representedCustodianOrganization/id/@root}|{custodian/assignedCustodian/representedCustodianOrganization/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{custodian/assignedCustodian/representedCustodianOrganization/id/@root}|{custodian/assignedCustodian/representedCustodianOrganization/id/@extension}" />
							 
							<identifier>
								<system value="urn:oid:{custodian/assignedCustodian/representedCustodianOrganization/id/@root}" />
								<value value="{custodian/assignedCustodian/representedCustodianOrganization/id/@extension}" />
								<assigner>
									<display value="{custodian/assignedCustodian/representedCustodianOrganization/id/@assigningAuthorityName}"/>
								</assigner>
							</identifier>
							<name value="{custodian/assignedCustodian/representedCustodianOrganization/name}" />

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="custodian/assignedCustodian/representedCustodianOrganization/telecom" />
							</xsl:call-template>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="custodian/assignedCustodian/representedCustodianOrganization/addr" />
							</xsl:call-template>

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
							<reference value="Practitioner/{legalAuthenticator/assignedEntity/id/@root}|{legalAuthenticator/assignedEntity/id/@extension}" />
						</practitioner>
						<xsl:if test="legalAuthenticator/assignedEntity/representedOrganization">
							<organization>
								<reference value="Organization/{legalAuthenticator/assignedEntity/representedOrganization/id/@root}|{legalAuthenticator/assignedEntity/representedOrganization/id/@extension}" />
							</organization>
						</xsl:if>
					</PractitionerRole>
				</resource>
			</entry>

			<!-- LEGAL AUTHOR ORGANIZATION -->
			<xsl:if test="legalAuthenticator/assignedEntity/representedOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{legalAuthenticator/assignedEntity/representedOrganization/id/@root}|{legalAuthenticator/assignedEntity/representedOrganization/id/@extension}" />
					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{legalAuthenticator/assignedEntity/representedOrganization/id/@root}|{legalAuthenticator/assignedEntity/representedOrganization/id/@extension}" />
							 
							<identifier>
								<system value="urn:oid:{legalAuthenticator/assignedEntity/representedOrganization/id/@root}" />
								<value value="{legalAuthenticator/assignedEntity/representedOrganization/id/@extension}" />
							</identifier>
							<name value="{legalAuthenticator/assignedEntity/representedOrganization/id/@assigningAuthorityName}" />
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- AUTHENTICATOR PRACTITIONER ROLE -->
			<xsl:if test="authenticator">
				<entry>
					<resource>
						<PractitionerRole xmlns="http://hl7.org/fhir">
							<id value="practitioner-role-authenticator" />
 
							<practitioner>
								<reference value="Practitioner/{authenticator/assignedEntity/id/@root}|{authenticator/assignedEntity/id/@extension}" />
							</practitioner>

							<xsl:if test="authenticator/assignedEntity/representedOrganization">
								<organization>
									<reference value="Organization/{authenticator/assignedEntity/representedOrganization/id/@root}|{authenticator/assignedEntity/representedOrganization/id/@extension}" />
								</organization>
							</xsl:if>
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
								<reference value="Practitioner/{documentationOf/serviceEvent/performer/assignedEntity/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/id/@extension}" />
							</practitioner>

							<xsl:if test="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization">
								<organization>
									<reference value="Organization/{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@extension}" />
								</organization>
							</xsl:if>

						</PractitionerRole>
					</resource>
				</entry>

			</xsl:if>

			<!-- AUTHENTICATOR PRACTITIONER -->
			<xsl:if test="authenticator/assignedEntity/assignedPerson">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{authenticator/assignedEntity/id/@root}|{authenticator/assignedEntity/id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{authenticator/assignedEntity/id/@root}|{authenticator/assignedEntity/id/@extension}" />
							 
							<identifier>
								<system value="urn:oid:{authenticator/assignedEntity/id/@root}" />
								<value value="{authenticator/assignedEntity/id/@extension}" />
								<assigner>
									<display value="{authenticator/assignedEntity/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>

							<xsl:call-template name="show_address">
								<xsl:with-param name="cda_address" select="assignedEntity/addr" />
							</xsl:call-template>

							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="assignedEntity/telecom" />
							</xsl:call-template>

							<name>
								<family value="{authenticator/assignedEntity/assignedPerson/name/family}" />
								<given value="{authenticator/assignedEntity/assignedPerson/name/given}" />
								<prefix value="{authenticator/assignedEntity/assignedPerson/name/prefix}" />
							</name>
							
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<!-- PERFORMER PRACTITIONER -->
			<xsl:if test="documentationOf/serviceEvent/performer">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{documentationOf/serviceEvent/performer/assignedEntity/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{documentationOf/serviceEvent/performer/assignedEntity/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/id/@extension}" />
							 
							<identifier>
								<system value="urn:oid:{documentationOf/serviceEvent/performer/assignedEntity/id/@root}" />
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

						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<!-- AUTHENTICATOR ORGANIZATION -->
			<xsl:if test="authenticator/assignedEntity/representedOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{authenticator/assignedEntity/representedOrganization/id/@root}|{authenticator/assignedEntity/representedOrganization/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{authenticator/assignedEntity/representedOrganization/id/@root}|{authenticator/assignedEntity/representedOrganization/id/@extension}" />
						 
							<identifier>
								<system value="urn:oid:{authenticator/assignedEntity/representedOrganization/id/@root}" />
								<value value="{authenticator/assignedEntity/representedOrganization/id/@extension}" />
							</identifier>
							<name value="{authenticator/assignedEntity/representedOrganization/id/@assigningAuthorityName}" />
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- REPRESENTED ORGANIZATION PERFORMER -->
			<xsl:if test="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@extension}" />
					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@extension}" />
							 
							<identifier>
								<system value="urn:oid:{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/id/@root}" />
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
									<reference value="Organization/{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@extension}" />
								</partOf>
							</xsl:if>
						</Organization>

					</resource>
				</entry>
			</xsl:if>

			<!-- LEGAL AUTHOR PRACTITIONER -->
			<entry>
				<fullUrl value="https://example.com/base/Practitioner/{legalAuthenticator/assignedEntity/id/@root}|{legalAuthenticator/assignedEntity/id/@extension}" />
				<resource>
					<Practitioner xmlns="http://hl7.org/fhir">
						<id value="{legalAuthenticator/assignedEntity/id/@root}|{legalAuthenticator/assignedEntity/id/@extension}" />
						 
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

					</Practitioner>
				</resource>
			</entry>

			<!-- FULLFILLMENT ENCOUNTER -->
			<xsl:for-each select="inFulfillmentOf">
				<entry>
					<resource>
						<ServiceRequest xmlns="http://hl7.org/fhir">
							<id value="service-request{position()}" />
							 
							<identifier>
								<system value="urn:oid:{./order/id/@root}" />
								<value value="{./order/id/@extension}" />
								<assigner>
									<display value="{./order/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>
							<priority value="{./order/priorityCode/@displayName}" />
						</ServiceRequest>
					</resource>
				</entry>
			</xsl:for-each>
		
			<xsl:if test="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@extension}" />
							 
							<identifier>
								<system value="urn:oid:{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@root}" />
								<value value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@extension}" />
								<assigner>
									<display value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>

							<xsl:if test="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization">
								<partOf>
									<reference value="Organization/{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@extension}" />
								</partOf>
							</xsl:if>
						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization">
				<entry>
					<fullUrl value="https://example.com/base/Organization/{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@extension}" />

					<resource>
						<Organization xmlns="http://hl7.org/fhir">
							<id value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@root}|{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@extension}" />
							 
							<identifier>
								<system value="urn:oid:{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@root}" />
								<value value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@extension}" />
								<assigner>
									<display value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/id/@assigningAuthorityName}" />
								</assigner>
							</identifier>

							<name value="{documentationOf/serviceEvent/performer/assignedEntity/representedOrganization/asOrganizationPartOf/wholeOrganization/name}" />

						</Organization>
					</resource>
				</entry>
			</xsl:if>

			<!-- ENCOUNTER PRACTITIONER ROLE -->
			<xsl:for-each select="participant">
				<entry>
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

							<xsl:if test="./associatedEntity">
								<practitioner>
									<reference value="Practitioner/{./associatedEntity/id/@root}|{./associatedEntity/id/@extension}" />
								</practitioner>
							</xsl:if>

							<xsl:if test="./associatedEntity/scopingOrganization">
								<organization>
									<reference value="Organization/{./associatedEntity/scopingOrganization/id/@root}|{./associatedEntity/scopingOrganization/id/@extension}" />
								</organization>
							</xsl:if>
						</PractitionerRole>
					</resource>
				</entry>
			</xsl:for-each>

			<!-- ENCOUNTER PRACTITIONER ROLE -->
			<entry>
				<resource>
					<Encounter xmlns="http://hl7.org/fhir">
						<id value="encounter" />
						 
						<xsl:for-each select="participant">
							<participant>
								<type>
									<coding>
										<display value="{./@typeCode}" />
									</coding>
								</type>

								<individual>
									<reference value="PractitionerRole/practitioner-role-encounter{position()}" />
								</individual>
								<period>
									<xsl:call-template name="show_date">
										<xsl:with-param name="cda_date" select="./time/@value" />
										<xsl:with-param name="tag" select="'start'" />
									</xsl:call-template>
								</period>
							</participant>
						</xsl:for-each>
						<basedOn>
							<xsl:for-each select="inFulfillmentOf">
								<reference value="ServiceRequest/service-request{position()}" />
							</xsl:for-each>
						</basedOn>
					</Encounter>
				</resource>
			</entry>

			<!-- ENCOUNTER PRACTITIONER -->
			<xsl:for-each select="participant/associatedEntity">
				<entry>
					<fullUrl value="https://example.com/base/Practitioner/{./id/@root}|{./id/@extension}" />
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{./id/@root}|{./id/@extension}" />
							 
							<xsl:if test="./id">
								<identifier>
									<xsl:if test="./id">
										<system value="urn:oid:{./id/@root}" />
									</xsl:if>
									<value value="{./id/@extension}" />
									<assigner>
										<display value="{./id/@assigningAuthorityName}" />
									</assigner>
								</identifier>
							</xsl:if>

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
						</Practitioner>
					</resource>
				</entry>
			</xsl:for-each>

			<!-- DIAGNOSTIC REPORT ENTRY -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:variable name="sectionIndex" select="position()" />
				<entry>
					<resource>
						<DiagnosticReport xmlns="http://hl7.org/fhir">
							<id value="diagnostic-report-entry{position()}" />
 
							<code>
								<coding>
									<code value="{./entry/act/code/@code}" />
									<system value="urn:oid:{./entry/act/code/@codeSystem}" />
									<version value="{./entry/act/code/@version}" />
									<display value="{./entry/act/code/@displayName}" />
								</coding>
							</code>

							<xsl:if test="./entry/act/statusCode = 'completed'">
								<status value="final" />
							</xsl:if>
							<xsl:if test="./entry/act/statusCode = 'active'">
								<status value="partial" />
							</xsl:if>
							<xsl:if test="./entry/act/statusCode = 'aborted'">
								<status value="canceled" />
							</xsl:if>

							<xsl:for-each select="./entry/act/specimen">
								<specimen>
									<reference value="Specimen/specimen-diagnostic-entry{$sectionIndex}_{position()}" />
								</specimen>
							</xsl:for-each>

							<xsl:if test="./component/section/entry/act/performer">
								<perfomer>
									<reference value="Practitioner/performer-sub-contractor{$sectionIndex}" />
								</perfomer>
							</xsl:if>

							<xsl:if test="./component/section/entry/act/author">
								<perfomer>
									<reference value="Practitioner/{./component/section/entry/act/author/assignedEntity/id/@root}|{./component/section/entry/act/author/assignedEntity/id/@extension}{$sectionIndex}" />
								</perfomer>
							</xsl:if>

							<encounter>
								<reference value="Encounter/encounter-act-section{$sectionIndex}" />
							</encounter>

							<xsl:if test="./entry/act/entryRelationship/observation">
								<xsl:for-each select="./entry/act/entryRelationship/observation">
										<result>
											<reference value="Observation/observation-act-section{$sectionIndex}_{position()}" />
										</result>
								</xsl:for-each>
							</xsl:if>
							
							<xsl:if test="./entry/act/entryRelationship/organizer/component/organizer">
								<xsl:for-each select="./entry/act/entryRelationship/organizer/component/organizer">
										<result>
											<reference value="Observation/organizer-act-section{$sectionIndex}_{position()}" />
										</result>
								</xsl:for-each>
							</xsl:if>
						</DiagnosticReport>
					</resource>
				</entry>
			</xsl:for-each>

			<!-- ENCOUNTER ACT SECTION -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act">
					<entry>
						<resource>
							<Encounter xmlns="http://hl7.org/fhir">
								<id value="encounter-act-section{position()}" />
	
								<xsl:for-each select="./entry/act/participant">
									<participant>
										<type>
											<coding>
												<code value="{./@typeCode}" />
												<system value="[http://terminology.hl7.org/CodeSystem/v3-ParticipationType]" />
											</coding>
										</type>
									</participant>
								</xsl:for-each>
							</Encounter>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- ACT AUTHOR -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/author">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/{./entry/act/author/assignedEntity/id/@root}|{./entry/act/author/assignedEntity/id/@extension}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="{./entry/act/author/assignedEntity/id/@root}|{./entry/act/author/assignedEntity/id/@extension}" />
								 
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
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- PERFORMER OBSERVATION -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/observation/performer">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/{./entry/act/entryRelationship/observation/performer/assignedEntity/id/@root}|{./entry/act/entryRelationship/observation/performer/assignedEntity/id/@extension}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="{./entry/act/entryRelationship/observation/performer/assignedEntity/id/@root}|{./entry/act/entryRelationship/observation/performer/assignedEntity/id/@extension}{position()}" />
								 
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
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- PERFORMER ORGANIZER -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/organizer/performer">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/{./entry/act/entryRelationship/organizer/performer/assignedEntity/id/@root}|{./entry/act/entryRelationship/organizer/performer/assignedEntity/id/@extension}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="{./entry/act/entryRelationship/organizer/performer/assignedEntity/id/@root}|{./entry/act/entryRelationship/organizer/performer/assignedEntity/id/@extension}" />
								
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
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- AUTHOR OBSERVATION -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/observation/author">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/{./entry/act/entryRelationship/observation/author/assignedEntity/id/@root}|{./entry/act/entryRelationship/observation/author/assignedEntity/id/@extension}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="{./entry/act/entryRelationship/observation/author/assignedEntity/id/@root}|{./entry/act/entryRelationship/observation/author/assignedEntity/id/@extension}" />
								 
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
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- AUTHOR ORGANIZER -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/organizer/author">
					<entry>
						<fullUrl value="https://example.com/base/Practitioner/{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@root}|{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@extension}" />
						<resource>
							<Practitioner xmlns="http://hl7.org/fhir">
								<id value="{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@root}|{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@extension}" />
					 
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
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- SPECIMEN DIAGNOSTIC ENTRY -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:variable name="sectionIndex" select="position()" />
				<xsl:for-each select="./entry/act/specimen">
					<entry>
						<resource>
							<Specimen xmlns="http://hl7.org/fhir">
								<id value="specimen-diagnostic-entry{$sectionIndex}_{position()}" />
								 
								<identifier>
									<system value="urn:oid:{./specimenRole/id/@root}" />
									<value value="{./specimenRole/id/@extension}" />
								</identifier>

								<type>
									<coding>
										<code value="{./specimenRole/specimenPlayingEntity/code/@code}" />
										<system value="urn:oid:{./specimenRole/specimenPlayingEntity/code/@codeSystem}" />
										<version value="{./specimenRole/specimenPlayingEntity/code/@codeSystemName}" />
										<display value="{./specimenRole/specimenPlayingEntity/code/@displayName}" />
									</coding>

									<xsl:for-each select="./specimenRole/specimenPlayingEntity/code/translation">
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
				</xsl:for-each>
			</xsl:for-each>

			<!-- HAS-MEMBER-OBSERVATION -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:variable name="sectionIndex" select="position()" />
				<xsl:for-each select="./entry/act/entryRelationship/organizer/component/observation">
					<entry>
						<resource>
							<Observation xmlns="http://hl7.org/fhir">
								<id value="has-member-observation{$sectionIndex}_{position()}" />
							 
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
									<reference value="Patient/{$patientId}"/>
								</subject>
								
								<xsl:if test = "./specimen">
									<specimen>
										<reference value="Specimen/specimen-has-member-observation{$sectionIndex}" />
									</specimen>
								</xsl:if>

								<xsl:if test="./organizer/performer">
									<perfomer>
										<reference value="Practitioner/performer-has-member-observation{$sectionIndex}" />
									</perfomer>
								</xsl:if>

								<xsl:if test="./organizer/author">
									<perfomer>
										<reference value="Practitioner/author-has-member-observation{$sectionIndex}" />
									</perfomer>
								</xsl:if>

								<xsl:if test="./organizer/participant">									<!-- Non esiste Encounter senza participant -->
									<encounter>
										<reference value="Encounter/encounter-has-member-observation" />
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
									<age value="{./entry/act/entryRelationship/organizer/component/observation/referenceRange/observationRange/precondition/criterion/value}"/>
								</referenceRange>

								 
								<note>
									<text value="{./entry/act/entryRelationship/organizer/component/observation/entryRelationship/act}"/>
								</note>

								<xsl:if test="./entry/act/entryRelationship/organizer/component/observation/entryRelationship/observationMedia">
									<derivedFrom>
										<reference value="Media/organizer-observation-media"/>
									</derivedFrom>
								</xsl:if>

								<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer">
									<hasMember>
										<reference value="Observation/has-member-has-member-observation" />
									</hasMember>
								</xsl:if>
							</Observation>
						</resource>
					</entry>
				</xsl:for-each>
			</xsl:for-each>
			
			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/observation/entryRelationship/observationMedia">
				<xsl:variable name="object" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/observation/entryRelationship/observationMedia"></xsl:variable>
				<entry>
					<resource>
						<Media xmlns="http://hl7.org/fhir">
							<id value="organizer-observation-media"/>
							 
							<content>
								<content value="{$object/value}" />
								<data value="{$object/value/representation/@value}" />
								<contentType value="{$object/value/mediaType/@value}"/>
							</content>
						</Media>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer">
				<entry>
					<resource>
						<Observation xmlns="http://hl7.org/fhir">
							<id value="has-member-has-member-observation" />
							 
							<code>
								<coding>
									<system value="urn:oid:{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/code/@codeSystem}" />
									<version value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/code/@codeSystemName} 
										V {component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/code/@codeSystemVersion}" />
									<code value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/code/@code}" />
									<display value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/code/@displayName}" />
								</coding>
							</code>
							<xsl:choose>
								<xsl:when test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/statusCode/@code = 'completed'">
									<status value="final" />
								</xsl:when>
								<xsl:otherwise>
									<status value="canceled" />
								</xsl:otherwise>
							</xsl:choose>

							<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/effectiveTime">
								<xsl:call-template name="show_date">
									<xsl:with-param name="cda_date" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/effectiveTime/@value" />
									<xsl:with-param name="tag" select="'effectiveDateTime'" />
								</xsl:call-template>
							</xsl:if>
							
							<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole">
								<subject>
									<reference value="Patient/body-patient" />
								</subject>
							</xsl:if>

							<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/specimen/specimenRole/specimenPlayingEntity">
								<specimen>
									<reference value="Specimen/body-specimen-entry-observation{position()}" />
								</specimen>
							</xsl:for-each>

							<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/componentOf/encompassingEncounter/responsibleParty/assignedEntity">
								<practitioner>
									<reference value="Practitioner/body-performer" />
								</practitioner>
							</xsl:if>

							<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/author">
								<practitioner>
									<reference value="Practitioner/body-author" />
								</practitioner>
							</xsl:if>

							<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/component/structuredBody/component/section/component/section">
								<hasMember>
									<reference value="Observation/body-has-member-observation{position()}" />
								</hasMember>
							</xsl:for-each>
						</Observation>
					</resource>
				</entry>
			</xsl:if>

			<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/component/structuredBody/component/section/component/section">
				<xsl:for-each select="./entry/act/entryRelationship/organizer/component/observation">
					<entry>
						<resource>
							<Observation xmlns="http://hl7.org/fhir">
								<id value="body-has-member-observation{position()}" />
							 
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
									<text value="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/component/act"/>
								</note>

							</Observation>
						</resource>
					</entry>
				</xsl:for-each>
			</xsl:for-each>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/author">
				<entry>
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

						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/componentOf/encompassingEncounter/responsibleParty/assignedEntity">
				<entry>
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
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/specimen/specimenRole/specimenPlayingEntity">
				<entry>
					<resource>
						<Specimen xmlns="http://hl7.org/fhir">
							<id value="body-specimen-entry-observation{position()}" />
							 
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
			
			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole">
				<entry>
					<resource>
						<Patient xmlns="http://hl7.org/fhir">
							<id value="body-patient" />
						 
							<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/id">
								<identifier>
									<system value="urn:oid:{./@root}" />
									<value value="{./@extension}" />
									<assigner>
										<display value="{./@assigingAuthorityName}" />
									</assigner>
								</identifier>
							</xsl:for-each>
	
							<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/addr">
								<xsl:call-template name="show_address">
									<xsl:with-param name="cda_address" select="./addr" />
								</xsl:call-template>
							</xsl:for-each>
	
							<xsl:call-template name="show_telecom">
								<xsl:with-param name="cda_telecom" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/telecom" />
							</xsl:call-template>
	
							<name>
								<family value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/patient/name/family}" />
								<given value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/patient/name/given}" />
							</name>
	
							<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/patient/administrativeGenderCode/@code='M'">
								<gender value="male" />
							</xsl:if>
							<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/patient/administrativeGenderCode/@code='F'">
								<gender value="female" />
							</xsl:if>
							<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/patient/administrativeGenderCode/@code='UN'">
								<gender value="unknown" />
							</xsl:if>
							<birthDate value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/patient/birthTime}" />
	
							<extension>
								<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/patient/birthplace/place/addr">
									<xsl:call-template name="show_address">
										<xsl:with-param name="cda_address" select="./addr" />
									</xsl:call-template>
								</xsl:for-each>
							</extension>
	
							<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/patient/guardian">
								<contact>
									<name>
										<family value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/patient/guardian/guardianPerson/name/family}"></family>
										<given value="{component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/organizer/recordTarget/patientRole/patient/guardian/guardianPerson/name/given}"></given>
									</name>
								</contact>
							</xsl:if>
						</Patient>
					</resource>
				</entry>
			</xsl:if>

			<!-- ENCOUNTER OBSERVATION -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/observation/participant">
					<entry>
						<resource>
							<Encounter xmlns="http://hl7.org/fhir">
								<id value="encounter-observation{position()}" />
	
								<xsl:for-each select="./entry/act/entryRelationship/observation/participant">
									<participant>
										<type>
											<coding>
												<code value="./@typeCode" />
												<system value="[http://terminology.hl7.org/CodeSystem/v3-ParticipationType]" />
											</coding>
										</type>
									</participant>
								</xsl:for-each>
							</Encounter>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- ENCOUNTER ORGANIZER -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/organizer/participant">
					<entry>
						<resource>
							<Encounter xmlns="http://hl7.org/fhir">
								<id value="encounter-organizer{position()}" />
	
								<xsl:for-each select="./entry/act/entryRelationship/organizer/participant">
									<participant>
										<type>
											<coding>
												<code value="./@typeCode" />
												<system value="[http://terminology.hl7.org/CodeSystem/v3-ParticipationType]" />
											</coding>
										</type>
									</participant>
								</xsl:for-each>
							</Encounter>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- SPECIMEN ENTRY OBSERVATION -->
			<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/specimen/specimenRole/specimenPlayingEntity">
				<entry>
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
						</Specimen>
					</resource>
				</entry>
			</xsl:for-each>

			<!-- SPECIMEN ENTRY ORGANIZER -->
			<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/specimen/specimenRole/specimenPlayingEntity">
				<entry>
					<resource>
						<Specimen xmlns="http://hl7.org/fhir">
							<id value="specimen-entry-organizer{position()}" />
						 
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

			<!-- HAS MEMBER OBSERVATION AUTHOR -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/organizer/author">
					<entry>
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
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- HAS MEMBER OBSERVATION PERFORMER -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/performer">
					<entry>
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
							</Practitioner>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- HAS MEMBER OBSERVATION ENCOUNTER -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:if test="./entry/act/entryRelationship/organizer/component/observation/participant">	
					<entry>
						<resource>
							<Encounter xmlns="http://hl7.org/fhir">
								<id value="encounter-has-member-observation{position()}" />

								<xsl:for-each select="./entry/act/entryRelationship/organizer/component/observation/participant">
									<participant>
										<type>
											<coding>
												<code value="./@typeCode" />
												<system value="[http://terminology.hl7.org/CodeSystem/v\-ParticipationType]" />
											</coding>
										</type>
									</participant>
								</xsl:for-each>
							</Encounter>
						</resource>
					</entry>
				</xsl:if>
			</xsl:for-each>

			<!-- HAS MEMBER OBSERVATION SPECIMEN ENTRY -->
			<xsl:if test = "component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/observation/specimen">
				<xsl:for-each select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/organizer/component/observation/specimen">
					<entry>
						<resource>
							<Specimen xmlns="http://hl7.org/fhir">
								<id value="specimen-has-member-observation{position()}" />
							 
								<xsl:if test="./code">
									<type>
										<coding>
											<system value="urn:oid:{./code/@codeSystem}" />
											<code value="{./code/@code}" />
											<display value="{./code/@displayName}" />
										</coding>
									</type>
								</xsl:if>
							</Specimen>
						</resource>
					</entry>
				</xsl:for-each>
			</xsl:if>

			<!-- OBSERVATION -->
			
			
			
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:variable name="sectionIndex" select="position()" />
				
				<!-- FOGLIA 1 -->
				<xsl:if test="./entry/act/entryRelationship/observation">
					<xsl:for-each select="./entry/act/entryRelationship/observation">
						<entry>
							<resource>
								<Observation xmlns="http://hl7.org/fhir">
									<id value="observation-act-section{$sectionIndex}_{position()}" />
 
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
												<display value="{./@displayName}"/>
											</coding>
										</xsl:for-each>
									</xsl:if>
									<subject>
										<reference value="Patient/{$patientId}"/>
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

									<value>
										<valueQuantity value="{./value/@unit}"/>
									</value>

									<xsl:if test="./interpretationCode">
										<interpretation>
											<coding>
												<code value="{./interpretationCode/@code}"/>
												<system value="{./interpretationCode/@codeSystem}"/>
												<version value=" {./interpretationCode/@codeSystemName} V {./interpretationCode/@codeSystemVersion}"/>
											</coding>										
										</interpretation>
									</xsl:if>

									<xsl:if test="./methodCode">
										<method>
											<coding>
												<code value="{./methodCode/@code}"/>
												<system value="{./methodCode/@codeSystem}"/>
												<version value=" {./methodCode/@codeSystemName} V {./methodCode/@codeSystemVersion}"/>
												<display value="{./methodCode/@displayName}"/>
											</coding>
										</method>
									</xsl:if>
									<xsl:if test="./specimen/specimenRole/specimenPlayingEntity">
										<specimen>
											<reference value="Specimen/specimen-entry-observation{$sectionIndex}" />
										</specimen>
									</xsl:if>

									<xsl:if test="./performer">
										<perfomer>
											<reference value="Practitioner/{./performer/assignedEntity/id/@root}|{./performer/assignedEntity/id/@extension}{$sectionIndex}" />
										</perfomer>
									</xsl:if>

									<xsl:if test="./author">
										<perfomer>
											<reference value="Practitioner/{./author/assignedEntity/id/@root}|{./author/assignedEntity/id/@extension}{$sectionIndex}" />
										</perfomer>
									</xsl:if>

									<xsl:if test="./participant">									<!-- Non esiste Encounter senza participant -->
										<encounter>
											<reference value="Encounter/encounter-observation" />
										</encounter>
									</xsl:if>

									<note>
										<text value="{./entryRelationship/act/text}"/>
									</note>

									<xsl:if test="./entryRelationship/observationMedia">
										<derivedFrom>
											<reference value="Media/observation-media"/>
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
											<age value="{./referenceRange/observationRange/precondition/criterion/value}"/>
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
						<reference value="Procedure/procedure"/>
					</partOf>
				</xsl:if>
			</xsl:for-each>
			
			<!-- FOGLIA 2 -->
			<xsl:for-each select="component/structuredBody/component/section/component/section">
				<xsl:variable name="sectionIndex" select="position()" />
				<xsl:if test="./entry/act/entryRelationship/organizer/component/organizer">
					<xsl:for-each select="./entry/act/entryRelationship/organizer/component/organizer">
						<entry>
							<resource>
								<Observation xmlns="http://hl7.org/fhir">
									<id value="organizer-act-section{$sectionIndex}_{position()}" />
 
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
												<display value="{./@displayName}"/>
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

									<specimen>
										<reference value="Specimen/specimen-entry-organizer{$sectionIndex}" />
									</specimen>

									<xsl:if test="./performer">
										<perfomer>
											<reference value="Practitioner/{./assignedEntity/id/@root}|{./assignedEntity/id/@extension}{$sectionIndex}" />
										</perfomer>
									</xsl:if>

									<xsl:if test="./author">
										<perfomer>
											<reference value="Practitioner/{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@root}|{./entry/act/entryRelationship/organizer/author/assignedEntity/id/@extension}{$sectionIndex}" />
										</perfomer>
									</xsl:if>

									<xsl:if test="./organizer/participant">									<!-- Non esiste Encounter senza participant -->
										<encounter>
											<reference value="Encounter/encounter-organizer" />
										</encounter>
									</xsl:if>
	
									<xsl:for-each select="./component/observation">
										<xsl:if test="./component/observation">
										<hasMember>
											<reference value="Observation/has-member-observation{$sectionIndex}_{position()}" />
										</hasMember>
										</xsl:if>
									</xsl:for-each>
								</Observation>
							</resource>
						</entry>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/specimen">
				<xsl:variable name="object" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship"></xsl:variable>
				<entry>
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

								<identifier value="{./act/specimen/specimenRole/id}"/>
								<collected>
									<xsl:call-template name="show_date">
										<xsl:with-param name="cda_date" select="$object/act/effectiveTime/@value" />
										<xsl:with-param name="tag" select="'effectiveDateTime'" />
									</xsl:call-template>
								</collected>
								
								<xsl:if test="$object/act/participant">
									<collector>
										<reference value="Practitioner/{$object/act/participant/assignedEntity/id/@root}|{$object/act/participant/assignedEntity/id/@extension}"/>
									</collector>
								</xsl:if>
							</collection>
						</Specimen>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/act/participant">
				<xsl:variable name="participant" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/act/participant"/>
				<entry>
					<resource>
						<Practitioner xmlns="http://hl7.org/fhir">
							<id value="{$participant/assignedEntity/id/@root}|{$participant/assignedEntity/id/@extension}" />
							 
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
						</Practitioner>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/entryRelationship/observationMedia">
				<xsl:variable name="object" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/entryRelationship/observationMedia"></xsl:variable>
				<entry>
					<resource>
						<Media xmlns="http://hl7.org/fhir">
							<id value="observation-media"/>
						 
							<content>
								<content value="{$object/value}" />
								<data value="{$object/value/representation/@value}" />
								<contentType value="{$object/value/mediaType/@value}"/>
							</content>
						</Media>
					</resource>
				</entry>
			</xsl:if>

			<xsl:if test="component/structuredBody/component/section/component/section/entry/act/entryRelationship/procedure">
				<xsl:variable name="object" select="component/structuredBody/component/section/component/section/entry/act/entryRelationship/procedure"></xsl:variable>
				<entry>
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
							<id value="{id/@extension}" />						
						</masterIdentifier>
																
						<securityLabel>
							<coding>
								<code value="{confidentialityCode/@code}"/>
							</coding>
						</securityLabel>
						
						<subject>
							<reference value="Patient/{recordTarget/patientRole/id/@root}|{recordTarget/patientRole/id/@extension}" />
						</subject>
						
						<type>
							<coding>
								<code value="{code/@code}" />
							</coding>
						</type>
							
						<author>
							<reference value="Practitioner/{author/assignedAuthor/id/@root}|{author/assignedAuthor/id/@extension}" />
						</author>
						
						<xsl:if test="legalAuthenticator/assignedEntity/representedOrganization">
							<organization>
								<reference value="Organization/{legalAuthenticator/assignedEntity/representedOrganization/id/@root}|{legalAuthenticator/assignedEntity/representedOrganization/id/@extension}" />
							</organization>
						</xsl:if>
						
						<xsl:if test="custodian">
							<custodian>
								<reference value="Organization/{custodian/assignedCustodian/representedCustodianOrganization/id/@root}|{custodian/assignedCustodian/representedCustodianOrganization/id/@extension}" />
							</custodian>
						</xsl:if>
						
						<content>
							<format>
								<code value="{templateId/@root}"/> 
							</format>
						</content>
						
						<context>
								<sourcePatientInfo>
									<reference value="Patient/{recordTarget/patientRole/id/@root}|{recordTarget/patientRole/id/@extension}" />
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
</xsl:stylesheet>