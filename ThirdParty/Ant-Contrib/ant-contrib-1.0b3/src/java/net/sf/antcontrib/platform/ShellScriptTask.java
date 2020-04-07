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


import java.io.File;
import java.io.FileOutputStream;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.util.FileUtils;

/**
 *  A generic front-end for passing "shell lines" to any application which can
 * accept a filename containing script input (bash, perl, csh, tcsh, etc.).
 * see antcontrib doc for useage
 *
 * @author stephan beal
 *@author peter reilly
 */

public class ShellScriptTask extends ExecTask {

    private StringBuffer script = new StringBuffer();
    private String shell = null;
    private File     tmpFile;
    private String tmpSuffix = null;

    /**
     *  Adds s to the lines of script code.
     */
    public void addText(String s) {
        script.append(getProject().replaceProperties(s));
    }

    /**
     *  Sets script code to s.
     */
    public void setInputString(String s) {
        script.append(s);
    }

    /**
     *  Sets the shell used to run the script.
     * @param shell the shell to use (bash is default)
     */
    public void setShell(String shell) {
        this.shell = shell;
    }

    /**
     *  Sets the shell used to run the script.
     * @param shell the shell to use (bash is default)
     */
    public void setExecutable(String shell) {
        this.shell = shell;
    }

    /**
     * Disallow the command attribute of parent class ExecTask.
     * ant.attribute ignore="true"
     * @param notUsed not used
     * @throws BuildException if called
     */
    public void setCommand(Commandline notUsed) {
        throw new BuildException("Attribute command is not supported");
    }
     
    
    /**
     * Sets the suffix for the tmp file used to
     * contain the script.
     * This is useful for cmd.exe as one can
     * use cmd /c call x.bat
     * @param tmpSuffix the suffix to use
     */

    public void setTmpSuffix(String tmpSuffix) {
        this.tmpSuffix = tmpSuffix;
    }
    
    /**
     * execute the task
     */
    public void execute() throws BuildException {
        // Remove per peter's comments.  Makes sense.
        /*
         if (shell == null)
         {
             // Get the default shell
             shell = Platform.getDefaultShell();

             // Get the default shell arguments
             String args[] = Platform.getDefaultShellArguments();
             for (int i=args.length-1;i>=0;i--)
                 this.cmdl.createArgument(true).setValue(args[i]);

             // Get the default script suffix
             if (tmpSuffix == null)
                 tmpSuffix = Platform.getDefaultScriptSuffix();
                 
         }
         */
        if (shell == null)
            throw new BuildException("You must specify a shell to run.");

        try {
            /* // The following may be used when ant 1.6 is used.
              if (tmpSuffix == null)
              super.setInputString(script.toString());
              else
            */
            {
                writeScript();
                super.createArg().setValue(tmpFile.getAbsolutePath());
            }
            super.setExecutable(shell);
            super.execute();
        }
        finally {
            if (tmpFile != null) {
                if (! tmpFile.delete()) {
                    log("Non-fatal error: could not delete temporary file " +
                        tmpFile.getAbsolutePath());
                }
            }
        }
    }

    /**
     *  Writes the script lines to a temp file.
     */
    protected void writeScript() throws BuildException {
        FileOutputStream os = null;
        try {
            FileUtils fileUtils = FileUtils.newFileUtils();
            // NB: use File.io.createTempFile whenever jdk 1.2 is allowed
            tmpFile = fileUtils.createTempFile("script", tmpSuffix, null);
            os = new java.io.FileOutputStream(tmpFile);
            String string = script.toString();
            os.write(string.getBytes(), 0, string.length());
            os.close();
        }
        catch (Exception e) {
            throw new BuildException(e);
        }
        finally {
            try {os.close();} catch (Throwable t) {}
        }
    }

}

