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

import org.jmodelica.api.problemHandling.ProblemSeverity;


public enum Level {
    ERROR,
    WARNING,
    INFO,
    VERBOSE,
    DEBUG;
    
    public Level union(Level other) {
        if (this.compareTo(other) > 0)
            return this;
        else
            return other;
    }
    
    public boolean shouldLog(Level other) {
        return this.compareTo(other) >= 0;
    }
    
    public boolean shouldLog(Level other, Level alreadySentLevel) {
        return this.compareTo(other) >= 0 && (alreadySentLevel == null || this.compareTo(alreadySentLevel) < 0);
    }
    
    public static Level fromKind(ProblemSeverity severity) {
        switch (severity) {
        case ERROR:
            return ERROR;
        case WARNING:
            return WARNING;
        }
        return ERROR; // Should never happen
    }
}
