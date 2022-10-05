package it.finanze.sanita.fse2.ms.gtw.fhirmapping.config;

/**
 * 
 * @author vincenzoingenito
 *
 * Constants application.
 */
public final class Constants {

	/**
	 *	Path scan.
	 */
	public static final class ComponentScan {

		/**
		 * Base path.
		 */
		public static final String BASE = "it.sanita.fse.fhirmapping";

		/**
		 * Controller path.
		 */
		public static final String CONTROLLER = "it.sanita.fse.fhirmapping.controller";

		/**
		 * Service path.
		 */
		public static final String SERVICE = "it.sanita.fse.fhirmapping.service";

		/**
		 * Configuration path.
		 */
		public static final String CONFIG = "it.sanita.fse.fhirmapping.config";
		
		/**
		 * Configuration mongo path.
		 */
		public static final String CONFIG_MONGO = "it.sanita.fse.fhirmapping.config.mongo";
		
		/**
		 * Configuration mongo repository path.
		 */
		public static final String REPOSITORY_MONGO = "it.sanita.fse.fhirmapping.repository";

		public static final class Collections {

			public static final String XSL_TRANSFORM = "xsl_transform";

			private Collections() {

			}
		}
		
		private ComponentScan() {
			//This method is intentionally left blank.
		}

	}

	public static final class XSLT {

		private XSLT() {
			//This method is intentionally left blank.
		}

		/**
		 * Constants that define xslt fields related to priority algorithm to remove duplicates.
		 */
		public static final String PRIORITY_CONST = "###PRIOR###";

		/**
		 * Constant that defines bundle fhir language.
		 */
		public static final String BUNDLE_FHIR_LANGUAGE = "it-IT";

		/**
		 * Constant that defines bundle fhir type.
		 */
		public static final String BUNDLE_FHIR_MIME_TYPE = "application/pdf";

		/**
		 * Constant that defines bundle fhir document reference identifier.
		 */
		public static final String BUNDLE_FHIR_DOCUMENT_REFERENCE_ID = "Document00";
	}
 
	public static final class Profile {
		public static final String TEST = "test";

		public static final String TEST_PREFIX = "test_";

		/** 
		 * Constructor.
		 */
		private Profile() {
			//This method is intentionally left blank.
		}

	}
  
	/**
	 *	Constants.
	 */
	private Constants() {

	}

}
