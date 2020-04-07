/*
    Copyright (C) 2014 Modelon AB

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

package org.jmodelica.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;
import java.util.Set;

import org.jmodelica.util.StringUtil;

/**
 * Class representing command line arguments.
 */
public class Arguments {
    String compilerName;
    private String[] args;
    private Hashtable<String, String> namedArgs;
    private List<String> unnamedArgs = new ArrayList<String>();
    private String className = "";
    private String libraryPath = "";

    /**
     * @param compilerName  the name of the compiler (Modelica/Optimica).
     * @param args          the list of arguments given through command line.
     * @throws InvalidArgumentException if there was any error in the arguments. 
     */
    public Arguments(String compilerName, String[] args) throws InvalidArgumentException {
        this.compilerName = compilerName;
        this.args = args;
        this.namedArgs = new Hashtable<String, String>();

        setDefaultArgs();
        extractProgramArguments();
        checkArgs();
    }

    private List<String> commandLineOptions() {
        return Arrays.asList(new String[] {
            "log",
            "modelicapath",
            "opt",
            "optfile",
            "target",
            "version",
            "dumpmemuse",
            "findflatinst",
            "platform",
            "out",
            "debugSrcIsHome",
        });
    }
    
    private void setDefaultArgs() {
        namedArgs.put("target", "jmu");
        namedArgs.put("out", ".");
    }

    private void extractProgramArguments() throws InvalidArgumentException {
        for (String arg : args) {
            if (argumentIsOption(arg)) {
                addOptionToMap(arg);
            } else {
                unnamedArgs.add(arg);
            }
        }

        int numberOfUnnamed = unnamedArgs.size();
        if (numberOfUnnamed == 0) {
            argError("Too few unnamed arguments.");
        }
        if (numberOfUnnamed > 2) {
            argError("Too many unnamed arguments.");
        }


        if (numberOfUnnamed == 1) {
            if (namedArgs.get("target").equals("parse")) {
                libraryPath = unnamedArgs.get(0);
            } else if (namedArgs.containsKey("modelicapath")) {
                className = unnamedArgs.get(0);
            } else {
                argError();
            }
        } else {
            libraryPath = unnamedArgs.get(0);
            className = unnamedArgs.get(1);
        }
    }

    private boolean argumentIsOption(String arg) {
        return arg.trim().startsWith("-");
    }

    private void addOptionToMap(String arg) {
        String[] parts = arg.trim().substring(1).split("=", 2);
        namedArgs.put(parts[0], (parts.length > 1) ? parts[1] : "");
    }

    private void checkArgs() throws InvalidArgumentException {
        if (unnamedArgs.isEmpty()) {
            argError();
        }

        Set<String> options = new HashSet<String>();
        options.addAll(commandLineOptions());

        for (String given : namedArgs.keySet()) {
            if (!options.contains(given)) {
                argError(String.format("Invalid argument '%s'\n", given));
            }
        }

        if (unnamedArgs.size() == 1) {
            if (!isParseTarget() && !hasModelicaPath()) {
                throw new InvalidArgumentException(compilerName
                        + " expects a file name and a path. If -modelicapath is set, the path can be omitted.");
            }
        } else if (isParseTarget()) {
            throw new InvalidArgumentException(compilerName + " -parse expects a list of filenames.");
        }

    }

    public String className() {
        return className;
    }

    public String libraryPath() {
        return libraryPath;
    }

    public String out() {
        return StringUtil.unquote(namedArgs.get("out"));
    }
    
    public boolean isParseTarget() {
        return namedArgs.get("target").equals("parse");
    }

    /**
     * @return  {@code true} if the modelica path was set.
     */
    public boolean hasModelicaPath() {
        return namedArgs.get("modelicapath") != null;
    }

    public String line() {
        StringBuilder buf = new StringBuilder();
        for (String arg : args) {
            buf.append(arg);
            buf.append(' ');
        }
        return buf.toString();
    }

    public boolean containsKey(String arg) {
        return namedArgs.containsKey(arg);
    }
    
    public String get(String arg) {
        return namedArgs.get(arg);
    }
    
    public int size() {
        return namedArgs.size();
    }

    private String argError() throws InvalidArgumentException {
        return argError(null);
    }

    private String argError(String pref) throws InvalidArgumentException {
        throw new InvalidArgumentException(argErrorMsg(pref));
    }

    private String argErrorMsg(String pref) {
        if (pref == null || pref.isEmpty()) {
            return tooltip();
        } else {
            return pref + " " + tooltip();
        }
    }

    private String tooltip() {
        return compilerName + " expects the command line arguments: \n" +
                "[<options>] <file name> <class name> [<target>] [<version>]\n" +
                " where options could be: \n" +
                "  -log=<i or w or e> \n" +
                "  -modelicapath=<path to modelica libraries> \n" +
                "  -optfile=<path to XML options file> -opt=opt1:val1,opt2:val2\n" + 
                "  -target=<fmume, me, fmucs, cs, jmu, fmux, parse or check>\n" +
                "  -version=<1.0 or 2.0>\n" +
                "  -dumpmemuse[=<resolution>] -findflatinst \n" + 
                "  -platform=<win32 or win64 or linux32 or linux64 or darwin32 or darwin64>\n" +
                " If no target is given, -jmu is assumed.\n" +
                " If no version is given in case of targets 'me' or 'cs', 1.0 is assumed\n";
    }

    public class InvalidArgumentException extends Exception{
        private static final long serialVersionUID = 8291101686361405225L;

        public InvalidArgumentException(String msg) {
            super(msg);
        }
    }

}
