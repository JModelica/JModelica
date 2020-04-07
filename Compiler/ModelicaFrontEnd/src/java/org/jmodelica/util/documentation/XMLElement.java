package org.jmodelica.util.documentation;

import org.w3c.dom.Document;

/**
 * Class representing XML elements.
 */
public class XMLElement extends DocumentElement {
    private final String encoding;
    private final String version;
    static final String XML = "xml";

    /**
     * Constructs an XML node.
     * <p>
     * This node type differs from {@link DocumentElement} in that it does not
     * have any children; only attributes.
     * 
     * @param document
     *            The {@link org.w3c.dom.Document} which encoding and version to
     *            represent.
     */
    public XMLElement(Document document) {
        super(XML, null);
        this.encoding = document.getXmlEncoding();
        this.version = document.getXmlVersion();
    }

    @Override
    public String text(String prefix) {
        return prefix + "<?xml version=\"" + version + "\" encoding=\"" + encoding + "\"?>";
    }

    @Override
    public String toString() {
        return text("");
    }
}
