package org.jmodelica.util.munkres;

import java.util.ArrayList;
import java.util.Collection;

/**
 * A class with a sparse implementation of the Munkres (Hungarian) algorithm:
 * based on the description at:
 * http://csclab.murraystate.edu/bob.pilgrim/445/munkres.html
 */
public class SparseMunkresProblem<T extends MunkresCost<T>> extends MunkresProblem<T> {
    private final SparseIndex<T> rowIndex;
    private final SparseIndex<T> columnIndex;
    private Collection<Incidence<T>> incidences;

    public SparseMunkresProblem(T[][] initialCost) {
        this(constructWeights(initialCost));
    }

    public SparseMunkresProblem(Collection<Incidence<T>> incidences) {
        super(computeK(incidences));
        this.incidences = incidences;
        rowIndex = new SparseIndex<T>(SparseIndex.Type.ROW, incidences);
        columnIndex = new SparseIndex<T>(SparseIndex.Type.COLUMN, incidences);
    }

    private static <T extends MunkresCost<T>> Collection<Incidence<T>> constructWeights(T[][] initialCost) {
        Collection<Incidence<T>> incidences = new ArrayList<Incidence<T>>();
        for (int row = 0; row < initialCost.length; row++) {
            for (int col = 0; col < initialCost[row].length; col++) {
                if (initialCost[row][col] != null) {
                    incidences.add(new Incidence<T>(row, col, initialCost[row][col]));
                }
            }
        }
        return incidences;
    }

    private static <T extends MunkresCost<T>> int computeK(Collection<Incidence<T>> incidences) {
        int rowMax = 0;
        int columnMax = 0;
        for (Incidence<?> incidence : incidences) {
            rowMax = Math.max(rowMax, incidence.getRow());
            columnMax = Math.max(columnMax, incidence.getColumn());
        }
        return Math.min(rowMax + 1, columnMax + 1);
    }

    @Override
    protected RowOrColumn<T> row(int index) {
        return rowIndex.getInnerIndex(index);
    }

    @Override
    protected RowOrColumn<T> column(int index) {
        return columnIndex.getInnerIndex(index);
    }

    @Override
    protected Iterable<? extends RowOrColumn<T>> rows() {
        return rowIndex;
    }

    @Override
    protected Iterable<? extends RowOrColumn<T>> columns() {
        return columnIndex;
    }

    @Override
    protected Iterable<Incidence<T>> incidences() {
        return incidences;
    }

}
