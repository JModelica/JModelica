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

import java.util.Vector;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.RegularExpression;
import org.apache.tools.ant.types.Substitution;
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


public class RegexTask
        extends AbstractPropertySetterTask
{
    private String input;

    private RegularExpression regexp;
    private String select;
    private Substitution replace;
    private String defaultValue;

    private boolean caseSensitive = true;
    private boolean global = true;

    public RegexTask()
    {
        super();
    }

    public void setInput(String input)
    {
        this.input = input;
    }

    public void setDefaultValue(String defaultValue)
    {
        this.defaultValue = defaultValue;
    }

    public void setRegexp(String regex)
    {
        if (this.regexp != null)
            throw new BuildException("Cannot specify more than one regular expression");

        this.regexp = new RegularExpression();
        this.regexp.setPattern(regex);
    }


    public RegularExpression createRegexp()
    {
        if (this.regexp != null)
            throw new BuildException("Cannot specify more than one regular expression");
        regexp = new RegularExpression();
        return regexp;
    }

    public void setReplace(String replace)
    {
        if (this.replace != null)
            throw new BuildException("Cannot specify more than one replace expression");
        if (select != null)
            throw new BuildException("You cannot specify both a select and replace expression");
        this.replace = new Substitution();
        this.replace.setExpression(replace);
    }

    public Substitution createReplace()
    {
        if (replace != null)
            throw new BuildException("Cannot specify more than one replace expression");
        if (select != null)
            throw new BuildException("You cannot specify both a select and replace expression");
        replace = new Substitution();
        return replace;
    }

    public void setSelect(String select)
    {
        if (replace != null)
            throw new BuildException("You cannot specify both a select and replace expression");
        this.select = select;
    }

    public void setCaseSensitive(boolean caseSensitive)
    {
        this.caseSensitive = caseSensitive;
    }

    public void setGlobal(boolean global)
    {
        this.global = global;
    }

    protected String doReplace()
        throws BuildException
    {
        if (replace == null)
            throw new BuildException("No replace expression specified.");

        int options = 0;
        if (! caseSensitive)
            options |= Regexp.MATCH_CASE_INSENSITIVE;
        if (global)
            options |= Regexp.REPLACE_ALL;

        Regexp sregex = regexp.getRegexp(project);

        String output = null;

        if (sregex.matches(input, options)) {
            String expression = replace.getExpression(project);
            output = sregex.substitute(input,
                                       expression,
                                       options);
        }

        if (output == null)
            output = defaultValue;

        return output;
    }

    protected String doSelect()
        throws BuildException
    {
        int options = 0;
        if (! caseSensitive)
            options |= Regexp.MATCH_CASE_INSENSITIVE;

        Regexp sregex = regexp.getRegexp(project);

        String output = select;
        Vector groups = sregex.getGroups(input, options);

        if (groups != null && groups.size() > 0)
        {
            output = RegexUtil.select(select, groups);
        }
        else
        {
            output = null;
        }

        if (output == null)
            output = defaultValue;
        
        return output;
    }


    protected void validate()
    {
        super.validate();
        if (regexp == null)
            throw new BuildException("No match expression specified.");
        if (replace == null && select == null)
            throw new BuildException("You must specify either a replace or select expression");
    }

    public void execute()
        throws BuildException
    {
        validate();

        String output = input;
        if (replace != null)
            output = doReplace();
        else
            output = doSelect();

        if (output != null)
            setPropertyValue(output);
    }
}
