package org.jmodelica.common.evaluation;

import org.jmodelica.common.evaluation.ExternalProcessMultiCache.External;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.Type;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.Value;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.Variable;

public abstract class ExternalProcessCache<K extends Variable<V, T>, V extends Value, T extends Type<V>, E extends External<K>> {

    /**
     * If there is no executable corresponding to <code>ext</code>, create one.
     */
    public abstract ExternalFunction<K, V> getExternalFunction(E ext);

    /**
     * Remove executables compiled by the constant evaluation framework.
     */
    public abstract void removeExternalFunctions();

    /**
     * Kill cached processes
     */
    public abstract void destroyProcesses();

    protected abstract void tearDown();

    public abstract ExternalFunction<K, V> failedEval(External<?> ext, String msg, boolean log);
    

}
