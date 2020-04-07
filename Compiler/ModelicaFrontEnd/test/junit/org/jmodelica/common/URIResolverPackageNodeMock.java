package org.jmodelica.common;

import org.jmodelica.common.URIResolver.PackageNode;

public class URIResolverPackageNodeMock implements PackageNode {
    private static final String FILE_NAME = "fileName";
    private static final String PACKAGE_PATH = URIResolverMock.absolutePath("packpath");
    private static final String TOP_PACKAGE_PATH = URIResolverMock.absolutePath("toppath");

    private boolean hasError = false;

    public boolean hasError() {
        return hasError;
    }

    @Override
    public String fileName() {
        return FILE_NAME;
    }

    @Override
    public String packagePath(String authority) {
        return authority.equals("pack") ? PACKAGE_PATH : null;
    }

    @Override
    public String topPackagePath() {
        return TOP_PACKAGE_PATH;
    }

    @Override
    public void error(String format, Object... args) {
        hasError = true;
    }
}