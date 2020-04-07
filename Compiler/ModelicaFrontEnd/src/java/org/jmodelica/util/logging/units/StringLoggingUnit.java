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

import org.jmodelica.util.XMLUtil;
import org.jmodelica.util.logging.Level;

public class StringLoggingUnit implements LoggingUnit {

    private static final long serialVersionUID = 7260935338610275821L;

    private String string;
    private Object[] args;

    public StringLoggingUnit(String string, Object ... args) {
        this.string = string;
        this.args = args;
    }
    
    /**
     * This method should be called before each print. It ensures that
     * expensive operation such as String.format() only is done once.
     */
    private void computeString() {
        if (args != null && args.length > 0) {
            string = String.format(string, args);
            args = null;
        }
    }

    @Override
    public String print(Level level) {
        computeString();
        return string;
    }

    @Override
    public String printXML(Level level) {
        computeString();
        return XMLUtil.escape(string);
    }

}
