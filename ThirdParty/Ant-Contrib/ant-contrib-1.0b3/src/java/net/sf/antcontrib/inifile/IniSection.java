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
 package net.sf.antcontrib.inifile;

import java.io.IOException;
import java.io.Writer;
import java.util.*;


/****************************************************************************
 * A section within an IniFile.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 *
 ****************************************************************************/


public class IniSection
        implements IniPart
{
    private String name;
    private List properties;
    private Map propertyMap;

    /***
     * Default contructor, constructs an IniSectino with no name
     */
    public IniSection()
    {
        super();
        this.propertyMap = new HashMap();
        this.properties = new ArrayList();
    }


    /***
     * Constructs an IniSection with the given name
     * @param name The name of the section
     */
    public IniSection(String name)
    {
        this();
        this.name = name;
    }


    /***
     * Gets a list of all properties in this section
     * @return A List of IniProperty objects
     */
    public List getProperties()
    {
        return properties;
    }


    /***
     * Gets the name of the section
     */
    public String getName()
    {
        return name;
    }


    /***
     * Sets the name of the section
     * @param name The name of the section
     */
    public void setName(String name)
    {
        this.name = name;
    }

    /***
     * Gets the property with the given name
     * @param name The name of the property
     */
    public IniProperty getProperty(String name)
    {
        return (IniProperty)propertyMap.get(name);
    }

    /***
     * Sets a property, replacing the old value, if necessary.
     * @param property The property to set
     */
    public void setProperty(IniProperty property)
    {
        IniProperty prop = (IniProperty)propertyMap.get(property.getName());
        if (prop != null)
        {
            int idx = properties.indexOf(prop);
            properties.set(idx, property);
        }
        else
        {
            properties.add(property);
        }

        propertyMap.put(property.getName(), property);
    }

    /***
     * Removes a property from this ection
     * @param name The name of the property to remove
     */
    public void removeProperty(String name)
    {
        IniProperty prop = (IniProperty)propertyMap.get(name);
        if (prop != null)
        {
            int idx = properties.indexOf(prop);
            properties.remove(idx);
            propertyMap.remove(name);
        }
    }


    public void write(Writer writer)
        throws IOException
    {
        writer.write("[" + name + "]");
        writer.write(System.getProperty("line.separator"));
        Iterator it = properties.iterator();
        IniProperty prop = null;
        while (it.hasNext())
        {
            prop = (IniProperty)it.next();
            prop.write(writer);
            writer.write(System.getProperty("line.separator"));
        }
    }
}
