package org.jmodelica.util.problemHandling;

import org.jmodelica.api.problemHandling.ProblemKind;
import org.jmodelica.api.problemHandling.ProblemSeverity;

public abstract class AbstractErrorProducerUnlessDisabled<T extends ReporterNode> extends ProblemProducer<T> {

    public AbstractErrorProducerUnlessDisabled(String identifier, ProblemKind kind) {
        super(identifier, kind);
    }

    protected void invokeWithCondition(T src, boolean condition, String message, Object... args) {
        ProblemSeverity severity = ProblemSeverity.ERROR;
        if (condition && src.inDisabledComponent()) {
            message = "Found error in disabled conditional:\n  " + message;
            severity = ProblemSeverity.WARNING;
        }
        invoke(src, severity, message, args);
    }

    @Override
    public ProblemSeverity severity() {
        return null;
    }

}
