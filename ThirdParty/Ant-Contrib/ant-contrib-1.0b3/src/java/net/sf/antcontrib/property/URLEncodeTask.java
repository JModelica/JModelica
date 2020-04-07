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

import java.io.File;
import java.net.URLEncoder;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.Reference;


/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *               
 ****************************************************************************/


public class URLEncodeTask
        extends AbstractPropertySetterTask
{
    private String value;
    private Reference ref;

    public void setName(String name)
    {
        setProperty(name);
    }


    public void setValue(String value)
    {
        this.value = URLEncoder.encode(value);
    }

    public String getValue(Project p)
    {
        String val = value;

        if (ref != null)
            val = ref.getReferencedObject(p).toString();

        return val;
    }

    public void setLocation(File location) {
        setValue(location.getAbsolutePath());
    }

    public void setRefid(Reference ref) {
        this.ref = ref;
    }

    public String toString() {
        return value == null ? "" : value;
    }

    protected void validate()
    {
        super.validate();
        if (value == null && ref == null)
        {
            throw new BuildException("You must specify value, location or "
                                     + "refid with the name attribute",
                                     getLocation());
        }
    }

    public void execute()
    {
        validate();
        String val = getValue(getProject());
        setPropertyValue(val);
    }

}
