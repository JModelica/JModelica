package org.jmodelica.util.values;
public class FunctionEvaluationException extends ConstantEvaluationException {

    private static final long serialVersionUID = 1L;

    private String functionName;
    private ConstantEvaluationException source;

    public FunctionEvaluationException(String functionName, ConstantEvaluationException source) {
        this.functionName = functionName;
        this.source = source;
    }

    @Override
    public String getMessage() {
        return source.getMessage();
    }

    @Override
    public void buildStackTrace(StringBuilder sb) {
        sb.append(STACK_SEP);
        sb.append("in function '");
        sb.append(functionName);
        sb.append("'");
        source.buildStackTrace(sb);
    }
}