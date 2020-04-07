package org.jmodelica.util.files;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

/**
 * Utility class for files.
 */
public final class FileUtil {

    /**
     * Hidden default constructor to prevent instantiation.
     */
    private FileUtil() {}

    /**
     * Retrieves all the files from the specified sources.
     * 
     * @param sources
     *            The file sources.
     * @return
     *         a list of files from the specified sources.
     * @see #allFiles(boolean, File...)
     */
    public static List<File> allFiles(File... sources) {
        return allFiles(false, sources);
    }

    /**
     * Retrieves all the directories from the specified sources.
     * 
     * @param sources
     *            The file sources.
     * @return
     *         a list of directories from the specified sources.
     * @see #allFiles(boolean, File...)
     */
    public static List<File> allDirectories(File... sources) {
        return allFiles(true, sources);
    }

    /**
     * Retrieves all the files or directories from the specified sources.
     * 
     * @param sources
     *            The file sources.
     * @param directory
     *            Flag for whether to collect directory names or file names.
     * @return
     *         a list of file names from the specified sources.
     */
    public static List<File> allFiles(boolean directory, File... sources) {
        List<File> files = new ArrayList<File>();
        for (File dir : sources) {

            if (dir.isDirectory()) {
                for (File file : dir.listFiles()) {
                    if (file.isDirectory() == directory) {
                        files.add(file);
                    }
                }
            } else {
                if (!directory) {
                    files.add(dir);
                }
            }
        }
        return files;
    }

    /**
     * Returns a collection of all files at the specified path recursively.
     * 
     * @param path
     *            The path from which to collect files. If {@code path} is a
     *            file it is the only element in the returned
     *            {@link Collection}.
     * @return
     *         a collection of all files at the specified path recursively.
     */
    public static Collection<File> getFilesRecursively(File path) {
        List<File> files = new ArrayList<File>();
        if (path.isFile()) {
            files.add(path);
        } else if (path.isDirectory()) {
            for (File file : path.listFiles()) {
                files.addAll(getFilesRecursively(file));
            }
        }
        return files;
    }

    /**
     * Retrieves all the names of the directories from the specified sources.
     * 
     * @param sources
     *            The file sources.
     * @return
     *         a list of directory names from the specified sources.
     * @see #allFileNames(boolean, File...)
     */
    public static List<String> allDirectoryNames(File... sources) {
        return allFileNames(true, sources);
    }

    /**
     * Retrieves all the names of the files from the specified sources.
     * 
     * @param sources
     *            The file sources.
     * @return
     *         a list of file names from the specified sources.
     * @see #allFileNames(boolean, File...)
     */
    public static List<String> allFileNames(File... sources) {
        return allFileNames(false, sources);
    }

    /**
     * Retrieves all the names of the files from the specified sources.
     * 
     * @param sources
     *            The file sources.
     * @return
     *         a list of file names from the specified sources.
     * @see #allFileNames(boolean, File...)
     */
    public static Collection<String> allFileNames(Collection<File> sources) {
        return allFileNames(sources.toArray(new File[sources.size()]));
    }

    /**
     * Retrieves all the names of the files or directories from the specified
     * sources.
     * 
     * @param sources
     *            The file sources.
     * @param directory
     *            Flag for whether to collect directory names or file names.
     * @return
     *         a list of file names from the specified sources.
     */
    public static List<String> allFileNames(boolean directory, File... sources) {
        List<String> names = new ArrayList<String>();
        for (File file : allFiles(directory, sources)) {
            names.add(file.getName());
        }
        return names;
    }

    /**
     * Copies a file from one location to another.
     * Wrapper function for {@link #copy(File, File, boolean)} defaulting to
     * override any existing file
     * in {@code destination}.
     * 
     * @param source The file to copy.
     * @param destination The location of the copied file.
     * @throws IOException if there was any error copying the file.
     */
    public static void copy(File source, File destination) throws IOException {
        copy(source, destination, true);
    }

    /**
     * Copies a file from one location to another.
     * 
     * @param source The file to copy.
     * @param destination The location of the copied file.
     * @param replace A flag specifying whether or not to replace the file if it
     *            already exists at {@code destination}.
     * @throws IOException if there was any error copying the file.
     */
    public static void copy(File source, File destination, boolean replace) throws IOException {
        if (!source.exists()) {
            return;
        }

        File newFile = destination;
        if (newFile.isDirectory()) {
            newFile = new File(newFile.getAbsolutePath(), source.getName());
        }

        Files.copy(source.toPath(), newFile.toPath(), replace(replace));
    }

    /**
     * Copies files from a source to a destination recursively.
     * <p>
     * Overwrites files if they already exist.
     * 
     * @param source
     *            The source folder or file.
     * @param destination
     *            The destination folder.
     * @param replace
     *            A flag specifying whether or not to replace the file if it
     *            already exists at {@code destination}.
     * @throws IOException
     *             if there was any error copying a file.
     */
    public static void copyRecursive(File source, File destination, boolean replace) throws IOException {
        if (source.isDirectory()) {
            File newDir = new File(destination.getAbsolutePath(), source.getName());
            newDir.mkdirs();
            for (File file : source.listFiles()) {
                copyRecursive(file, newDir, replace);
            }
        } else if (source.isFile()) {
            Files.copy(source.toPath(), new File(destination.getAbsolutePath(), source.getName()).toPath(),
                    replace(replace));
        }
    }

    /**
     * Copies several files to a directory.
     * 
     * @param files
     *            The files to copy.
     * @param destination
     *            The destination of the copied files (if the parameter is a
     *            file, files are copied to the same directory).
     * @param replace
     *            A flag specifying whether or not to replace the file if it
     *            already exists at {@code destination}.
     * @throws IOException
     *             if there was any error copying the files.
     */
    public static void copyRecursive(Collection<File> files, File destination, boolean replace) throws IOException {
        for (File file : files) {
            copyRecursive(file, destination, replace);
        }
    }

    /**
     * Deletes a file or directory recursively.
     * <p>
     * If a file is provided, that file is deleted, if a directory is provided,
     * then all child files and directories are deleted recursively first.
     * <p>
     * The return argument of this method indicates whether the delete was
     * successful, basically an aggregate of the return value for
     * {@link File#delete()}.
     * 
     * @param file The file or directory to delete.
     * @return True if the file doesn't exist, or if, file or entire directory
     *         structure was deleted, otherwise false.
     */
    public static boolean recursiveDelete(File file) {
        if (!file.exists()) {
            return true;
        }
        boolean res = true;
        if (file.isDirectory()) {
            for (File subFile : file.listFiles()) {
                res &= recursiveDelete(subFile);
            }
        }
        res &= file.delete();
        return res;
    }

    /**
     * Retrieves the contents of a file as a list of string lines.
     * 
     * @param file
     *            The file from which to fetch contents.
     * @return
     *         a list of strings where each string is a line in {@code file}.
     * @throws IOException
     *             if there was any error reading {@code file}.
     */
    public static List<String> fileAsLines(File file) throws IOException {
        return Arrays.asList(new String(Files.readAllBytes(Paths.get(file.getAbsolutePath()))).split("\n"));
    }

    /**
     * Filters a set of file on their extensions.
     * 
     * @param files the files to filter.
     * @param extensions the extensions to filter on.
     * @return a collection of files from {@code files} with a file extension
     *         present
     *         in {@code extensions}.
     */
    public static Collection<File> filterOnExtensions(Collection<File> files, String... extensions) {
        Collection<File> filtered = new ArrayList<File>();
        for (File file : files) {
            for (String ext : extensions) {
                if (file.getName().endsWith(ext)) {
                    filtered.add(file);
                    break;
                }
            }
        }
        return filtered;
    }

    /**
     * Quick method for specifying {@link StandardCopyOption#REPLACE_EXISTING}.
     * 
     * @param replace
     *            Flag for whether or not to replace existing files when copying
     *            or moving.
     * @return
     *         {@link StandardCopyOption#REPLACE_EXISTING} if replace is
     *         {@code true}, {@code null} otherwise.
     */
    private static StandardCopyOption replace(boolean replace) {
        return replace ? StandardCopyOption.REPLACE_EXISTING : null;
    }

    /**
     * Creates a list of {@link File} objects from a list of string paths.
     * 
     * @param paths the string paths.
     * @return a list of {@link File} objects.
     */
    public static Collection<File> toFile(String... paths) {
        java.util.List<File> files = new ArrayList<File>();
        for (String name : paths) {
            files.add(new File(name));
        }
        return files;
    }

    /**
     * Creates a list of {@link File} objects from a list of string paths.
     * 
     * @param paths the string paths.
     * @return a list of {@link File} objects.
     */
    public static Collection<File> toFile(List<String> paths) {
        java.util.List<File> files = new ArrayList<File>();
        for (String name : paths) {
            files.add(new File(name));
        }
        return files;
    }

    /**
     * Creates a file object from a list of names.
     * 
     * @param names the names, i.e. directory names and the file name.
     * @return a file pointing to "{@code names[0]/names[1]/...}".
     */
    public static File pathsToFile(String... names) {
        int length = names.length;
        if (length == 0) {
            throw new IllegalArgumentException("Can not build file no names.");
        }

        File file = new File(names[0]);
        for (int i = 1; i < length; ++i) {
            file = new File(file, names[i]);
        }
        return file;
    }

}
