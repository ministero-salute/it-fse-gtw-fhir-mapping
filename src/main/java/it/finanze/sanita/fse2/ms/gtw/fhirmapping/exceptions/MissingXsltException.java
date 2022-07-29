package it.finanze.sanita.fse2.ms.gtw.fhirmapping.exceptions;

/**
 * Exception to be thrown whenever an xslt file is not found on database but is required.
 * 
 * @author Simone Lungarella
 */
public class MissingXsltException extends RuntimeException {
    
    /**
	 * Message constructor.
	 * 
	 * @param msg Message to be shown.
	 */
	public MissingXsltException(final String msg) {
		super(msg);
	}
	
	/**
	 * Complete constructor.
	 * 
	 * @param msg	Message to be shown.
	 * @param e		Exception to be shown.
	 */
	public MissingXsltException(final String msg, final Exception e) {
		super(msg, e);
	}
	
	/**
	 * Exception constructor.
	 * 
	 * @param e	Exception to be shown.
	 */
	public MissingXsltException(final Exception e) {
		super(e);
	}
	
}
