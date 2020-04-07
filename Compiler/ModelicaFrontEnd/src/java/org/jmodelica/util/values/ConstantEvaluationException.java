package org.jmodelica.util.values;

// TODO: shouldn't this inherit ModelicaException?
public class ConstantEvaluationException extends RuntimeException {

    private static final long serialVersionUID = 1L;
    private ConstValue val;

    public ConstantEvaluationException(ConstValue val, String op) {
        super(op);
        this.val = val;
    }

    public ConstantEvaluationException() {
        super("Unspecified constant evaluation failure");
        this.val = null;
    }

    /**
     * Gets the CValue that caused the failure.
     */
    public ConstValue getCValue() {
        return val;
    }

    /**
     * Gets the error message.
     */
    @Override
    public String getMessage() {
        return (val == null) ? super.getMessage() :
            "Cannot " + super.getMessage() + val.errorDesc();
    }

    public String getModelicaStackTrace() {
        StringBuilder sb = new StringBuilder();
        buildStackTrace(sb);
        return sb.toString();
    }

    protected static final String STACK_SEP = "\n    ";

    public void buildStackTrace(StringBuilder sb) {
        sb.append(STACK_SEP);
        sb.append(getMessage());
    }

}
