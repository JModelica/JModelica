package org.jmodelica.util.munkres;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;

class SparseIndex<T extends MunkresCost<T>> implements Iterable<RowOrColumn<T>> {

    public enum Type {
        ROW, COLUMN;
        private int getOuterCompare(Incidence<?> incidence) {
            switch (this) {
            case ROW:
                return incidence.getRow();
            case COLUMN:
                return incidence.getColumn();
            default:
                throw new UnsupportedOperationException(this + " is not implemented for Type enum");
            }
        }

        private int getInnerCompare(Incidence<?> incidence) {
            switch (this) {
            case ROW:
                return incidence.getColumn();
            case COLUMN:
                return incidence.getRow();
            default:
                throw new UnsupportedOperationException(this + " is not implemented for Type enum");
            }
        }
    }

    private final Type type;
    private final List<RowOrColumn<T>> innerIndices;
    private final int length;

    public SparseIndex(Type type, Collection<Incidence<T>> incidences) {
        this.type = type;
        int length = 0;
        for (Incidence<T> incidence : incidences) {
            length = Math.max(length, type.getOuterCompare(incidence) + 1);
        }
        this.length = length;
        List<List<Incidence<T>>> buckets = new ArrayList<List<Incidence<T>>>(length);
        for (int i = 0; i < length; i++) {
            buckets.add(new ArrayList<Incidence<T>>());
        }
        for (Incidence<T> incidence : incidences) {
            int index = type.getOuterCompare(incidence);
            buckets.get(index).add(incidence);
        }
        List<RowOrColumn<T>> innerIndices = new ArrayList<RowOrColumn<T>>(length);
        Comparator<Incidence<T>> comparator = innerComparator();
        for (int i = 0; i < length; i++) {
            List<Incidence<T>> bucket = buckets.get(i);
            Collections.sort(bucket, comparator);
            innerIndices.add(new SparseRowOrColumn(i, buckets.get(i)));
        }
        this.innerIndices = Collections.unmodifiableList(innerIndices);
    }

    public int getLength() {
        return length;
    }

    private Comparator<Incidence<T>> innerComparator() {
        return new Comparator<Incidence<T>>() {

            @Override
            public int compare(Incidence<T> a, Incidence<T> b) {
                return type.getInnerCompare(a) - type.getInnerCompare(b);
            }
        };
    }

    public RowOrColumn<T> getInnerIndex(int index) {
        return innerIndices.get(index);
    }

    @Override
    public Iterator<RowOrColumn<T>> iterator() {
        return innerIndices.iterator();
    }

    private class SparseRowOrColumn extends RowOrColumn<T> {
        private final Collection<Incidence<T>> incidences;

        private SparseRowOrColumn(int index, Collection<Incidence<T>> incidences) {
            this.incidences = Collections.unmodifiableCollection(incidences);
        }

        @Override
        public Iterator<Incidence<T>> iterator() {
            return incidences.iterator();
        }
    }

}
