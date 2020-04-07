package org.jmodelica.util.xml;

import java.io.PrintStream;
import java.util.Stack;

import org.jmodelica.util.StringUtil;
import org.jmodelica.util.XMLUtil;

public class XMLPrinter {
    private Stack<XMLPrinter.Entry> stack;
    private String indent;
    private PrintStream out;
    private String indentStep;
    
    public XMLPrinter(PrintStream out, String indent, String indentStep) {
        stack = new Stack<XMLPrinter.Entry>();
        this.indent = indent;
        this.out = out;
        this.indentStep = indentStep;
    }
    
    /**
     * Enters a new XML node with supplied name and arguments. Arguments are
     * provided as key-value pairs, e.g. args must bet of size modulo two.
     * 
     * @param name Name of the node
     * @param args Arguments for the XML node in the form of key-value pairs
     */
    public void enter(String name, Object... args) {
        stack.push(new Entry(indent, name));
        printHead(name, args);
        out.println('>');
        indent = indent + indentStep;
    }

    /**
     * Exits an arbitrary number of XML nodes.
     * 
     * @param n Number of nodes to exit
     */
    public void exit(int n) {
        for (int i = 0; i < n; i++) {
            exit();
        }
    }

    /**
     * Exits the most inner XML node that has been opened
     */
    public void exit() {
        XMLPrinter.Entry e = stack.pop();
        indent = e.indent;
        out.format("%s</%s>\n", indent, e.name);
    }

    /**
     * Prints an empty XML node which is self-closing. The node will have the
     * provided name and provided arguments. Arguments are provided as
     * key-value pairs, e.g. args must bet of size modulo two.
     * 
     * @param name Name of the node
     * @param args Arguments for the XML node in the form of key-value pairs
     */
    public void single(String name, Object... args) {
        printHead(name, args);
        out.print(" />\n");
    }

    /**
     * Prints an "one-line" XML node with provided name, arguments and contents.
     * Arguments are provided as key-value pairs, e.g. args must bet of size
     * modulo two.
     * 
     * The content will be sanitized and escaped!
     * 
     * @param name Name of the node
     * @param cont The content which should be inside of the XML node
     * @param args Arguments for the XML node in the form of key-value pairs
     */
    public void oneLine(String name, String cont, Object... args) {
        printHead(name, args);
        out.format(">%s</%s>\n", XMLUtil.escape(cont), name);
    }

    /**
     * Outputs text into the surronding XML node. The text is sanitized and
     * escaped!
     * 
     * @param text The text to print
     * @param width with of the text
     */
    public void text(String text, int width) {
        StringUtil.wrapText(out, XMLUtil.escape(text), indent, width);
    }

    /**
     * Prints raw text to the output stream. This method should be used with
     * caution! It inserts the string verbatim into the output stream and no
     * sanitization is done! This can lead to incorrect XML file if used
     * incorrectly!
     * 
     * @param rawXML string to print to output stream
     */
    protected void printRaw(String rawXML) {
        out.print(rawXML);
    }

    /**
     * Returns the current indent, this method is intended to be used together
     * with {@link #printRaw(String)}
     * 
     * @return Current indentation
     */
    protected String currentIndent() {
        return indent;
    }

    private void printHead(String name, Object... args) {
        out.format("%s<%s", indent, name);
        for (int i = 0; i < args.length - 1; i += 2) {
            out.format(" %s=\"%s\"", args[i], args[i + 1]);
        }
    }

    private static class Entry {
        public final String indent;
        public final String name;
        
        private Entry(String indent, String name) {
            this.indent = indent;
            this.name = name;
        }
    }
}