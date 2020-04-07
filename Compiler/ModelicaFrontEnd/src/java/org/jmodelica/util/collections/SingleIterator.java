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

package org.jmodelica.util.collections;

import java.util.Iterator;
import java.util.NoSuchElementException;

/**
 * \brief Generic iterator over a single value.
 */
public class SingleIterator<T> implements Iterator<T> {
	
	protected T elem;
	protected boolean ok;
	
	public SingleIterator(T e) {
		elem = e;
		ok = true;
	}
	
	@Override
    public boolean hasNext() {
		return ok;
	}
	
	@Override
    public T next() {
		if (!ok)
			throw new NoSuchElementException();
		ok = false;
		return elem;
	}
	
	@Override
    public void remove() {
		throw new UnsupportedOperationException();
	}
}
