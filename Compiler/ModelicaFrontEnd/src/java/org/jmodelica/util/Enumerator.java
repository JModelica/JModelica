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

/**
 * A simple class that can be used when calculating indexes to nodes
 * 
 * @author jsten
 *
 */
public class Enumerator {
	
	private int count;
	
	/**
	 * Default constructor with start value of zero.
	 */
	public Enumerator() {
		this(0);
	}
	
	/**
	 * Constructor allows for custom start value when enumerating.
	 * 
	 * @param start The start value
	 */
	public Enumerator(int start) {
		count = start;
	}
	
	/**
	 * Produces a copy of this enumerator, current index is preserved.
	 * @return A copy of this enumerator
	 */
	public Enumerator copy() {
		return new Enumerator(count);
	}
	
	/**
	 * Returns the current index and increments it.
	 * @return current index
	 */
	public int next() {
		return count++;
	}
	
	/**
	 * Returns the current index without incrementing.
	 * @return current index
	 */
	public int peek() {
		return count;
	}

    @Override
    public String toString() {
        return getClass().getSimpleName() + ", next value: " + count;
    }

}