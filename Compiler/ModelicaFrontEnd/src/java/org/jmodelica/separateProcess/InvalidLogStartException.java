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

public class InvalidLogStartException extends SeparateProcessException {
    private static final long serialVersionUID = 1;
    private final String completeLog;
    public InvalidLogStartException(String log) {
        super(createLogMessage(log));
        completeLog = log;
    }
    
    public String getCompleteLog() {
        return completeLog;
    }
    
    private static String createLogMessage(String log) {
        int pos = log.indexOf('\n');
        if (pos != -1) {
            pos = log.indexOf('\n', pos + 1);
            if (pos != -1) {
                log = log.substring(0, pos + 1) + "...";
            }
        }
        
        return "Unexpected start of output stream from compiler:\n" + log;
    }
}
