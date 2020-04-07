/*
 * Copyright (c) 2001-2004 Ant-Contrib project.  All rights reserved.
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

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;


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
public class Package {
    
    public final static String DEFAULT = "default package";
    private String name;
    private String pack;
    
    //holds the name attribute of the package element of each
    //package this package depends on.
    private List depends;
    private Set unusedDepends = new HashSet();
    private boolean isIncludeSubpackages;
    private boolean needDeclarations;
    private boolean needDepends;
    private boolean isUsed = false;

    public void setName(String name) {
        if("".equals(name))
            name = DEFAULT;
        this.name = name;
    }
    public String getName() {
        return name;
    }
        
    public void setPackage(String pack) {
        this.pack = pack;
    }
    
    public String getPackage() {
        return pack;
    }

    public void addDepends(Depends d) {
        if(depends == null)
            depends = new ArrayList();
        depends.add(d);
        unusedDepends.add(d);
    }
    
    public Depends[] getDepends() {
        Depends[] d = new Depends[0];
        if(depends == null)
            return d;
        return (Depends[])depends.toArray(d);
    }
    
    /**
     * @param b
     */
    public void setIncludeSubpackages(boolean b) {
        isIncludeSubpackages = b;
    }
    /**
     * @return
     */
    public boolean isIncludeSubpackages() {
        return isIncludeSubpackages;
    }
    /**
     * @param b
     */
    public void setNeedDeclarations(boolean b) {
        needDeclarations = b;
    }
    /**
     * @return
     */
    public boolean isNeedDeclarations() {
        return needDeclarations;
    }
    /**
     * @param b
     */
    public void setNeedDepends(boolean b) {
        needDepends = b;
    }
    
    public boolean getNeedDepends() {
        return needDepends;
    }
    /**
     * @param b
     */
    public void setUsed(boolean b)
    {
        isUsed  = b;
    }
    public boolean isUsed()
    {
        return isUsed;
    }
    /**
     * @param d
     */
    public void addUsedDependency(Depends d)
    {
        unusedDepends.remove(d);
    }
    
    public Set getUnusedDepends() {
        return unusedDepends;
    }
    
}

