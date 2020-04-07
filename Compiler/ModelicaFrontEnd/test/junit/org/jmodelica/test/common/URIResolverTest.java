package org.jmodelica.test.common;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.fail;

import java.io.File;
import java.io.IOException;

import org.jmodelica.common.URIResolver;
import org.jmodelica.common.URIResolver.PackageNode;
import org.jmodelica.common.URIResolver.URIException;
import org.jmodelica.common.URIResolverMock;
import org.jmodelica.common.URIResolverPackageNodeMock;
import org.junit.Test;

public class URIResolverTest {

    

    /*
     * Test canonicalPath()
     */

    @Test
    public void testCanonicalPath() {
        String path = URIResolverMock.absolutePath("test.txt");
        String res = URIResolver.DEFAULT.canonicalPath(new File(path));
        assertEquals(path, res);
    }

    @Test
    public void testCanonicalPathNoIO() {
        String path = URIResolverMock.absolutePath("test.txt");
        @SuppressWarnings("serial")
        String res = URIResolver.DEFAULT.canonicalPath(new File(path) {
            @Override
            public String getCanonicalPath() throws IOException {
                throw new IOException();
            }
        });
        assertEquals(path, res);
    }

    /*
     * Test resolve()
     */

    @Test
    public void testResolvePathCorrect() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String path = URIResolverMock.absolutePath("pack/subpath");
        String res = URIResolver.DEFAULT.resolve(n, path);
        assertEquals(path, res);
    }

    @Test
    public void testResolvePathMissing() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String path = URIResolverMock.absolutePath("pack/subpath/missing");
        String res = URIResolver.DEFAULT.resolve(n, path);
        assertEquals(path, res);
    }

    @Test
    public void testResolveModelicaCorrect() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String uri = "modelica://pack/subpath";
        String path = URIResolverMock.absolutePath("packpath/subpath");
        String res = URIResolver.DEFAULT.resolve(n, uri);
        assertEquals(path, res);
    }

    /*
     * Test resolveInPackage()
     */

    @Test
    public void testResolveInPackageModelicaCorrect() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String uri = "modelica://pack/subpath";
        String path = URIResolverMock.absolutePath("packpath/subpath");
        String res = URIResolver.DEFAULT.resolveInPackage(n, uri);
        assertEquals(path, res);
    }

    @Test
    public void testResolveInPackageModelicaIncorrect() {
        // TODO: This is a strange test, it is very unclear if the tested behavior is actually the 
        //       desired one. When given a modelica URI with an unknown package as host, shouldn't 
        //       you get a URI exception back? It also seems made redundant by 
        //       testResolveInPackageModelicaIncorrect3() below.
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveInPackage(n, "modelica://pack2/subpath");
        String expected = System.getProperty("user.dir").replaceAll("\\\\", "/") + "/modelica:/pack2/subpath";
        assertEquals(expected, res);
    }

    @Test
    public void testResolveInPackageModelicaIncorrect2() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock() {
            @Override
            public String topPackagePath() {
                return null;
            }
        };
        String res = URIResolver.DEFAULT.resolveInPackage(n, "modelica://pack2/subpath");
        assertNull(res);
    }

    @Test
    public void testResolveInPackageModelicaIncorrect3() {
        // TODO: This is a strange test, it is very unclear if the tested behavior is actually the 
        //       desired one. When given a modelica URI with an unknown package as host, shouldn't 
        //       you get a URI exception back?
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String res = new URIResolverMock().resolveInPackage(n, "modelica://pack2/subpath");
        String path = URIResolverMock.absolutePath("toppath/modelica:/pack2/subpath");
        assertEquals(path, res);
    }

    /*
     * Test resolveURIChecked()
     */

    @Test
    public void testResolveURICheckedCorrect() throws URIException {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        String res = "";
        String uri = "modelica://pack/subpath";
        String path = URIResolverMock.absolutePath("packpath/subpath");
        res = URIResolver.DEFAULT.resolveURIChecked(n, uri);
        assertEquals(path, res);
    }

    @Test
    public void testResolveURICheckedIncorrect() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        try {
            new URIResolverMock().resolveURIChecked(n, "modelica://pack2/subpath");
            fail();
        } catch (URIException e) {
            // expected
        }
    }
    
    @Test
    public void testResolveURICheckedFileCorrect() throws URIException {
        PackageNode n = new URIResolverPackageNodeMock();
        String path = URIResolverMock.absolutePath("/pack/subpath");
        String uri = "file://" + path;
        String res = URIResolver.DEFAULT.resolveURIChecked(n, uri);
        assertEquals(path, res);
    }

    @Test
    public void testResolveURICheckedFileNoHost() throws URIException {
        PackageNode n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveURIChecked(n, "file:///pack/subpath");
        assertEquals("/pack/subpath", res);
    }

    @Test
    public void testResolveURICheckedFileWithHost() throws URIException {
        PackageNode n = new URIResolverPackageNodeMock();
        String res = URIResolver.DEFAULT.resolveURIChecked(n, "file://pack/subpath");
        assertEquals("pack/subpath", res);
    }

    @Test
    public void testResolveURICheckedModelicaIncorrectSyntax() {
        URIResolverPackageNodeMock n = new URIResolverPackageNodeMock();
        try {
            URIResolver.DEFAULT.resolveURIChecked(n, "]");
            fail();
        } catch (URIException e) {
            // expected
        }
    }
}
