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
package net.sf.antcontrib.walls;

import java.util.*;


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
public class Walls {
    
    private List packages = new LinkedList();
    private Map nameToPackage = new HashMap();
    
    public Package getPackage(String name) {
        return (Package)nameToPackage.get(name);        
    }
    
    public void addConfiguredPackage(Package p) {
        
        String pack = p.getPackage();
        if(!pack.endsWith(".*") && !pack.endsWith(".**"))
            p.setFaultReason("The package='"+pack+"' must end with "
                        +".* or .** such as biz.xsoftware.* or "
                        +"biz.xsoftware.**");
        
        String[] depends = p.getDepends();
        if(depends == null) {
            nameToPackage.put(p.getName(), p);
            packages.add(p);
            return;
        } 
        
        //make sure all depends are in Map first
        //circular references then are not a problem because they must
        //put the stuff in order
        for(int i = 0; i < depends.length; i++) {
            Package dependsPackage = (Package)nameToPackage.get(depends[i]);
            
            if(dependsPackage == null) {
                p.setFaultReason("package name="+p.getName()+" did not have "
                        +depends[i]+" listed before it and cannot compile without it");
            }
        }
        
        nameToPackage.put(p.getName(), p);
        packages.add(p);
    }

    public Iterator getPackagesToCompile() {
        //must return the list, as we need to process in order, so unfortunately
        //we cannot pass back an iterator from the hashtable because that would
        //be unordered and would break.
        return packages.iterator();
    }    
}