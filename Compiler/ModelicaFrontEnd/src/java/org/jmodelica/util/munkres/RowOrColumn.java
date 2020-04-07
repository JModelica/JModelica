package org.jmodelica.util.munkres;

abstract class RowOrColumn<T extends MunkresCost<T>> implements Iterable<Incidence<T>> {
    private boolean covered = false;

    public final boolean isCovered() {
        return covered;
    }

    public final void setCovered(boolean newValue) {
        covered = newValue;
    }

    public final boolean hasStarredIncidences() {
        return getStarredIncidence() != null;
    }

    public final Incidence<T> getStarredIncidence() {
        for (Incidence<T> incidence : this) {
            if (incidence.isStarred()) {
                return incidence;
            }
        }
        return null;
    }

    public final boolean hasPrimedIncidences() {
        return getPrimedIncidences() != null;
    }

    public final Incidence<T> getPrimedIncidences() {
        for (Incidence<T> incidence : this) {
            if (incidence.isPrimed()) {
                return incidence;
            }
        }
        return null;
    }

}
