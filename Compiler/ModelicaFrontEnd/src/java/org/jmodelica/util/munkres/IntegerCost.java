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
 * Cost represented by an Integer that is used in Munkres problem. A lower
 * value results in the variable being more prone for selection since the
 * Munkres algorithm tries to minimize the sum of all matched variables.
 * 
 * Use the static method create() for instantiating a matrix of this type
 */
public class IntegerCost implements MunkresCost<IntegerCost> {
    
    private int value;
    
    private IntegerCost(int value) {
        this.value = value;
    }
    
    @Override
    public int compareTo(IntegerCost other) {
        return Integer.compare(value, other.value);
    }

    @Override
    public void subtract(IntegerCost other) {
        value -= other.value;
    }

    @Override
    public void add(IntegerCost other) {
        value += other.value;
    }

    @Override
    public boolean isZero() {
        return value == 0;
    }
    
    @Override
    public IntegerCost copy() {
        return new IntegerCost(value);
    }
    
    /**
     * Constructs an matrix of Integer costs.
     * @param values The integer costs
     * @return A matrix which can be used in a Munkres problem
     */
    public static IntegerCost[][] create(int[][] values) {
        IntegerCost[][] costs = new IntegerCost[values.length][];
        for (int j = 0; j < values.length; j++) {
            costs[j] = new IntegerCost[values[j].length];
            for (int i = 0; i < values.length; i++)
                costs[j][i] = new IntegerCost(values[j][i]);
        }
        return costs;
    }
    
    @Override
    public String toString() {
        return Integer.toString(value);
    }
}
