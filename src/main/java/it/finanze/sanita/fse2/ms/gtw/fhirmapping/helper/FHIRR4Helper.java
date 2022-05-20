package it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper;

import org.hl7.fhir.instance.model.api.IBaseResource;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.narrative.DefaultThymeleafNarrativeGenerator;
import ca.uhn.fhir.parser.IParser;
import ca.uhn.fhir.rest.client.api.IGenericClient;

public class FHIRR4Helper {

	private static FhirContext context;

	static {
		context = FhirContext.forR4();
		getContext().setNarrativeGenerator(new DefaultThymeleafNarrativeGenerator());
	}

	public static String serializeResource(IBaseResource resource, Boolean flagPrettyPrint, Boolean flagSuppressNarratives, Boolean flagSummaryMode) {
		IParser parser = context.newJsonParser();
		parser.setPrettyPrint(flagPrettyPrint);
		parser.setSuppressNarratives(flagSuppressNarratives);
		parser.setSummaryMode(flagSummaryMode);
		return parser.encodeResourceToString(resource);
	}

	public static <T> T deserializeResource(Class<? extends IBaseResource> resourceClass, String input) {
		IParser parser = context.newJsonParser();
		return (T) parser.parseResource(resourceClass, input);
	}

	public static IGenericClient createClient(String serverURL) {
		return context.newRestfulGenericClient(serverURL);
	}

	public static FhirContext getContext() {
		return context;
	}
	public static byte[] xml2json(byte[] bytes) {
		String xml = new String(bytes);
		String json = xml2json(xml);
		return json.getBytes();
	}
	public static byte[] json2xml(byte[] bytes) {
		String xml = new String(bytes);
		String json = json2xml(xml);
		return json.getBytes();
	}
	public static String xml2json(String xmlStr){
		IParser xmlParser = context.newXmlParser();
		IBaseResource res = xmlParser.parseResource(xmlStr);
		IParser jsonParser = context.newJsonParser();
		jsonParser.setPrettyPrint(true);
		String jsonStr = jsonParser.encodeResourceToString(res);
		return jsonStr;
	}
	public static String json2xml(String jsonStr){
		IParser jsonParser = context.newJsonParser();
		IBaseResource res = jsonParser.parseResource(jsonStr);
		IParser xmlParser = context.newXmlParser();
		jsonParser.setPrettyPrint(true);
		String xmlStr = xmlParser.encodeResourceToString(res);
		return xmlStr;
	}
	
//	public static FHIRTrasformationDTO transform(String xml) {
//		List<IBaseResource> res = new ArrayList<>();
//		String json = xml2json(xml);
//		for (BundleEntryComponent bec:((Bundle)FHIRR4Helper.deserializeResource(Bundle.class, json)).getEntry()) {
//			IBaseResource resource = bec.getResource();
//			res.add(resource);
//		}
//		return FHIRTrasformationDTO.builder().jsonBundle(json).xmlBundle(xml).resources(res).build();
//	}
}