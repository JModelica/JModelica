package org.jmodelica.test.common;

import java.util.LinkedList;

import org.jmodelica.util.logging.Level;
import org.jmodelica.util.logging.ModelicaLogger;
import org.jmodelica.util.logging.units.LoggingUnit;

public class TestLogger extends ModelicaLogger {
    private LinkedList<String> messages = new LinkedList<>();
    public TestLogger() {
        super(Level.INFO);
    }
    
    public TestLogger(Level loglevel) {
    	super(loglevel);
    }

    @Override
    public void close() {
        // ignore
    }

    @Override
    protected void write(Level level, Level alreadySentLevel, LoggingUnit logMessage) {
        messages.add(level + ": " + logMessage.print(getLevel()));
    }

    public String next() {
        if (messages.isEmpty()) {
            return null;
        }
        return messages.removeFirst();
    }
    
}