package org.jmodelica.common;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.jmodelica.util.exceptions.InternalCompilerError;
import org.jmodelica.util.files.FileUtil;

public final class ResourceLoader {

    private final List<String> resourcePaths;

    public ResourceLoader(List<String> resourcePaths) {
        this.resourcePaths = resourcePaths;
    }

    /**
     * Copies all files included by {@code loadResource(...)} to resource folder.
     * 
     * @return A list of error messages
     */
    public List<String> loadResources(File outputDirectory) {
        ArrayList<String> errors = new ArrayList<>();
        int i = 0;
        for (String resourcePath : resourcePaths) {
            File destination = new File(outputDirectory, Integer.toString(i++));
            File resource = new File(resourcePath);

            if (checkResourceErrors(errors, resource)) {
                continue;
            }

            destination.mkdirs();

            copyResource(errors, destination, resource);
        }
        return errors;
    }

    private static boolean checkResourceErrors(ArrayList<String> errors, File resource) {
        String message = null;
        String absolutePath = resource.getAbsolutePath();

        if (!resource.exists()) {
            message = String.format("Resource file '%s' does not exist", absolutePath);
        } else if (resource.isDirectory()) {
            message = String.format("Resource file '%s' is a directory.", absolutePath);
        }

        if (message != null) {
            errors.add(message);
            return true;
        }

        return false;
    }

    private static void copyResource(ArrayList<String> errors, File destination, File resource) {
        try {
            FileUtil.copy(resource, destination);
        } catch (IOException exception) {
            errors.add("Could not copy resource: " + resource.getAbsolutePath() + " to destination: '"
                    + destination.getAbsolutePath() + "': " + exception.getMessage());
        }
    }

    /**
     * Get the path of a loaded resource relative to the directory it was loaded
     * into.
     */
    public String loadedResourceRelativePath(String resourceOriginalPath) {
        int index = resourcePaths.indexOf(resourceOriginalPath);
        if (index < 0) {
            throw new InternalCompilerError("Missing resource in ResourceLoader: " + resourceOriginalPath);
        }
        return String.format("%d/%s", index, new File(resourceOriginalPath).getName());
    }

}
