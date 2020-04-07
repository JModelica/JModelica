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

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import org.jmodelica.util.EnvironmentUtils;
import org.jmodelica.util.exceptions.CcodeCompilationException;
import org.jmodelica.util.logging.ModelicaLogger;
import org.jmodelica.util.streams.NullStream;

/**
 * Compiles DLL(s) from generated C code using make.
 */
public class GccCompilerDelegator extends CCompilerDelegator {

    public static final Creator CREATOR = CCompilerDelegator.addDelegator(GccCompilerDelegator.NAME, new Creator() {
        @Override
        public CCompilerDelegator create() {
            return new GccCompilerDelegator(EnvironmentUtils.getJModelicaHome(), EnvironmentUtils.getJavaPlatform());
        }
    });

    public static final String NAME = "gcc";

    public GccCompilerDelegator(File jmHome, String buildPlatform) {
        super(jmHome, buildPlatform);
    }

    /**
     * Get the target platforms to compile for.
     */
    @Override
    protected String[] getDefaultTargetPlatforms() {
        return new String[] { getBuildPlatform() };
    }
    
    /**
     * Get the path to the Makefile.
     */
    protected File getMakefile() {
        File res = new File(getJMHome(), "Makefiles/MakeFile");
        if (!res.exists()) {
            throw new CcodeCompilationException("Makefile '" + res + "' does not exist.");
        }
        return res;
    }
    
    /**
     * Get the make command to use for the specified build platform.
     */
    protected String getMake(String platform) {
        if (getBuildPlatform().startsWith("win")) 
            return new File(getEnv().get("MINGW_HOME"), "bin/mingw32-make").getPath();
        else
            return "make";
    }
    
    protected final QuoteOperation INC_OP = new QuoteOperation("-I");
    
    /**
     * Add make variables to set that is valid for all target platforms.
     */
    protected void addFixedMakeVars(Map<String,String> vars, String fileName,
            Set<String> ext_libs, Set<String> ext_incl_dirs) {
        String filesep = File.separator;
        vars.put("FILE_NAME", fileName);
        vars.put("JMODELICA_HOME", getJMHome().getPath());
        vars.put("SUNDIALS_HOME", getEnv().get("SUNDIALS_HOME"));
        vars.put("EXT_LIBS", varFromList(ext_libs) != null ?
                      (varFromList(ext_libs) + " " + varFromList(ext_libs)): null);
        vars.put("EXT_INC_DIRS", varFromList(ext_incl_dirs, INC_OP));
        vars.put("JMTABLES_HOME", getJMHome().getPath() + filesep + "ThirdParty" + filesep + "Tables");
        vars.put("MODULE_HOME", getEnv().get("MODULE_HOME"));
    }
    
    /**
     * Add make variables specific to the build platform.
     */
    protected void addBuildPlatformMakeVars(Map<String,String> vars, String platform) {
        if (platform.startsWith("win")) {
            File mingw_bin = new File(getEnv().get("MINGW_HOME"), "bin");
            vars.put("CXX", new File(mingw_bin, "g++").getPath());
            vars.put("AR", new File(mingw_bin, "ar").getPath());
        }
    }
    
    /**
     * Add make variables specific to the target platform.
     */
    protected void addTargetPlatformMakeVars(Map<String,String> vars, Set<String> ext_lib_dirs, String platform) {
        vars.put("PLATFORM", platform);
        StringOperation libOp = new QuoteOperation("-L");
        Set<String> expandedLibDirs = expandLibraries(ext_lib_dirs, platform, "gcc" + compilerVersionNumber());
        sharedLibs.addAll(expandedLibDirs);
        vars.put("EXT_LIB_DIRS", varFromList(expandedLibDirs, libOp));
    }
    
    public String compilerVersionNumber() {
        String[] cmd = new String[] {
                "gcc", "--version"
        };

        OutputStream os = new ByteArrayOutputStream();
        OutputStream es = NullStream.OUTPUT;
        if (ProcessExecutor.executeProcess(cmd, getEnv(), new File("."), os, es) > 0) {
            // TODO: give a useful error message here
            return null;
        }
        
        String output = os.toString();
        String[] firstLine = output.split("\n")[0].split(" ");
        String prefix = firstLine[1].contains("tdm") ? "tdm" : "";
        String versionNumber = firstLine[2].replaceAll("\\.", "");
        return prefix + versionNumber.substring(0, versionNumber.length() - 1);
    }
    
    /**
     * Compile DLL(s) from generated C code for a set of target platforms.
     */
    @Override
    protected void compileCCode(ModelicaLogger log, CCompilerArguments args, File workDir, String[] platforms) {
        String make = getMake(getBuildPlatform());
        
        Set<String> ext_libs = new LinkedHashSet<String>();
        ext_libs.addAll(args.getExternalLibraries());
        
        if (moduleLibNames != null) {
            for (String name : moduleLibNames) {
                ext_libs.add(name);
            }
        }
        
        Map<String, String> vars = new LinkedHashMap<String, String>();
        addFixedMakeVars(vars, args.getFileName(), ext_libs, args.getExternalIncludeDirectories());
        
        addBuildPlatformMakeVars(vars, getBuildPlatform());
        
        vars.put("EXTRA_CFLAGS", args.getExtraCFlags());
        
        for (String platform : platforms) {
            Map<String, String> pVars = new LinkedHashMap<String, String>(vars);
            addTargetPlatformMakeVars(pVars, args.getExternalLibraryDirectories(), platform);
            
            File makefile = getMakefile();
            String makefileVar = "MAKEFILE=" + makefile.getPath();
            String[] mArgs = new String[] { make, "-f", makefile.getPath(), "-j", Integer.toString(args.getMaxProc()), 
                    args.getTarget().getMakeFileFlag(), makefileVar };
            ArrayList<String> vArgs = new ArrayList<String>(pVars.size());
            for (Map.Entry<String,String> var : pVars.entrySet())
                if (var.getValue() != null)
                    vArgs.add(var.getKey() + '=' + var.getValue());
            String[] cmd = new String[mArgs.length + vArgs.size()];
            System.arraycopy(mArgs, 0, cmd, 0, mArgs.length);
            int i = mArgs.length;
            for (String arg : vArgs)
                cmd[i++] = arg;
                
            log.debug("C-code compilation command:");
            log.debug(printStringArrayObject(cmd));

            if (ProcessExecutor.loggedProcess(log, cmd, getEnv(), workDir) != 0) {
                File sourceDir = new File(workDir, "sources");
                File cfile = new File(sourceDir, args.getFileName()+".c");
                throw new CcodeCompilationException("Compilation of generated C code failed.\n" +
                        "C file location: "+cfile.getAbsolutePath());
            }
        }
    }

}
