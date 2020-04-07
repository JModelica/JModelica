package org.jmodelica.api.problemHandling;

/**
 * A class representing a {@link Problem}'s kind.
 */
public enum ProblemKind {
    /**
     * Represents any kind not specified by the other kinds.
     */
    OTHER(2),

    /**
     * Represents lexical problems.
     */
    LEXICAL("Syntax", 1),

    /**
     * Represents syntactical problems.
     */
    SYNTACTIC("Syntax", 1),

    /**
     * Represents semantical problems.
     */
    SEMANTIC(2),

    /**
     * Represents compliance problems.
     */
    COMPLIANCE("Compliance", 2);

    private String desc = null;

    /**
     * Represents the order of the problem kind (1 or 2).
     */
    public final int order;

    private ProblemKind(int order) {
        this.order = order;
    }

    private ProblemKind(String desc, int order) {
        this.desc = desc;
        this.order = order;
    }

    /**
     * Writes the problem severity and kind to a message {@code StringBuilder}.
     * 
     * @param sb
     *            The string builder which to add the severity and kind
     *            information to.
     * @param sev
     *            The problem severity.
     */
    public void writeKindAndSeverity(StringBuilder sb, ProblemSeverity sev) {
        String s = sev.toString().toLowerCase();
        if (desc != null) {
            sb.append(desc);
            sb.append(' ');
            sb.append(s);
        } else {
            sb.append(Character.toUpperCase(s.charAt(0)));
            sb.append(s.substring(1));
        }
    }
}