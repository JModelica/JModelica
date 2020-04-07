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
 * Iterable that iterates over several iterables in parallel.
 */
public class ParallelIterable<T> implements Iterable<T[]> {
	
	private T[] elems;
	private Iterable<? extends T>[] iters;
	private boolean max;

    @SafeVarargs
	public ParallelIterable(T[] res, Iterable<? extends T>... iterables) {
		this(res, false, iterables);
	}

    @SafeVarargs
	public ParallelIterable(T[] res, boolean max, Iterable<? extends T>... iterables) {
		iters = iterables;
		elems = res;
		this.max = max;
	}

    @Override
    public Iterator<T[]> iterator() {
        @SuppressWarnings("unchecked")
        Iterator<? extends T>[] iterators = new Iterator[iters.length];
        for (int i = 0; i < iters.length; i++)
            iterators[i] = iters[i].iterator();
        return new ParallelIterator<T>(elems, max, iterators);
    }

}
