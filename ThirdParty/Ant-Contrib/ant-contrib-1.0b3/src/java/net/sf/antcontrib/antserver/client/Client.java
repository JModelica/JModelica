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

import java.io.*;
import java.net.Socket;
import java.net.SocketException;

import org.apache.tools.ant.Project;

import net.sf.antcontrib.antserver.Command;
import net.sf.antcontrib.antserver.Response;
import net.sf.antcontrib.antserver.Util;
import net.sf.antcontrib.antserver.commands.DisconnectCommand;


/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *
 ****************************************************************************/


public class Client
{
    private String machine;
    private int port;
    private Project project;


    public Client(Project project, String machine, int port)
    {
        super();
        this.machine = machine;
        this.port = port;
        this.project = project;
    }


    private Socket socket;
    private OutputStream os;
    private InputStream is;
    private ObjectOutputStream oos;
    private ObjectInputStream ois;
    private boolean connected;


    public void connect()
            throws IOException
    {
        project.log("Opening connection to " + machine + ":" + port,
                Project.MSG_DEBUG);

        try
        {
            socket = new Socket(machine, port);
            socket.setKeepAlive(true);
            project.log("Got connection to " + machine + ":" + port,
                    Project.MSG_DEBUG);

            os = socket.getOutputStream();
            is = socket.getInputStream();

            oos = new ObjectOutputStream(os);
            ois = new ObjectInputStream(is);

            connected = true;
            try
            {
                // Read the initial response object so that the
                // object stream is initialized
                ois.readObject();
            }
            catch (ClassNotFoundException e)
            {
                ; // gulp
            }
        }
        finally
        {
            // If we were unable to connect, close everything
            if (!connected)
            {

                try
                {
                    if (os != null)
                        os.close();
                    os = null;
                    oos = null;
                }
                catch (IOException e)
                {

                }

                try
                {
                    if (is != null)
                        is.close();
                    is = null;
                    ois = null;
                }
                catch (IOException e)
                {

                }

                try
                {
                    if (socket != null)
                        socket.close();
                    socket = null;
                }
                catch (IOException e)
                {

                }
            }
        }


    }

    public void shutdown()
    {
        try
        {
            if (os != null)
                os.close();
        }
        catch (IOException e)
        {
            ; // gulp

        }
        os = null;
        oos = null;

        try
        {
            if (is != null)
                is.close();
        }
        catch (IOException e)
        {
            ; // gulp

        }
        is = null;
        ois = null;

        try
        {
            socket.close();
        }
        catch (IOException e)
        {
            ; // gulp
        }
        socket = null;

        connected = false;
    }


    public void disconnect()
            throws IOException
    {
        if (!connected)
            return;

        try {
            oos.writeObject(DisconnectCommand.DISCONNECT_COMMAND);
            try
            {
                // Read disconnect response
                ois.readObject();
            }
            catch (ClassNotFoundException e)
            {
                ; // gulp
            }

            shutdown();
        }
        catch (SocketException e) {
            ; // connection was closed
        }
        catch (EOFException e) {
            ; // connection was closed
        }
    }


    public Response sendCommand(Command command)
        throws IOException
    {
        project.log("Sending command: " + command,
                Project.MSG_DEBUG);
        oos.writeObject(command);

        if (command.getContentLength() > 0)
        {
            Util.transferBytes(command.getContentStream(),
                    command.getContentLength(),
                    os,
                    true);
        }

        Response response = null;

        try
        {
            // Read the response object
            response = (Response) ois.readObject();
            project.log("Received Response: " + response,
                    Project.MSG_DEBUG);
            if (response.getContentLength() != 0)
            {
                command.respond(project,
                        response.getContentLength(),
                        is);
            }
        }
        catch (ClassNotFoundException e)
        {
            ; // gulp
        }

        return response;
    }

}
