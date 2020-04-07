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

import org.jmodelica.util.logging.units.LoggingUnit;

/**
 * TeeLogger splits the incoming log and writes it to several other logs.
 */
public class TeeLogger extends ModelicaLogger {
    
    private ModelicaLogger[] loggers;
    
    /**
     * Constructs a TeeLogger, takes a list of sub loggers that the log
     * will be written to.
     * @param loggers a list of sub loggers
     */
    public TeeLogger(ModelicaLogger[] loggers) {
        super(calculateLevel(loggers));
        this.loggers = loggers;
    }

    @Override
    public void close() {
        for (ModelicaLogger logger : loggers)
            logger.close();
    }
    
    private static Level calculateLevel(ModelicaLogger[] loggers) {
        Level level = Level.ERROR;
        for (ModelicaLogger logger : loggers)
            level = level.union(logger.getLevel());
        return level;
    }

    @Override
    protected void write(Level level, Level alreadySentLevel, LoggingUnit logMessage) {
        for (ModelicaLogger logger : loggers)
            logger.write(level, alreadySentLevel, logMessage);
    }

}
