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

/***
 * Task definition for the propertycopy task, which copies the value of a
 * named property to another property.  This is useful when you need to
 * plug in the value of another property in order to get a property name
 * and then want to get the value of that property name.
 *
 * <pre>
 * Usage:
 *
 *   Task declaration in the project:
 *   <code>
 *     &lt;taskdef name="propertycopy" classname="net.sf.antcontrib.property.PropertyCopy" /&gt;
 *   </code>
 *
 *   Call Syntax:
 *   <code>
 *     &lt;propertycopy name="propname" from="copyfrom" (silent="true|false")? /&gt;
 *   </code>
 *
 *   Attributes:
 *     name      --&gt; The name of the property you wish to set with the value
 *     from      --&gt; The name of the property you wish to copy the value from
 *     silent    --&gt; Do you want to suppress the error if the "from" property
 *                   does not exist, and just not set the property "name".  Default
 *                   is false.
 *
 *   Example:
 *     &lt;property name="org" value="MyOrg" /&gt;
 *     &lt;property name="org.MyOrg.DisplayName" value="My Organiziation" /&gt;
 *     &lt;propertycopy name="displayName" from="org.${org}.DisplayName" /&gt;
 *     &lt;echo message="${displayName}" /&gt;
 * </pre>
 *
 * @author <a href="mailto:mattinger@yahoo.com">Matthew Inger</a>
 */
public class PropertyCopy
        extends AbstractPropertySetterTask
{
    private String from;
    private boolean silent;

    /***
     * Default Constructor
     */
    public PropertyCopy()
    {
        super();
        this.from = null;
        this.silent = false;
    }

    public void setName(String name)
    {
        setProperty(name);
    }

    public void setFrom(String from)
    {
        this.from = from;
    }

    public void setSilent(boolean silent)
    {
        this.silent = silent;
    }

    protected void validate()
    {
        super.validate();
        if (from == null)
            throw new BuildException("Missing the 'from' attribute.");
    }

    public void execute()
        throws BuildException
    {
        validate();

        String value = getProject().getProperty(from);

        if (value == null && ! silent)
            throw new BuildException("Property '" + from + "' is not defined.");

        if (value != null)
            setPropertyValue(value);
    }

}


