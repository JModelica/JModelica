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
package org.jmodelica.util.logging.units;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.StringWriter;

import org.jmodelica.util.exceptions.ModelicaException;
import org.jmodelica.util.logging.Level;
import org.jmodelica.util.logging.XMLLogger;

public class ThrowableLoggingUnit implements LoggingUnit {

    private static final long serialVersionUID = 1975890836770936933L;

    private Throwable throwable;

    public ThrowableLoggingUnit(Throwable throwable) {
        this.throwable = throwable;
    }

    @Override
    public String print(Level level) {
        StringWriter str = new StringWriter();
        PrintWriter print = new PrintWriter(str);
        if (throwable instanceof ModelicaException) {
            print.append(throwable.getMessage());
        } else if (throwable instanceof FileNotFoundException) {
            print.append("Could not find file: " + throwable.getMessage());
        } else if (throwable instanceof OutOfMemoryError) {
            print.append("Out of memory. Please set the memory limit of the JVM higher.");
        } else {
            print.append("Unknown program error, " + throwable.getClass().getName());
            if (throwable.getMessage() != null)
                print.append(": " + throwable.getMessage());
        }
        if (level.shouldLog(Level.DEBUG)) {
            throwable.printStackTrace(print);
        }
        return str.toString();
    }

    @Override
    public String printXML(Level level) {
        StringWriter str = new StringWriter();
        PrintWriter print = new PrintWriter(str);
        throwable.printStackTrace(print);
        return XMLLogger.write_node("Exception", 
                   "kind",       throwable.getClass().getName(),
                   "message",    throwable.getMessage() == null ? "" : throwable.getMessage(), 
                   "stacktrace", str.toString());
    }

    public Throwable getException() {
        return throwable;
    }

}
