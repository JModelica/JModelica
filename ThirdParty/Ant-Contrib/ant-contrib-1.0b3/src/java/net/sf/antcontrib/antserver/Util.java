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
import java.io.OutputStream;


/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *
 ****************************************************************************/


public class Util
{
    public static final int CHUNK = 10*1024;

    public static final void transferBytes(InputStream input,
                                           long length,
                                           OutputStream output,
                                           boolean closeInput)
        throws IOException
    {

        byte b[] = new byte[CHUNK];
        int read = 0;
        int totalread = 0;

        while (totalread < length)
        {
            int toRead = (int)Math.min(CHUNK, length - totalread);
            read = input.read(b, 0, toRead);
            output.write(b, 0, read);
            totalread += read;
        }

        try
        {
            if (closeInput)
                input.close();
        }
        catch (IOException e)
        {
            // ; gulp
        }
    }
}
