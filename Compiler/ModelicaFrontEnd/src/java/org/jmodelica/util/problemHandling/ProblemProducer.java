package org.jmodelica.util.problemHandling;

import java.io.PrintStream;
import java.util.Collection;
import java.util.TreeSet;

import org.jmodelica.api.problemHandling.Problem;
import org.jmodelica.api.problemHandling.ProblemKind;
import org.jmodelica.api.problemHandling.ProblemSeverity;
import org.jmodelica.util.xml.XMLPrinter;

/**
 * Base class for all problem producers. An instance of a problem producer
 * (or sub classes) represents a unique type of error or warning that the 
 * compiler can issue during compilation. All problems given by the compiler
 * during compilation should ideally be produced and returned by a instance of
 * problem producer. This ensures that we can provide the user with the means
 * for filtering and categorizing the problems given.
 *
 * All instances of this and sub-classes should be declared as static final on
 * ASTNode!
 * 
 * @param <T> Generic type that allows for sub classes which need access to 
 *      specific classes that implement ReporterNode, hint hint, a sub class
 *      of ASTNode!
 */
public abstract class ProblemProducer<T extends ReporterNode> implements Comparable<ProblemProducer<?>> {

    private static final Collection<ProblemProducer<?>> problemProducers = new TreeSet<ProblemProducer<?>>();
    
    private final String identifier;
    private final ProblemKind kind;

    protected ProblemProducer(String identifier, ProblemKind kind) {
        this.identifier = identifier;
        this.kind = kind;
        if (!problemProducers.add(this)) {
            // TODO: Removing this line since it causes crash if the Modelica
            // and Optimica ASTNode is loaded in the same java process..
//            throw new IllegalArgumentException("The problem producer with the identifier '" + identifier + "' has already been registrerd!");
        }
    }

    protected void invoke(T src, ProblemSeverity severity, String message, Object ... args) {
        src.reportProblem(Problem.createProblem(identifier, src, severity, kind, String.format(message, args)));
    }
    
    @Override
    public int compareTo(ProblemProducer<?> o) {
        return identifier.compareTo(o.identifier);
    }
    
    /**
     * An informative and generic description of the problem, usually the
     * message without data
     * @return description of the problem
     */
    public abstract String description();

    /**
     * The severity of the problem or null if the severity is context dependent
     * and unknown at this time.
     * @return severity of the problem
     */
    public abstract ProblemSeverity severity();
    
    public static void exportXML(PrintStream os) {
        XMLPrinter out = new XMLPrinter(os, "", "    ");
        out.enter("ProblemProducers");
        for (ProblemProducer<?> pp : problemProducers) {
            pp.doExportXML(out);
        }
        out.exit();
    }
    
    private void doExportXML(XMLPrinter out) {
        ProblemSeverity severity = severity();
        out.enter("ProblemProducer");
        out.oneLine("identifier", identifier);
        out.oneLine("severity", (severity == null ? "UNKNOWN" : severity).toString());
        out.oneLine("kind", kind.toString());
        out.enter("description");
        out.text(description(), 80);
        out.exit();
        out.exit();
    }
}
