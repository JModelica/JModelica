/*
    Copyright (C) 2010-2018 Modelon AB

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

package org.jmodelica.util;

import org.jmodelica.common.options.AbstractOptionRegistry;

public class OptionRegistry extends AbstractOptionRegistry {
    /*
     * This class is only here to support old versions of pymodelica
     */
    
    public static class UnknownOptionException extends AbstractOptionRegistry.UnknownOptionException {
        private static final long serialVersionUID = 7226800291471043612L;

        public UnknownOptionException(String message) {
            super(message);
        }
    }

    @Override
    public AbstractOptionRegistry copy() {
        OptionRegistry res = new OptionRegistry();
        res.copyAllOptions(this);
        return res;
    }
}
