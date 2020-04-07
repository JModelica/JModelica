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

public class ChainedIterator<E> implements Iterator<E> {
	
	private Iterator<? extends E>[] its;
	private int i;
	
    @SafeVarargs // This is safe, we never edit the array!
    public ChainedIterator(Iterator<? extends E>... its) {
		this.its = its;
	}

	@Override
    public boolean hasNext() {
		while (i < its.length && !its[i].hasNext()) {
			i++;
		}
		return i < its.length;
	}

	@Override
    public E next() {
		if (!hasNext()) {
			throw new NoSuchElementException();
		}
		return its[i].next();
	}

	@Override
    public void remove() {
		throw new UnsupportedOperationException();
	}

}
