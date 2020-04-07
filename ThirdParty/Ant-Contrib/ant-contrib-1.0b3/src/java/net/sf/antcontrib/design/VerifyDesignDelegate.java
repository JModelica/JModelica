/*
 * Copyright (c) 2004-2005 Ant-Contrib project.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package net.sf.antcontrib.design;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Vector;
import java.util.jar.JarFile;
import java.util.zip.ZipEntry;

import org.apache.bcel.Constants;
import org.apache.bcel.classfile.ClassFormatException;
import org.apache.bcel.classfile.ClassParser;
import org.apache.bcel.classfile.Constant;
import org.apache.bcel.classfile.ConstantClass;
import org.apache.bcel.classfile.ConstantPool;
import org.apache.bcel.classfile.ConstantUtf8;
import org.apache.bcel.classfile.DescendingVisitor;
import org.apache.bcel.classfile.JavaClass;
import org.apache.bcel.classfile.Utility;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DirectoryScanner;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;
import org.apache.tools.ant.types.PatternSet;
import org.apache.tools.ant.util.JAXPUtils;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.XMLReader;

/**
 * 
 * 
 * 
 * @author dhiller
 * 
 */

public class VerifyDesignDelegate implements Log {

    private File designFile;
    private Vector paths = new Vector();
    private boolean isCircularDesign = false;
    private boolean deleteFiles = false;
    private boolean fillInBuildException = false;
    private boolean needDeclarationsDefault = true;
    private boolean needDependsDefault = true;
    
    private Task task;
    private Design design;
    private HashSet primitives = new HashSet();
    private Vector designErrors = new Vector();
    private boolean verifiedAtLeastOne = false;

    public VerifyDesignDelegate(Task task) {
        this.task = task;
        primitives.add("B");
        primitives.add("C");
        primitives.add("D");
        primitives.add("F");
        primitives.add("I");
        primitives.add("J");
        primitives.add("S");
        primitives.add("Z");
    }

    public void addConfiguredPath(Path path) {
//      Path newPath = new Path(task.getProject());
//      path.
        
        
        paths.add(path);
    }

    public void setJar(File f) {
        Path p = (Path)task.getProject().createDataType("path");
        p.createPathElement().setLocation(f.getAbsoluteFile());
        addConfiguredPath(p);
    }

    public void setDesign(File f) {
        this.designFile = f;          
    }

    public void setCircularDesign(boolean isCircularDesign) {
        this.isCircularDesign = isCircularDesign;
    }

    public void setDeleteFiles(boolean deleteFiles) {
        this.deleteFiles = deleteFiles;
    }

    public void setFillInBuildException(boolean b) {
        fillInBuildException = b;
    }
    
    public void setNeedDeclarationsDefault(boolean b) {
        needDeclarationsDefault = b;
    }
    
    public void setNeedDependsDefault(boolean b) {
        needDependsDefault = b;
    }

    public void execute() {
        if(!designFile.exists() || designFile.isDirectory())
            throw new BuildException("design attribute in verifydesign element specified an invalid file="+designFile);
        
        verifyJarFilesExist();

        try {
            XMLReader reader = JAXPUtils.getXMLReader();
            DesignFileHandler ch = new DesignFileHandler(this, designFile, isCircularDesign, task.getLocation());
            ch.setNeedDeclarationsDefault(needDeclarationsDefault);
            ch.setNeedDependsDefault(needDependsDefault);
            reader.setContentHandler(ch);
            //reader.setEntityResolver(ch);
            //reader.setErrorHandler(ch);
            //reader.setDTDHandler(ch);

            log("about to start parsing file='"+designFile+"'", Project.MSG_INFO);
            FileInputStream fileInput = new FileInputStream(designFile);
            InputSource src = new InputSource(fileInput);
            reader.parse(src);
            design = ch.getDesign();

            Enumeration pathsEnum = paths.elements();
            Path p = null;
            while (pathsEnum.hasMoreElements()) {
                p = (Path)pathsEnum.nextElement();
                verifyPathAdheresToDesign(design, p);
            }

            //only put unused errors if there are no other errors
            //this is because you end up with false unused errors if you don't do this.
            if(designErrors.isEmpty())
                design.fillInUnusedPackages(designErrors);
            
            if (! designErrors.isEmpty()) {
                log(designErrors.size()+"Errors.", Project.MSG_WARN);
                if(!fillInBuildException)
                    throw new BuildException("Design check failed due to previous errors");
                throwAllErrors();
            }

        } catch (SAXException e) {
            maybeDeleteFiles();
            if (e.getException() != null
                    && e.getException() instanceof RuntimeException)
                throw (RuntimeException) e.getException();
            else if (e instanceof SAXParseException) {
                SAXParseException pe = (SAXParseException) e;
                throw new BuildException("\nProblem parsing design file='"
                        + designFile + "'.  \nline=" + pe.getLineNumber()
                        + " column=" + pe.getColumnNumber() + " Reason:\n"
                        + e.getMessage() + "\n", e);
            }
            throw new BuildException("\nProblem parsing design file='"
                    + designFile + "'. Reason:\n" + e, e);
        } catch (IOException e) {
            maybeDeleteFiles();
            throw new RuntimeException("See attached exception", e);
            // throw new BuildException("IOException on design file='"
            // + designFile + "'. attached:", e);
        } catch(RuntimeException e) {
            maybeDeleteFiles();
            throw e;
        } finally {

        }
        
        if(!verifiedAtLeastOne) 
            throw new BuildException("Did not find any class or jar files to verify");
    }
    //some auto builds like cruisecontrol can only report all the
    //standard ant task errors and the build exceptions so here
    //we need to fill in the buildexception so the errors are reported
    //correctly through those tools....though, you think ant has a hook
    //in that cruisecontrol is not using like LogListeners or something
    private void throwAllErrors() {
        String result = "Design check failed due to following errors";
        Enumeration exceptions = designErrors.elements();
        while(exceptions.hasMoreElements()) {
            BuildException be = (BuildException)exceptions.nextElement();
            String message = be.getMessage();
            result += "\n" + message;
        }
        throw new BuildException(result);
    }

    private void verifyJarFilesExist() {
        Enumeration pathsEnum = paths.elements();
        Path p = null;
        while (pathsEnum.hasMoreElements()) {
            p = (Path)pathsEnum.nextElement();
            String files[] = p.list();
            for (int i=0;i<files.length;i++) {
                File file = new File(files[i]);

                if (!file.exists())
                    throw new BuildException(VisitorImpl.getNoFileMsg(file));
            }            
        }
    }
    
    private void maybeDeleteFiles() {
        if (deleteFiles) {
            log("Deleting all class and jar files so you do not get tempted to\n" +
                    "use a jar that doesn't abide by the design(This option can\n" +
                    "be turned off if you really want)", Project.MSG_INFO);
            
            Enumeration pathsEnum = paths.elements();
            Path p = null;
            while (pathsEnum.hasMoreElements()) {
                p = (Path)pathsEnum.nextElement();
                deleteFilesInPath(p);
            }           
        }
    }
    
    private void deleteFilesInPath(Path p) {
        String files[] = p.list();
        for (int i=0;i<files.length;i++) {
            File file = new File(files[i]);

            boolean deleted = file.delete();
            if (! deleted) {
                file.deleteOnExit();
            }
        }       
    }
    
    private void verifyPathAdheresToDesign(Design d, Path p) throws ClassFormatException, IOException {
        String files[] = p.list();
        for (int i=0;i<files.length;i++) {
            File file = new File(files[i]);
            if(file.isDirectory()) {
                FileSet set = new FileSet();
                set.setDir(file);
                set.setProject(task.getProject());
                PatternSet.NameEntry entry1 = set.createInclude();
                PatternSet.NameEntry entry2 = set.createInclude();
                PatternSet.NameEntry entry3 = set.createInclude();
                entry1.setName("**/*.class");
                entry2.setName("**/*.jar");
                entry3.setName("**/*.war");
                DirectoryScanner scanner = set.getDirectoryScanner(task.getProject());
                scanner.setBasedir(file);
                String[] scannerFiles = scanner.getIncludedFiles();
                for(int j = 0; j < scannerFiles.length; j++) {
                    verifyPartOfPath(scannerFiles[j], new File(file, scannerFiles[j]), d);
                }
            } else
                verifyPartOfPath(files[i], file, d);
        }
    }
    
    private void verifyPartOfPath(String fileName, File file, Design d) throws IOException {
        if (fileName.endsWith(".jar") || fileName.endsWith(".war")) {
            JarFile jarFile = new JarFile(file);
            verifyJarAdheresToDesign(d, jarFile, file);
        } else if (fileName.endsWith(".class")) {
            verifyClassAdheresToDesign(d, file);
        } else
            throw new BuildException("Only directories, jars, wars, and class files can be supplied to verify design, not file="+file.getAbsolutePath());
    }

    private void verifyClassAdheresToDesign(Design d, File classFile)
            throws ClassFormatException, IOException {
        FileInputStream fis = null;
        try {
            fis = new FileInputStream(classFile);
            verifyClassAdheresToDesign(d, fis, classFile.getAbsolutePath(), classFile);
        }
        finally {
            try {
                if (fis != null) {
                    fis.close();
                }
            }
            catch (IOException e) {
                ; //doh!!
            }
        }

    }
    
    private void verifyJarAdheresToDesign(Design d, JarFile jarFile, File original)
            throws ClassFormatException, IOException {

        try {
        Enumeration en = jarFile.entries();
        while(en.hasMoreElements()) {
            ZipEntry entry = (ZipEntry)en.nextElement();
            InputStream in = null;
            if(entry.getName().endsWith(".class")) {
                in = jarFile.getInputStream(entry);
                try {
                    in = jarFile.getInputStream(entry);
                    verifyClassAdheresToDesign(d, in, entry.getName(), original);
                }
                finally {
                    try {
                        if (in != null) {
                            in.close();
                        }
                    }
                    catch (IOException e) {
                        ; // doh!!!
                    }
                }
            }
        }
        }
        finally {
            try {
                jarFile.close();
            }
            catch (IOException e) {
                ; //doh!!!
            }
        }
    }

    private String className = "";

    private void verifyClassAdheresToDesign(Design d, InputStream in, String name, File originalClassOrJarFile) throws ClassFormatException, IOException {
        try {
            verifiedAtLeastOne = true;
            ClassParser parser = new ClassParser(in, name);
            JavaClass javaClass = parser.parse();
            className = javaClass.getClassName();
            
            if(!d.needEvalCurrentClass(className))
                return;
    
            ConstantPool pool = javaClass.getConstantPool();
            processConstantPool(pool);
            VisitorImpl visitor = new VisitorImpl(pool, this, d, task.getLocation());
            DescendingVisitor desc = new DescendingVisitor(javaClass, visitor);
            desc.visit();
        } catch(BuildException e) {
            log(Design.getWrapperMsg(originalClassOrJarFile, e.getMessage()), Project.MSG_ERR);
            designErrors.addElement(e);         
        }
    }

    private void processConstantPool(ConstantPool pool) {
        Constant[] constants = pool.getConstantPool();
        if(constants == null) {
            log("      constants=null", Project.MSG_VERBOSE);
            return;
        }
        
        log("      constants len="+constants.length, Project.MSG_VERBOSE);      
        for(int i = 0; i < constants.length; i++) {
            processConstant(pool, constants[i], i);
        }
    }
    
    private void processConstant(ConstantPool pool, Constant c, int i) {
        if(c == null) //don't know why, but constant[0] seems to be always null.
            return;

        log("      const["+i+"]="+pool.constantToString(c)+" inst="+c.getClass().getName(), Project.MSG_DEBUG); 
        byte tag = c.getTag();
        switch(tag) {
            //reverse engineered from ConstantPool.constantToString..
        case Constants.CONSTANT_Class:
            int ind   = ((ConstantClass)c).getNameIndex();
            c   = pool.getConstant(ind, Constants.CONSTANT_Utf8);
            String className = Utility.compactClassName(((ConstantUtf8)c).getBytes(), false);
            log("      classNamePre="+className, Project.MSG_DEBUG);
            className = getRidOfArray(className);
            String firstLetter = className.charAt(0)+"";
            if(primitives.contains(firstLetter))
                return;
            log("      className="+className, Project.MSG_VERBOSE);
            design.checkClass(className);
            break;
        default:
                
        }
    }
    
    private static String getRidOfArray(String className) {
        while(className.startsWith("["))
            className = className.substring(1, className.length());
        return className;
    }
    
    public static String getPackageName(String className) {
        String packageName = Package.DEFAULT;
        int index = className.lastIndexOf(".");
        if(index > 0)
            packageName = className.substring(0, index);
        //DEANDO: test the else scenario here(it is a corner case)...

        return packageName;
    }
    
    public void log(String msg, int level) {
        //if(level == Project.MSG_WARN || level == Project.MSG_INFO 
        //      || level == Project.MSG_ERR || level == Project.MSG_VERBOSE)
        //VerifyDesignTest.log(msg);
        task.log(msg, level);
    }
}
