package org.jmodelica.util.problemHandling;

import org.jmodelica.common.options.AbstractOptionRegistry;

public interface ProblemOptionsProvider {
    public AbstractOptionRegistry getOptionRegistry();
    public boolean filterThisWarning(String identifier);
}
