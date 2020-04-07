package org.jmodelica.test.common;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;

import org.jmodelica.common.ResourceLoader;
import org.jmodelica.util.exceptions.InternalCompilerError;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class ResourceLoaderTests {

    private ResourceLoader rl;
    
    @Before
    public void setUp() {
        ArrayList<String> resourcePaths = new ArrayList<>();
        resourcePaths.add("/path1/resource1");
        resourcePaths.add("/path2/resource2");
        rl = new ResourceLoader(resourcePaths);
    }
    
    @After
    public void tearDown() {
        rl = null;
    }
    
    @Test
    public void testLoadedResourceRelativePath() {
        assertEquals("1/resource2", rl.loadedResourceRelativePath("/path2/resource2"));
    }
    
    @Test
    public void testNoSuchLoadedResourceRelativePath() {
        try {
            rl.loadedResourceRelativePath("/path3/missing");
            fail();
        } catch (InternalCompilerError e) {
            // expected
        }
    }
    
    @Test
    public void testLoadResources() {
        Collection<String> errors = rl.loadResources(new File("resources"));
        assertEquals(2, errors.size());
    }

}
