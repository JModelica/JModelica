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

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.RegularExpression;
import org.apache.tools.ant.util.regexp.Regexp;


/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *
 ****************************************************************************/


public class PropertySelector
        extends AbstractPropertySetterTask
{
    private RegularExpression match;
    private String select = "\\0";
    private char delim = ',';
    private boolean caseSensitive = true;
    private boolean distinct = false;


    public PropertySelector()
    {
        super();
    }


    public void setMatch(String match)
    {
        this.match = new RegularExpression();
        this.match.setPattern(match);
    }


    public void setSelect(String select)
    {
        this.select = select;
    }


    public void setCaseSensitive(boolean caseSensitive)
    {
        this.caseSensitive = caseSensitive;
    }


    public void setDelimiter(char delim)
    {
        this.delim = delim;
    }


    public void setDistinct(boolean distinct)
    {
        this.distinct = distinct;
    }


    protected void validate()
    {
        super.validate();
        if (match == null)
            throw new BuildException("No match expression specified.");
    }


    public void execute()
            throws BuildException
    {
        validate();

        int options = 0;
        if (!caseSensitive)
            options |= Regexp.MATCH_CASE_INSENSITIVE;

        Regexp regex = match.getRegexp(project);
        Hashtable props = project.getProperties();
        Enumeration e = props.keys();
        StringBuffer buf = new StringBuffer();
        int cnt = 0;

        Vector used = new Vector();

        while (e.hasMoreElements())
        {
            String key = (String) (e.nextElement());
            if (regex.matches(key, options))
            {
                String output = select;
                Vector groups = regex.getGroups(key, options);
                int sz = groups.size();
                for (int i = 0; i < sz; i++)
                {
                    String s = (String) (groups.elementAt(i));

                    RegularExpression result = null;
                    result = new RegularExpression();
                    result.setPattern("\\\\" + i);
                    Regexp sregex = result.getRegexp(project);
                    output = sregex.substitute(output, s, Regexp.MATCH_DEFAULT);
                }

                if (!(distinct && used.contains(output)))
                {
                    used.addElement(output);
                    if (cnt != 0) buf.append(delim);
                    buf.append(output);
                    cnt++;
                }
            }
        }

        if (buf.length() > 0)
            setPropertyValue(buf.toString());
    }
}
