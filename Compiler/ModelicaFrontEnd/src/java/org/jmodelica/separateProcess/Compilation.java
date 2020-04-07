/*
    Copyright (C) 2015 Modelon AB

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
package org.jmodelica.separateProcess;

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ConcurrentLinkedQueue;

import org.jmodelica.api.problemHandling.Problem;
import org.jmodelica.api.problemHandling.ProblemSeverity;
import org.jmodelica.util.CompiledUnit;
import org.jmodelica.util.Criteria;
import org.jmodelica.util.collections.FilteredIterator;
import org.jmodelica.util.logging.ObjectStreamLogger;
import org.jmodelica.util.logging.units.LoggingUnit;
import org.jmodelica.util.logging.units.ThrowableLoggingUnit;
import org.jmodelica.util.streams.StreamGobbler;

public final class Compilation
{
    
    private final Process process;
    private final LogReceiver receiver;
    private final Collection<Problem> problems = new ConcurrentLinkedQueue<>();
    private Throwable exception = null;
    private CompiledUnit compiledUnit = null;
    
    protected Compilation(List<String> args, String jmodelicaHome) throws IOException {
        ProcessBuilder builder = new ProcessBuilder(args);
        builder.environment().put("JMODELICA_HOME", jmodelicaHome);
        
        process = builder.start();
        
        StreamGobbler sg = new StreamGobbler(process.getInputStream(), System.out);
        sg.start();
        
        receiver = new LogReceiver();
        receiver.start();
    }
    
    public boolean join() throws Throwable, InterruptedException {
        return join(true);
    }

    public boolean join(boolean throwException) throws Throwable, InterruptedException {
        process.waitFor();
        receiver.join();
        if (exception != null) {
            if (throwException)
                throw exception;
            else
                return false;
        }

        return true;
    }
    
    public Throwable getException() {
        return exception;
    }

    public Iterator<Problem> getProblems() {
        return problems.iterator();
    }

    public CompiledUnit getCompiledUnit() {
        return compiledUnit;
    }

    public Iterator<Problem> getErrors() {
        return new FilteredIterator<>(getProblems(), new Criteria<Problem>() {
            @Override
            public boolean test(Problem elem) {
                return elem.severity() == ProblemSeverity.ERROR;
            }});
    }
    
    public Iterator<Problem> getWarnings() {
        return new FilteredIterator<>(getProblems(), new Criteria<Problem>() {
            @Override
            public boolean test(Problem elem) {
                return elem.severity() == ProblemSeverity.WARNING;
            }});
    }
    
    private class LogReceiver extends Thread {
        @Override
        public void run() {
            try {
                readStartBytes(process.getErrorStream());
                ObjectInputStream stream = new ObjectInputStream(process.getErrorStream());
                
                Object o;
                while ((o = stream.readObject()) != null) {
                    if (o instanceof String) {
                        // Ignore
                    } else if (o instanceof Problem) {
                        problems.add((Problem) o);
                    } else if (o instanceof CompiledUnit) {
                        compiledUnit = (CompiledUnit) o;
                    } else if (o instanceof ThrowableLoggingUnit) {
                        if (exception == null)
                            exception = ((ThrowableLoggingUnit) o).getException();
                    } else if (o instanceof LoggingUnit) {
                        // Ignore these... E.g. sometimes we get StringLoggingUnits here...
                    } else {
                        throw new SeparateProcessException("Unknown object type '" + o.getClass().getName() + "' received on compiler log");
                    }
                }
            } catch (EOFException e) {
                // OK
                return;
            } catch (IOException e) {
                if (exception == null)
                    exception = new SeparateProcessException("Exception while parsing compiler log", e);
            } catch (ClassNotFoundException e) {
                if (exception == null)
                    exception = new SeparateProcessException("Unable to reconstruct compiler log object", e);
            } catch (SeparateProcessException e) {
                if (exception == null)
                    exception = e;
            }
            readAndThrow(process.getErrorStream());
        }
        
        private void readStartBytes(InputStream stream) throws IOException, InvalidLogStartException {
            byte[] readStartBytes = new byte[ObjectStreamLogger.START_BYTES.length];
            int read = 0;
            while (read < readStartBytes.length) {
                int len = stream.read(readStartBytes, read, readStartBytes.length - read);
                if (len == -1)
                    break;
                read += len;
            }
            if (!Arrays.equals(readStartBytes, ObjectStreamLogger.START_BYTES)) {
                StringBuilder sb = new StringBuilder(new String(readStartBytes, 0, read));
                byte[] buffer = new byte[2048];
                int len;
                while ((len = stream.read(buffer)) != -1)
                    sb.append(new String(buffer, 0, len));
                throw new InvalidLogStartException(sb.toString());
            }
        }
        
        private void readAndThrow(InputStream stream) {
            try {
                byte[] buffer = new byte[2048];
                while (stream.read(buffer) != -1) { /* ignore the received data */ }
            } catch (IOException e) {
                // Not much to do here, we are in serious problems if we get here!
                e.printStackTrace();
            }
        }
    }
    
}
