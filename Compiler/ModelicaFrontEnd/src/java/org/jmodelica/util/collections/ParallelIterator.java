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

/**
 * Iterator that iterates over several iterators in parallel.
 */
public class ParallelIterator<T> implements Iterator<T[]> {
	
	private T[] elems;
	private Iterator<? extends T>[] iters;
	private boolean max;

    @SafeVarargs
	public ParallelIterator(T[] res, Iterator<? extends T>... iterators) {
		this(res, false, iterators);
	}

    @SafeVarargs
	public ParallelIterator(T[] res, boolean max, Iterator<? extends T>... iterators) {
		iters = iterators;
		elems = res;
		this.max = max;
		if (elems.length < iters.length)
			throw new IllegalArgumentException();
		for (int i = iters.length; i < elems.length; i++)
			elems[i] = null;
	}
	
	@Override
    public boolean hasNext() {
		for (Iterator<? extends T> it : iters)
			if (it.hasNext() == max)
				return max;
		return !max;
	}
	
	@Override
    public T[] next() {
		for (int i = 0; i < iters.length; i++)
			elems[i] = iters[i].hasNext() ? iters[i].next() : null;
		return elems;
	}

	@Override
    public void remove() {
		for (Iterator<? extends T> it : iters)
			it.remove();
	}
	
}
