package org.jmodelica.util.files;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.List;

/**
 * Wrapper class for {@link File}s which allows modification (line deletion and
 * insertion) using a list of lines and a row pointer.
 */
public class ModifiableFile {
    /**
     * The character set to use when printing this file.
     */
    public static final String CHAR_SET = "UTF-8";

    private int currentLine;
    private File destination;
    private File source;
    private List<String> lines;

    /**
     * Constructs a modifiable file.
     * 
     * @param file
     *            The file to modify.
     * @throws IOException
     *             if there was any error reading the file.
     */
    public ModifiableFile(File file) throws IOException {
        this(file, file, "UTF-8");
    }

    /**
     * Constructs a modifiable file that will output modified content to another
     * file than its source file.
     * 
     * @param source
     *            The source file which contents to modify.
     * @param destination
     *            The destination file to which to write the modified content.
     * @param characterSet
     *            The character set to use for the read file.
     * @throws IOException
     *             if there was any error reading the file.
     */
    public ModifiableFile(File source, File destination, String characterSet) throws IOException {
        checkFiles(false, source);
        checkFiles(true, destination.getParentFile());

        this.currentLine = 0;
        this.destination = destination;
        this.source = source;
        this.lines = new ArrayList<String>();
        restore();
    }

    /**
     * Verifies that a collection of paths ({@link File} objects) points to
     * either purely files or directories.
     * <p>
     * An exception is thrown if any of the {@link File}s do not comply to the
     * specified criterion.
     * 
     * @param dir
     *            Specifies whether or not to verify that the
     * @param files
     *            The files to check.
     */
    private void checkFiles(boolean dir, File... files) {
        StringBuilder message = new StringBuilder();
        for (File file : files) {
            if (file.isDirectory() != dir || !file.exists()) {
                message.append("Path " + file + " is not a " + (dir ? "directory" : "file") + ".\n");
            }
        }

        if (message.length() > 0) {
            throw new IllegalArgumentException(message.toString());
        }
    }

    /**
     * Adds a new line at the current line position.
     * 
     * @param line
     *            the line to add.
     */
    public void add(String line) {
        add(currentLine++, line);
    }

    /**
     * Adds a new line to a specified line position.
     * 
     * @param lineNumber
     *            The line number specifying where to insert the new line.
     * @param line
     *            the line to add.
     */
    public void add(int lineNumber, String line) {
        lines.add(Math.min(lines.size(), lineNumber), line);
    }

    /**
     * Deletes the current line.
     */
    public void deleteLine() {
        delete(currentLine--);
    }

    /**
     * Deletes the specified line.
     * 
     * @param line
     *            The line number of the line to delete.
     */
    public void delete(int line) {
        this.lines.remove(line);
    }

    /**
     * Advances the pointer a number of lines.
     * 
     * @param delta
     *            The number of lines to advance the pointer.
     * @return
     *         {@code false} if the change would bring the pointer beyond the
     *         files lines (the current line is not changed then), {@code true}
     *         otherwise.
     */
    public boolean advance(int delta) {
        int newPosition = currentLine + delta;
        if (newPosition < 0 || newPosition >= lines.size()) {
            return false;
        }
        currentLine = newPosition;
        return true;
    }

    /**
     * Advances the line pointer to the point where it first encounters a
     * matching string. If no match is found, the pointer is not moved.
     * 
     * @param string
     *            The string to find.
     * @return
     *         the updated position of the line pointer if {@code string} was
     *         found, -1 otherwise.
     */
    public int advanceTo(String string) {
        int newLine = find(string);
        if (newLine != -1) {
            this.currentLine = newLine;
        }
        return newLine;
    }

    /**
     * Retrieves the <i>first</i> line containing a specified string.
     * 
     * @param string
     *            The string to find.
     * @return
     *         the line number of the first line containing {@code string} if it
     *         exists within this file, -1 otherwise.
     */
    public int find(String string) {
        for (int i = 0; i < lines.size(); ++i) {
            if (lines.get(i).contains(string)) {
                return i;
            }
        }
        return -1;
    }

    /**
     * Retrieves the current line.
     * 
     * @return
     *         the current line.
     */
    public String get() {
        return get(currentLine);
    }

    /**
     * Retrieves the line at the specified line number.
     * <p>
     * Returns {@code null} if a line outside of the file is requested.
     * 
     * @param lineNumber
     *            The line number of the requested line.
     * @return
     *         the requested line if within the number of lines in this file,
     *         {@code null} otherwise.
     */
    public String get(int lineNumber) {
        return lines.get(lineNumber);
    }

    /**
     * Retrieves the path to the destination file.
     * 
     * @return
     *         the path to the destination file.
     */
    public String destination() {
        return destination.getAbsolutePath();
    }

    /**
     * Retrieves the path to the source file.
     * 
     * @return
     *         the path to the source file.
     */
    public String source() {
        return source.getAbsolutePath();
    }

    /**
     * Restores the modified content to the original source's content.
     * <p>
     * Note that if the source file is also the destination file, as is the case
     * when the constructor {@link #ModifiableFile(File)} is used, using
     * {@link #write} will also update the point to which this method can
     * revert content.
     * 
     * @throws IOException
     *             if there was any error reading the source file.
     */
    public void restore() throws IOException {
        try(BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(source), "UTF-8"))) {
            String line = "";
            while ((line = reader.readLine()) != null) {
                lines.add(line);
            }
        }
    }

    /**
     * Writes the (possibly) modified content to its destination file.
     * 
     * @param characterSet
     *            The character set to use when writing the file.
     * @throws IOException
     *             if there was any error opening the destination file.
     */
    public void write(String characterSet) throws IOException {
        try(BufferedWriter writer =
                new BufferedWriter(new OutputStreamWriter(new FileOutputStream(destination), characterSet))) {
            for (String line : lines) {
                writer.write(line);
                writer.newLine();
            }
        }
    }

    @Override
    public String toString() {
        return source + " -> " + destination + " @" + currentLine + "/" + lines.size();
    }
}
