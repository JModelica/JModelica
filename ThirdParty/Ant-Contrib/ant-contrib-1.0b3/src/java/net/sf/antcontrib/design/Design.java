/*
 * Copyright (c) 2001-2005 Ant-Contrib project.  All rights reserved.
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
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.Vector;

import net.sf.antcontrib.logic.ProjectDelegate;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Location;
import org.apache.tools.ant.Project;


/*
 * Created on Aug 24, 2003
 *
 * To change the template for this generated file go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
/**
 * FILL IN JAVADOC HERE
 *
 * @author Dean Hiller(dean@xsoftware.biz)
 */
public class Design {

    private Map nameToPackage = new HashMap();
    private Map packageNameToPackage = new HashMap();
    private boolean isCircularDesign;
    private Log log;
    private Location location;
    
    private String currentClass = null;
    private String currentPackageName = null;
    private Package currentAliasPackage = null;
    
    private HashSet primitives = new HashSet();
    
    public Design(boolean isCircularDesign, Log log, Location loc) {
        //by default, add java as a configured package with the name java
        Package p = new Package();
        p.setIncludeSubpackages(true);
        p.setName("java");
        p.setUsed(true);
        p.setNeedDeclarations(false);
        p.setPackage("java");
        addConfiguredPackage(p);
        
        this.isCircularDesign = isCircularDesign;
        this.log = log;
        this.location = loc;
        
        primitives.add("boolean");

        //integral types
        primitives.add("byte");
        primitives.add("short");
        primitives.add("int");
        primitives.add("long");
        primitives.add("char");
        
        //floating point types
        primitives.add("double");
        primitives.add("float");        
    }
    
    public Package getPackage(String nameAttribute) {
        return (Package)nameToPackage.get(nameAttribute);
    }
    
    private Package retreivePack(String thePackage) {
        if(thePackage == null)
            throw new IllegalArgumentException("Cannot retrieve null packages");
        
        String currentPackage = thePackage;
        Package result = (Package)packageNameToPackage.get(currentPackage);
        while(!Package.DEFAULT.equals(currentPackage)) {
            log.log("p="+currentPackage+"result="+result, Project.MSG_DEBUG);
            if(result != null) {
                if(currentPackage.equals(thePackage))
                    return result;
                else if(result.isIncludeSubpackages())
                    return result;
                return null;
            }
            currentPackage = VerifyDesignDelegate.getPackageName(currentPackage);
            result = (Package)packageNameToPackage.get(currentPackage);
        }
        
        //result must now be default package
        if(result != null && result.isIncludeSubpackages())
            return result;

        return null;
    }
    
    public void addConfiguredPackage(Package p) {
        
        String pack = p.getPackage();
        
        Depends[] depends = p.getDepends();
        
        if(depends != null && !isCircularDesign) {
            //make sure all depends are in Map first
            //circular references then are not a problem because they must
            //put the stuff in order
            for(int i = 0; i < depends.length; i++) {
                Package dependsPackage = (Package)nameToPackage.get(depends[i].getName());
                
                if(dependsPackage == null) {
                    throw new RuntimeException("package name="+p.getName()+" did not\n" +
                            "have "+depends[i]+" listed before it.  circularDesign is off\n"+
                            "so package="+p.getName()+" must be moved up in the xml file");
                }
            }
        }
        
        nameToPackage.put(p.getName(), p);
        packageNameToPackage.put(p.getPackage(), p);
    }

    /**
     * @param className Class name of a class our currentAliasPackage depends on.
     */
    public void verifyDependencyOk(String className) {
        log.log("         className="+className, Project.MSG_DEBUG);
        if(className.startsWith("L"))
            className = className.substring(1, className.length());     
        
        //get the classPackage our currentAliasPackage depends on....
        String classPackage = VerifyDesignDelegate.getPackageName(className);
        
        //check if this is an needdeclarations="false" package, if so, the dependency is ok if it
        //is not declared
        log.log("         classPackage="+classPackage, Project.MSG_DEBUG);
        Package p = retreivePack(classPackage);
        if(p == null)
            throw new BuildException(getNoDefinitionError(className), location);        
        p.setUsed(true); //set package to used since we have classes in it
        if(p != null && !p.isNeedDeclarations())
            return;
        
        String pack = currentAliasPackage.getPackage();
        
        log.log("         AllowedDepends="+pack, Project.MSG_DEBUG);
        log.log("         CurrentDepends="+className, Project.MSG_DEBUG);
        if(isClassInPackage(className, currentAliasPackage))
            return;
        
        Depends[] depends = currentAliasPackage.getDepends();
        
        //probably want to create a regular expression out of all the depends and just match on that 
        //each time.  for now though, just get it working and do the basic(optimize later if needed)        
        for(int i = 0; i < depends.length; i++) {
            Depends d = depends[i];
            String name = d.getName();
            
            Package temp = getPackage(name);
            log.log("         AllowedDepends="+temp.getPackage(), Project.MSG_DEBUG);
            log.log("         CurrentDepends="+className, Project.MSG_DEBUG);           
            if(isClassInPackage(className, temp)) {
                temp.setUsed(true); //set package to used since we are depending on it(could be external package like junit)
                currentAliasPackage.addUsedDependency(d);
                return;
            }
        }
        
        log.log("***************************************", Project.MSG_DEBUG);
        log.log("***************************************", Project.MSG_DEBUG);

        throw new BuildException(Design.getErrorMessage(currentClass, className), location);        
    }

    public boolean isClassInPackage(String className, Package p) {
        String classPackage = VerifyDesignDelegate.getPackageName(className);
        if(p.isIncludeSubpackages()) {
            if(className.startsWith(p.getPackage()))
                return true;
        } else { //if not including subpackages, the it must be the exact package.
            if(classPackage.equals(p.getPackage()))
                return true;
        }
        return false;
    }
    /**
     * @param className
     * @return whether or not this class needs to be checked. (ie. if the
     * attribute needdepends=false, we don't care about this package.
     */
    public boolean needEvalCurrentClass(String className) {
        currentClass = className;
        String packageName = VerifyDesignDelegate.getPackageName(className);
//      log("class="+className, Project.MSG_DEBUG);
        if(!packageName.equals(currentPackageName) || currentAliasPackage == null) {
            currentPackageName = packageName;
            log.log("\nEvaluating package="+currentPackageName, Project.MSG_INFO);
            currentAliasPackage = retreivePack(packageName);
            //DEANDO: test this scenario
            if(currentAliasPackage == null) {
                log.log("   class="+className, Project.MSG_VERBOSE);
                throw new BuildException(getNoDefinitionError(className), location);
            }
            
            currentAliasPackage.setUsed(true);
        }
        log.log("   class="+className, Project.MSG_VERBOSE);
        
        if(!className.startsWith(currentPackageName))
            throw new RuntimeException("Internal Error");
        
        if(!currentAliasPackage.getNeedDepends())
            return false;
        return true;
    }
    
    public String getCurrentClass() {
        return currentClass;
    }   
    
    void checkClass(String dependsOn) {
        log.log("         dependsOn1="+dependsOn, Project.MSG_DEBUG);
        if(dependsOn.endsWith("[]")) {
            int index = dependsOn.indexOf("[");
            dependsOn = dependsOn.substring(0, index);
            log.log("         dependsOn2="+dependsOn, Project.MSG_DEBUG);           
        }
        
        if(primitives.contains(dependsOn))
            return;
        
        //Anything in java.lang package seems to be passed in as just the 
        //className with no package like Object, String or Class, so here we try to
        //see if the name is a java.lang class....
        String tempTry = "java.lang."+dependsOn;
        try {
            Class c = VerifyDesign.class.getClassLoader().loadClass(tempTry);
            return;
        } catch(ClassNotFoundException e) {
            //not found, continue on...
        }
        //sometimes instead of passing java.lang.String or java.lang.Object, the bcel 
        //passes just String or Object
//      if("String".equals(dependsOn) || "Object".equals(dependsOn))
//          return;
        
        verifyDependencyOk(dependsOn);
            
    }

    public static String getErrorMessage(String className, String dependsOnClass) {
        String s =  "\nYou are violating your own design...." +
                    "\nClass = "+className+" depends on\nClass = "+dependsOnClass+
                    "\nThe dependency to allow this is not defined in your design" +
                    "\nPackage="+VerifyDesignDelegate.getPackageName(className)+" is not defined to depend on"+
                    "\nPackage="+VerifyDesignDelegate.getPackageName(dependsOnClass)+
                    "\nChange the code or the design";
        return s;
    }
    
    public static String getNoDefinitionError(String className) {
        String s = "\nPackage="+VerifyDesignDelegate.getPackageName(className)+" is not defined in the design.\n"+
                    "All packages with classes must be declared in the design file\n"+
                    "Class found in the offending package="+className;
        return s;
    }
    
    public static String getWrapperMsg(File originalFile, String message) {
        String s = "\nThe file '" + originalFile.getAbsolutePath() + "' failed due to: " + message;
        return s;
    }

    /**
     * @param designErrors
     */
    public void fillInUnusedPackages(Vector designErrors)
    {
        Collection values = nameToPackage.values();
        Iterator iterator = values.iterator();
        while(iterator.hasNext()) {
            Package pack = (Package)iterator.next();
            if(!pack.isUsed()) {
                String msg = "Package name="+pack.getName()+" is unused.  Full package="+pack.getPackage();
                log.log(msg, Project.MSG_ERR);
                designErrors.add(new BuildException(msg));
            } else {
                fillInUnusedDepends(designErrors, pack);
            }
        }
    }

    /**
     * @param designErrors
     * @param pack
     */
    private void fillInUnusedDepends(Vector designErrors, Package pack)
    {
        Iterator iterator = pack.getUnusedDepends().iterator();
        while(iterator.hasNext()) {
            Depends depends = (Depends)iterator.next();
            String msg = "Package name="+pack.getName()+" has a dependency declared that is not true anymore.  Please erase the dependency <depends>"+depends.getName()+"</depends> from package="+pack.getName();
            log.log(msg, Project.MSG_ERR);
            designErrors.add(new BuildException(msg));
        }
    }
}