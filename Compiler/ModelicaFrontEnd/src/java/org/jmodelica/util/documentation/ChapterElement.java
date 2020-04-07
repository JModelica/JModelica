package org.jmodelica.util.documentation;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.xml.parsers.DocumentBuilder;

import org.jmodelica.util.StringUtil;
import org.jmodelica.util.files.ModifiableFile;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * Represents {@code <chapter>} elements.
 */
public class ChapterElement extends DocumentElement {
    /**
     * Regular expression describing which characters to escape in file names.
     */
    private static final String ESCAPE_REGEX =
            "[^0-9a-zA-ZåäöÅÄÖ]";

    /**
     * String to replace characters escaped with {@link #ESCAPE_REGEX}.
     */
    private static final String ESCAPE_REPLACEMENT = "_";

    protected static final String APPENDIX = "appendix";
    protected static final String CHAPTER = "chapter";
    private DocumentElement xml;
    private String name;
    private String fileName;

    /**
     * Constructs a new section element, representing a Docbook chapter.
     * <p>
     * Note that any white space occurrences in the name will be interpreted as
     * a singular space.
     * 
     * @param element
     *            The {@link org.w3c.dom.Element} to construct this object from.
     * @param document
     *            The {@link org.w3c.dom.Document} containing the XML
     *            specification.
     */
    public ChapterElement(Element element, Document document) {
        super(element);
        this.name = StringUtil.conformWhiteSpace(element.getElementsByTagName(TITLE).item(0).getTextContent());
        this.fileName = name.replaceAll(ESCAPE_REGEX, ESCAPE_REPLACEMENT) + ".xml";
        this.xml = new XMLElement(document);
    }

    /**
     * Writes the {@code xi:include} tag for this element to a
     * {@link ModifiableFile}.
     * <p>
     * Standard implementation does nothing. Behaviour must be overridden by
     * sub classes.
     * 
     * @param file
     *            the file within which to put the include-tag.
     */
    public void include(ModifiableFile file) {
        file.add(includeTag("    "));
    }

    /**
     * Returns a non-prefixed {@code xi:include} tag for this element.
     * 
     * @return
     *         a {@code xi:include} tag for this element.
     */
    public String includeTag() {
        return includeTag("");
    }

    /**
     * Returns a non-prefixed {@code xi:include} tag for this element.
     * 
     * @param prefix
     *            The string which to put as prefix for the tag.
     * @return
     *         a {@code xi:include} tag for this element.
     */
    public String includeTag(String prefix) {
        return prefix + "<xi:include href=\"" + fileName + "\" xpointer=\"element(/1)\"/>";
    }

    /**
     * Joins this chapter with another. This element will retain its sections as
     * well as that of the other chapter, and the complementary attributes of
     * the other chapter will be added to this.
     * 
     * @param chapter
     *            The chapter to join to this one.
     */
    public void join(ChapterElement chapter) {
        Set<String> keys = new HashSet<String>(chapter.meta.keySet());
        keys.removeAll(meta.keySet());

        for (String key : keys) {
            meta.put(key, chapter.meta.get(key));
        }

        for (DocumentElement section : chapter) {
            addElement(section);
        }
    }

    @Override
    public boolean isChapter() {
        return true;
    }

    @Override
    public String tag(String prefix) {
        StringBuilder chapter = new StringBuilder(xml.text(prefix) + "\n" + super.tag(prefix));
        return chapter.append("\n" + titleTag(prefix + PREFIX) + "\n").toString();
    }

    /**
     * Generates the title tag for this chapter.
     * 
     * @param prefix
     *            The string to prefix the tag with.
     * @return
     *         a title tag for this chapter.
     */
    private String titleTag(String prefix) {
        return prefix + "<title>" + name + "</title>";
    }

    @Override
    public final int compareTo(DocumentElement element) {
        if (!element.isChapter()) {
            /*
             * Chapters go first.
             */
            return -1;
        }

        ChapterElement chapter = (ChapterElement) element;
        String otherOrdinal = chapter.ordinal();
        String otherTitle = chapter.name();

        if (ordinal == null) {
            if (otherOrdinal == null) {
                return name.compareTo(otherTitle);
            }

            return 1;
        }

        if (otherOrdinal == null) {
            return -1;
        }

        if (ordinal.equals(otherTitle)) {
            return 1;
        }

        if (name.equals(otherOrdinal)) {
            return -1;
        }

        return name.compareTo(otherTitle);
    }

    /**
     * Writes this element to a Docbook XML-file.
     * <p>
     * Standard implementation does nothing. Behaviour must be overridden by
     * sub classes.
     * 
     * @param destination
     *            The directory to write the file to.
     * @param replacements
     *            A map of string-string key-value pairs; in text, all
     *            occurrences of a key will be replaced by the corresponding
     *            value.
     * @param characterSet
     *            The character set to use when writing the file.
     * @throws IOException
     *             if there was any error writing to the file.
     */
    public void writeFile(File destination, Map<String, String> replacements, String characterSet) throws IOException {
        File dest =
                new File(destination.getAbsolutePath() + (destination.isDirectory() ? File.separator + fileName : ""));
        try(BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(dest), characterSet))) {

            String text = text("");
            for (String key : replacements.keySet()) {
                text = text.replaceAll(key, replacements.get(key));
            }
            writer.write(text);
        }
    }

    /**
     * Returns the name of this chapter.
     * 
     * @return
     *         the name of this chapter.
     */
    public String name() {
        return name;
    }

    @Override
    public String toString() {
        StringBuilder string =
                new StringBuilder(xml.toString() + "\nChapter " + name + ", outputs to " + fileName + ":\n<");
        for (String attribute : meta.keySet()) {
            string.append("\n\t" + attribute + ":" + meta.get(attribute));
        }
        string.append(">\n");
        for (DocumentElement section : elements) {
            string.append("\n\t" + section.tag());
        }
        return string.append("\n").toString();
    }

    /**
     * Retrieves all sections of this chapter.
     * <p>
     * NOTE: If the {@link DocumentBuilder} is extended to be able to arrange
     * sections individually, make this public. Likely rework
     * {@code ChapterElement}s to keep explicit track of sections as well so
     * that filtering is not required.
     * 
     * @return
     *         all sections in this chapter.
     */
    @SuppressWarnings("unused")
    private List<DocumentElement> sections() {
        List<DocumentElement> sections = new ArrayList<DocumentElement>();
        for (DocumentElement element : elements) {
            if (element.isChapter()) {
                sections.add(element);
            }
        }
        return sections;
    }
}
