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
 * Iterator that iterates over a specified sub class.
 */
public final class SubClassIterator<U, T extends U> implements Iterator<T> {

    private final Iterator<? extends U> subIterator;
    private final Class<T> typeOfClass;
    private T next = null;

    public SubClassIterator(Class<T> typeOfClass, Iterator<? extends U> subIterator) {
        this.typeOfClass = typeOfClass;
        this.subIterator = subIterator;
        updateNext();
    }

    private void updateNext() {
        while (subIterator.hasNext()) {
            U val = subIterator.next();
            if (typeOfClass.isInstance(val)) {
                next = typeOfClass.cast(val);
                return;
            }
        }
        next = null;
    }

    @Override
    public boolean hasNext() {
        return next != null;
    }

    @Override
    public T next() {
        T ret = next;
        if (ret == null) {
            throw new NoSuchElementException();
        }
        updateNext();
        return ret;
    }

    @Override
    public void remove() {
        throw new UnsupportedOperationException();
    }

}
