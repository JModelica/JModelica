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

import org.jmodelica.util.Criteria;

public class FilteredIterator<T> implements Iterator<T> {
	
	private final Iterator<T> parent;
	private final Criteria<? super T> criteria;
	private T next;
	private boolean hasNext = true;
	
	public FilteredIterator(Iterator<T> parent, Criteria<? super T> criteria) {
		this.parent = parent;
		this.criteria = criteria;
		progress();
	}
	
	private void progress() {
		while (parent.hasNext()) {
			next = parent.next();
			if (criteria.test(next)) {
				return;
			}
		}
		next = null;
		hasNext = false;
	}

	@Override
    public boolean hasNext() {
		return hasNext;
	}

	@Override
    public T next() {
		if (!hasNext) {
			throw new NoSuchElementException();
		}
		T res = next;
		progress();
		return res;
	}

	@Override
    public void remove() {
		throw new UnsupportedOperationException();
	}

}
