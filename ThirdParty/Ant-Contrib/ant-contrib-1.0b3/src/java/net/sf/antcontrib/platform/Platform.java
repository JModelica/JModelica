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
package net.sf.antcontrib.platform;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Properties;
import java.util.Vector;

import org.apache.tools.ant.taskdefs.Execute;

/***
 *
 * </pre>
 * @author <a href="mailto:mattinger@yahoo.com">Matthew Inger</a>
 */
public class Platform
{
    public static final int FAMILY_NONE = 0;
    public static final int FAMILY_UNIX = 1;
    public static final int FAMILY_WINDOWS = 2;
    public static final int FAMILY_OS2 = 3;
    public static final int FAMILY_ZOS = 4;
    public static final int FAMILY_OS400 = 5;
    public static final int FAMILY_DOS = 6;
    public static final int FAMILY_MAC = 7;
    public static final int FAMILY_MACOSX = 8;
    public static final int FAMILY_TANDEM = 9;
    public static final int FAMILY_OPENVMS = 10;

    public static final String FAMILY_NAME_UNIX = "unix";
    public static final String FAMILY_NAME_WINDOWS = "windows";
    public static final String FAMILY_NAME_OS2 = "os/2";
    public static final String FAMILY_NAME_ZOS = "z/os";
    public static final String FAMILY_NAME_OS400 = "os/400";
    public static final String FAMILY_NAME_DOS = "dos";
    public static final String FAMILY_NAME_MAC = "mac";
    public static final String FAMILY_NAME_TANDEM = "tandem";
    public static final String FAMILY_NAME_OPENVMS = "openvms";

    private static final Hashtable familyNames;

    static
    {
    	familyNames = new Hashtable();
    	familyNames.put(new Integer(FAMILY_WINDOWS), FAMILY_NAME_WINDOWS);
        familyNames.put(new Integer(FAMILY_OS2), FAMILY_NAME_OS2);
        familyNames.put(new Integer(FAMILY_ZOS), FAMILY_NAME_ZOS);
        familyNames.put(new Integer(FAMILY_OS400), FAMILY_NAME_OS400);
        familyNames.put(new Integer(FAMILY_DOS), FAMILY_NAME_DOS);
        familyNames.put(new Integer(FAMILY_MAC), FAMILY_NAME_MAC);
        familyNames.put(new Integer(FAMILY_MACOSX), FAMILY_NAME_UNIX);
        familyNames.put(new Integer(FAMILY_TANDEM), FAMILY_NAME_TANDEM);
        familyNames.put(new Integer(FAMILY_UNIX), FAMILY_NAME_UNIX);
        familyNames.put(new Integer(FAMILY_OPENVMS), FAMILY_NAME_OPENVMS);
	}

    public static final int getOsFamily()
    {
        String osName = System.getProperty("os.name").toLowerCase();
        String pathSep = System.getProperty("path.separator");
        int family = FAMILY_NONE;

        if (osName.indexOf("windows") != -1)
        {
            family = FAMILY_WINDOWS;
        }
        else if (osName.indexOf("os/2") != -1)
        {
            family = FAMILY_OS2;
        }
        else if (osName.indexOf("z/os") != -1
                 || osName.indexOf("os/390") != -1)
        {
            family = FAMILY_ZOS;
        }
        else if (osName.indexOf("os/400") != -1)
        {
            family = FAMILY_OS400;
        }
        else if (pathSep.equals(";"))
        {
            family = FAMILY_DOS;
        }
        else if (osName.indexOf("mac") != -1)
        {
            if (osName.endsWith("x"))
                family = FAMILY_UNIX; // MACOSX
            else
                family = FAMILY_MAC;
        }
        else if (osName.indexOf("nonstop_kernel") != -1)
        {
            family = FAMILY_TANDEM;
        }
        else if (osName.indexOf("openvms") != -1)
        {
            family = FAMILY_OPENVMS;
        }
        else if (pathSep.equals(":"))
        {
            family = FAMILY_UNIX;
        }

        return family;
	}

    public static final String getOsFamilyName()
    {
        int family = getOsFamily();
        return (String)(familyNames.get(new Integer(family)));
    }

    public static final Properties getEnv()
    {
        Properties env = new Properties();
        Vector osEnv = Execute.getProcEnvironment();
        for (Enumeration e = osEnv.elements(); e.hasMoreElements();) {
            String entry = (String) e.nextElement();
            int pos = entry.indexOf('=');
            if (pos != -1) {
                env.setProperty(entry.substring(0, pos),
                        entry.substring(pos + 1));
            }
        }
        return env;
    }

    public static final String getDefaultShell()
    {
        String shell = getEnv().getProperty("SHELL");

        if (shell == null)
        {
            int family = getOsFamily();
            switch (family)
            {
                case FAMILY_DOS:
                case FAMILY_WINDOWS:
                {
                    shell = "CMD.EXE";
                    break;
                }

                default:
                {
                    shell = "bash";
                    break;
                }
            }
        }
        return shell;
    }

    public static final String getDefaultScriptSuffix()
    {
        int family = getOsFamily();
        String suffix = null;

        switch (family)
        {
            case FAMILY_DOS:
            case FAMILY_WINDOWS:
            {
                suffix = ".bat";
                break;
            }

            default:
            {
                suffix = null;
                break;
            }
        }

        return suffix;
    }
        

    public static final String[] getDefaultShellArguments()
    {
        int family = getOsFamily();
        String args[] = null;

        switch (family)
        {
            case FAMILY_DOS:
            case FAMILY_WINDOWS:
            {
                args = new String[] { "/c" , "call" };
                break;
            }

            default:
            {
                args = new String[0];
                break;
            }
        }

        return args;
    }

}
