package org.jmodelica.util.munkres;

class Incidence<T extends MunkresCost<T>> {
    private final int row;
    private final int column;
    private boolean starred = false;
    private boolean primed = false;
    private T cost;

    public Incidence(int row, int column, T initialCost) {
        this.row = row;
        this.column = column;
        cost = initialCost.copy();
    }

    public int getRow() {
        return row;
    }

    public int getColumn() {
        return column;
    }

    public boolean isStarred() {
        return starred;
    }

    public void setStarred(boolean newValue) {
        starred = newValue;
    }

    public boolean isPrimed() {
        return primed;
    }

    public void setPrimed(boolean newValue) {
        primed = newValue;
    }

    public T getCost() {
        return cost;
    }

    @Override
    public String toString() {
        return "(" + row + "," + column + ")";
    }

}
