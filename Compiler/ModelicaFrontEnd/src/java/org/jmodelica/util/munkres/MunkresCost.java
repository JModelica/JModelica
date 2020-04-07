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
package org.jmodelica.util.munkres;

/**
 * Interface that must be implemented for the cost of each incidence. Classes
 * implementing this interface can be used to solved dense Munkres problems.
 */
public interface MunkresCost<T> extends Comparable<T> {
    /**
     * Compares this cost with another of the same type. A return value less
     * than zero means that this cost is lower than the other, higher means
     * that this is higher than the other and zero indicates that the two
     * costs are equal
     * 
     * @param other The other cost
     * @return Integer indicating the difference between the two costs
     */
    @Override
    public int compareTo(T other);

    /**
     * Updates this cost by subtracting the cost of the cost other.
     * 
     * @param other The cost that should be subtracted.
     */
    public void subtract(T other);

    /**
     * Updates this cost by adding the cost of the cost other.
     * 
     * @param other The cost that should be added.
     */
    public void add(T other);

    /**
     * Checks if this cost is equal to zero.
     * 
     * @return true if the cost is equal to zero, otherwise false
     */
    public boolean isZero();

    /**
     * Creates a new copy of this cost.
     * 
     * @return A copy of this cost
     */
    public T copy();
}
