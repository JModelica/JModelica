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

import java.io.*;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;

import net.sf.antcontrib.antserver.Command;
import net.sf.antcontrib.antserver.Util;

/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *
 ****************************************************************************/


public class SendFileCommand
        extends AbstractCommand
        implements Command
{
    private long contentLength;
    private String todir;
    private String tofile;
    private String fileBaseName;
    private transient File file;

    public File getFile()
    {
        return file;
    }

    public long getContentLength()
    {
        return contentLength;
    }

    public InputStream getContentStream()
        throws IOException
    {
        return new FileInputStream(file);
    }

    public void setFile(File file)
    {
        this.file = file;
        this.fileBaseName = file.getName();
        this.contentLength = file.length();
    }


    public String getTofile()
    {
        return tofile;
    }


    public void setTofile(String tofile)
    {
        this.tofile = tofile;
    }


    public String getTodir()
    {
        return todir;
    }


    public void setTodir(String todir)
    {
        this.todir = todir;
    }

    public void validate(Project project)
    {
        if (file == null)
            throw new BuildException("Missing required attribute 'file'");

        if (tofile == null && todir == null)
            throw new BuildException("Missing both attributes 'tofile' and 'todir'"
                + " at least one must be supplied");

        /*
        try
        {
            String realBasePath = project.getBaseDir().getCanonicalPath();
            String realGetBasePath = file.getCanonicalPath();
            if (! realGetBasePath.startsWith(realBasePath))
                throw new SecurityException("Cannot access a file that is not rooted in the project execution directory");
        }
        catch (IOException e)
        {
            throw new BuildException(e);
        }
        */


    }

    public boolean execute(Project project,
                           long contentLength,
                           InputStream content)
            throws Throwable
    {
        File dest = null;

        if (tofile != null)
        {
            dest = new File(project.getBaseDir(), tofile);
            if (! new File(tofile).getCanonicalPath().startsWith(project.getBaseDir().getCanonicalPath())) {
                System.out.println("throwing an exception");
                throw new SecurityException("The requested filename must be a relative path.");
            }
        }
        else
        {
            dest = new File(project.getBaseDir(), todir);
            dest = new File(dest, fileBaseName);

            if (! new File(todir, tofile).getCanonicalPath().startsWith(project.getBaseDir().getCanonicalPath())) {
                throw new SecurityException("The requested filename must be a relative path.");
            }

        }

        FileOutputStream fos =  null;

        try
        {
            fos = new FileOutputStream(dest);

            Util.transferBytes(content,
                    contentLength,
                    fos,
                    false);
        }
        finally
        {
            try
            {
                if (fos != null)
                    fos.close();
            }
            catch (IOException e)
            {
                ; // gulp;
            }
        }
        return false;
    }
}
