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

public class ChainedIterable<T> implements Iterable<T> {

    private Iterable<? extends T>[] its;

    @SafeVarargs // This is safe, we never edit the array!
    public ChainedIterable(Iterable<? extends T> ... its) {
        this.its = its;
    }

    @Override
    public Iterator<T> iterator() {
        @SuppressWarnings("unchecked")
        Iterator<? extends T>[] iterators = new Iterator[its.length];
        for (int i = 0; i < its.length; i++)
            iterators[i] = its[i].iterator();
        return new ChainedIterator<T>(iterators);
    }
}
