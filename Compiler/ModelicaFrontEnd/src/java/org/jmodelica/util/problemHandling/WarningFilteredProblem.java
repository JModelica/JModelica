package org.jmodelica.util.problemHandling;

import org.jmodelica.api.problemHandling.Problem;
import org.jmodelica.api.problemHandling.ProblemKind;
import org.jmodelica.api.problemHandling.ProblemSeverity;

public class WarningFilteredProblem extends Problem {
    
    private static final long serialVersionUID = 1L;
    private int count = 1;

    public WarningFilteredProblem() {
        super("%d warning(s) has been ignored due to the 'filter_warnings' option", ProblemSeverity.WARNING, ProblemKind.SEMANTIC);
    }

    @Override
    public boolean equals(Object o) {
        return o instanceof WarningFilteredProblem;
    }

    @Override
    public void merge(Problem p) {
        if (!(p instanceof WarningFilteredProblem)) {
            throw new IllegalArgumentException("Unable to merge WarningFilteredProblem with Problem of type " + p.getClass().getName());
        }
        WarningFilteredProblem other = (WarningFilteredProblem) p;
        count += other.count;
    }

    @Override
    public String message() {
        return String.format(super.message(), count);
    }

}
