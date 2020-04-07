package org.jmodelica.test.common;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.IOException;

import org.jmodelica.common.evaluation.ExternalProcessCache;
import org.jmodelica.common.evaluation.ExternalFunction;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.Variable;
import org.jmodelica.common.options.AbstractOptionRegistry;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.Value;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.Type;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.External;
import org.jmodelica.common.evaluation.ProcessCommunicator;
import org.jmodelica.util.ccompiler.CCompilerDelegator;
import org.jmodelica.util.exceptions.CcodeCompilationException;
import org.jmodelica.util.logging.ModelicaLogger;
import org.junit.Test;

public class ExternalProcessCacheTest {

    private TestLogger log = new TestLogger();

    /**
     * Test that tearDown call reaches the ExternalFunction
     */
    @Test
    public void testTearDown1() {
        String key1 = "key1";
        ExternalMock ext1 = new ExternalMock();
        CompilerMock comp = new CompilerMock();
        ExternalProcessMultiCache<VariableMock, ValueMock, TypeMock, ExternalMock> epc = new ExternalProcessCacheMock<>(comp);
        ExternalProcessCache<VariableMock, ValueMock, TypeMock, ExternalMock> ce1 = epc.getExternalProcessCache(key1);
        ce1.getExternalFunction(ext1);
        assertNull(log.next());
        epc.tearDown();
        assertEquals("INFO: Called tearDown()", log.next());
        assertNull(log.next());
    }

    @Test
    public void testTearDown2() {
        String key1 = "key1";
        String key2 = "key2";
        ExternalProcessMultiCache<VariableMock, ValueMock, TypeMock, ExternalMock> epc = new ExternalProcessCacheMock<>(null);
        ExternalProcessCache<VariableMock, ValueMock, TypeMock, ExternalMock> ce1 = epc.getExternalProcessCache(key1);
        ExternalProcessCache<VariableMock, ValueMock, TypeMock, ExternalMock> ce2 = epc.getExternalProcessCache(key2);
        assertTrue(ce1 != ce2);
        assertTrue(ce1 == epc.getExternalProcessCache(key1));
        assertTrue(ce2 == epc.getExternalProcessCache(key2));
        epc.tearDown(key1);
        assertEquals("INFO: Called tearDown()", log.next());
        assertNull(log.next());
        assertTrue(ce1 != epc.getExternalProcessCache(key1));
        assertTrue(ce2 == epc.getExternalProcessCache(key2));
        epc.tearDown(key2);
        assertEquals("INFO: Called tearDown()", log.next());
        assertNull(log.next());
        assertTrue(ce1 != epc.getExternalProcessCache(key1));
        assertTrue(ce2 != epc.getExternalProcessCache(key2));
        epc.tearDown();
        assertEquals("INFO: Called tearDown()", log.next());
        assertEquals("INFO: Called tearDown()", log.next());
        assertNull(log.next());
        epc.tearDown();
        assertNull(log.next());
    }

    class ExternalProcessCacheMock<K extends Variable<V,T>, V extends Value, T extends Type<V>, E extends External<K>> extends ExternalProcessMultiCache<K,V,T,E> {

        public ExternalProcessCacheMock(Compiler<K,E> mc) {
            super(mc);
        }

        @Override
        public ExternalProcessCache<K, V, T, E> createCachedExternals() {
            return new CachedExternalsMock<K, V, T, E>();
        }
    }
    
    class CachedExternalsMock<K extends Variable<V,T>, V extends Value, T extends Type<V>, E extends External<K>> extends ExternalProcessCache<K,V,T,E> {

        @Override
        public ExternalFunction<K,V> getExternalFunction(E ext) {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public void removeExternalFunctions() {
            log.info("Called removeExternalFunctions()");
            
        }

        @Override
        public void destroyProcesses() {
            log.info("Called destroyProcesses()");
        }

        @Override
        protected void tearDown() {
            log.info("Called tearDown()");
        }

        @Override
        public ExternalFunction<K,V> failedEval(External<?> ext, String msg, boolean log) {
            // TODO Auto-generated method stub
            return null;
        }
        
    }

    class CompilerMock implements ExternalProcessMultiCache.Compiler<VariableMock, ExternalMock> {

        @Override
        public ModelicaLogger log() {
            return log;
        }

        @Override
        public String compileExternal(ExternalMock ext) throws FileNotFoundException, CcodeCompilationException {
            throw new CcodeCompilationException();
        }

        @Override
        public CCompilerDelegator getCCompiler() {
            // TODO Auto-generated method stub
            return null;
        }

    }

    class VariableMock implements ExternalProcessMultiCache.Variable<ValueMock, TypeMock> {

        @Override
        public ValueMock ceval() {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public TypeMock type() {
            // TODO Auto-generated method stub
            return null;
        }

    }

    class ValueMock implements ExternalProcessMultiCache.Value {

        @Override
        public String getMarkedExternalObject() {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public void serialize(BufferedWriter out) throws IOException {
            // TODO Auto-generated method stub

        }

    }

    class TypeMock implements ExternalProcessMultiCache.Type<ValueMock> {

        @Override
        public ValueMock deserialize(
                ProcessCommunicator<ValueMock, ? extends org.jmodelica.common.evaluation.ExternalProcessMultiCache.Type<ValueMock>> processCommunicator)
                throws IOException {
            // TODO Auto-generated method stub
            return null;
        }

    }

    class ExternalMock implements ExternalProcessMultiCache.External<VariableMock> {

        @Override
        public String getName() {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public boolean shouldCacheProcess() {
            // TODO Auto-generated method stub
            return false;
        }

        @Override
        public AbstractOptionRegistry myOptions() {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public String libraryDirectory() {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public VariableMock cachedExternalObject() {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public Iterable<VariableMock> externalObjectsToSerialize() {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public Iterable<VariableMock> functionArgsToSerialize() {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public Iterable<VariableMock> varsToDeserialize() {
            // TODO Auto-generated method stub
            return null;
        }

    }

}
