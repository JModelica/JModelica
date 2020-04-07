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
 package net.sf.antcontrib.antserver.client;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Enumeration;
import java.util.Vector;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import net.sf.antcontrib.antserver.Command;
import net.sf.antcontrib.antserver.Response;
import net.sf.antcontrib.antserver.commands.RunAntCommand;
import net.sf.antcontrib.antserver.commands.RunTargetCommand;
import net.sf.antcontrib.antserver.commands.SendFileCommand;
import net.sf.antcontrib.antserver.commands.ShutdownCommand;

/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *
 ****************************************************************************/


public class ClientTask
        extends Task
{
    private String machine = "localhost";
    private int port = 17000;
    private Vector commands;
    private boolean persistant = false;
    private boolean failOnError = true;

    public ClientTask()
    {
        super();
        this.commands = new Vector();
    }


    public void setMachine(String machine)
    {
        this.machine = machine;
    }


    public void setPort(int port)
    {
        this.port = port;
    }


    public void setPersistant(boolean persistant)
    {
        this.persistant = persistant;
    }


    public void setFailOnError(boolean failOnError)
    {
        this.failOnError = failOnError;
    }


    public void addConfiguredShutdown(ShutdownCommand cmd)
    {
        commands.add(cmd);
    }

    public void addConfiguredRunTarget(RunTargetCommand cmd)
    {
        commands.add(cmd);
    }

    public void addConfiguredRunAnt(RunAntCommand cmd)
    {
        commands.add(cmd);
    }

    public void addConfiguredSendFile(SendFileCommand cmd)
    {
        commands.add(cmd);
    }


    public void execute()
    {
        Enumeration e = commands.elements();
        Command c = null;
        while (e.hasMoreElements())
        {
            c = (Command)e.nextElement();
            c.validate(getProject());
        }

        Client client = new Client(getProject(), machine, port);

        try
        {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();

            try
            {
                int failCount = 0;

                client.connect();

                e = commands.elements();
                c = null;
                Response r = null;
                Document d = null;
                boolean keepGoing = true;
                while (e.hasMoreElements() && keepGoing)
                {
                    c = (Command)e.nextElement();
                    r = client.sendCommand(c);
                    if (! r.isSucceeded())
                    {
                        failCount++;
                        log("Command caused a build failure:" + c,
                                Project.MSG_ERR);
                        log(r.getErrorMessage(),
                                Project.MSG_ERR);
                        log(r.getErrorStackTrace(),
                                Project.MSG_DEBUG);
                        if (! persistant)
                            keepGoing = false;
                    }

                    try
                    {
                        ByteArrayInputStream bais =
                                new ByteArrayInputStream(r.getResultsXml().getBytes());
                        d = db.parse(bais);
                        NodeList nl = d.getElementsByTagName("target");
                        int len = nl.getLength();
                        Element element = null;
                        for (int i=0;i<len;i++)
                        {
                            element = (Element)nl.item(i);
                            getProject().log("[" + element.getAttribute("name") + "]",
                                    Project.MSG_INFO);
                        }
                    }
                    catch (SAXException se)
                    {

                    }

                    if (c instanceof ShutdownCommand)
                    {
                        keepGoing = false;
                        client.shutdown();
                    }
                }

                if (failCount > 0 && failOnError)
                    throw new BuildException("One or more commands failed.");
            }
            finally
            {
                if (client != null)
                    client.disconnect();
            }
        }
        catch (ParserConfigurationException ex)
        {
            throw new BuildException(ex);
        }
        catch (IOException ex)
        {
            throw new BuildException(ex);
        }
    }
}
