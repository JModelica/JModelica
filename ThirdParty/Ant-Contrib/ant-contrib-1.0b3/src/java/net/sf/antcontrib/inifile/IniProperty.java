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


/****************************************************************************
 * A single property in an IniSection.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 *
 ****************************************************************************/


public class IniProperty
        implements IniPart
{
    private String name;
    private String value;

    /***
     * Default constructor
     */
    public IniProperty()
    {
        super();
    }

    /***
     * Construct an IniProperty with a certain name and value
     * @param name The name of the property
     * @param value The property value
     */
    public IniProperty(String name, String value)
    {
        this();
        this.name = name;
        this.value = value;
    }

    /***
     * Gets the name of the property
     */
    public String getName()
    {
        return name;
    }

    /***
     * Sets the name of the property
     * @param name The name of the property
     */
    public void setName(String name)
    {
        this.name = name;
    }


    /***
     * Gets the value of the property
     */
    public String getValue()
    {
        return value;
    }


    /***
     * Sets the value of the property
     * @param value the value of the property
     */
    public void setValue(String value)
    {
        this.value = value;
    }


    /***
     * Write this property to a writer object.
     * @param writer
     * @throws IOException
     */
    public void write(Writer writer)
            throws IOException
    {
        writer.write(name);
        if (! name.trim().startsWith(";"))
            writer.write("=" + value);
    }

}
