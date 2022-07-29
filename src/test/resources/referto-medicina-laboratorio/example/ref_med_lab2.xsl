<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:strip-space elements="*"/>
	<xsl:template match="/">
		<Bundle xmlns="http://hl7.org/fhir">
			<id value="father"/>
			<meta>
			    <profile value="http://ihe.net/fhir/tag/iti-65"/>
			</meta>
			<implicitRules value="{ClinicalDocument/typeId/@root}"/>
			<language value="{ClinicalDocument/languageCode/@code}"/>
			<identifier>
				<system value="urn:oid:{ClinicalDocument/id/@root}"/>
				<value value="{ClinicalDocument/id/@extension}"/>
			</identifier>
			<type value="transaction"/>
			<xsl:call-template name="show_date">
				<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
				<xsl:with-param name="tag" select="'timestamp'" />
		    </xsl:call-template>

			<!-- COMPOSITION -->

			<entry>
				<fullUrl value="https://example.com/base/Composition/composition"/>
				<resource>
					<Composition xmlns="http://hl7.org/fhir">
						<id value="composition"/>
						<meta>
							<versionId value="{ClinicalDocument/versionNumber/@value}"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<language value="{ClinicalDocument/languageCode/@code}"/>
						<extension url="http://hl7.org/fhir/StructureDefinition/composition-clinicaldocument-versionNumber">
							<valueString value="{ClinicalDocument/versionNumber/@value}"/>
						</extension>
						<identifier>
							<system value="urn:oid:{ClinicalDocument/setId/@root}"/>
							<value value="{ClinicalDocument/setId/@extension}"/>
							<assigner>
								<display value="{ClinicalDocument/setId/@assigningAuthorityName}"/>
							</assigner>
						</identifier>
						<xsl:choose>
							<xsl:when test="/ClinicalDocument/statusCode/@code = 'completed'">
								<status value="final"/>
							</xsl:when>
							<xsl:otherwise>
								<status value="preliminary"/>
							</xsl:otherwise>
						</xsl:choose>

						<type>
							<coding>
								<system value="urn:oid:{ClinicalDocument/code/@codeSystem}"/>
								<version value="{ClinicalDocument/code/@codeSystemName} V {ClinicalDocument/code/@codeSystemVersion}"/>
								<code value="{ClinicalDocument/code/@code}"/>
								<display value="{ClinicalDocument/code/@displayName}"/>
							</coding>							
							<xsl:if test="/ClinicalDocument/code/translation">
								<coding>
									<system value="urn:oid:{ClinicalDocument/code/translation/@codeSystem}"/>
									<version value="{ClinicalDocument/code/translation/@codeSystemName} V {ClinicalDocument/code/translation/@codeSystemVersion}"/>
									<code value="{ClinicalDocument/code/translation/@code}"/>
									<display value="{ClinicalDocument/code/translation/@displayName}"/>
								</coding>							
							</xsl:if>
							
						</type>

						<subject>
							<reference value="Patient/patient"/>
						</subject>

						<encounter>
							<reference value="Encounter/encounter"/>
						</encounter>
						
						<xsl:call-template name="show_date">
							<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
							<xsl:with-param name="tag" select="'date'" />
					    </xsl:call-template>

						<author>
							<reference value="PractitionerRole/practitioner-role-author"/>
						</author>

						<title value="{ClinicalDocument/title}"/>
						<confidentiality value="{ClinicalDocument/confidentialityCode/@code}"/>

						<attester>
							<mode value="legal"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'time'" />
						    </xsl:call-template>
							<party>
								<reference value="PractitionerRole/practitioner-role-legal-aut"/>
							</party>
						</attester>

						<attester>
							<mode value="professional"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'time'" />
						    </xsl:call-template>
							<party>
								<reference value="Practitioner/practitioner-attester"/>
							</party>
						</attester>

						<custodian>
							<reference value="Organization/organization-custodian"/>
						</custodian>
						
						<event>
							<period>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'start'" />
						    </xsl:call-template>
							</period>
							<detail>
								<reference value="PractitionerRole/practitioner-role-performer"/>
							</detail>
						</event>
						<section>
							<code>
								<coding>
									<system value="urn:oid:{ClinicalDocument/component/structuredBody/component/section/code/@codeSystem}"/>
									<version value="{ClinicalDocument/component/structuredBody/component/section/code/@codeSystemName} V {ClinicalDocument/code/@codeSystemVersion}"/>
									<code value="{ClinicalDocument/component/structuredBody/component/section/code/@code}"/>
									<display value="{ClinicalDocument/component/structuredBody/component/section/code/@displayName}"/>
								</coding>
							</code>
							<section>
								<title value="{ClinicalDocument/component/structuredBody/component/section/component/section/title}"/>
								<code>
									<coding>
										<system value="urn:oid:{ClinicalDocument/component/structuredBody/component/section/component/section/code/@codeSystem}"/>
										<version value="{ClinicalDocument/component/structuredBody/component/section/component/section/code/@codeSystemName} V {ClinicalDocument/code/@codeSystemVersion}"/>
										<code value="{ClinicalDocument/component/structuredBody/component/section/component/section/code/@code}"/>
										<display value="{ClinicalDocument/component/structuredBody/component/section/component/section/code/@displayName}"/>
									</coding>
								</code>
								<entry>
									<reference value="DiagnosticReport/diagnosticReport"/>
								</entry>
							</section>
						</section>
					</Composition>
				</resource>
			</entry>

			<!-- PATIENT -->
			<entry>
				<fullUrl value="https://example.com/base/Patient/patient"/>
				<resource>
					<Patient xmlns="http://hl7.org/fhir">
						<id value="patient"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<extension url="http://hl7.org/fhir/StructureDefinition/patient-birthPlace">
							<xsl:for-each select="/ClinicalDocument/recordTarget/patientRole/patient/birthplace/place/addr">
								<valueAddress>
									<xsl:if test="./@use='HP'">
										<use value="home"/>
									</xsl:if>
									<xsl:if test="./@use='H'">
										<use value="home"/>
									</xsl:if>
									<xsl:if test="./@use='TMP'">
										<use value="temp"/>
									</xsl:if>
									<line value="{ClinicalDocument/recordTarget/patientRole/patient/birthplace/place/addr/streetAddressLine}"/>
									<city value="{ClinicalDocument/recordTarget/patientRole/patient/birthplace/place/addr/city}"/>
									<postalCode value="{ClinicalDocument/recordTarget/patientRole/patient/birthplace/place/addr/postalCode}"/>
									<country value="{ClinicalDocument/recordTarget/patientRole/patient/birthplace/place/addr/country}"/>
								</valueAddress>
							</xsl:for-each>
						</extension>
						<identifier>
							<system value="urn:oid:{ClinicalDocument/recordTarget/patientRole/id/@root}"/>
							<value value="{ClinicalDocument/recordTarget/patientRole/id/@extension}"/>
							<assigner>
								<display value="{ClinicalDocument/recordTarget/patientRole/id/@assigingAuthorityName}"/>
							</assigner>
						</identifier>
						<name>
							<family value="{ClinicalDocument/recordTarget/patientRole/patient/name/family}"/>
							<given value="{ClinicalDocument/recordTarget/patientRole/patient/name/given}"/>
						</name>
						
						<xsl:call-template name="show_telecom">
							<xsl:with-param name="cda_telecom" select="ClinicalDocument/recordTarget/patientRole/telecom" />
					    </xsl:call-template>
						
						<xsl:if test="ClinicalDocument/recordTarget/patientRole/patient/administrativeGenderCode/@code='M'">
							<gender value="male"/>
						</xsl:if>
						<xsl:if test="ClinicalDocument/recordTarget/patientRole/patient/administrativeGenderCode/@code='F'">
							<gender value="female"/>
						</xsl:if>
						<xsl:if test="ClinicalDocument/recordTarget/patientRole/patient/administrativeGenderCode/@code='UN'">
							<gender value="unknown"/>
						</xsl:if>
						<birthTime value="{/ClinicalDocument/recordTarget/patientRole/patient/birthTime}"/>

						<xsl:for-each select="ClinicalDocument/recordTarget/patientRole/addr">
							<address>
								<xsl:if test="./@use='HP'">
									<use value="home"/>
								</xsl:if>
								<xsl:if test="./@use='H'">
									<use value="home"/>
								</xsl:if>
								<xsl:if test="./@use='TMP'">
									<use value="temp"/>
								</xsl:if>
								<type value="both"/>
								<line value="{/ClinicalDocument/recordTarget/patientRole/addr/streetAddressLine}"/>
								<city value="{/ClinicalDocument/recordTarget/patientRole/addr/city}"/>
								<district value="{/ClinicalDocument/recordTarget/patientRole/addr/county}"/>
								<state value="{/ClinicalDocument/recordTarget/patientRole/addr/country}"/>
								<postalCode value="{/ClinicalDocument/recordTarget/patientRole/addr/postalCode}"/>
							</address>
						</xsl:for-each>

					</Patient>
				</resource>
			</entry>

			<!-- ATTESTER -->

			<entry>
				<fullUrl value="https://example.com/base/Practitioner/practitioner-attester"/>
				<resource>
					<Practitioner xmlns="http://hl7.org/fhir">
						<id value="practitioner-attester"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<identifier>
							<system value="urn:oid:{ClinicalDocument/informationRecipient/intendedRecipient/id/@root}"/>
							<value value="{ClinicalDocument/informationRecipient/intendedRecipient/id/@extension}"/>
							<assigner>
								<display value="{ClinicalDocument/informationRecipient/intendedRecipient/id/@assigningAuthorityName}"/>
							</assigner>
						</identifier>
						<name>
							<family value="{ClinicalDocument/informationRecipient/intendedRecipient/informationRecipient/name/family}"/>
							<given value="{ClinicalDocument/informationRecipient/intendedRecipient/informationRecipient/name/given}"/>
							<prefix value="{ClinicalDocument/informationRecipient/intendedRecipient/informationRecipient/name/prefix}"/>
						</name>
					</Practitioner>
				</resource>
			</entry>

			<!-- AUTHOR -->

			<entry>
				<fullUrl value="https://example.com/base/Practitioner/practitioner-author"/>
				<resource>
					<Practitioner xmlns="http://hl7.org/fhir">
						<id value="practitioner-author"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<identifier>
							<system value="urn:oid:{ClinicalDocument/author/assignedAuthor/id/@root}"/>
							<value value="{ClinicalDocument/author/assignedAuthor/id/@extension}"/>
							<assigner>
								<reference value="Organization/organization1"/>
							</assigner>
						</identifier>
						<name>
							<family value="{ClinicalDocument/author/assignedAuthor/assignedPerson/name/family}"/>
							<given value="{ClinicalDocument/author/assignedAuthor/assignedPerson/name/given}"/>
							<prefix value="{ClinicalDocument/author/assignedAuthor/assignedPerson/name/prefix}"/>
						</name>
						
						<xsl:call-template name="show_telecom">
							<xsl:with-param name="cda_telecom" select="ClinicalDocument/author/assignedAuthor/telecom" />
					    </xsl:call-template>

					</Practitioner>
				</resource>
			</entry>

			<entry>
				<fullUrl value="https://example.com/base/PractitionerRole/practitioner-role-author"/>
				<resource>
					<PractitionerRole xmlns="http://hl7.org/fhir">
						<id value="practitioner-role-author"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<practitioner>
							<reference value="Practitioner/practitioner-author"/>
						</practitioner>
						<organization>
							<reference value="Organization/organization-author"/>
						</organization>
					</PractitionerRole>
				</resource>
			</entry>
			
			<entry>
				<fullUrl value="https://example.com/base/Organization/organization-author"/>
				<resource>
					<Organization xmlns="http://hl7.org/fhir">
						<id value="organization-author"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<identifier>
							<system value="urn:oid:{/ClinicalDocument/author/assignedAuthor/representedOrganization/id/@root}"/>
							<value value="{/ClinicalDocument/author/assignedAuthor/representedOrganization/id/@extension}"/>
						</identifier>
						<name value="/ClinicalDocument/author/assignedAuthor/representedOrganization/id/@assigningAuthorityName"/>
					</Organization>
				</resource>
			</entry>

			<!-- CUSTODIAN -->

			<entry>
				<fullUrl value="https://example.com/base/Organization/organization-custodian"/>
				<resource>
					<Organization xmlns="http://hl7.org/fhir">
						<id value="organization-custodian"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<identifier>
							<system value="urn:oid:{/ClinicalDocument/custodian/assignedCustodian/representedCustodianOrganization/id/@root}"/>
							<value value="{/ClinicalDocument/custodian/assignedCustodian/representedCustodianOrganization/id/@extension}"/>
						</identifier>
						<name value="{/ClinicalDocument/custodian/assignedCustodian/representedCustodianOrganization/id/@assigningAuthorityName}"/>
					</Organization>
				</resource>
			</entry>

			<!-- LEGAL AUTHENTICATOR -->
			<entry>
				<fullUrl value="https://example.com/base/PractitionerRole/practitioner-role-legal-aut"/>
				<resource>
					<PractitionerRole xmlns="http://hl7.org/fhir">
						<id value="practitioner-role-legal-aut"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<practitioner>
							<reference value="Practitioner/practitioner-legal-aut"/>
						</practitioner>
						<organization>
							<reference value="Organization/organization-legal-aut"/>
						</organization>
					</PractitionerRole>
				</resource>
			</entry>

			<entry>
				<fullUrl value="https://example.com/base/Organization/organization-legal-aut"/>
				<resource>
					<Organization xmlns="http://hl7.org/fhir">
						<id value="organization-legal-aut"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<identifier>
							<system value="urn:oid:{/ClinicalDocument/legalAuthenticator/assignedEntity/representedOrganization/id/@root}"/>
							<value value="{/ClinicalDocument/legalAuthenticator/assignedEntity/representedOrganization/id/@extension}"/>
						</identifier>
						<name value="{/ClinicalDocument/legalAuthenticator/assignedEntity/representedOrganization/id/@assigningAuthorityName}"/>
					</Organization>
				</resource>
			</entry>

			<entry>
				<fullUrl value="https://example.com/base/Practitioner/practitioner-legal-aut"/>
				<resource>
					<Practitioner xmlns="http://hl7.org/fhir">
						<id value="practitioner-legal-aut"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<identifier>
							<system value="urn:oid:{/ClinicalDocument/legalAuthenticator/assignedEntity/id/@root}"/>
							<value value="{/ClinicalDocument/legalAuthenticator/assignedEntity/id/@extension}"/>
							<assigner>
								<display value="{/ClinicalDocument/legalAuthenticator/assignedEntity/id/@assigningAuthorityName}"/>
							</assigner>
						</identifier>
						<name>
							<family value="{/ClinicalDocument/legalAuthenticator/assignedEntity/assignedPerson/name/family}"/>
							<given value="{/ClinicalDocument/legalAuthenticator/assignedEntity/assignedPerson/name/given}"/>
							<prefix value="{/ClinicalDocument/legalAuthenticator/assignedEntity/assignedPerson/name/prefix}"/>
						</name>

					</Practitioner>
				</resource>
			</entry>

<!-- ======================================================================================================== -->
<!-- ================================================= BODY ================================================= -->
<!-- ======================================================================================================== -->

			<entry>
				<fullUrl value="https://example.com/base/ServiceRequest/serviceRequest"/>
				<resource>
					<ServiceRequest xmlns="http://hl7.org/fhir">
						<id value="serviceRequest"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<identifier>
							<system value="urn:oid:{ClinicalDocument/inFulfillmentOf/order/id/@root}"/>
							<value value="{ClinicalDocument/inFulfillmentOf/order/id/@extension}"/>
							<assigner>
								<display value="{ClinicalDocument/inFulfillmentOf/order/id/@assigningAuthorityName}"/>
							</assigner>							
						</identifier>
						<status value="active"/>
						<intent value="order"/>
						<priority value="{ClinicalDocument/inFulfillmentOf/order/priorityCode/@displayName}"/>
						<subject>
							<reference value="Patient/patient"/>
						</subject>
					</ServiceRequest>
				</resource>
			</entry>

			<entry>
				<fullUrl value="https://example.com/base/DiagnosticReport/diagnosticReport"/>
				<resource>
					<DiagnosticReport xmlns="http://hl7.org/fhir">
						<id value="diagnosticReport"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<status value="final"/>
						<code>
							<coding>
								<system value="urn:oid:{ClinicalDocument/component/structuredBody/component/section/code/@codeSystem}"/>
								<code value="{ClinicalDocument/component/structuredBody/component/section/code/@code}"/>
								<display value="{ClinicalDocument/component/structuredBody/component/section/code/@displayName}"/>
							</coding>
						</code>
						<encounter>
							<reference value="Encounter/encounter"/>
						</encounter>
						<result>
							<reference value="Observation/observation"/>
						</result>
					</DiagnosticReport>
				</resource>
			</entry>

			<entry>
				<fullUrl value="https://example.com/base/Observation/observation"/>
				<resource>
					<Observation xmlns="http://hl7.org/fhir">
						<id value="observation"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<status value="final"/>
						<code>
							<coding>
								<system value="urn:oid:{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/code/@codeSystem}"/>
								<version value="{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/code/@codeSystemName} V {ClinicalDocument/code/@codeSystemVersion}"/>
								<code value="{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/code/@code}"/>
								<display value="{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/code/@displayName}"/>
							</coding>
						</code>

						<xsl:call-template name="show_date">
							<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
							<xsl:with-param name="tag" select="'effectiveDateTime'" />
					    </xsl:call-template>
								
						<valueQuantity>
							<value value="{translate(/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/value/@value, ' ', '')}"/>
							<unit value="{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/value/@unit}"/>
						</valueQuantity>
						<interpretation>
							<coding>
								<system value="urn:oid:{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/interpretationCode/@codeSystem}"/>
								<version value="{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/interpretationCode/@codeSystemName}"/>
								<code value="{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/interpretationCode/@code}"/>
							</coding>
						</interpretation>
						<specimen>
							<reference value="Specimen/specimen"/>
						</specimen>
						<referenceRange>
							<low>
								<value value="{translate(/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/referenceRange/observationRange/value/low/@value, ' ', '')}"/>
								<unit value="{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/referenceRange/observationRange/value/low/@unit}"/>
							</low>
							<high>
								<value value="{translate(/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/referenceRange/observationRange/value/high/@value, ' ', '')}"/>
								<unit value="{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/referenceRange/observationRange/value/high/@unit}"/>
							</high>
						</referenceRange>
					</Observation>
				</resource>
			</entry>

			<entry>
				<fullUrl value="https://example.com/base/Specimen/specimen"/>
				<resource>
					<Specimen xmlns="http://hl7.org/fhir">
						<id value="specimen"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<type>
							<coding>
								<system value="urn:oid:{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/specimen/specimenRole/specimenPlayingEntity/code/@codeSystem}"/>
								<code value="{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/specimen/specimenRole/specimenPlayingEntity/code/@code}"/>
								<display value="{/ClinicalDocument/component/structuredBody/component/section/component/section/entry/act/entryRelationship/observation/specimen/specimenRole/specimenPlayingEntity/code/@displayName}"/>
							</coding>
						</type>
					</Specimen>
				</resource>
			</entry>
<!-- ======================================================================================================================================================================== -->						

			<!--============================== TODO PERFORMER + ENCOUNTER ==============================-->

			<entry>
				<fullUrl value="https://example.com/base/PractitionerRole/practitioner-role-performer"/>
				<resource>
					<PractitionerRole xmlns="http://hl7.org/fhir">
						<id value="practitioner-role-performer"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<code>
							<coding>
								<system value="urn:oid:2.16.840.1.113883.2.9.5.1.88"/>
								<code value="PRE"/>
								<display value="primary performer"/>
							</coding>
						</code>
					</PractitionerRole>
				</resource>
			</entry>
			
			<entry>
				<fullUrl value="https://example.com/base/Encounter/encounter"/>
				<resource>
					<Encounter xmlns="http://hl7.org/fhir">
						<id value="encounter"/>
						<meta>
							<versionId value="1"/>
							<xsl:call-template name="show_date">
								<xsl:with-param name="cda_date" select="ClinicalDocument/effectiveTime/@value" />
								<xsl:with-param name="tag" select="'lastUpdated'" />
						    </xsl:call-template>
						</meta>
						<status value="finished"/>
						<class>
							<system value="http://terminology.hl7.org/CodeSystem/v3-ActCode"/>
							<code value="AMB"/>
							<display value="ambulatory"/>
						</class>

						<type>
							<coding>
								<system value="urn:oid:2.16.840.1.113883.2.9.5.1.88"/>
								<code value="PRE"/>
								<display value="primary performer"/>
							</coding>
						</type>
						<basedOn>
							<reference value="ServiceRequest/serviceRequest"/>
						</basedOn>
							
						<participant>
							<type>
								<coding>
									<system value="urn:oid:2.16.840.1.113883.2.9.5.1.88"/>
									<code value="REF"/>
									<display value="referrer"/>
								</coding>
								<coding>
									<system value="urn:oid:2.16.840.1.113883.2.9.5.1.88"/>
									<code value="PRE"/>
									<display value="PRE"/>
								</coding>
							</type>
<!-- 							<period> -->
<!-- 								<start value="2022-01-09T12:24:37Z"/> -->
<!-- 							</period> -->
							<individual>
								<reference value="PractitionerRole/practitionerRole3"/>
							</individual>
						</participant>
						<period>
							<start value="{concat(substring(ClinicalDocument/effectiveTime/@value, 1, 4), '-', substring(ClinicalDocument/effectiveTime/@value, 5, 2), '-', substring(ClinicalDocument/effectiveTime/@value, 7, 2), 'T', substring(ClinicalDocument/effectiveTime/@value, 9, 2), ':', substring(ClinicalDocument/effectiveTime/@value, 11, 2), ':', substring(ClinicalDocument/effectiveTime/@value, 13, 2), substring(ClinicalDocument/effectiveTime/@value, 15, 3), ':', substring(ClinicalDocument/effectiveTime/@value, 18, 2))}"/>
						</period>
					</Encounter>
				</resource>
			</entry>
		</Bundle>
	</xsl:template>

	<xsl:template name = "show_date" >
		<xsl:param name = "cda_date" />
		<xsl:param name = "tag" />
		
		<xsl:variable name="fhir_date" select="concat(substring($cda_date, 1, 4), '-', substring($cda_date, 5, 2), '-', substring($cda_date, 7, 2), 'T', substring($cda_date, 9, 2), ':', substring($cda_date, 11, 2), ':', substring($cda_date, 13, 2), substring($cda_date, 15, 3), ':', substring($cda_date, 18, 2))" />
		
		<xsl:if test="$tag='lastUpdated'">
			<lastUpdated value="{$fhir_date}"/>
		</xsl:if>
		
		<xsl:if test="$tag='start'">
			<start value="{$fhir_date}"/>
		</xsl:if>
		
		<xsl:if test="$tag='effectiveDateTime'">
			<effectiveDateTime value="{$fhir_date}"/>
		</xsl:if>
		
		<xsl:if test="$tag='time'">
			<time value="{$fhir_date}"/>
		</xsl:if>
		
		<xsl:if test="$tag='date'">
			<date value="{$fhir_date}"/>
		</xsl:if>
		
		<xsl:if test="$tag='timestamp'">
			<timestamp value="{$fhir_date}"/>
		</xsl:if>
		
	</xsl:template>

	<xsl:template name = "show_telecom" >
		<xsl:param name = "cda_telecom" />

		<xsl:for-each select="$cda_telecom">
			<telecom>
				<xsl:if test="starts-with(./@value, 'tel')">
					<system value="phone"/>
					<value value="{substring(./@value,5)}"/>
					<xsl:if test="./@use='HP'">
						<use value="home"/>
					</xsl:if>
					<xsl:if test="./@use='WP'">
						<use value="work"/>
					</xsl:if>
					<xsl:if test="./@use='MC'">
						<use value="mobile"/>
					</xsl:if>
				</xsl:if>
				<xsl:if test="starts-with(./@value, 'mail')">
					<system value="email"/>
					<value value="{substring(./@value,7)}"/>
					<xsl:if test="./@use='HP'">
						<use value="home"/>
					</xsl:if>
					<xsl:if test="./@use='WP'">
						<use value="work"/>
					</xsl:if>
				</xsl:if>
			</telecom>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>