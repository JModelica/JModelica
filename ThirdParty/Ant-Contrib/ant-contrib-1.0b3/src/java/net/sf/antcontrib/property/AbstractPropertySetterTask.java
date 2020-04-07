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
package net.sf.antcontrib.property;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Property;


/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *
 ****************************************************************************/


public abstract class AbstractPropertySetterTask
        extends Task
{
    private boolean override;
    private String property;

    public AbstractPropertySetterTask()
    {
        super();
    }


    public void setOverride(boolean override)
    {
        this.override = override;
    }


    public void setProperty(String property)
    {
        this.property = property;
    }

    protected void validate()
    {
        if (property == null)
            throw new BuildException("You must specify a property to set.");
    }


    protected final void setPropertyValue(String value)
    {
        if (value != null)
        {
            if (override)
            {
                if (getProject().getUserProperty(property) == null)
                    getProject().setProperty(property, value);
                else
                    getProject().setUserProperty(property, value);
            }
            else
            {
                Property p = (Property)project.createTask("property");
                p.setName(property);
                p.setValue(value);
                p.execute();
            }
        }
    }
}
