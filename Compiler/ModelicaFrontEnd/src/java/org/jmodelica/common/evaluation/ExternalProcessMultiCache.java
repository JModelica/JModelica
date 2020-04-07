package org.jmodelica.common.evaluation;

import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import org.jmodelica.common.LogContainer;
import org.jmodelica.common.options.AbstractOptionRegistry;
import org.jmodelica.util.ccompiler.CCompilerDelegator;
import org.jmodelica.util.exceptions.CcodeCompilationException;

public class ExternalProcessMultiCache<K extends ExternalProcessMultiCache.Variable<V, T>, V extends ExternalProcessMultiCache.Value, T extends ExternalProcessMultiCache.Type<V>, E extends ExternalProcessMultiCache.External<K>> {

    public interface Compiler<K, E extends External<K>> extends LogContainer {
        public String compileExternal(E ext) throws FileNotFoundException, CcodeCompilationException;

        public CCompilerDelegator getCCompiler();
    }

    public interface External<K> {
        public String getName();

        public boolean shouldCacheProcess();

        public AbstractOptionRegistry myOptions();

        public String libraryDirectory();

        public K cachedExternalObject();

        public Iterable<K> externalObjectsToSerialize();

        public Iterable<K> functionArgsToSerialize();

        public Iterable<K> varsToDeserialize();
    }

    public interface Variable<V extends Value, T extends Type<V>> {
        public V ceval();

        public T type();
    }

    public interface Value {
        public String getMarkedExternalObject();

        public void serialize(BufferedWriter out) throws IOException;
    }

    public interface Type<V extends Value> {
        public V deserialize(ProcessCommunicator<V, ? extends Type<V>> processCommunicator) throws IOException;
    }

    private Map<String, ExternalProcessCache<K, V, T, E>> map = new LinkedHashMap<>();

    private Compiler<K, E> mc;

    public ExternalProcessMultiCache(Compiler<K, E> mc) {
        this.mc = mc;
    }

    public ExternalProcessCache<K, V, T, E> getExternalProcessCache(String key) {
        ExternalProcessCache<K, V, T, E> ce = map.get(key);
        if (ce == null) {
            ce = createCachedExternals();
            map.put(key, ce);
        }
        return ce;
    }
    
    public ExternalProcessCache<K, V, T, E> createCachedExternals() {
        return new ExternalProcessCacheImpl<K, V, T, E>(mc);
    }

    public void destroyProcesses() {
        for (ExternalProcessCache<K, V, T, E> ce : map.values()) {
            ce.destroyProcesses();
        }
    }

    public void tearDown() {
        for (ExternalProcessCache<K, V, T, E> ce : map.values()) {
            ce.tearDown();
        }
        map.clear();
    }

    public void tearDown(String key) {
        ExternalProcessCache<K, V, T, E> ce = map.remove(key);
        if (ce != null) {
            ce.tearDown();
        }
    }

}
