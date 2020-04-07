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

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;

public class LinkedHashListMap<K, V> extends LinkedHashMap<K, List<V>> implements ListMap<K, V> {

    private static final long serialVersionUID = 1L;

    public LinkedHashListMap() {
        super();
    }

    public LinkedHashListMap(int initialCapacity, float loadFactor) {
        super(initialCapacity, loadFactor);
    }

    public LinkedHashListMap(int initialCapacity) {
        super(initialCapacity);
    }

    @Override
    public void add(K key, V value) {
        List<V> list = getList(key, true);
        list.add(value);
    }

    @Override
    public List<V> getList(K key) {
        return getList(key, false);
    }

    @Override
    public List<V> getList(K key, boolean create) {
        java.util.List<V> list = get(key);
        if (list != null) {
            return list;
        } else if (create) {
            list = new ArrayList<V>();
            put(key, list);
            return list;
        } else {
            return Collections.<V>emptyList();
        }
    }

    @Override
    public boolean removeFirst(K key, V value) {
        java.util.List<V> l = get(key);
        if (l != null) {
            Iterator<V> li = l.iterator();
            while (li.hasNext()) {
                if (li.next() == value) {
                    li.remove();
                    return true;
                }
            }
        }
        return false;
    }

}
