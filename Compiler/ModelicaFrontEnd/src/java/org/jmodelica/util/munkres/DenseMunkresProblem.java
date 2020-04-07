package org.jmodelica.util.munkres;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

/** 
 * A class with a dense implementation of the Munkres (Hungarian) algorithm:
 * based on the description at:
 * http://csclab.murraystate.edu/bob.pilgrim/445/munkres.html
 */
public class DenseMunkresProblem<T extends MunkresCost<T>> extends MunkresProblem<T> {

    private final Incidence<T>[][] matrix;
    private final List<RowOrColumn<T>> rows;
    private final List<RowOrColumn<T>> columns;
    private final IncidenceIterable incidenceIterable;
    private final int numRows;
    private final int numColumns;

    @SuppressWarnings("unchecked")
    public DenseMunkresProblem(T[][] initialCost) {
        super(initialCost.length == 0 ? 0 : Math.min(initialCost.length, initialCost[0].length));
        int tmpNumColumns = 0;
        matrix = new Incidence[initialCost.length][];
        for (int row = 0; row < initialCost.length; row++) {
            if (tmpNumColumns == 0) {
                tmpNumColumns = initialCost[row].length;
            } else if (tmpNumColumns != initialCost[row].length) {
                throw new IllegalArgumentException("The length of the rows in the matrix differ, got " + tmpNumColumns + " previously and " + initialCost[row].length + " now!");
            }
            matrix[row] = new Incidence[tmpNumColumns];
            for (int column = 0; column < tmpNumColumns; column++) {
                matrix[row][column] = new Incidence<T>(row, column, initialCost[row][column]);
            }
        }
        numRows = initialCost.length;
        numColumns = tmpNumColumns;
        List<RowOrColumn<T>> tmpRows = new ArrayList<RowOrColumn<T>>(numRows);
        for (int row = 0; row < numRows; row++) {
            tmpRows.add(new DenseRow(row));
        }
        rows = Collections.unmodifiableList(tmpRows);
        List<RowOrColumn<T>> tmpColumns = new ArrayList<RowOrColumn<T>>(numRows);
        for (int column = 0; column < numColumns; column++) {
            tmpColumns.add(new DenseColumn(column));
        }
        columns = Collections.unmodifiableList(tmpColumns);
        incidenceIterable = new IncidenceIterable();
    }

    @Override
    protected Iterable<Incidence<T>> incidences() {
        return incidenceIterable;
    }

    @Override
    protected Iterable<? extends RowOrColumn<T>> rows() {
        return rows;
    }

    @Override
    protected Iterable<? extends RowOrColumn<T>> columns() {
        return columns;
    }

    @Override
    protected RowOrColumn<T> row(int index) {
        return rows.get(index);
    }

    @Override
    protected RowOrColumn<T> column(int index) {
        return columns.get(index);
    }

    private class DenseRow extends RowOrColumn<T> {

        private final int row;

        public DenseRow(int row) {
            this.row = row;
        }

        @Override
        public Iterator<Incidence<T>> iterator() {
            return new Iterator<Incidence<T>>() {
                private int column = 0;

                @Override
                public boolean hasNext() {
                    return numColumns > column;
                }

                @Override
                public Incidence<T> next() {
                    return matrix[row][column++];
                }

                @Override
                public void remove() {
                    throw new UnsupportedOperationException("remove() is not supported");
                }
            };
        }

    }

    private class DenseColumn extends RowOrColumn<T> {

        private final int column;

        public DenseColumn(int column) {
            this.column = column;
        }

        @Override
        public Iterator<Incidence<T>> iterator() {
            return new Iterator<Incidence<T>>() {
                private int row = 0;

                @Override
                public boolean hasNext() {
                    return numRows > row;
                }

                @Override
                public Incidence<T> next() {
                    return matrix[row++][column];
                }

                @Override
                public void remove() {
                    throw new UnsupportedOperationException("remove() is not supported");
                }
            };
        }

    }

    private class IncidenceIterable implements Iterable<Incidence<T>> {

        @Override
        public Iterator<Incidence<T>> iterator() {
            return new Iterator<Incidence<T>>() {

                private int row = 0;
                private int column = 0;

                @Override
                public boolean hasNext() {
                    return numRows > row;
                }

                @Override
                public Incidence<T> next() {
                    Incidence<T> val = matrix[row][column];
                    column++;
                    if (numColumns <= column) {
                        column = 0;
                        row++;
                    }
                    return val;
                }

                @Override
                public void remove() {
                    throw new UnsupportedOperationException("remove() is not supported");
                }
            };
        }

    }

}
