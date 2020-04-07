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

import java.io.Serializable;

/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *               
 ****************************************************************************/


public class ReferenceContainer
        implements Serializable
{
    private String refId;
    private String toRefId;

    public ReferenceContainer()
    {
        super();
    }


    public String getRefId()
    {
        return refId;
    }


    public void setRefid(String refId)
    {
        this.refId = refId;
    }


    public String getToRefId()
    {
        return toRefId;
    }


    public void setToRefId(String toRefId)
    {
        this.toRefId = toRefId;
    }
}
