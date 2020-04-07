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
import java.util.LinkedHashSet;
import java.util.Set;

import org.jmodelica.common.options.AbstractOptionRegistry;

public class CCompilerArguments {
    private String fileName;
    private AbstractOptionRegistry options;
    private CCompilerTarget target;
    
    Set<String> externalLibraries;
    Set<String> externalLibraryDirectories;
    Set<String> externalIncludeDirectories;
    
    public CCompilerArguments(String fileName, AbstractOptionRegistry options, CCompilerTarget target,
                              Set<String> externalLibraries, Set<String> externalLibraryDirectories,
                              Set<String> externalIncludeDirectories) {
        
        this.fileName = fileName;
        this.options = options;
        this.target = target;
        
        this.externalLibraries = externalLibraries;
        this.externalLibraryDirectories = sanitizeDirectories(externalLibraryDirectories);
        this.externalIncludeDirectories = sanitizeDirectories(externalIncludeDirectories);
    }

    /**
     * Make sure the paths are on a form acceptable to the c-compiler.
     */
    private Set<String> sanitizeDirectories(Set<String> dirs) {
        Set<String> res = new LinkedHashSet<String>();
        for (String dir : dirs) {
            res.add(new File(dir).getAbsolutePath());
        }
        return res;
    }

    public AbstractOptionRegistry getOptions() {
        return options;
    }
    
    public String getFileName() {
        return fileName;
    }
    
    public CCompilerTarget getTarget() {
        return target;
    }
    
    public Set<String> getExternalLibraries() {
        return externalLibraries;
    }
    
    public Set<String> getExternalLibraryDirectories() {
        return externalLibraryDirectories;
    }
    
    public Set<String> getExternalIncludeDirectories() {
        return externalIncludeDirectories;
    }
    
    public int getMaxProc() {
        return options.getIntegerOption("max_n_proc");
    }
    
    public String getExtraCFlags() {
        return target.createExtraCFlagsString(options, fileName);
    }
}