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
package org.jmodelica.util.logging;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jmodelica.api.problemHandling.Problem;
import org.jmodelica.util.CompiledUnit;
import org.jmodelica.util.exceptions.CompilerException;
import org.jmodelica.util.logging.units.LoggingUnit;
import org.jmodelica.util.logging.units.StringLoggingUnit;
import org.jmodelica.util.logging.units.ThrowableLoggingUnit;
import org.jmodelica.util.streams.NullStream;

/**
 * \brief Base class for logging messages from the tree.
 * 
 * This implementation discards all messages.
 */
public abstract class ModelicaLogger {

    private final Level level;

    protected ModelicaLogger(Level level) {
        this.level = level;
    }

    /**
     * Retreives the log level for this logger
     */
    public final Level getLevel() {
        return level;
    }

    /**
     * Closes the logger and underlying streams
     */
    public abstract void close();

    protected final void write(Level level, LoggingUnit logMessage) {
        write(level, null, logMessage);
    }

    protected abstract void write(Level level, Level alreadySentLevel, LoggingUnit logMessage);

    /**
     * Log <code>message</code> on log level <code>level</code>.
     */
    public final void debug(Object obj) {
        log(Level.DEBUG, obj);
    }

    public final void verbose(Object obj) {
        log(Level.VERBOSE, obj);
    }
    
    public final void info(Object obj) {
        log(Level.INFO, obj);
    }

    public final void warning(Object obj) {
        log(Level.WARNING, obj);
    }

    public final void error(Object obj) {
        log(Level.ERROR, obj);
    }

    private void log(Level level, Object obj) {
        if (!getLevel().shouldLog(level)) {
            return;
        }
        
        if (obj instanceof Throwable) {
            write(level, new ThrowableLoggingUnit((Throwable) obj));
        } else if (obj instanceof LoggingUnit) {
            write(level, (LoggingUnit) obj);
        } else {
            //TODO: remove toString(). Own LoggingUnit?
            write(level, new StringLoggingUnit(obj.toString()));
        }
    }

    /**
     * Build message using <code>format</code> as format string and log
     * on log level <code>level</code>.
     * 
     * Uses {@link #log(Level, String, Object...)} to log message.
     */
    public final void debug(String format, Object... args) {
        log(Level.DEBUG, format, args);
    }

    public final void verbose(String format, Object... args) {
        log(Level.VERBOSE, format, args);
    }
    
    public final void info(String format, Object... args) {
        log(Level.INFO, format, args);
    }

    public final void warning(String format, Object... args) {
        log(Level.WARNING, format, args);
    }

    public final void error(String format, Object... args) {
        log(Level.ERROR, format, args);
    }

    private void log(Level level, String format, Object... args) {
        if (!getLevel().shouldLog(level)) {
            return;
        }
        write(level, new StringLoggingUnit(format, args));
    }

    /**
     * Handle and log problems in an CompilerException.
     */
    public void logCompilerException(CompilerException e) {
        logProblems(e.getProblems());
    }

    /**
     * Log a list of problems.
     */
    public void logProblems(Collection<Problem> problems) {
        for (Problem problem : problems) {
            logProblem(problem);
        }
    }

    /**
     * Log a compiler problem, will be written to log depending
     * on severity
     */
    public void logProblem(Problem problem) {
        write(Level.fromKind(problem.severity()), problem);
    }

    /**
     * Log the compiled unit (e.g. FMU file).
     */
    public void logCompiledUnit(CompiledUnit unit) {
        write(Level.ERROR, unit);
    }

    /**
     * Log the compiled unit, it will be written on level info.
     * 
     * @param unitFile              the file object pointing to the compiled FMU.
     * @param numberOfComponents    the number of components in the FMU.
     * @return                      an object representing the successful compilation.
     * @deprecated                  use {@link #logCompiledUnit(Path, Collection, int)} instead.
     */
    @Deprecated
    public CompiledUnit logCompiledUnit(File unitFile, int numberOfComponents) {
        CompiledUnit unit = new CompiledUnit(unitFile, numberOfComponents);
        logCompiledUnit(unit);
        return unit;
    }

    /**
     * Log the compiled unit, it will be written on level info.
     * 
     * @param unitFile              the file object pointing to the compiled FMU.
     * @param warnings              the warnings generated during compilation.
     * @param numberOfComponents    the number of components in the FMU.
     * @return                      an object representing the successful compilation.
     * @deprecated                  use {@link #logCompiledUnit(Path, Collection, int)} instead.
     */
    @Deprecated
    public CompiledUnit logCompiledUnit(File unitFile, Collection<Problem> warnings, int numberOfComponents) {
        return logCompiledUnit(unitFile.toPath(), warnings, numberOfComponents);
    }
    
    /**
     * Log the compiled unit, it will be written on level info.
     * 
     * @param unitPath              the path pointing to the compiled FMU.
     * @param warnings              the warnings generated during compilation.
     * @param numberOfComponents    the number of components in the FMU.
     * @return                      an object representing the successful compilation.
     */
    public CompiledUnit logCompiledUnit(Path unitPath, Collection<Problem> warnings, int numberOfComponents) {
        CompiledUnit unit = new CompiledUnit(unitPath.toFile(), warnings, numberOfComponents);
        logCompiledUnit(unit);
        return unit;
    }

    /**
     * Creates an output stream that writes to the log on the debug log level.
     * 
     * Note that while this class tries to log entire lines separately, it
     * only handles the line break representations "\n", "\r" and "\r\n",
     * and assumes that the character encoding used encodes both '\n' and '\r'
     * like ASCII & UTF-8 does.
     */
    public final OutputStream debugStream() {
        return logStream(Level.DEBUG);
    }

    /**
     * Creates an output stream that writes to the log on the verbose log level.
     * 
     * Note that while this class tries to log entire lines separately, it
     * only handles the line break representations "\n", "\r" and "\r\n",
     * and assumes that the character encoding used encodes both '\n' and '\r'
     * like ASCII & UTF-8 does.
     */
    public final OutputStream verboseStream() {
        return logStream(Level.VERBOSE);
    }
    
    /**
     * Creates an output stream that writes to the log on the info log level.
     * 
     * Note that while this class tries to log entire lines separately, it
     * only handles the line break representations "\n", "\r" and "\r\n",
     * and assumes that the character encoding used encodes both '\n' and '\r'
     * like ASCII & UTF-8 does.
     */
    public final OutputStream infoStream() {
        return logStream(Level.INFO);
    }

    /**
     * Creates an output stream that writes to the log on the warning log level.
     * 
     * Note that while this class tries to log entire lines separately, it
     * only handles the line break representations "\n", "\r" and "\r\n",
     * and assumes that the character encoding used encodes both '\n' and '\r'
     * like ASCII & UTF-8 does.
     */
    public final OutputStream warningStream() {
        return logStream(Level.WARNING);
    }

    /**
     * Creates an output stream that writes to the log on the error log level.
     * 
     * Note that while this class tries to log entire lines separately, it
     * only handles the line break representations "\n", "\r" and "\r\n",
     * and assumes that the character encoding used encodes both '\n' and '\r'
     * like ASCII & UTF-8 does.
     */
    public final OutputStream errorStream() {
        return logStream(Level.ERROR);
    }

    private OutputStream logStream(Level level) {
        if (getLevel().shouldLog(level)) {
            return new LogOutputStream(level);
        } else {
            return NullStream.OUTPUT;
        }
    }

    /**
     * Creates an memory logger which allows for continuous printing on one
     * error level and optional printing afterwards on another level.
     * @param postPrintLevel the log level used when sending logs afterwards
     * @return a MemoryLogger
     */
    public final MemoryLogger memoryLogger(Level postPrintLevel) {
        return new MemoryLogger(this, postPrintLevel);
    }

    private class LogOutputStream extends OutputStream {

        private final Level level;
        private byte[] buf;
        private int n;
        private boolean lastR;

        private static final byte R = (byte) '\r';
        private static final byte N = (byte) '\n';

        public LogOutputStream(Level level) {
            this.level = level;
            buf = new byte[2048];
        }

        @Override
        public void write(int b) throws IOException {
            buf[n++] = (byte) b;
            if (lastR || b == N) {
                logBuffer();
            }
            lastR = (b == R);
        }

        @Override
        public void write(byte[] b, int off, int len) throws IOException {
            while (n + len > buf.length) {
                int part = buf.length - n;
                System.arraycopy(b, off, buf, n, part);
                n = buf.length;
                logBuffer();
                off += part;
                len -= part;
            }
            System.arraycopy(b, off, buf, n, len);
            n += len;
            logBuffer();
        }

        @Override
        public void close() throws IOException {
            log(level, new String(buf, 0, n));
        }

        private void logBuffer() {
            int start = 0;
            int nlpos = 0;

            while (nlpos >= 0) {
                nlpos = -1;
                for (int i = start; nlpos < 0 && i < n; i++) {
                    if (buf[i] == N || buf[i] == R) {
                        nlpos = i;
                    }
                }
                if (nlpos == n - 1 && buf[nlpos] == R && (start > 0 || n < buf.length)) {
                    lastR = true;
                    nlpos = -1;
                } else if (nlpos >= 0) {
                    log(level, new String(buf, start, nlpos - start));
                    start = nlpos + 1;
                    if (start < n && buf[start] == N && buf[start - 1] == R) {
                        start++;
                    }
                } else if (start == 0 && n == buf.length) {
                    log(level, new String(buf, 0, n));
                    start = n;
                }
            }

            n -= start;
            if (n > 0 && start > 0) {
                System.arraycopy(buf, start, buf, 0, n);
            }
        }

    }

    /**
     * Constructs a modelica logger based on the configuration string
     * given by <code>logString</code>. The syntax is:
     * format := log ',' format
     * format := log
     * log := flag ':' file # Writes to the file <code>file</code> with the log
     * level <code>flag</code> log := flag '|stdout' # Writes to stdout with the
     * log level <code>flag</code> log := flag '|stderr' # Writes to stderr with
     * the log level <code>flag</code> log := flag # Writes to stdout with the
     * log level <code>flag</code> flag := 'e' | 'w' | 'i' | 'd'
     * file := ... # Valid output file
     * 
     * @throws IllegalLogStringException when invalid log string is supplied
     */
    public static ModelicaLogger createModelicaLoggersFromLogString(String logString) throws IllegalLogStringException {
        Collection<String> problems = new ArrayList<String>();
        Map<String, LoggerProps> loggerMap = new HashMap<String, LoggerProps>();
        if (logString == null) {
            logString = "";
        }
        logString = logString.trim();
        // Step 1. Parse log string, put in map to remove duplicates
        if (logString.length() > 0) {
            String[] logParts = logString.split(",");
            for (String logPart : logParts) {
                int pipePos = logPart.indexOf('|');
                int colonPos = logPart.indexOf(':');
                LoggerProps.LoggerTarget target;
                if (pipePos > 0 && (colonPos == -1 || pipePos < colonPos) && logPart.length() >= pipePos + 4 && "|xml".equals(logPart.substring(pipePos, pipePos + 4))) {
                    target = LoggerProps.LoggerTarget.XML;
                    logPart = logPart.substring(0, pipePos) + logPart.substring(pipePos + 4);
                    pipePos = logPart.indexOf('|');
                    colonPos = logPart.indexOf(':');
                } else if (pipePos > 0 && (colonPos == -1 || pipePos < colonPos) && logPart.length() >= pipePos + 3 && "|os".equals(logPart.substring(pipePos, pipePos + 3))) {
                    target = LoggerProps.LoggerTarget.OBJECT_STREAM;
                    logPart = logPart.substring(0, pipePos) + logPart.substring(pipePos + 3);
                    pipePos = logPart.indexOf('|');
                    colonPos = logPart.indexOf(':');
                } else {
                    target = LoggerProps.LoggerTarget.STREAM;
                }
                String logLevelString;
                String targetString;
                if (pipePos == -1 && colonPos == -1) {
                    logLevelString = logPart.trim().toLowerCase();
                    targetString = "|stdout";
                } else if (pipePos > 0 && (colonPos == -1 || pipePos < colonPos)) {
                    logLevelString = logPart.substring(0, pipePos).trim().toLowerCase();
                    targetString = logPart.substring(pipePos).trim().toLowerCase();
                } else {
                    logLevelString = logPart.substring(0, colonPos).trim().toLowerCase();
                    targetString = logPart.substring(colonPos).trim();
                }
                Level logLevel;
                if ("e".equals(logLevelString) || "error".equals(logLevelString)) {
                    logLevel = Level.ERROR;
                } else if ("w".equals(logLevelString) || "warning".equals(logLevelString)) {
                    logLevel = Level.WARNING;
                } else if ("i".equals(logLevelString) || "info".equals(logLevelString)) {
                    logLevel = Level.INFO;
                } else if ("v".equals(logLevelString) || "verbose".equals(logLevelString)) {
                    logLevel = Level.VERBOSE;
                } else if ("d".equals(logLevelString) || "debug".equals(logLevelString)) {
                    logLevel = Level.DEBUG;
                } else {
                    problems.add("Unknown log level '" + logLevelString + "'!");
                    continue;
                }
                loggerMap.put(targetString, new LoggerProps(logLevel, target));
            }
        }
        // Step 2. Create loggers
        List<ModelicaLogger> loggers = new ArrayList<ModelicaLogger>();
        for (Map.Entry<String, LoggerProps> logPair : loggerMap.entrySet()) {
            String delimiter = logPair.getKey().substring(0, 1);
            String destination = logPair.getKey().substring(1);
            LoggerProps.LoggerTarget target = logPair.getValue().target;
            Level level = logPair.getValue().level;
            try {
                ModelicaLogger logger;
                if (delimiter.startsWith(":")) {
                    logger = target.createLogger(level, destination);
                } else if ("stdout".equals(destination)) {
                    logger = target.createLogger(level, System.out);
                } else if ("stderr".equals(destination)) {
                    logger = target.createLogger(level, System.err);
                } else {
                    problems.add("Unknown pipe log output: '" + destination + "'. Possible values are 'stdout' and 'stderr'.");
                    continue;
                }
                loggers.add(logger);
            } catch (FileNotFoundException e) {
                problems.add("Unable to open log file '" + destination + "' for writing!" + (e.getMessage() != null ? " " + e.getMessage() : ""));
            } catch (IOException e) {
                problems.add("Unable to open log stream '" + logPair.getKey() + "'!" + (e.getMessage() != null ? " " + e.getMessage() : ""));
            }
        }
        if (loggers.size() == 0) {
            loggers.add(new StreamingLogger(Level.ERROR, System.out));
        }
        // Step 3. Create TeeLogger if necessary
        ModelicaLogger logger;
        if (loggers.size() == 1) {
            logger = loggers.get(0);
        } else {
            logger = new TeeLogger(loggers.toArray(new ModelicaLogger[loggers.size()]));
        }
        if (problems.size() > 0) {
            StringBuilder sb = new StringBuilder();
            sb.append("Invalid log string, the following problems was found:\n");
            for (String problem : problems) {
                sb.append("    ");
                sb.append(problem);
                sb.append('\n');
            }
            throw new IllegalLogStringException(sb.toString(), logger);
        }
        return logger;
    }

    private static class LoggerProps {
        private final LoggerTarget target;
        private final Level level;

        private LoggerProps(Level level, LoggerTarget target) {
            this.level = level;
            this.target = target;
        }

        private static enum LoggerTarget {
            STREAM {
                @Override
                public PipeLogger createLogger(Level level, OutputStream stream) throws IOException {
                    return new StreamingLogger(level, stream);
                }
                
                @Override
                public PipeLogger createLogger(Level level, String filename) throws IOException {
                    return new StreamingLogger(level, filename);
                }
            },
            OBJECT_STREAM {
                @Override
                public PipeLogger createLogger(Level level, OutputStream stream) throws IOException {
                    return new ObjectStreamLogger(level, stream);
                }
                
                @Override
                public PipeLogger createLogger(Level level, String filename) throws IOException {
                    return new ObjectStreamLogger(level, filename);
                }
            },
            XML {
                @Override
                public PipeLogger createLogger(Level level, OutputStream stream) throws IOException {
                    return new XMLLogger(level, stream);
                }
                
                @Override
                public PipeLogger createLogger(Level level, String filename) throws IOException {
                    return new XMLLogger(level, filename);
                }
            };

            public abstract PipeLogger createLogger(Level level, OutputStream stream) throws IOException;
            public abstract PipeLogger createLogger(Level level, String filename) throws IOException;
        }
    }

}
