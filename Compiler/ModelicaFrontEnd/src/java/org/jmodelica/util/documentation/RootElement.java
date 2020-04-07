package org.jmodelica.util.documentation;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.w3c.dom.Node;

/**
 * Represents a root node, i.e. the "entry" point of a Docbook documentation.
 */
public class RootElement extends DocumentElement {
    static final String BOOK = "book";
    private Map<String, ChapterElement> chapters;

    /**
     * Constructs a root element from a specified point in the XML tree.
     * 
     * @param node
     *            The {@link org.w3c.dom.Node} specified as a root node.
     */
    public RootElement(Node node) {
        super(node);
        this.chapters = new LinkedHashMap<>();

        for (DocumentElement child : elements) {
            if (child.isChapter()) {
                ChapterElement chapter = (ChapterElement) child;
                this.chapters.put(chapter.name(), chapter);
            }
        }
    }

    @Override
    public void addElement(DocumentElement element) {
        super.addElement(element);
        if (element.isChapter()) {
            ChapterElement chapter = (ChapterElement) element;
            String name = chapter.name();

            if (chapters.containsKey(name)) {
                chapters.get(name).join(chapter);
            } else {
                chapters.put(name, chapter);
            }
        }
    }

    /**
     * Retrieves all the chapters of this root element.
     * 
     * @return
     *         a listing of all chapters.
     */
    public List<ChapterElement> chapters() {
        return new ArrayList<>(chapters.values());
    }

    /**
     * Retrieves the names of all the chapters of this root element.
     * 
     * @return
     *         a listing of all chapter names.
     */
    public List<String> chapterNames() {
        return new ArrayList<>(chapters.keySet());
    }

    /**
     * Retrieves a chapter by its name if it exists.
     * 
     * @param name
     *            The name of the chapter.
     * @return
     *         a {@link ChapterElement} with the name {@code name} if it exists,
     *         {@code null} otherwise.
     */
    public ChapterElement getChapter(String name) {
        if (!hasChapter(name)) {
            return null;
        }
        return chapters.get(name);
    }

    /**
     * Checks whether or not a chapter exists.
     * 
     * @param name
     *            The name of the chapter.
     * @return
     *         {@code true} if the chapter exists, {@code false} otherwise.
     */
    public boolean hasChapter(String name) {
        return chapters.containsKey(name);
    }

    @Override
    public boolean isRoot() {
        return true;
    }

    @Override
    public String toString() {
        StringBuilder string = new StringBuilder("Root element:");
        for (String chapter : chapters.keySet()) {
            string.append("\n\t" + chapter);
        }
        return string.append("\n").toString();
    }

}
