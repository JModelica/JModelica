package org.jmodelica.util.problemHandling;

import org.jmodelica.api.problemHandling.ProblemKind;
import org.jmodelica.api.problemHandling.ProblemSeverity;

public class ErrorProducerUnlessDisabled extends AbstractErrorProducerUnlessDisabled<ReporterNode> {

    private final String message;
    
    public ErrorProducerUnlessDisabled(String identifier, ProblemKind kind, String message) {
        super(identifier, kind);
        this.message = message;
    }

    public void invoke(ReporterNode src, Object... args) {
        invokeWithCondition(src, true, args);
    }

    public void invokeWithCondition(ReporterNode src, boolean condition, Object... args) {
        invokeWithCondition(src, condition, message, args);
    }
    
    @Override
    public String description() {
        return message;
    }
    
    @Override
    public ProblemSeverity severity() {
        return null;
    }

}
