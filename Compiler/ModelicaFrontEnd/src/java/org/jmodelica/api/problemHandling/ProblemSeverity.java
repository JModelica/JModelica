package org.jmodelica.api.problemHandling;

/**
 * Enumerations representing a {@link Problem}'s severity.
 */
public enum ProblemSeverity {
    /**
     * Represents errors, i.e. problems that stop compilation.
     */
    ERROR,

    /**
     * Represents warnings, i.e. problems that do not stop compilation but might
     * cause issues.
     */
    WARNING

}