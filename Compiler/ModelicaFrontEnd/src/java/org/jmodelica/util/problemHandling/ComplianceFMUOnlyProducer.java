package org.jmodelica.util.problemHandling;

import org.jmodelica.api.problemHandling.ProblemKind;

/**
 * ErrorProducer which only produces errors if we are compiling anything other
 * than a FMU. This class will suffix the message provided to the constructor 
 * with the phrase " currently only supported when compiling FMUs", so adapt
 * your message accordingly!
 */
public class ComplianceFMUOnlyProducer extends SimpleErrorProducer {

    public ComplianceFMUOnlyProducer(String identifier, String message) {
        super(identifier, ProblemKind.COMPLIANCE, message + " currently only supported when compiling FMUs");
    }

    @Override
    public void invoke(ReporterNode src, Object ... args) {
        if (!src.myProblemOptionsProvider().getOptionRegistry().getBooleanOption("generate_ode")) {
            super.invoke(src, args);
        }
    }
}
