/*
    Copyright (C) 2010 Modelon AB

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

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Scanner;

/**
 * \brief Generates a test case annotation for a test model.
 * 
 * Most of the logic of this class is delegated to TestAnnotationizerHelper, a 
 * class that is generated from TestAnnotationizer.jrag. This class handles 
 * parsing the arguments and choosing between Modelica and Optimica versions 
 * of TestAnnotationizerHelper.
 * 
 * Usage: java TestAnnotationizer <.mo file path> [options...] [description]
 *   Options:
 *     -w           write result to file instead of stdout
 *     -m/-o        create annotation for Modelica/Optimica (default is infer from file path)
 *     -r           regenerate an already present annotation
 *     -e           continue generating until an empty modelname is given
 *     -a           regenerate annotations for all models in test file (implies -r)
 *     -f=<file>    input file that specifies .mo file path and model name. comma-separated one entry per line
 *     -t=<type>    set type of test, e.g. ErrorTestCase
 *     -c=<class>   set name of class to generate annotation for, if name 
 *                  does not contain a dot, base name of .mo file is prepended
 *     -d=<data>    set extra data to send to the specific generator, \n is interpreted
 *     -p=<opts>    comma-separated list of compiler options to override defaults for,
 *                  example: -p=eliminate_alias_variables=false,default_msl_version="2.2"
 *     -l=<libs>    comma-separated list of libraries needed by test (except for MSL) 
 *                  paths should be relative to test file
 *     -h           print this help
 *   User will be prompted for type and/or class if not set with options. 
 *   Options can *not* share a single "-", e.g. "-mw" will not work.
 *   Description is the text that will be entered in the "description" field of 
 *   the test annotation.
 */
public class TestAnnotationizer {

    private enum Lang { none, modelica, optimica }

    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            usageError();
            System.exit(1);
        }
        
        String filePath = null;
        String inputFilePath = null;
        boolean hasInputFilePath = false;
        String testType = null;
        String modelName = null;
        String description = "";
        String data = null;
        boolean write = false;
        boolean regenerate = false;
        boolean repeat = false;
        Lang inputlang = Lang.none;
        Lang lang = Lang.none;
        String platform = null;
        String opts = null;
        String checkType = null;
        String libs = null;
        boolean all_models = false;
        
        for (String arg : args) {
            String value = (arg.length() > 3) ? arg.substring(3) : "";
            if (arg.startsWith("-t=")) {
                testType = value;
            } else if (arg.startsWith("-c=")) {
                modelName = value;
            } else if (arg.startsWith("-d=")) {
                data = value;
            } else if (arg.startsWith("-P=")) {
                platform = value;
            } else if (arg.startsWith("-p=")) {
                opts = value;
            } else if (arg.startsWith("-k=")) {
                checkType = value;
            } else if (arg.startsWith("-l=")) {
                libs = value;
            } else if (arg.startsWith("-f=")) {
                inputFilePath = value;
                hasInputFilePath = true;
            } else if (arg.equals("-w")) {
                write = true;
            } else if (arg.equals("-r")) {
                regenerate = true;
            } else if (arg.equals("-e")) {
                repeat = true;
            } else if (arg.equals("-h")) {
                usageError();
                return;
            } else if (arg.equals("-o")) {
                inputlang = Lang.optimica;
            } else if (arg.equals("-m")) {
                inputlang = Lang.modelica;
            } else if (arg.equals("-a")) {
                all_models = true;
                regenerate = true;
            } else if (arg.startsWith("-")) {
                System.err.println("Unrecognized option: " + arg + "\nUse -h for help.");
            } else if (filePath == null) {
                filePath = arg;
            } else {
                description += " " + arg;
                description = description.trim();
            }
        }
        
        // Check for bad combinations
        if (repeat && modelName != null) {
            System.err.println("Cannot use -e when giving classname on command line.");
            System.exit(1);
        }
        
        if (filePath == null && !hasInputFilePath) {
            System.err.println("No input file specified. give path as argument or use -file");
        }

        if (all_models && hasInputFilePath) {
            System.err.println("Cannot use -a and -file at the same time");
        }
        
        Scanner inputFileScanner = null;
        boolean cont = true;
        Iterator<String> allModelsIterator = null;
        if (all_models) {
            allModelsIterator = collectAllModels(filePath);
            cont = allModelsIterator.hasNext();
        }
        if (hasInputFilePath) {
            inputFileScanner = new Scanner(new File(inputFilePath));
            cont = inputFileScanner.hasNextLine();
        }
        while (cont) {
            BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
            if(hasInputFilePath) {
                String line = inputFileScanner.nextLine();
                String[] parts = line.split(",");
                filePath = parts[0];
                modelName = parts[1];
            }
            String packageName = null;
            if(!(all_models || hasInputFilePath)) {
                packageName = getPackageName(filePath);
                modelName = composeModelName(packageName, modelName);
            } else if (hasInputFilePath) {
                packageName = getPackageName(filePath);
                modelName = packageName + "." + modelName;
            }
            if (all_models) {
                modelName = allModelsIterator.next();
            } else if (!modelName.contains(".")) {
                System.out.print("Enter class name: ");
                System.out.flush();
                String given = in.readLine().trim();
                if (given.isEmpty()) {
                    System.out.println("Empty modelname given, exiting.");
                    System.exit(0);
                }
                modelName = composeModelName(modelName, given);
            }
            
            if (inputlang == Lang.none)
                lang = filePath.contains("Optimica") ? Lang.optimica : Lang.modelica;
            else {
                lang = inputlang;
            }
            boolean optimica = lang == Lang.optimica;
            if (regenerate) {
                doRegenerate(optimica, filePath, modelName, write);
            } else {
                if (testType == null) {
                    System.out.print("Enter type of test: ");
                    System.out.flush();
                    testType = in.readLine().trim();
                }
                
                doAnnotation(optimica, filePath, testType, modelName, description, platform, opts, data, checkType, libs, write);
            }
            
            if (repeat) {
                modelName = packageName;
            } else if (all_models) {
                cont = allModelsIterator.hasNext();
            } else if (hasInputFilePath) {
                cont = inputFileScanner.hasNextLine();
            } else {
                cont = false;
            }
        }

        if (hasInputFilePath) {
            inputFileScanner.close();
        }
    }

    private static Iterator<String> collectAllModels(String filePath) throws FileNotFoundException,
            IOException {
        Iterator<String> allModelsIterator;
        ArrayList<String> models = new ArrayList<String>();
        HashSet<String> except = new HashSet<String>();
        
        ArrayList<String> packStack = new ArrayList<String>();
        packStack.add("");
        try(BufferedReader f = new BufferedReader(new FileReader(new File(filePath)))) {
            String fullLine;
            String[] line;
            boolean inModel = false;
            while((fullLine = f.readLine()) != null) {
                line = fullLine.trim().split(" ");
                if (!inModel && (line[0].equals("package") || line[0].equals("model"))) {
                    String top = packStack.get(packStack.size()-1);
                    if (top != "") {
                        top += ".";
                    }
                    top += line[1];
                    if (line[0].equals("model")) {
                        inModel = true;
                        if (!except.contains(top)) {
                            models.add(top);
                        }
                    }
                    if (!(line.length > 2 && line[2].startsWith("="))) {
                        packStack.add(top);
                    }
                } else if (line[0].equals("end")){
                    String[] t = packStack.get(packStack.size()-1).split("\\.");
                    if (line[1].equals(t[t.length-1] + ";")) {
                        packStack.remove(packStack.size()-1);
                        inModel = false;
                    }
                }
            }
        }
        allModelsIterator = models.iterator();
        return allModelsIterator;
    }

    private static void doRegenerate(boolean optimica, String filePath, String modelName, boolean write) throws Exception {
        Method m = getHelperClass(optimica ? OPTIMICA : MODELICA).getMethod("doRegenerate", 
                String.class, String.class, boolean.class);
        m.invoke(null, filePath, modelName, write);
    }

    private static void doAnnotation(boolean optimica, String filePath,
            String testType, String modelName, String description, String platform, String optStr, 
            String data, String checkType, String libStr, boolean write) throws Exception {
        String[] opts = (optStr == null) ? new String[0] : optStr.split(",");
        String[] libs = (libStr == null) ? new String[0] : libStr.split(",");
        Method m = getHelperClass(optimica ? OPTIMICA : MODELICA).getMethod("doAnnotation", 
                String.class, String.class, String.class, String.class, String.class, String[].class, String.class, 
                String.class, String[].class, boolean.class);
        m.invoke(null, filePath, testType, modelName, description, platform, opts, data, checkType, libs, write);
    }

    private static void usageError() throws Exception {
        getHelperClass(ANY).getMethod("usageError").invoke(null);
    }

	private static final String[] MODELICA = { "org.jmodelica.modelica.compiler.TestAnnotationizerHelper" };
	private static final String[] OPTIMICA = { "org.jmodelica.optimica.compiler.TestAnnotationizerHelper" };
	private static final String[] ANY      = { MODELICA[0], OPTIMICA[0] };
	
	private static Class<?> getHelperClass(String[] names) {
		for (String name : names) {
			try {
				return Class.forName(name);
			} catch (Exception e) {
			    // ignore
			}
		}
		System.err.println("Could not load helper class. Compiler classes must be on path.");
		System.exit(1);
		return null;
	}

	private static String composeModelName(String extracted, String entered) {
		if (entered == null)
			return extracted;
		else if (entered.contains("."))
			return entered;
		else
			return extracted + "." + entered;
	}

	private static String getPackageName(String filePath) {
		String[] parts = filePath.split("\\\\|/");
		return parts[parts.length - 1].split("\\.")[0];
	}
}
