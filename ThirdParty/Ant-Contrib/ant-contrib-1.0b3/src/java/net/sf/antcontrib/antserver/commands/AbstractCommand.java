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
package net.sf.antcontrib.antserver.commands;

import java.io.IOException;
import java.io.InputStream;

import org.apache.tools.ant.Project;

import net.sf.antcontrib.antserver.Command;


/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 *
 ****************************************************************************/


public abstract class AbstractCommand
        implements Command
{
    public long getContentLength()
    {
        return 0;
    }


    public InputStream getContentStream()
        throws IOException
    {
        return null;
    }


    public long getResponseContentLength()
    {
        return 0;
    }


    public InputStream getReponseContentStream() throws IOException
    {
        return null;
    }


    public boolean respond(Project project,
                           long contentLength,
                           InputStream contentStream)
            throws IOException
    {
        return false;
    }
}
