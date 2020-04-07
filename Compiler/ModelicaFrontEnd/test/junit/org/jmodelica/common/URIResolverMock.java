package org.jmodelica.common;

import java.io.File;
import java.net.URI;

public class URIResolverMock extends URIResolver {
    public static final File ROOT = File.listRoots()[0];

    @Override
    boolean exists(File f) {
        return true;
    }

    @Override
    String scheme(URI uri) {
        return null;
    }

    /**
     * Helper method that converts a path relative to the root of the file system 
     * to an absolute path, and replaces any back slashes with forward slashes.
     * 
     * @param path  the relative path
     * @return      the absolute path
     */
    public static String absolutePath(String path) {
        return new File(ROOT, path).getAbsolutePath().replace('\\', '/');
    }
}
