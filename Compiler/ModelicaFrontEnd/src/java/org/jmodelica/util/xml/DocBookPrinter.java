package org.jmodelica.util.xml;

import java.io.PrintStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.jmodelica.util.XMLUtil;

public class DocBookPrinter extends XMLPrinter {
    private static final Pattern PREPARE_PAT = 
            Pattern.compile("(?<=^|[^-a-zA-Z_])('[a-z]+'|true|false|[a-z]+(_[a-z]+)+)(?=$|[^-a-zA-Z_])");

    public DocBookPrinter(PrintStream out, String indent) {
        super(out, indent, "  ");
    }

    /**
     * Prints contents within a literal XML node.
     * 
     * @param str Contents to put within the node
     */
    public void printLiteral(String str) {
        oneLine("literal", str);
    }

    /**
     * Wraps constants ('abc', true, false, ab_cd_ef) with formatting and
     * outputs the entire string inside a XML node with the provided name.
     * 
     * @param surroundingNode Name of the surrounding node
     * @param str Contents to parse and highlight "constants"
     */
    public void printWrappedPreFormatedText(String surroundingNode, String str) {
        Matcher m = PREPARE_PAT.matcher(str);
        StringBuilder sb = new StringBuilder(currentIndent());
        int lastEnd = 0;
        while (m.find()) {
            sb.append(XMLUtil.escape(str.substring(lastEnd, m.start(1))));
            sb.append("<literal>");
            sb.append(XMLUtil.escape(m.group(1)));
            sb.append("</literal>");
            lastEnd = m.end(1);
        }
        sb.append(XMLUtil.escape(str.substring(lastEnd, str.length())));
        sb.append('\n');
        enter(surroundingNode);
        printRaw(sb.toString());
        exit();
    }
}