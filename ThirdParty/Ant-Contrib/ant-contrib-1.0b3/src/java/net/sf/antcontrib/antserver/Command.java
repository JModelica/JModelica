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
 package net.sf.antcontrib.antserver;

import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;

import org.apache.tools.ant.Project;


/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *
 ****************************************************************************/


public interface Command
        extends Serializable
{
    /***
     * This should throw a build exception if the parameters
     * are invalid.
     */
    public void validate(Project project);

    /***
     * Is there additional content being sent from the local
     * machine to the remote server
     */
    public long getContentLength();

    /***
     * Gets the content's input stream.  Should be called only on the
     * client side for sending the content over the connection
     * @return the content's input stream.
     */
    public InputStream getContentStream() throws IOException;


    public long getResponseContentLength();

    public InputStream getReponseContentStream() throws IOException;

    /***
     * Execute the command.
     * @param project The project which is being executed
     * @return If true, the connection will be closed
     * @throws Throwable
     */
    public boolean execute(Project project,
                           long contentLength,
                           InputStream contentStream)
        throws Throwable;

    /***
     * Process any additional data from a response.
     */
    public boolean respond(Project project,
                           long contentLength,
                           InputStream contentStream)
        throws IOException;

}
