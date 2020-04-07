package org.jmodelica.util.problemHandling;

import org.jmodelica.api.problemHandling.ProblemKind;
import org.jmodelica.api.problemHandling.ProblemSeverity;

/**
 * If you have a error message which only consists of a string and format
 * arguments, then this is the right class for you. Simple create a static
 * final field instantiating this class and then invoke the error as needed!
 */
public class SimpleErrorProducer extends SimpleProblemProducer {

    public SimpleErrorProducer(String identifier, ProblemKind kind, String message) {
        super(identifier, kind, ProblemSeverity.ERROR, message);
    }

}
