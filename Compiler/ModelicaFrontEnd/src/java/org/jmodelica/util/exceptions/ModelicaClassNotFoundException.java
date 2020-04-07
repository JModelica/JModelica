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
package org.jmodelica.util.exceptions;

/**
 * Exception to be thrown when the Modelica class to instantiate is not
 * found.
 */
public class ModelicaClassNotFoundException extends ModelicaException {
    private static final long serialVersionUID = 1;
	private String className;

	public ModelicaClassNotFoundException(String className) {
		super("Class " + className + " not found");
		this.className = className;
	}

	public String getClassName() {
		return className;
	}

}
