/**
 * 
 */
package it.finanze.sanita.fse2.ms.gtw.fhirmapping.unit.helper;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.hl7.fhir.convertors.loaders.R3ToR4Loader;
import org.hl7.fhir.convertors.misc.CDAUtilities;
import org.hl7.fhir.exceptions.FHIRException;
import org.hl7.fhir.r4.context.SimpleWorkerContext;
import org.hl7.fhir.r4.elementmodel.Element;
import org.hl7.fhir.r4.elementmodel.XmlParser;
import org.hl7.fhir.r4.formats.IParser.OutputStyle;
import org.hl7.fhir.r4.formats.JsonParser;
import org.hl7.fhir.r4.model.Base;
import org.hl7.fhir.r4.model.Coding;
import org.hl7.fhir.r4.model.MetadataResource;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.ResourceFactory;
import org.hl7.fhir.r4.model.StructureDefinition;
import org.hl7.fhir.r4.model.StructureDefinition.StructureDefinitionKind;
import org.hl7.fhir.r4.model.StructureMap;
import org.hl7.fhir.r4.model.UriType;
import org.hl7.fhir.r4.test.utils.TestingUtilities;
import org.hl7.fhir.r4.utils.StructureMapUtilities;
import org.hl7.fhir.r4.utils.StructureMapUtilities.ITransformerServices;
import org.hl7.fhir.utilities.TextFile;
import org.hl7.fhir.utilities.Utilities;
import org.hl7.fhir.utilities.npm.FilesystemPackageCacheManager;
import org.hl7.fhir.utilities.npm.ToolsVersion;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.helper.FHIRMappingHelper;
import it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility.FileUtility;
import lombok.extern.slf4j.Slf4j;

/**
 * @author AndreaPerquoti
 *
 */
@Slf4j
@SpringBootTest(classes = { FHIRMappingHelper.class })
@ExtendWith(SpringExtension.class)
@ActiveProfiles("test") 
@DisplayName("FHIR Mapping Unit Test")
class FHIRMappingHelperUnitTests implements ITransformerServices {

	
	@Autowired
	private FHIRMappingHelper fmh;
	
	private static final boolean SAVING = true;
	private FilesystemPackageCacheManager pcm = null;
	private static SimpleWorkerContext contextR3;
	private static SimpleWorkerContext contextR4;
	
	
	private static SimpleWorkerContext contextFinal;
	
	
	@Test
	@Disabled("This microservice is not yet ready")
	@DisplayName("Transform example XML to FHIR")
	void exampleTransformXMLtoFHIR() throws Exception {
		checkLoad();
		StructureMapUtilities smu4 = new StructureMapUtilities(contextR4, this);
		String tn = null;
	    String workingid = null;
		
	    
		// load the example xml
	    byte[] content = FileUtility.getFileFromInternalResources("cdaExample/Esempio CDA2_Referto Medicina di Laboratorio v6_OK.xml");
	    Element cda = new XmlParser(contextR4).parse(new ByteArrayInputStream(content));
	    tn = cda.fhirType();
	    workingid = cda.getChildValue("id");
	    
	    CDAUtilities cdaUtils = new CDAUtilities(null);
	    cdaUtils.getElement();
	}

		
	@Test
	@Disabled("This microservice is not yet ready")
	@DisplayName("Transform example R3 to R4")
	void exampleTransformHelloWord() throws Exception {
		checkLoad();
		StructureMapUtilities smu4 = new StructureMapUtilities(contextR4, this);
	    StructureMapUtilities smu3 = new StructureMapUtilities(contextR3, this);
	    String tn = null;
	    String workingid = null;
	    
	    // load the example (r3)
	    byte[] content = null;
	    Element r3 = new XmlParser(contextR3).parse(new ByteArrayInputStream(content));
	    tn = r3.fhirType();
	    workingid = r3.getChildValue("id");
	    
	    // load r4 structure for target
	    String mapFile = Utilities.path(TestingUtilities.home(), "implementations", "r3maps", "R3toR4", r3.fhirType() + ".map");
	    if (new File(mapFile).exists()) {
	    	
	    	StructureMap sm = smu4.parse(TextFile.fileToString(mapFile), mapFile);
	        tn = smu4.getTargetType(sm).getType();

	        // convert from r3 to r4
	        Resource r4 = ResourceFactory.createResource(tn);
	        smu4.transform(contextR4, r3, sm, r4);

	        
	        // save r4 transformed target
	        List<Resource> extras = new ArrayList<Resource>();
	        ByteArrayOutputStream bs = new ByteArrayOutputStream();
	        new JsonParser().setOutputStyle(OutputStyle.PRETTY).compose(bs, r4);
	        if (SAVING) {
	          TextFile.bytesToFile(bs.toByteArray(), Utilities.path(TestingUtilities.home(), "implementations", "r3maps", "test-output", tn + "-" + workingid + ".r4.json"));
	          for (Resource r : extras) {
	            bs = new ByteArrayOutputStream();
	            new JsonParser().setOutputStyle(OutputStyle.PRETTY).compose(bs, r);
	            TextFile.bytesToFile(bs.toByteArray(), Utilities.path(TestingUtilities.home(), "implementations", "r3maps", "test-output", r.fhirType() + "-" + r.getId() + ".r4.json"));
	          }
	        }

	    	
	    }
	}


	/*
	   * Supporting multiple versions at once is a little tricky. We're going to have
	   * 2 contexts: - an R3 context which is used to read/write R3 instances - an R4
	   * context which is used to perform the transforms
	   *
	   * R3 structure definitions are cloned into R3 context with a modified URL (as
	   * 3.0/)
	   *
   	*/
	private void checkLoad() throws IOException, FHIRException, Exception {
	    if (contextR3 != null) {
	    	return;
	    }

	    try {
	    	
	    	pcm = new FilesystemPackageCacheManager(true, ToolsVersion.TOOLS_VERSION);
		    R3ToR4Loader ldr = (R3ToR4Loader) new R3ToR4Loader().setPatchUrls(true).setKillPrimitives(true);
		
		    
		    log.info("loading R3");
			contextR3 = new SimpleWorkerContext();
			contextR3.setAllowLoadingDuplicates(true);
			contextR3.setOverrideVersionNs("http://hl7.org/fhir/3.0/StructureDefinition");
			contextR3.loadFromPackage(pcm.loadPackage("hl7.fhir.core", "3.0.1"), ldr, new String[]{});
			
			log.info("loading R4");
			contextR4 = new SimpleWorkerContext();
			contextR4 = SimpleWorkerContext.fromPackage(pcm.loadPackage("hl7.fhir.core", "4.0.0"));
			contextR4.setCanRunWithoutTerminology(true);
			
			for (StructureDefinition sd : contextR3.allStructures()) {
			  StructureDefinition sdn = sd.copy();
			  sdn.getExtension().clear();
			  contextR4.cacheResource(sdn);
			}
			
			for (StructureDefinition sd : contextR4.allStructures()) {
			  if (sd.getKind() == StructureDefinitionKind.PRIMITIVETYPE) {
			    contextR3.cacheResource(sd);
			    StructureDefinition sdn = sd.copy();
			    sdn.setUrl(sdn.getUrl().replace("http://hl7.org/fhir/", "http://hl7.org/fhir/3.0/"));
			    sdn.addExtension().setUrl("http://hl7.org/fhir/StructureDefinition/elementdefinition-namespace").setValue(new UriType("http://hl7.org/fhir"));
			    contextR3.cacheResource(sdn);
			    contextR4.cacheResource(sdn);
			  }
			}
			
			contextR3.setExpansionProfile(new org.hl7.fhir.r4.model.Parameters());
			contextR4.setExpansionProfile(new org.hl7.fhir.r4.model.Parameters());
			contextR3.setName("R3");
			contextR4.setName("R4");
			
			//   contextR4.setValidatorFactory(new InstanceValidatorFactory());
			// TODO: this has to be R% now...    contextR4.setValidatorFactory(new InstanceValidatorFactory());
			
			log.info("loading Maps");
			
			loadLib(Utilities.path(TestingUtilities.home(), "implementations", "r3maps", "R4toR3"));
			loadLib(Utilities.path(TestingUtilities.home(), "implementations", "r3maps", "R3toR4"));
			
			log.info("loaded");	    	
			
		} catch (Exception e) {
			log.error("Check load failed: ", e);
			throw e;
		}

	}
	
	private void loadLib(String dir) throws FileNotFoundException, IOException {
		
	    StructureMapUtilities smu = new StructureMapUtilities(contextR4);
	    for (String s : new File(dir).list()) {
	      String map = TextFile.fileToString(Utilities.path(dir, s));
	      
	      try {
	        StructureMap sm = smu.parse(map, s);
	        contextR3.cacheResource(sm);
	        contextR4.cacheResource(sm);
	        for (Resource r : sm.getContained()) {
	          if (r instanceof MetadataResource) {
	            MetadataResource mr = (MetadataResource) r.copy();
	            mr.setUrl(sm.getUrl() + "#" + r.getId());
	            contextR3.cacheResource(mr);
	            contextR4.cacheResource(mr);
	          }
	        }
	      
	      } catch (FHIRException e) {
	        log.error("Unable to load " + Utilities.path(dir, s) + ": " + e.getMessage());
//	        loadErrors.put(s, e);
	        // e.printStackTrace();
	      }
	    }
	    
	}



	@Override
	public void log(String message) {
		// TODO Auto-generated method stub
		throw new Error("translate not done yet");
	}


	@Override
	public Base createType(Object appInfo, String name) throws FHIRException {
		// TODO Auto-generated method stub
		throw new Error("translate not done yet");
	}


	@Override
	public Base createResource(Object appInfo, Base res, boolean atRootofTransform) {
		// TODO Auto-generated method stub
		throw new Error("translate not done yet");
	}


	@Override
	public Coding translate(Object appInfo, Coding source, String conceptMapUrl) throws FHIRException {
		// TODO Auto-generated method stub
		throw new Error("translate not done yet");
	}


	@Override
	public Base resolveReference(Object appContext, String url) throws FHIRException {
		// TODO Auto-generated method stub
		throw new Error("translate not done yet");
	}


	@Override
	public List<Base> performSearch(Object appContext, String url) throws FHIRException {
		// TODO Auto-generated method stub
		throw new Error("translate not done yet");
	}
		  
}
