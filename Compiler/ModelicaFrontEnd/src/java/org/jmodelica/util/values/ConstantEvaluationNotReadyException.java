package org.jmodelica.util.values;
public class ConstantEvaluationNotReadyException extends ConstantEvaluationException {
	
    private static final long serialVersionUID = 1L;

    public ConstantEvaluationNotReadyException() {
        super(null, "Cannot evaluate expression yet");
    }

}