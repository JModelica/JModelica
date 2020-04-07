package org.jmodelica.util.problemHandling;

import org.jmodelica.api.problemHandling.ProblemKind;
import org.jmodelica.api.problemHandling.ProblemSeverity;

public class SanityProblemProducer extends ProblemProducer<ReporterNode> {

    public SanityProblemProducer() {
        super("DEBUG_SANITY_CHECK", ProblemKind.SEMANTIC);
    }

    @Override
    public String description() {
        return "Problem discovered during sanity check between transformation steps.";
    }

    @Override
    public ProblemSeverity severity() {
        return ProblemSeverity.ERROR;
    }

    public void invoke(ReporterNode src, String step, int num, String message, Object... args) {
        invoke(src, ProblemSeverity.ERROR, "Sanity check after step %d, %s: %s", num, step, String.format(message, args));
    }

}
