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

import java.io.InputStream;

import org.apache.tools.ant.Project;

import net.sf.antcontrib.antserver.Command;

/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *
 ****************************************************************************/


public class HelloWorldCommand
        extends AbstractCommand
        implements Command
{
    public void validate(Project project)
    {
    }

    public boolean execute(Project project,
                           long contentLength,
                           InputStream content)
            throws Throwable
    {
        project.log("Hello World", Project.MSG_ERR);
        return false;
    }
}
