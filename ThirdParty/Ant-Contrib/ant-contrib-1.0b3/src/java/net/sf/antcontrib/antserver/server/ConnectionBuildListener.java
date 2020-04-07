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
 package net.sf.antcontrib.antserver.server;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.util.Stack;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.tools.ant.BuildEvent;
import org.apache.tools.ant.BuildListener;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *
 ****************************************************************************/


public class ConnectionBuildListener
        implements BuildListener
{
    private Document results;
    private Stack elementStack;
    private ThreadGroup group;

    public ConnectionBuildListener()
        throws ParserConfigurationException
    {
        group = Thread.currentThread().getThreadGroup();
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        results = builder.newDocument();
        elementStack = new Stack();

        Element rootElement = results.createElement("results");
        elementStack.push(rootElement);
        results.appendChild(rootElement);
    }

    public Document getDocument()
    {
        return results;
    }

    public void buildStarted(BuildEvent event)
    {
    }


    public void buildFinished(BuildEvent event)
    {
    }


    public void targetStarted(BuildEvent event)
    {
        if (Thread.currentThread().getThreadGroup() != group)
            return;

        Element parent = (Element)elementStack.peek();

        Element myElement = results.createElement("target");
        myElement.setAttribute("name", event.getTarget().getName());
        parent.appendChild(myElement);

        elementStack.push(myElement);
    }


    public void targetFinished(BuildEvent event)
    {
        if (Thread.currentThread().getThreadGroup() != group)
            return;

        Element myElement = (Element)elementStack.peek();

        String message = event.getMessage();
        if (message != null)
            myElement.setAttribute("message", message);

        Throwable t = event.getException();
        if (t != null)
        {
            myElement.setAttribute("status", "failure");
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            PrintStream ps = new PrintStream(baos);
            t.printStackTrace(ps);
            ps.flush();
            String errorMessage = t.getMessage();
            String stackTrace = baos.toString();

            Element error = results.createElement("error");
            Element errorMsgElement = results.createElement("message");
            errorMsgElement.appendChild(results.createTextNode(errorMessage));
            Element stackElement = results.createElement("stack");
            stackElement.appendChild(results.createCDATASection(stackTrace));
            error.appendChild(errorMsgElement);
            error.appendChild(stackElement);
            myElement.appendChild(error);
        }
        else
        {
            myElement.setAttribute("status", "success");
        }

        elementStack.pop();
    }


    public void taskStarted(BuildEvent event)
    {

        if (Thread.currentThread().getThreadGroup() != group)
            return;

        Element parent = (Element)elementStack.peek();

        Element myElement = results.createElement("task");
        myElement.setAttribute("name", event.getTask().getTaskName());
        parent.appendChild(myElement);

        elementStack.push(myElement);
    }


    public void taskFinished(BuildEvent event)
    {
        if (Thread.currentThread().getThreadGroup() != group)
            return;

        Element myElement = (Element)elementStack.peek();

        Throwable t = event.getException();
        if (t != null)
        {
            myElement.setAttribute("status", "failure");
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            PrintStream ps = new PrintStream(baos);
            t.printStackTrace(ps);
            ps.flush();
            String errorMessage = t.getMessage();
            String stackTrace = baos.toString();

            Element error = results.createElement("error");
            Element errorMsgElement = results.createElement("message");
            errorMsgElement.appendChild(results.createTextNode(errorMessage));
            Element stackElement = results.createElement("stack");
            stackElement.appendChild(results.createCDATASection(stackTrace));
            error.appendChild(errorMsgElement);
            error.appendChild(stackElement);
            myElement.appendChild(error);
        }
        else
        {
            myElement.setAttribute("status", "success");
        }

        elementStack.pop();
    }


    public void messageLogged(BuildEvent event)
    {
        /*
        if (Thread.currentThread().getThreadGroup() != group)
            return;

        Element parentElement = (Element)elementStack.peek();

        Element messageElement = results.createElement("message");
        messageElement.setAttribute("level", String.valueOf(event.getPriority()));
        messageElement.appendChild(results.createCDATASection(event.getMessage()));
        parentElement.appendChild(messageElement);
        */
    }
}
