package it.finanze.sanita.fse2.ms.gtw.fhirmapping.utility;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.UUID;

import org.apache.commons.codec.binary.Hex;
import org.hl7.fhir.r4.model.Identifier;

import it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions.BusinessException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public final class StringUtility {

	/**
	 * Private constructor to avoid instantiation.
	 */
	private StringUtility() {
		// Constructor intentionally empty.
	}

	/**
	 * Returns {@code true} if the String passed as parameter is null or empty.
	 * 
	 * @param str	String to validate.
	 * @return		{@code true} if the String passed as parameter is null or empty.
	 */
	public static boolean isNullOrEmpty(final String str) {
		return str == null || str.isEmpty();
	}

	/**
	 * Returns the encoded String of the SHA-256 algorithm represented in base 64.
	 * 
	 * @param objectToEncode String to encode.
	 * @return String Encoded.
	 */
	public static String encodeSHA256B64(String objectToEncode) {
		try {
		    final MessageDigest digest = MessageDigest.getInstance("SHA-256");
		    final byte[] hash = digest.digest(objectToEncode.getBytes());
		    return encodeBase64(hash);
		} catch (Exception e) {
			log.error("Errore in fase di calcolo sha", e);
			throw new BusinessException("Errore in fase di calcolo SHA-256", e);
		}
	}
	
	/**
	 * Returns the encoded String of the SHA-256 algorithm encoded represented in base hex.
	 * 
	 * @param objectToEncode String to encode.
	 * @return String Encoded.
	 */
	public static String encodeSHA256Hex(String objectToEncode) {
		try {
		    final MessageDigest digest = MessageDigest.getInstance("SHA-256");
		    final byte[] hash = digest.digest(objectToEncode.getBytes());
		    return encodeHex(hash);
		} catch (Exception e) {
			log.error("Errore in fase di calcolo sha", e);
			throw new BusinessException("Errore in fase di calcolo SHA-256", e);
		}
	}

	/**
	 * Encode in Base64 the byte array passed as parameter.
	 * 
	 * @param input	The byte array to encode.
	 * @return		The encoded byte array to String.
	 */
	public static String encodeBase64(final byte[] input) {
		return Base64.getEncoder().encodeToString(input);
	}

	/**
	 * Encodes the byte array passed as parameter in hexadecimal.
	 * 
	 * @param input	The byte array to encode.
	 * @return		The encoded byte array to String.
	 */
	public static String encodeHex(final byte[] input) {
		return Hex.encodeHexString(input);
	}
	
	/**
	 * Get filename from complete path.
	 * 
	 * @param completePath	path
	 * @return				filename
	 */
	public static String getFilename(final String completePath) {
		String output = "";
		try {
			Path path = Paths.get(completePath);
			output = path.getFileName().toString(); 
		} catch(Exception ex) {
			log.error("Error to get filename from complete path " , ex);
			throw new BusinessException("Error to get filename from complete path " , ex);
		}
		return output;
	}

	public static String generateUUID() {
	    return UUID.randomUUID().toString();
	}

	public static String getIdentifierAsString(final Identifier identifier) {
		if (identifier != null && identifier.getSystem() != null && identifier.getValue() != null) {
			return (identifier.getSystem() + "|" + identifier.getValue());
		} else {
			return null;
		}
	}
 }
