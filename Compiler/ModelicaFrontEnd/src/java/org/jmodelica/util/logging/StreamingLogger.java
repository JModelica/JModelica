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

import org.jmodelica.util.logging.units.LoggingUnit;

public class StreamingLogger extends PipeLogger {

    /**
     * Constructs a logger with log level <code>level</code> and
     * writes to the file with the name <code>fileName</code>.
     * 
     * @param level log level of this logger
     * @param fileName Name of file that should be written
     * @throws FileNotFoundException thrown when invalid file name is supplied
     */
    public StreamingLogger(Level level, String fileName) throws IOException {
        super(level, fileName);
    }

    /**
     * Constructs a logger with log level <code>level</code> and
     * writes to the file <code>file</code>.
     * 
     * @param level log level of this logger
     * @param file File that should be written
     * @throws FileNotFoundException thrown when invalid file is supplied
     */
    public StreamingLogger(Level level, File file) throws IOException {
        super(level, file);
    }

    /**
     * Constructs a logger with log level <code>level</code> and
     * writes log output to OutputStream <code>stream</code>
     * 
     * @param level log level of this logger
     * @param stream OutputStream that the log is written to
     */
    public StreamingLogger(Level level, OutputStream stream) {
        super(level, stream);
    }

    @Override
    protected void do_write(LoggingUnit logMessage) throws IOException {
        write_raw(logMessage.print(getLevel()));
        write_raw("\n");
    }

}
