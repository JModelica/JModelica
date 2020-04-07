/*
    Copyright (C) 2009-2018 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.jmodelica.util.ccompiler;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import org.jmodelica.common.options.AbstractOptionRegistry;
import org.jmodelica.util.SystemUtil;
import org.jmodelica.util.files.FileUtil;
import org.jmodelica.util.logging.ModelicaLogger;

/**
 * Base class for interface to C compiler.
 * 
 * To add a new delegator, call {@link #addDelegator(String, CCompilerDelegator.Creator)} before 
 * AbstractOptionRegistry is instantiated. This is preferably accomplished by using a JastAdd
 * aspect to add a static field in this class that gets its value from addDelegator().
 */
public abstract class CCompilerDelegator {
    private static final Map<String, Creator> creators = new HashMap<String, Creator>();
    
    public static final String OPTION = "c_compiler";
    public static final String OPTION_DESC = "The C compiler to use to compile generated C code.";
    
    public interface Creator {
        public CCompilerDelegator create();
    }
    
    private final File jmHome;
    private final String buildPlatform;
    
    public CCompilerDelegator(File jmHome, String buildPlatform) {
        this.jmHome = jmHome;
        this.buildPlatform = buildPlatform;
    }
    
    public File getJMHome() {
        return jmHome;
    }
    
    public String getBuildPlatform() {
        return buildPlatform;
    }
    
    /**
     * Add support for a new compiler delegator.
     * 
     * @param name     a short name for the delegator that the user can use to select it
     * @param creator  the creator for the delegator class
     */
    public static Creator addDelegator(String name, Creator creator) {
        if (creators.containsKey(name)) {
            throw new IllegalArgumentException("Compiler delegator name " + name + 
                    " is already used by " + creators.get(name).create().getClass().getSimpleName());
        }
        creators.put(name, creator);
        return creator;
    }
    
    /**
     * Create a C compiler delegator for the given set of options.
     * Not case sensitive. Comparation is done in lower case.
     */
    public static CCompilerDelegator delegatorFor(String c_compiler) {
        Creator c = creators.get(c_compiler.toLowerCase());
        if (c == null) {
            throw new IllegalArgumentException("c_compiler doesn't support option " + c_compiler);
        }
        return c.create();
    }
    
    public static void addCompilerOptionValues(AbstractOptionRegistry opt) {
        for (String name : creators.keySet())
            opt.addStringOptionAllowed(OPTION, name);
    }
    
    private static Map<String, String> env = System.getenv();
    private String[] targetPlatforms = null;

    protected Set<String> sharedLibs = new HashSet<String>();
    protected java.util.List<String> moduleLibNames;

    public void setModuleLibraryNames(java.util.List<String> names) {
        moduleLibNames = names;
    }

    /**
     * "Expands" libraries, i.e., generates path strings for a directory and all the subdirectories within it where
     * libraries should be searched for.
     * <p>
     * E.g. for the path set ["/dir"] and with the {@code subDir} argument equal to ["dir1", "dir2"],
     * the following paths are generated:
     * <ul>
     * <li>"/dir/dir1/dir2"</li>
     * <li>"/dir/dir1"</li>
     * <li>"/dir"</li>
     * </ul>
     * 
     * @param paths
     *          The paths to the library directories which to expand.
     * @param subDirs
     *          The sub-directories of the paths in {@code paths} for which to generate library sub-directories.
     * @return
     *          a set of all sub-directories 
     */
    public Set<String> expandLibraries(Set<String> paths, String... subDirs) {
        Set<String> libraries = new LinkedHashSet<String>();

        for (String path : paths) {
            expandLibraries(libraries, subDirs, path, 0);
        }
        return libraries;
    }

    private void expandLibraries(Set<String> newPaths, String[] subDirs, String workingPath, int currentIndex) {
        String newPath = workingPath;
        if (currentIndex > 0) {
            newPath = newPath + "/" + subDirs[currentIndex - 1];
        }
        if (currentIndex < subDirs.length) {
            expandLibraries(newPaths, subDirs, newPath, currentIndex + 1);
        }
        newPaths.add(newPath);
    }

    /**
     * Compile DLL(s) from generated C code.
     */
    public final void compileCCode(ModelicaLogger log, CCompilerArguments args, File workDir) {
        compileCCode(log, args, workDir, getTargetPlatforms());
    }
    
    /**
     * Sets <code>platform</code> arch to 32 bit if not in <code>targetPlatforms</code>
     */
    public static String reduceBits(String platform, String[] targetPlatforms) {
        if (!Arrays.asList(targetPlatforms).contains(platform)) {
            platform = platform.substring(0, platform.length() - 2) + "32";
        }
        return platform;
    }
    
    /**
     * Compile an executable for build platform.
     */
    public final String compileCCodeLocal(ModelicaLogger log, CCompilerArguments args, File workDir) {
        String[] platform = {reduceBits(getBuildPlatform(), getTargetPlatforms())};
        compileCCode(log, args, workDir, platform);
        File dir = new File(workDir, "binaries");
        File executable = new File(dir, args.getFileName() + SystemUtil.executableExtension());
        return executable.getAbsolutePath();
    }
    
    /**
     * Compile DLL(s) from generated C code for a set of target platforms.
     */
    protected abstract void compileCCode(ModelicaLogger log, CCompilerArguments args, File workDir, String[] platforms);
    
    abstract protected String[] getDefaultTargetPlatforms();
    
    public String[] getTargetPlatforms() {
        if (targetPlatforms != null)
            return targetPlatforms;
        else
            return getDefaultTargetPlatforms();
    }
    
    public void setTargetPlatforms(String[] platforms) {
        targetPlatforms = platforms;
    }
    
    /**
     * Copy shared libs to binaries[\<platform>] folder.
     */
    public void copySharedLibs(File outDir, Set<String> ext_libs) {
        for (String platform : getTargetPlatforms()) {
            StringOperation po = new PlatformDirOperation(platform);
            StringOperation sh = new SharedLibOperation(platform);
            for (String dir : sharedLibs) {
                String dirpath = po.op(dir);
                for (String lib : ext_libs) {
                    String libname = sh.op(lib);
                    File shlib = new File(dirpath, libname);
                    if (shlib.exists()) {
                        String destfile = "binaries" + File.separator + platform + File.separator + libname; 
                        File destdir = new File(outDir, destfile);
                        try {
                            FileUtil.copy(shlib, destdir);
                        } catch (IOException e) {
                            // TODO: this should result in an error message about failing copy shared libs
                            e.printStackTrace();
                        }
                    }
                }
            }
        }
        sharedLibs.clear();
    }
    
    public static Map<String, String> getEnv() {
        return env;
    }
    
    /**
     * Format a list of values into space-separated.
     */
    protected String varFromList(Collection<String> list) {
        return varFromList(list, StringOperation.NULL_OP);
    }
    
    /**
     * Format a list of values into a form understood by make (i.e. space-separated).
     * 
     * Applies op to each value before adding it to the result.
     */
    protected String varFromList(Collection<String> list, StringOperation op) {
        StringBuilder buf = new StringBuilder();
        String prefix = "";
        for (String str : list) {
            str = op.op(str);
            if (str != null) {
                buf.append(prefix);
                buf.append(str);
                prefix = " ";
            }
        }
        return (buf.length() == 0) ? null : buf.toString();
    }
    
    protected interface StringOperation {
        
        public static final StringOperation NULL_OP = new StringOperation() {
            @Override
            public String op(String str) { return str; }
        };
        
        public String op(String str);
        
    }
    
    protected static class ChainedOperations implements StringOperation {
        
        private StringOperation[] ops;
        
        public ChainedOperations(StringOperation... ops) {
            this.ops = ops;
        }
        
        @Override
        public String op(String path) {
            for (StringOperation op : ops)
                path = op.op(path);
            return path;
        }
        
    }
    
    protected class QuoteOperation implements StringOperation {
        
        private String prefix;
        
        public QuoteOperation() {
            this("");
        }
        
        public QuoteOperation(String prefix) {
            this.prefix = prefix;
        }
        
        @Override
        public String op(String path) {
            if (getBuildPlatform().startsWith("win")) {
                return String.format("%s\\\"%s\\\"", prefix, path);
            } else {
                return String.format("%s\"%s\"", prefix, path);
            }
        }
    }
    
    protected static class PlatformDirOperation implements StringOperation {
        
        private String platform;
        
        public PlatformDirOperation(String platform) {
            this.platform = platform;
        }
        
        @Override
        public String op(String path) {
            File f = new File(path, platform);
            return f.isDirectory() ? f.getPath() : path;
        }
    }
    
    protected static class SharedLibOperation implements StringOperation {
        
        private String format;
        
        public SharedLibOperation(String platform) {
            if (platform.startsWith("win")) 
                format = "%s.dll";
            else if (platform.startsWith("darwin")) 
                format = "lib%s.dylib";
            else
                format = "lib%s.so";
        }
        
        @Override
        public String op(String library) {
            return String.format(format, library);
        }

    }

    protected static Object printStringArrayObject(final String[] strArr) {
        return new Object() {
            @Override
            public String toString() {
                StringBuilder sb = new StringBuilder();
                boolean first = true;
                for (String str : strArr) {
                    if (!first)
                        sb.append(' ');
                    first = false;
                    sb.append(str);
                }
                return sb.toString();
            }
        };
    }
}

