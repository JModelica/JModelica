package org.jmodelica.util.problemHandling;

import org.jmodelica.api.problemHandling.ProblemKind;
import org.jmodelica.api.problemHandling.ProblemSeverity;

/**
 * Abstract base class for all types of problem messages which only consists of
 * a message and some optional format parameters.
 */
public abstract class SimpleProblemProducer extends ProblemProducer<ReporterNode> {

    private final String message;
    private final ProblemSeverity severity;

    protected SimpleProblemProducer(String identifier, ProblemKind kind, ProblemSeverity severity, String message) {
        super(identifier, kind);
        this.message = message;
        this.severity = severity;
    }

    public void invoke(ReporterNode src, Object ... args) {
        invoke(src, severity, message, args);
    }

    @Override
    public String description() {
        return message;
    }

    @Override
    public ProblemSeverity severity() {
        return severity;
    }
}
