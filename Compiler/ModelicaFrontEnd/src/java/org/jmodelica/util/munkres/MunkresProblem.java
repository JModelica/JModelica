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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.jmodelica.util.exceptions.MunkresException;

/**
 * An abstract class with the implementation of the Munkres (Hungarian)
 * algorithm: based on the description at:
 * http://csclab.murraystate.edu/bob.pilgrim/445/munkres.html
 */
public abstract class MunkresProblem<T extends MunkresCost<T>> {

    private enum State {
        COVER_MATCHED_COLUMNS, PRIME_ZEROS, ADD_SUB_MIN_VALUE
    }

    private final int k;
    private State nextStep = State.COVER_MATCHED_COLUMNS;

    /**
     * Constructor...
     * @param k The minimum of the number of rows and the number of columns
     */
    protected MunkresProblem(int k) {
        this.k = k;
    }

    /**
     * Solves the Munkres problem.
     * 
     * @return the optimal solution as and integer matrix where
     */
    public int[][] solve() {
        minimizeRows();

        match();

        nextStep = State.COVER_MATCHED_COLUMNS;

        boolean done = false;
        while (!done) {

            switch (nextStep) {
            case COVER_MATCHED_COLUMNS:
                int nbrMatchedColumns = coverMatchedColumns();
                if (nbrMatchedColumns == k) {
                    done = true;
                }
                break;
            case PRIME_ZEROS:
                primeZeros();
                break;
            case ADD_SUB_MIN_VALUE:
                addSubMinValue();
                break;
            }
        }

        int[][] result = new int[k][2];
        int ind = 0;
        for (Incidence<T> incidence : incidences()) {
            if (incidence.isStarred()) {
                result[ind++] = new int[] { incidence.getRow(), incidence.getColumn() };
            }
        }
        return result;
    }

    /**
     * Returns an Iterable that can be used to iterate over all the elements
     * in the problem. Iteration should be done row by row.
     * 
     * @return an Iterable for iteration over the incidences
     */
    protected abstract Iterable<Incidence<T>> incidences();

    /**
     * Returns an Iterable that can be used to iterate over the rows.
     * 
     * @return and Iterable for iteration over the rows
     */
    protected abstract Iterable<? extends RowOrColumn<T>> rows();

    /**
     * Returns an Iterable that can be used to iterate over the columns.
     * 
     * @return and Iterable for iteration over the columns
     */
    protected abstract Iterable<? extends RowOrColumn<T>> columns();

    /**
     * Retrieves a specific row with the index index.
     * 
     * @param index index of the row that should be retrieved
     * @return a specific row
     */
    protected abstract RowOrColumn<T> row(int index);

    /**
     * Retrieves a specific column with the index index.
     * 
     * @param index index of the column that should be retrieved
     * @return a specific column
     */
    protected abstract RowOrColumn<T> column(int index);

    private RowOrColumn<T> row(Incidence<T> incidence) {
        return row(incidence.getRow());
    }

    private RowOrColumn<T> column(Incidence<T> incidence) {
        return column(incidence.getColumn());
    }

    private void minimizeRows() {
        for (RowOrColumn<T> row : rows()) {
            T row_min = null;
            for (Incidence<T> incidence : row) {
                if (row_min == null || incidence.getCost().compareTo(row_min) < 0) {
                    row_min = incidence.getCost();
                }
            }
            if (row_min == null) {
                throw new MunkresException("No incidences found in row");
            }
            row_min = row_min.copy();
            for (Incidence<T> incidence : row) {
                    incidence.getCost().subtract(row_min);
            }
        }
    }

    private void match() {
        // Greedy matching: Hopcorft Karp would be better
        for (Incidence<T> incidence : incidences()) {
            if (incidence.getCost().isZero() && !row(incidence).isCovered() && !column(incidence).isCovered()) {
                incidence.setStarred(true);
                row(incidence).setCovered(true);
                column(incidence).setCovered(true);
            }
        }
        resetCovers();
    }

    private int coverMatchedColumns() {
        int nStarred = 0;
        for (RowOrColumn<T> column : columns()) {
            if (column.hasStarredIncidences()) {
                column.setCovered(true);
                nStarred++;
            }
        }
        nextStep = State.PRIME_ZEROS;
        return nStarred;
    }

    private void primeZeros() {
        while (true) {
            Incidence<T> uncovered = findUncoveredZero();
            if (uncovered == null) {
                nextStep = State.ADD_SUB_MIN_VALUE;
                return;
            }
            uncovered.setPrimed(true);
            RowOrColumn<T> uncoveredRow = row(uncovered);
            Incidence<T> starred = uncoveredRow.getStarredIncidence();
            if (starred == null) {
                augmentPath(uncovered);
                return;
            } else {
                RowOrColumn<T> starredColumn = column(starred);
                uncoveredRow.setCovered(true);
                starredColumn.setCovered(false);
            }
        }
    }

    private void augmentPath(Incidence<T> start) {
        List<Incidence<T>> path = new ArrayList<Incidence<T>>();
        path.add(start);
        while (true) {
            Incidence<T> last = path.get(path.size() - 1);
            RowOrColumn<T> column = column(last);
            Incidence<T> starred = column.getStarredIncidence();
            if (starred != null) {
                path.add(starred);
                last = starred;
            } else {
                break;
            }

            RowOrColumn<T> row = row(last);
            Incidence<T> primed = row.getPrimedIncidences();
            path.add(primed);
        }
        // Flip stars
        for (Incidence<T> incidence : path) {
            incidence.setStarred(!incidence.isStarred());
        }
        resetCovers();
        resetPrimed();
        nextStep = State.COVER_MATCHED_COLUMNS;
    }

    private void addSubMinValue() {
        T minValue = findMinUncoveredValue();
        for (Incidence<T> incidence : incidences()) {
            if (row(incidence).isCovered()) {
                incidence.getCost().add(minValue);
            }
            if (!column(incidence).isCovered()) {
                incidence.getCost().subtract(minValue);
            }
        }
        nextStep = State.PRIME_ZEROS;
    }

    private Incidence<T> findUncoveredZero() {
        for (RowOrColumn<T> column : columns()) {
            if (column.isCovered()) {
                // This improves computation speed!
                continue;
            }
            for (Incidence<T> incidence : column) {
                if (!row(incidence).isCovered() && incidence.getCost().isZero()) {
                    return incidence;
                }
            }
        }
        return null;
    }

    private T findMinUncoveredValue() {
        T minValue = null;
        for (RowOrColumn<T> column : columns()) {
            if (column.isCovered()) {
                // This improves computation speed!
                continue;
            }
            for (Incidence<T> incidence : column) {
                if (!row(incidence).isCovered() && (minValue == null || incidence.getCost().compareTo(minValue) < 0)) {
                    minValue = incidence.getCost();
                }
            }
        }
        if (minValue == null) {
            throw new MunkresException("Unable to find any uncovered incidence");
        }
        return minValue.copy();
    }

    private void resetCovers() {
        for (RowOrColumn<T> row : rows()) {
            row.setCovered(false);
        }
        for (RowOrColumn<T> column : columns()) {
            column.setCovered(false);
        }
    }

    private void resetPrimed() {
        for (Incidence<T> incidence : incidences()) {
            incidence.setPrimed(false);
        }
    }

    @Override
    public String toString() {
        StringBuffer str = new StringBuffer();
        int numColumns = 0;
        for (RowOrColumn<T> column : columns()) {
            if (column.isCovered())
                str.append(String.format("%30s", "x"));
            else
                str.append(String.format("%30s", " "));
            numColumns++;
        }
        str.append("\n");
        for (RowOrColumn<T> row : rows()) {
            if (row.isCovered())
                str.append("x");
            else
                str.append(" ");
            Iterator<Incidence<T>> it = row.iterator();
            int pos = 0;
            while (it.hasNext()) {
                Incidence<T> next = it.next();
                for (; pos < next.getColumn(); pos++) {
                    str.append("                              ");
                }
                str.append(String.format("%28s", next.getCost()));
                if (next.isStarred())
                    str.append("*");
                else
                    str.append(" ");
                if (next.isPrimed())
                    str.append("'");
                else
                    str.append(" ");
                pos++;
            }
            for (; pos < numColumns; pos++) {
                str.append("                              ");
            }
            str.append("\n");
        }
        return str.toString();
    }

}
