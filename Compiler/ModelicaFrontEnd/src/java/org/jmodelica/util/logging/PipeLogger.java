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

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.jmodelica.util.logging.units.LoggingUnit;

public abstract class PipeLogger extends ModelicaLogger {

    private State state = State.ACTIVE;
    private final OutputStream stream;
    private final boolean thisCreatedStream;

    public PipeLogger(Level level, String fileName) throws IOException {
        this(level, new File(fileName));
    }

    public PipeLogger(Level level, File file) throws IOException {
        super(level);
        this.stream = createStream(file);
        thisCreatedStream = true;
    }

    public PipeLogger(Level level, OutputStream stream) {
        super(level);
        this.stream = stream;
        thisCreatedStream = false;
    }
    
    protected OutputStream getStream() {
        return stream;
    }
    
    protected OutputStream createStream(File file) throws IOException {
        return new BufferedOutputStream(new FileOutputStream(file));
    }

    @Override
    public final void close() {
        if (state == State.CLOSED)
            return;
        state = State.CLOSED;
        try {
            do_close();
        } catch (IOException e) {
            // ignore
        }
    }
    
    protected void do_close() throws IOException {
        if (thisCreatedStream) {
            stream.close();
        }
    }

    @Override
    protected void finalize() throws Throwable {
        close();
        super.finalize();
    }

    /**
     * Check if a message on given level should be written.
     */
    private boolean shouldWrite(Level level, Level alreadySentLevel) {
        if (!getLevel().shouldLog(level, alreadySentLevel))
            return false;
        if (state == State.EXCEPTION)
            return false;
        if (state == State.CLOSED) {
            System.err.println("Compiler is writing to closed logger!");
            state = State.EXCEPTION;
            return false;
        }
        return true;
    }

    /**
     * Called for exceptions caught while writing to pipe.
     */
    private void exceptionOnWrite(Exception e) {
        state = State.EXCEPTION;
        System.err.println("Compiler logger failed to write." + (e.getMessage() != null ? " " + e.getMessage() : ""));
    }

    @Override
    protected final void write(Level level, Level alreadySentLevel, LoggingUnit logMessage) {
        if (!shouldWrite(level, alreadySentLevel))
            return;
        try {
            do_write(logMessage);
        } catch (IOException e) {
            exceptionOnWrite(e);
        }
    }

    protected abstract void do_write(LoggingUnit logMessage) throws IOException;

    private static enum State {
        ACTIVE, CLOSED, EXCEPTION,
    }
    
    protected void write_raw(String logMessage) throws IOException {
        stream.write(logMessage.getBytes());
    }

}
