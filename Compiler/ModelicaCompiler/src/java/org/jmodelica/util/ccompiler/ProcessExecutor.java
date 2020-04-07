/*
    Copyright (C) 2009-2018 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.jmodelica.util.ccompiler;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Map;

import org.jmodelica.util.logging.Level;
import org.jmodelica.util.logging.MemoryLogger;
import org.jmodelica.util.logging.ModelicaLogger;
import org.jmodelica.util.streams.StreamGobbler;

public class ProcessExecutor {
    
    /**
     * Executes the given command as a separate process, writing any output to the logger.
     * 
     * Stdout goes on log level "verbose", and stderr on "warning. If the process fails, 
     * then all output goes on "warning".
     */
    public static int loggedProcess(ModelicaLogger log, String[] cmd, Map<String,String> env, File workDir) {
        MemoryLogger logger = log.memoryLogger(Level.WARNING);
        try {
            int code = executeProcessInternal(cmd, env, workDir, logger.verboseStream(), logger.warningStream());
            if (code > 0) {
                logger.printCache();
            }
            return code;
        } catch (IOException e) {
            logger.printCache();
        } catch (InterruptedException e) {
            logger.printCache();
        } finally {
            logger.close();
        }
        return 1;
    }

    /**
     * Executes the given command as a separate process, writing any output to
     * the given output streams.
     */
    public static int executeProcess(
            String[] cmd, Map<String,String> env, File workDir, OutputStream stdout, OutputStream stderr) {
        try {
            return executeProcessInternal(cmd, env, workDir, stdout, stderr);
        } catch (IOException | InterruptedException e) {
            return 1;
        }
    }

    private static int executeProcessInternal(
            String[] cmd, Map<String,String> env, File workDir, OutputStream stdout, OutputStream stderr)
    throws IOException, InterruptedException {
        String[] e = (env != null) ? convertEnv(env) : null;
        Process proc = Runtime.getRuntime().exec(cmd, e, workDir);
        
        Thread err = new StreamGobbler(proc.getErrorStream(), stderr);
        Thread out = new StreamGobbler(proc.getInputStream(), stdout);
        
        err.start();
        out.start();
        
        // Wait for process to finish and return result
        int code = proc.waitFor();
        err.join();
        out.join();
        return code;
    }

    private static String[] convertEnv(Map<String, String> envMap) {
        String[] res = new String[envMap.size()];
        int i = 0;
        for (String key : envMap.keySet())
            res[i++] = key + '=' + envMap.get(key);
        return res;
    }
}

