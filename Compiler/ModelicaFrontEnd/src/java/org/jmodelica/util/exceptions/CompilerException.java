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
package org.jmodelica.util.exceptions;

import java.util.ArrayList;
import java.util.Collection;

import org.jmodelica.api.problemHandling.Problem;
import org.jmodelica.api.problemHandling.ProblemSeverity;

/**
 * Exception containing a list of compiler errors/warnings.
 */
public class CompilerException extends ModelicaException {

    private static final long serialVersionUID = 1;

    private Collection<Problem> errors;
    private Collection<Problem> warnings;

    /**
     * Default constructor.
     */
    public CompilerException() {
        errors = new ArrayList<Problem>();
        warnings = new ArrayList<Problem>();
    }

    /**
     * Construct from a list of problems.
     */
    public CompilerException(Collection<Problem> problems) {
        this();
        for (Problem p : problems)
            addProblem(p);
    }

    /**
     * Add a new problem.
     */
    public void addProblem(Problem p) {
        if (p.severity() == ProblemSeverity.ERROR)
            errors.add(p);
        else
            warnings.add(p);
    }

    /**
     * Get the list of problems.
     */
    public Collection<Problem> getProblems() {
        Collection<Problem> problems = new ArrayList<Problem>();
        problems.addAll(errors);
        problems.addAll(warnings);
        return problems;
    }

    /**
     * Get the list of errors.
     */
    public Collection<Problem> getErrors() {
        return errors;
    }

    /**
     * Get the list of warnings.
     */
    public Collection<Problem> getWarnings() {
        return warnings;
    }

    /**
     * Should these problems cause compilation to stop?
     * 
     * @param warnings value to return if there are warnings but not errors
     */
    public boolean shouldStop(boolean warnings) {
        return !errors.isEmpty() || (warnings && !this.warnings.isEmpty());
    }

    /**
     * Convert to error message.
     */
    @Override
    public String getMessage() {
        return getMessage(false);
    }
    
    public String getMessage(boolean printIdentifier) {
        StringBuilder str = new StringBuilder();
        if (!errors.isEmpty()) {
            str.append(errors.size());
            str.append(" errors ");
            str.append(warnings.isEmpty() ? "found:\n\n" : "and ");
        }
        if (!warnings.isEmpty()) {
            str.append(warnings.size());
            str.append(" warnings found:\n\n");
        }
        for (Problem p : errors) {
            str.append(p.toString(printIdentifier));
            str.append("\n\n");
        }
        for (Problem p : warnings) {
            str.append(p.toString(printIdentifier));
            str.append("\n\n");
        }
        str.deleteCharAt(str.length() - 1);
        return str.toString();
    }

}