/*
    Copyright (C) 2015-2018 Modelon AB

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
package org.jmodelica.api.problemHandling;

import java.nio.file.Path;
import java.util.Collection;
import java.util.Collections;
import java.util.Objects;
import java.util.Set;
import java.util.TreeSet;

import org.jmodelica.util.logging.Level;
import org.jmodelica.util.logging.XMLLogger;
import org.jmodelica.util.logging.units.LoggingUnit;
import org.jmodelica.util.problemHandling.ReporterNode;
import org.jmodelica.util.problemHandling.WarningFilteredProblem;

/**
 * Represents a error or warning given by the compiler during compilation of
 * a model. It contains information about where, type, severity and message
 * about the problem.
 */
public class Problem implements Comparable<Problem>, LoggingUnit {
    private static final long serialVersionUID = 4;

    private final String identifier;
    private final int beginLine;
    private final int beginColumn;
    private final int endLine;
    private final int endColumn;
    private final String fileName;
    private final String message;
    private final ProblemSeverity severity;
    private final ProblemKind kind;
    private final Set<String> components = new TreeSet<String>(); // TreeSet is used so that we get a sorted set

    /**
     * Deprecated in favor of {@link Problem#createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)
     * createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)}.
     * 
     * @param message Human readable message describing the problem
     */
    @Deprecated
    public Problem(String message) {
        this(message, ProblemSeverity.ERROR);
    }

    /**
     * Deprecated in favor of {@link Problem#createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)
     * createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)}.
     * 
     * @param message Human readable message describing the problem
     * @param severity The severity of the problem
     */
    @Deprecated
    public Problem(String message, ProblemSeverity severity) {
        this(message, severity, ProblemKind.OTHER);
    }

    /**
     * Deprecated in favor of {@link Problem#createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)
     * createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)}.
     * 
     * @param message Human readable message describing the problem
     * @param severity The severity of the problem
     * @param kind The type of the problem
     */
    @Deprecated
    public Problem(String message, ProblemSeverity severity, ProblemKind kind) {
        this(null, null, message, severity, kind, 0, 0, 0, 0);
    }

    /**
     * Deprecated in favor of {@link Problem#createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)
     * createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)}.
     * 
     * @param fileName Name or path to the source file where the problem is
     *          located
     * @param message Human readable message describing the problem
     * @param severity The severity of the problem
     * @param kind The type of the problem
     * @param beginLine Problem start line in the source file
     * @param beginColumn Problem start column in the source file
     * @param endLine Problem end line in the source file
     * @param endColumn Problem end column in the source file
     */
    @Deprecated
    public Problem(String fileName, String message, ProblemSeverity severity, ProblemKind kind, int beginLine, int beginColumn, int endLine, int endColumn) {
        this(null, fileName, message, severity, kind, beginLine, beginColumn, endLine, endColumn);
    }

    /**
     * Deprecated in favor of {@link Problem#createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)
     * createProblem(String, ReporterNode, ProblemSeverity, ProblemKind, String)}.
     * 
     * @param identifier An unique identifier for this category of problem
     * @param fileName Name or path to the source file where the problem is
     *          located
     * @param message Human readable message describing the problem
     * @param severity The severity of the problem
     * @param kind The type of the problem
     * @param beginLine Problem start line in the source file
     * @param beginColumn Problem start column in the source file
     * @param endLine Problem end line in the source file
     * @param endColumn Problem end column in the source file
     */
    @Deprecated
    protected Problem(String identifier, String fileName, String message, ProblemSeverity severity, ProblemKind kind, int beginLine, int beginColumn, int endLine, int endColumn) {
        this.identifier = identifier;
        this.fileName = fileName;
        this.message = message;
        this.severity = severity;
        this.kind = kind;
        this.beginLine = beginLine;
        this.beginColumn = beginColumn;
        this.endLine = endLine;
        this.endColumn = endColumn;
        
        if (message == null)
            throw new NullPointerException();
    }

    /**
     * Provides the identifier for this problem. The identifier can be used to
     * identify problems which originates from the same problem check even
     * though the messages differ, i.e. some problems checks are parameterized
     * and the message differs between instances.
     * 
     * @return a string identifier specifying the problem or null if
     *          unavailable.
     */
    public String identifier() {
        return identifier;
    }

    /**
     * Provides the starting line in the source file where the problem was
     * encountered.
     * 
     * The value returned by this method is one-based, i.e. the first line in
     * the file has line number one.
     * 
     * Note; not all problems have positional information, please use
     * {@link #hasPosition()} to verify whether this method will provide
     * useful information or not.
     * 
     * @return the start line for this problem or zero if positional
     *          information is unavailable
     */
    public int beginLine() {
        return beginLine;
    }
    
    /**
     * Provides the starting column in the source file where the problem was
     * encountered.
     * 
     * The value returned by this method is one-based, i.e. the first column on
     * a line has column number one.
     * 
     * Note; not all problems have positional information, please use
     * {@link #hasPosition()} to verify whether this method will provide
     * useful information or not.
     * 
     * @return the start column for this problem or zero if positional
     *          information is unavailable
     */
    public int beginColumn() {
        return beginColumn;
    }
  
    /**
     * Provides the ending line in the source file where the problem was
     * encountered. Beware, for some problems, the start and end line is the
     * same, i.e. this method and {@link #beginLine()} will return the same
     * line number.
     * 
     * The value returned by this method is one-based, i.e. the first line in
     * the file has line number one.
     * 
     * Note; not all problems have positional information, please use
     * {@link #hasPosition()} to verify whether this method will provide
     * useful information or not.
     * 
     * @return the ending line for this problem or zero if positional
     *          information is unavailable
     */
    public int endLine() {
        return endLine;
    }

    /**
     * Provides the ending column in the source file where the problem was
     * encountered. Beware, the column returned by this method is inclusive,
     * meaning that the character at provided column should be regarded as
     * included in the problem. This means that, for some problems, the start
     * and end column is the same, i.e. this method and {@link #beginColumn()}
     * is the same column number.
     * 
     * The value returned by this method is one-based, i.e. the first column on
     * a line has column number one.
     * 
     * Note; not all problems have positional information, please use
     * {@link #hasPosition()} to verify whether this method will provide
     * useful information or not.
     * 
     * @return the ending column for this problem or zero if positional
     *          information is unavailable
     */
    public int endColumn() {
        return endColumn;
    }

    /**
     * Provides the name of the source file where this problem occurred. In
     * some situations the problem doesn't have any clear source and this
     * method will return null, {@link #hasLocation()} can be used to determine
     * whether this method will return any useful value. 
     * 
     * @return the name of the source file of the problem or null if
     *          unavailable
     */
    public String fileName() {
        return fileName;
    }

    /**
     * Provides the raw message for this problem, without any location and
     * positional information.
     * 
     * @return the problem message (presented when the error is reported)
     */
    public String message() {
        return message;
    }

    /**
     * Provides the severity for this problem. Please see
     * {@link ProblemSeverity} for the different severity levels.
     * 
     * @return the problem severity
     */
    public ProblemSeverity severity() {
        return severity;
    }

    /**
     * Indicates what kind of problem this problem is of. Please see
     * {@link ProblemKind} for the different kinds of problems that can be
     * produced.
     * 
     * @return the problem kind
     */
    public ProblemKind kind() {
        return kind;
    }

    /**
     * Internal, do not use!
     * 
     * @param component
     *          The component to add to the problem.
     */
    public void addComponent(String component) {
        if (component != null) {
            components.add(component);
        }
    }

    /**
     * Provides a list of Modelica components for which this problem has
     * occurred in. Not all problem checks are able to report the component, so
     * for some problems this collection will be empty.
     * 
     * @return a collection of the problem's components
     */
    public Collection<String> components() {
        return Collections.unmodifiableCollection(components);
    }

    /**
     * Indicates whether the source file of the problem is known or not. I.e.
     * this method can be used to determine if {@link #fileName()} will provide
     * useful information or not.
     * 
     * @return true if the source file of the problem is known, otherwise false
     */
    public boolean hasLocation() {
        return fileName() != null;
    }

    /**
     * Indicates whether the position in the source file is known or not. I.e.
     * this method can be used to determine if {@link #beginLine()},
     * {@link #beginColumn()}, {@link #endLine()} and {@link #endColumn()} will
     * provide useful information or not.
     * 
     * @return true if the problem position in source file is known,
     *          otherwise false
     */
    public boolean hasPosition() {
        return hasLocation() && beginLine > 0 && beginColumn > 0 && endLine > 0 && endColumn > 0;
    }

    /**
     * Internal, do not use!
     * 
     * @param checkAll
     *      A flag specifying whether or not to include all problems.
     * @return
     *      {@code true} if the error is for testing, {@code false} otherwise.
     */
    public boolean isTestError(boolean checkAll) {
        return checkAll || (severity == ProblemSeverity.ERROR && kind != ProblemKind.COMPLIANCE);
    }

    @Override
    public boolean equals(Object o) {
        return (o instanceof Problem) && (compareTo((Problem) o) == 0);
    }
    
    @Override
    public int hashCode() {
        // This is not expected to be used much, so no need to take all fields into consideration.
        return Objects.hash(message, kind, identifier, fileName);
    }

    @Override
    public int compareTo(Problem other) {
        if (kind.order != other.kind.order)
            return kind.order - other.kind.order;
        if (fileName == null || other.fileName == null) {
            if (fileName != null)
                return -1;
            if (other.fileName != null)
                return 1;
        } else {
            if (!fileName.equals(other.fileName))
                return fileName.compareTo(other.fileName);
        }
        if (beginLine != other.beginLine)
            return beginLine - other.beginLine;
        if (beginColumn != other.beginColumn)
            return beginColumn - other.beginColumn;
        if (endLine != other.endLine)
            return endLine - other.endLine;
        if (endColumn != other.endColumn)
            return endColumn - other.endColumn;
        if (identifier != null && other.identifier != null && !identifier.equals(other.identifier)) {
            return identifier.compareTo(other.identifier);
        }
        return message.compareTo(other.message);
    }

    /**
     * Joins together two problems. Internal, do not use!
     * 
     * @param p
     *      The {@code Problem} to join with {@code this}.
     */
    public void merge(Problem p) {
        components.addAll(p.components);
    }

    @Override
    public String toString() {
        return toString(false);
    }

    /**
     * Produces a human readable string representation of this problem. This
     * string will contain as much information as possible, severity, kind,
     * location, position, components and message.
     * 
     * @param printIdentifier
     *          A flag specifying whether or not the identifier should be
     *          included in the string representation
     * @return
     *          A string representation of the {@code Problem}
     */
    public String toString(boolean printIdentifier) {
        StringBuilder sb = new StringBuilder();
        kind.writeKindAndSeverity(sb, severity);
        if (!hasLocation()) {
            sb.append(" in flattened model");
        } else {
            if (hasPosition()) {
                sb.append(" at line ");
                sb.append(beginLine);
                sb.append(", column ");
                sb.append(beginColumn);
                sb.append(",");
            }
            sb.append(" in file '");
            sb.append(fileName);
            sb.append("'");
        }
        if (printIdentifier && identifier != null) {
            sb.append(", " + identifier);
        }
        if (!components.isEmpty()) {
            sb.append(",\n");
            if (components.size() > 1) {
                int limit = 4;
                sb.append("In components:\n");
                int i = 0;
                if (limit + 1 == components.size())
                    limit += 1;
                for (String component : components) {
                    i++;
                    sb.append("    ");
                    sb.append(component);
                    sb.append("\n");
                    if (i == limit) break;
                }
                if (components.size() > limit) {
                    sb.append("    .. and ");
                    sb.append(components.size() - limit);
                    sb.append(" additional components\n");
                }
            } else {
                sb.append("In component ");
                sb.append(components.iterator().next());
                sb.append(":\n");
            }
        } else {
            sb.append(":\n");
        }
        sb.append("  ");
        sb.append(message());
        return sb.toString();
    }

    @Override
    public String print(Level level) {
        return toString(level.shouldLog(Level.INFO));
    }

    @Override
    public String printXML(Level level) {
        return XMLLogger.write_node(Problem.capitalize(severity()), 
                "identifier",   identifier() == null ? "" : identifier(),
                "kind",         kind().toString().toLowerCase(),
                "file",         fileName(),
                "line",         beginLine(),
                "column",       beginColumn(),
                "message",      message());
    }

    /**
     * Creates a {@code Problem} object. Internal, do not use!
     * 
     * @param identifier
     *      The problem's identifier.
     * @param src
     *      The node which reported the problem (the problem source).
     * @param severity
     *      The severity level of the problem (error, warning).
     * @param kind
     *      The type of the problem (syntactical, semantical, et.c.).
     * @param message
     *      The message to present when the error is reported.
     * @return
     *      a {@code Problem} instance.
     */
    public static Problem createProblem(String identifier, ReporterNode src, ProblemSeverity severity, ProblemKind kind, String message) {
        Problem p;
        if (src == null) {
            // TODO, insert something else than null in filename, that way we
            // can differentiate between errors in flattened model and generic
            // errors
            p = new Problem(identifier, null, message, severity, kind, 0, 0, 0, 0);
        } else {
            if (identifier != null && severity == ProblemSeverity.WARNING && src.myProblemOptionsProvider().filterThisWarning(identifier)) {
                return new WarningFilteredProblem();
            }
            p = new Problem(identifier, src.fileName(), message, severity, kind, src.beginLineRecursive(), src.beginColumnRecursive(), src.endLineRecursive(), src.endColumnRecursive());
            if (src.myProblemOptionsProvider().getOptionRegistry().getBooleanOption("component_names_in_errors")) {
                p.addComponent(src.errorComponentName());
            }
        }
        return p;
    }

    /**
     * Creates a {@code Problem} object. Internal, do not use!
     * 
     * @param filePath
     *      Path to the file which reported the problem (the problem source).
     * @param severity
     *      The severity level of the problem (error, warning).
     * @param kind
     *      The type of the problem (syntactical, semantical, et.c.).
     * @param message
     *      The message to present when the error is reported.
     * @return
     *      a {@code Problem} instance.
     */
    public static Problem createProblem(Path filePath, ProblemSeverity severity, ProblemKind kind, String message) {
        return new Problem(filePath.toString(), message, severity, kind, 0, 0, 0, 0);
    }
    
    private static String capitalize(Object o) {
        String name = o.toString();
        return Character.toUpperCase(name.charAt(0)) + name.substring(1).toLowerCase();
    }
}

