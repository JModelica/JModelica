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
package org.jmodelica.util;

import java.lang.reflect.Field;
import java.security.AccessController;
import java.security.PrivilegedAction;

import beaver.Symbol;

/**
 * Changes value of <code>value</code> field of beaver.Symbol to refer to itself.
 * Needed to work around bug where fullCopy() copies <code>value</code> field as well.
 */
public class SymbolValueFixer {
	private final static Field VALUE;

	static {
		Field f = null;
		try {
			f = beaver.Symbol.class.getField("value");
		} catch (Exception e) {
			throw (e instanceof RuntimeException) ? (RuntimeException) e : new RuntimeException(e);
		}
		VALUE = f;
		AccessEnabler.enable(VALUE);
	}

	public static void fix(Symbol s) {
		try {
			VALUE.set(s, s);
		} catch (Exception e) {
			throw (e instanceof RuntimeException) ? (RuntimeException) e : new RuntimeException(e);
		}
	}

	private static class AccessEnabler implements PrivilegedAction<Object> {

		public static void enable(Field f) {
			AccessController.doPrivileged(new AccessEnabler(f));
		}

		private Field field;

		private AccessEnabler(Field f) {
			field = f;
		}

		@Override
        public Object run() {
			field.setAccessible(true);
			return null;
		}

	}

}
