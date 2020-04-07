package org.jmodelica.util.documentation;

import java.io.StringWriter;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Node;

/**
 * Represents a documentation text element to be used when aggregating
 * JModelica.org documentation.
 * <p>
 * This means that the element is translated as-is when being written to a
 * Docbook file, i.e. it represents all segments in a Docbook file not managed
 * by other {@link DocumentElement}s.
 */
public class TextElement extends DocumentElement {
    private String text;

    /**
     * Constructs a text element
     * 
     * @param title
     *            The title of the element. This is only used in order to
     *            represent this element when using {@link #toString()} and
     *            should always be equal to "#text".
     * @param ordinal
     *            The title of the element to order this element after.
     * @param text
     *            The textual content of this element.
     */
    public TextElement(String title, String ordinal, String text) {
        super(title, ordinal);
        this.text = text.trim().length() <= 0 ? null : text;
    }

    /**
     * Constructs a text element from a {@link org.w3c.dom.Node}.
     * <p>
     * A text element uses the node's name as title, and keeps a reference to
     * the text contained within the node.
     * 
     * @param node
     *            The node to construct this element from.
     */
    public TextElement(Node node) {
        this(node.getNodeName(), null, getText(node));
    }

    private static String getText(Node node) {
        StringWriter sw = new StringWriter();
        try {
            Transformer t = TransformerFactory.newInstance().newTransformer();
            t.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
            t.setOutputProperty(OutputKeys.VERSION, "1.0");
            t.transform(new DOMSource(node), new StreamResult(sw));
        } catch (TransformerException te) {
            throw new DocumentationBuilderException("nodeToString Transformer Exception in node " + node);
        }
        return new String(sw.getBuffer());
    }

    @Override
    public String text(String prefix) {
        return text == null ? "" : text;
    }

    @Override
    public String toString() {
        return tag();
    }

    @Override
    String toString(String prefix) {
        return prefix + toString();
    }

}
