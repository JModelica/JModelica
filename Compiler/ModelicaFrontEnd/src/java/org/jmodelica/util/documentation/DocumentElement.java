package org.jmodelica.util.documentation;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * Represents a documentation element to be used when aggregating JModelica.org
 * documentation.
 */
public class DocumentElement implements Comparable<DocumentElement>, Iterable<DocumentElement> {
    /**
     * Prefix whitespace to use when printing documentation.
     */
    public static final String PREFIX = "    ";

    /**
     * Name of section tags.
     */
    static final String SECTION = "section";
    /**
     * Name of title tags.
     */
    static final String TITLE = "title";

    /**
     * Line width to format attributes to.
     */
    static final int LINE_WIDTH = 80;

    protected List<DocumentElement> elements;
    protected Map<String, String> meta;
    protected String tag;
    protected String ordinal;

    /**
     * Constructs an element ordered after another element.
     * 
     * @param tag
     *            The tag this element represents.
     * @param ordinal
     *            The title of the element to order this element after.
     *            {@code null} is a valid value.
     */
    public DocumentElement(String tag, String ordinal) {
        this.tag = tag;
        this.ordinal = ordinal;
        this.elements = new ArrayList<>();
        this.meta = new LinkedHashMap<>();
    }

    /**
     * Constructs an element from a {@link org.w3c.dom.Node}.
     * 
     * @param node
     *            the node to create the element from.
     */
    public DocumentElement(Node node) {
        this((Element) node);
    }

    /**
     * Constructs an element from a {@link org.w3c.dom.Element}.
     * 
     * @param element
     *            the {@link org.w3c.dom.Element} to create this element from.
     */
    public DocumentElement(Element element) {
        this(element.getTagName(), null);
        addAttributes(element.getAttributes());

        NodeList nodeList = element.getChildNodes();
        boolean first = true;
        for (int i = 0; i < nodeList.getLength(); ++i) {
            Node node = nodeList.item(i);
            String nodeName = node.getNodeName();

            /*
             * We only want one title element per chapter, and it is generated separately.
             */
            if (nodeName.equals(TITLE) && first
                    && (this.tag.equals(ChapterElement.APPENDIX) || this.tag.equals(ChapterElement.CHAPTER))) {
                first = false;
                continue;
            }

            DocumentElement newElement = null;
            switch (nodeName) {
            case SECTION:
                newElement = new DocumentElement(node);
                break;
            default:
                newElement = new TextElement(node);
                break;
            }
            addElement(newElement);
        }
    }

    /**
     * Adds all attributes specified in a {@link org.w3c.dom.NamedNodeMap} to
     * this element.
     * 
     * @param attributes
     *            the attributes to add.
     */
    protected void addAttributes(NamedNodeMap attributes) {
        for (int i = 0; i < attributes.getLength(); ++i) {
            Node attribute = attributes.item(i);
            this.meta.put(attribute.getNodeName(), attribute.getNodeValue());
        }
    }

    /**
     * Adds a child.
     * 
     * @param element
     *            The child to add.
     */
    public void addElement(DocumentElement element) {
        this.elements.add(element);
    }

    /**
     * Adds several children.
     * 
     * @param addElements
     *            The children to add.
     */
    public void addElements(Collection<? extends DocumentElement> addElements) {
        this.elements.addAll(addElements);
    }

    /**
     * Retrieves the ordinal of this element, i.e. the name of the element to
     * order this one after.
     * 
     * @return
     *         the ordinal of this element.
     */
    public String ordinal() {
        return ordinal;
    }

    /**
     * Returns the text to be generated for all the children of this element.
     * 
     * @param prefix
     *            The string to prefix each line.
     * @return
     *         the text to be generated for all the children of this element.
     */
    public String text(String prefix) {
        StringBuilder text = new StringBuilder(tag(prefix) + "\n");
        String innerPrefix = prefix + PREFIX;
        for (DocumentElement element : elements) {
            text.append(element.text(innerPrefix));
        }
        return text.append(endTag(prefix) + "\n").toString();
    }

    /**
     * The name of the XML tag of this element.
     * 
     * @return
     *         the name of the XML tag of this element.
     */
    public String tag() {
        return tag;
    }

    /**
     * XML beginning tag.
     * 
     * @return
     *         the beginning tag.
     */
    protected String tag(String prefix) {
        StringBuilder element = new StringBuilder(prefix + "<" + tag);
        int currentLength = element.length();

        String space = "";
        String innerPrefix = prefix + PREFIX;
        for (String attribute : meta.keySet()) {
            String toAppend = attribute + "=\"" + meta.get(attribute) + "\"";
            int appendLength = toAppend.length();

            if (currentLength + appendLength > LINE_WIDTH) {
                element.append("\n" + innerPrefix);
                currentLength = appendLength;
                space = "";
            } else {
                currentLength += appendLength;
                space = " ";
            }
            element.append(space + toAppend);
        }
        return element.append(">").toString();
    }

    /**
     * XML end tag.
     * 
     * @return
     *         the end tag.
     */
    protected String endTag(String prefix) {
        return prefix + "</" + tag + ">";
    }

    @Override
    public int compareTo(DocumentElement other) {
        return tag.compareTo(other.tag);
    }

    @Override
    public Iterator<DocumentElement> iterator() {
        return elements.iterator();
    }

    @Override
    public String toString() {
        return toString("");
    }

    /**
     * Returns the quick string representation of this element indented.
     * 
     * @param prefix
     *            The indentation.
     * @return
     *         a quick string representation of this element indented.
     */
    String toString(String prefix) {
        StringBuilder string = new StringBuilder(tag());
        for (DocumentElement element : elements) {
            string.append(element.toString("\n" + prefix + PREFIX));
        }
        return string.toString();
    }

    /* =========== *
     *  Identity.  *
     * =========== */

    /**
     * Checks whether or not this element is a {@link ChapterElement}.
     * 
     * @return
     *         {@code true} if this element is a {@link ChapterElement},
     *         {@code false} otherwise.
     */
    public boolean isChapter() {
        return false;
    }

    /**
     * Checks whether or not this element is a {@link RootElement}.
     * 
     * @return
     *         {@code true} if this element is a {@link RootElement},
     *         {@code false} otherwise.
     */
    public boolean isRoot() {
        return false;
    }

}
