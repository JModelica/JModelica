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

import java.util.List;
import java.util.Map;

/**
 * A map of lists.
 */
public interface ListMap<K, V> extends Map<K, List<V>> {

    /**
     * If there is a list mapped to key, add value to it, otherwise map a new list containing value to key.
     */
    public void add(K key, V value);

    /**
     * Get the list mapped to key, or an empty list if there is no list mapped to key.
     */
    public List<V> getList(K key);

    /**
     * Get the list mapped to key, or an empty list if there is no list mapped to key.
     * 
     * @param create If true and key doesn't exist in the map, then a new
     *                  list will be created and inserted
     */
    public List<V> getList(K key, boolean create);
    
    /**
     * Remove the first instance of value from the list mapped to key, if any.
     * 
     * @return  true if any element was removed
     */
    public boolean removeFirst(K key, V value);
}
