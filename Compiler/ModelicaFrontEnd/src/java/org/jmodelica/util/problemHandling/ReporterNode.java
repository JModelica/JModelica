package org.jmodelica.util.problemHandling;

import org.jmodelica.api.problemHandling.Problem;

/**
 * A interface that all problem reporting nodes should fulfill. In reality
 * this is implemented by ASTNode and the interface is needed since ASTnode
 * isn't visible from the utils package. It also means that references of this
 * type shouldn't be saved in classes which are meant to be serialized!
 */
public interface ReporterNode {
    public int beginLineRecursive();
    public int beginColumnRecursive();
    public int endLineRecursive();
    public int endColumnRecursive();
    public String fileName();
    public String errorComponentName();
    public void reportProblem(Problem problem);
    public ProblemOptionsProvider myProblemOptionsProvider();
    public boolean inDisabledComponent();
}
