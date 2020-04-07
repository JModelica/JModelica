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
package net.sf.antcontrib.logic.condition;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.condition.IsFalse;

/**
 * Extends IsFalse condition to check the value of a specified property.
 * <p>Developed for use with Antelope, migrated to ant-contrib Oct 2003.
 *
 * @author     Dale Anson, danson@germane-software.com
 * @version $Revision: 1.3 $
 */
public class IsPropertyFalse extends IsFalse {
    
    private String name = null;
    
    public void setProperty(String name) {
        this.name = name;   
    }
    
    public boolean eval() throws BuildException {
        if (name == null)
            throw new BuildException("Property name must be set.");
        String value = getProject().getProperty(name);
        if (value == null)
            return true;
        return !getProject().toBoolean(value);
    }

}
