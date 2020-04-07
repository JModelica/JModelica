package org.jmodelica.util.exceptions;

/**
 * Exception that is useful to throw when we encounter an internal error in the
 * compiler. The idea is that we should use this in all location where we don't
 * expect the execution flow to go but, the Java compiler thinks that it can.
 */
public class InternalCompilerError extends ModelicaException {

    private static final long serialVersionUID = 2L;

    /**
     * Constructs a new exception, this constructor take a message and an
     * optional number of arguments. The message and argument is then formatted
     * using {@link String#format(String, Object...)}.
     * 
     * @param msg Error message in the form of a formatting string
     * @param args Formatting arguments
     */
    public InternalCompilerError(String msg, Object ... args) {
        super(String.format(msg, args));
    }

    /**
     * Same as {@link #InternalCompilerError(String, Object...)} but also takes
     * a causing exception.
     * 
     * @param cause The underlying exception
     * @param msg Error message in the form of a formatting string
     * @param args Formatting arguments
     */
    public InternalCompilerError(Exception cause, String msg, Object ... args) {
        super(String.format(msg, args), cause);
    }

    /**
     * Simple constructor which only takes a message and underlying cause, no
     * formatting is done.
     * 
     * @param msg Error message
     * @param cause The underlying exception
     */
    public InternalCompilerError(String msg, Exception cause) {
        this(cause, msg);
    }
}
