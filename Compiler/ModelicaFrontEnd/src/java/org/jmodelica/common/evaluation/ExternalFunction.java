package org.jmodelica.common.evaluation;

import java.io.IOException;
import java.util.Map;

import org.jmodelica.common.evaluation.ExternalProcessMultiCache.External;

/**
 * Represents an external function that can be evaluated using
 * {@link #evaluate}.
 */
public interface ExternalFunction<K, V> {

    public int evaluate(External<K> ext, Map<K, V> values, int timeout) throws IOException;

    public void destroyProcess();

    public void remove();

    public String getMessage();
}