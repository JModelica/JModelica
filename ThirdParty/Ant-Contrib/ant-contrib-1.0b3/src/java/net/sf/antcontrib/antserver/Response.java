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

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.io.Serializable;

/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 *
 ****************************************************************************/


public class Response
        implements Serializable
{
    private boolean succeeded;
    private String errorStackTrace;
    private String errorMessage;
    private String resultsXml;

    private long contentLength;

    public Response()
    {
        super();
        this.succeeded = true;
    }


    public boolean isSucceeded()
    {
        return succeeded;
    }


    public void setSucceeded(boolean succeeded)
    {
        this.succeeded = succeeded;
    }

    public void setThrowable(Throwable t)
    {
        errorMessage = t.getMessage();
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PrintStream ps = new PrintStream(baos);
        t.printStackTrace(ps);
        ps.flush();
        setErrorStackTrace(baos.toString());
    }

    public String getErrorStackTrace()
    {
        return errorStackTrace;
    }


    public void setErrorStackTrace(String errorStackTrace)
    {
        this.errorStackTrace = errorStackTrace;
    }


    public String getErrorMessage()
    {
        return errorMessage;
    }


    public void setErrorMessage(String errorMessage)
    {
        this.errorMessage = errorMessage;
    }


    public String getResultsXml()
    {
        return resultsXml;
    }


    public void setResultsXml(String resultsXml)
    {
        this.resultsXml = resultsXml;
    }

    public long getContentLength()
    {
        return contentLength;
    }

    public void setContentLength(long contentLength)
    {
        this.contentLength = contentLength;
    }
}
