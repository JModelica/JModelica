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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.util.*;


/****************************************************************************
 * Class representing a windows style .ini file.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 *
 ****************************************************************************/

public class IniFile
{
    private List sections;
    private Map sectionMap;

    /***
     * Create a new IniFile object
     */
    public IniFile()
    {
        super();
        this.sections = new ArrayList();
        this.sectionMap = new HashMap();
    }

    /***
     * Gets the List of IniSection objects contained in this IniFile
     * @return a List of IniSection objects
     */
    public List getSections()
    {
        return sections;
    }


    /***
     * Gets the IniSection with the given name
     * @param name the name of the section
     */
    public IniSection getSection(String name)
    {
        return (IniSection)sectionMap.get(name);
    }

    /***
     * Sets an IniSection object.  If a section with the given
     * name already exists, it is replaced with the passed in section.
     * @param section The section to set.
     */
    public void setSection(IniSection section)
    {
        IniSection sec = (IniSection)sectionMap.get(section.getName());
        if (sec != null)
        {
            int idx = sections.indexOf(sec);
            sections.set(idx, section);
        }
        else
        {
            sections.add(section);
        }

        sectionMap.put(section.getName(), section);
    }

    /***
     * Removes an entire section from the IniFile
     * @param name The name of the section to remove
     */
    public void removeSection(String name)
    {
        IniSection sec = (IniSection)sectionMap.get(name);
        if (sec != null)
        {
            int idx = sections.indexOf(sec);
            sections.remove(idx);
            sectionMap.remove(name);
        }
    }

    /***
     * Gets a named property from a specific section
     * @param section The name of the section
     * @param property The name of the property
     * @return The property value, or null, if either the section or property
     * does not exist.
     */
    public String getProperty(String section, String property)
    {
        String value = null;
        IniSection sec = getSection(section);
        if (sec != null)
        {
            IniProperty prop = sec.getProperty(property);
            if (prop != null)
            {
                value = prop.getValue();
            }
        }
        return value;
    }

    /***
     * Sets the value of a property in a given section.  If the section does
     * not exist, it is automatically created.
     * @param section The name of the section
     * @param property The name of the property
     * @param value The value of the property
     */
    public void setProperty(String section, String property, String value)
    {
        IniSection sec = getSection(section);
        if (sec == null)
        {
            sec = new IniSection(section);
            setSection(sec);
        }

        sec.setProperty(new IniProperty(property, value));
    }

    /***
     * Removes a property from a section.
     * @param section The name of the section
     * @param property The name of the property
     */
    public void removeProperty(String section, String property)
    {
        IniSection sec = getSection(section);
        if (sec != null)
        {
            sec.removeProperty(property);
        }
    }

    /***
     * Writes the current iniFile instance to a Writer object for
     * serialization.
     * @param writer The writer to write to
     * @throws IOException
     */
    public void write(Writer writer)
        throws IOException
    {
        Iterator it = sections.iterator();
        IniSection section = null;
        while (it.hasNext())
        {
            section = (IniSection)it.next();
            section.write(writer);
            writer.write(System.getProperty("line.separator"));
        }
    }

    /***
     * Reads from a Reader into the current IniFile instance.  Reading
     * appends to the current instance, so if the current instance has
     * properties, those properties will still exist.
     * @param reader The reader to read from.
     * @throws IOException
     */
    public void read(Reader reader)
        throws IOException
    {
        BufferedReader br = new BufferedReader(reader);
        String line = null;

        IniSection currentSection = new IniSection("NONE");

        while ((line = br.readLine()) != null)
        {
            line = line.trim();
            if (line.length() > 0 && !line.startsWith("#") && !line.startsWith(";"))
            {
                if(line.startsWith("[") && line.endsWith("]"))
                {
                    String secName = line.substring(1, line.length()-1);
                    currentSection = getSection(secName);
                    if (currentSection == null)
                    {
                        currentSection = new IniSection(secName);
                        setSection(currentSection);
                    }
                }
                else
                {
                    String name = line;
                    String value = "";
                    int pos = line.indexOf("=");
                    if (pos != -1)
                    {
                        name = line.substring(0,pos);
                        value = line.substring(pos+1);
                    }

                    currentSection.setProperty(new IniProperty(name,value));
                }
            }


        }
    }
}
