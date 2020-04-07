package org.jmodelica.util.documentation;

/**
 * Class for exceptions raised from behaviour specific to the
 * {@code DocumentationBuilder}.
 */
public final class DocumentationBuilderException extends RuntimeException {

    /**
     * Serial version identification number.
     */
    private static final long serialVersionUID = 1178042193194517628L;

    /**
     * Constructs a {@code DocumentationBuilderException}.
     * 
     * @param message
     *            The exception message.
     */
    public DocumentationBuilderException(String message) {
        super(message);
    }

}