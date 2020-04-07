package org.jmodelica.util.documentation;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.jmodelica.util.StringUtil;
import org.jmodelica.util.files.FileUtil;
import org.jmodelica.util.files.ModifiableFile;
import org.jmodelica.util.xml.XMLPrinter;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * Class for building the JModelica.org documentation, i.e. the JModelica.org
 * User's Guide.
 * <p>
 * TODO: Use the xml printer? {@link XMLPrinter}.
 */
@SuppressWarnings("unused")
public final class DocumentationBuilder {
    /**
     * {@link org.w3c.dom.DocumentBuilder} instance for generating XML nodes.
     */
    private static final DocumentBuilder BUILDER = setUpDocumentBuilder();

    /**
     * Line prefixes for comments when parsing chapter order and properties
     * files.
     */
    private static final String[] COMMENTS = {
        "#", "//"
    };

    /**
     * The comment tag specifying where in a Docbook file to put
     * {@code xi:include} tags.
     */
    private static final String INCLUDE_TAG = "<!-- ===INCLUDE=== -->";

    /**
     * Default name for the chapter order file.
     */
    private static final String CHAPTER_ORDER_FILE = "chapter.order";

    /**
     * The character set to use when writing files.
     */
    private static final String CHARACTER_SET = "UTF-8";

    /**
     * Verbosity flag, used by {@link #log(String, Object...)}.
     */
    private static boolean verbose = false;

    /**
     * Sets up a {@link org.w3c.dom.DocumentBuilder}.
     * <p>
     * N.b.
     * {@link javax.xml.parsers.DocumentBuilderFactory#setNamespaceAware(boolean)}
     * must be called with {@code true} in order for document attribute
     * references to work.
     * 
     * @return
     *         a document builder to be used when parsing XML files.
     * @throws DocumentationBuilderException
     *             if there was any error during builder setup.
     */
    private static DocumentBuilder setUpDocumentBuilder() throws DocumentationBuilderException {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(true);

        try {
            return factory.newDocumentBuilder();
        } catch (ParserConfigurationException e) {
            throw new DocumentationBuilderException(
                    "There was an error setting up the DOM DocumentBuilder: " + e.getLocalizedMessage() + ".");
        }
    }

    /*
     * Property file list types.
     */
    private static final String EXCLUDE = "exclude";
    private static final String INCLUDE = "include";
    private static final String MODULES = "modules";
    private static final String ORDER = "order";

    private File source;
    private File destination;
    private List<String> chapterOrder;
    private List<File> images;
    private List<File> moduleSources;
    private Map<String, String> replacements;

    /**
     * Sets up a {@code DocumentationBuilder}.
     * 
     * @param source
     *            The main source file.
     * @param destination
     *            The directory to which to write the main Docbook XML. The
     *            resulting file will have the same name as {@code source}.
     * @param moduleSources
     *            A list of files to include in the documentation.
     * @param chapterOrder
     *            A listing of chapter names specifying the order in which to
     *            write chapters.
     * @param images
     *            A list of images to copy to the destination.
     * @param replacements
     *            A map of string-string key-value pairs; all keys are replaced
     *            by their corresponding values in the text.
     * @param verbose
     *            Flag specifying whether or not the builder should print
     *            messages.
     */
    public DocumentationBuilder(File source, File destination, List<File> moduleSources, List<String> chapterOrder,
            List<File> images, Map<String, String> replacements, boolean verbose) {

        this.source = source;
        this.destination = destination;
        this.moduleSources = moduleSources;
        this.chapterOrder = chapterOrder;
        this.images = images;
        this.replacements = replacements;
        DocumentationBuilder.verbose = verbose;
    }

    /**
     * Produces a top Docbook file containing the overall structure of the
     * documentation. This top file contains the text specified by a source
     * file, which is expected to contain a comment equal to
     * {@link INCLUDE_TAG}.
     * <p>
     * The {@link INCLUDE_TAG} tag is replaced by a listing of
     * {@code xi:include} tags pointing to other chapters also produced by this
     * method.
     * <p>
     * Sections in the source file and all the <i>module</i> source files are
     * read and joined together into {@link DocumentElement}s. These aggregated
     * sections are then written as a single section.
     * 
     * @throws DocumentationBuilderException
     *             if there was any error parsing any file.
     */
    private void writeDocumentation() throws IOException, DocumentationBuilderException {

        log("Using %s as source.\n", source);
        DocumentElement doc = parse(source);
        if (!doc.isRoot()) {
            throw new DocumentationBuilderException(
                    "Entry point XML must be a <book>, " + doc.tag() + " found in " + source + ".");
        }
        RootElement root = (RootElement) doc;

        for (File file : moduleSources) {
            log("\tParsed %s.\n", file);
            root.addElement(parse(file));
        }
        checkChapters(root, chapterOrder);

        ModifiableFile file =
                new ModifiableFile(source, new File(destination + File.separator + source.getName()), CHARACTER_SET);
        if (file.advanceTo(INCLUDE_TAG) == -1) {
            throw new DocumentationBuilderException(
                    "Missing \"" + INCLUDE_TAG + "\" in documentation root " + file.source() + ".");
        }
        file.deleteLine();
        file.advance(1);

        List<String> chapterNames = root.chapterNames();
        chapterNames.removeAll(chapterOrder);
        chapterOrder.addAll(chapterNames);
        log("Chapter%s written in the following order:\n\t%s\n", (chapterNames.size() > 1 ? "s" : ""), chapterOrder);

        log("Including chapters in %s. Writing to %s.\n", file, destination);
        for (String name : chapterOrder) {
            ChapterElement chapter = root.getChapter(name);
            chapter.include(file);
            chapter.writeFile(destination, replacements, CHARACTER_SET);
            log("\tWrote chapter %s.\n", name);
        }
        file.write(CHARACTER_SET);

        String fileSeparator = File.separator;
        File imageDest = new File(destination + fileSeparator + "images");
        imageDest.mkdirs();

        log("Copying images to %s.\n", imageDest);
        for (File image : images) {
            log("    Copied %s to %s.\n", image, imageDest);
            FileUtil.copyRecursive(image, imageDest, true);
        }
        log("Done building.\n");
    }

    /**
     * Verifies that all chapters listed in the chapter order file are accounted
     * for after parsing all XML files.
     */
    private void checkChapters(RootElement root, List<String> chapterOrder) {
        List<String> errorList = new ArrayList<String>();
        for (String chapterName : chapterOrder) {
            if (!root.hasChapter(chapterName)) {
                errorList.add(chapterName);
            }
        }

        int errorSize = errorList.size();
        if (errorSize > 0) {
            StringBuilder message = new StringBuilder(
                    "\nThe following chapter" + (errorSize > 1 ? "s" : "") + " could not be located:\n");
            for (String errorChapter : errorList) {
                message.append("\t" + errorChapter + "\n");
            }
            throw new DocumentationBuilderException(message.toString());
        }
    }

    /**
     * Parses a Docbook file to a {@link DocumentElement} object using
     * {@link javax.xml.parsers} and {@link org.w3c.dom} as intermediaries.
     * 
     * @param file
     *            The XML file to parse.
     * @return
     *         a {@link DocumentElement} object representing the structure of
     *         the Docbook file.
     * @throws DocumentationBuilderException
     *             if there was any error parsing the file.
     * @throws IOException
     *             if there was any error reading the file.
     */
    private DocumentElement parse(File file) throws DocumentationBuilderException, IOException {
        if (!file.getName().endsWith(".xml")) {
            // TODO: Just ignore instead? Is filtered in advance now so can probably remove.
            throw new IllegalArgumentException("Attempting to parse non-XML file " + file.getAbsolutePath() + ".");
        }

        try {
            Document document = BUILDER.parse(
                    new InputSource(new InputStreamReader(new FileInputStream(file.getAbsolutePath()), CHARACTER_SET)));
            Element element = document.getDocumentElement();
            element.normalize();

            switch (element.getNodeName()) {
            case RootElement.BOOK:
                return new RootElement(element);
            case ChapterElement.APPENDIX:
            case ChapterElement.CHAPTER:
                return new ChapterElement(element, document);
            default:
                return new DocumentElement(element);
            }

        } catch (SAXException e) {
            throw new DocumentationBuilderException(
                    "Error parsing XML-file " + file.getAbsolutePath() + ": " + e.getMessage());
        }
    }

    @Override
    public String toString() {
        StringBuilder string =
                new StringBuilder("Source: " + source + "\nDestination: " + destination + "\nModule sources:");
        for (File module : moduleSources) {
            string.append("\n\t" + module);
        }
        string.append("\nChapters:");
        for (String chapter : chapterOrder) {
            string.append("\n\t" + chapter);
        }
        return string.append("\n").toString();
    }

    /* ====== *
     *  Run.  *
     * ====== */

    /**
     * Options required to be set in order to run the
     * {@code DocumentationBuilder}.
     */
    private static final Set<String> REQUIRED_OPTIONS;
    static {
        Set<String> set = new HashSet<String>();
        set.add("-d");
        set.add("-m");
        set.add("-p");
        set.add("-s");
        REQUIRED_OPTIONS = Collections.<String> unmodifiableSet(set);
    }

    /**
     * Runs the documentation builder. This program aggregates Docbook
     * documentation chapters from several XML files.
     * <p>
     * The XML files used are determined with a properties file and a chapter
     * order file.
     * <ul>
     * <li>The chapter order file specifies in which order the chapters should
     * be listed in the final document. If a chapter exists that is not listed
     * in this file, it will be added after the other chapters. If a chapter is
     * specified in this ordering but could not be found after all XML files
     * have been parsed, the program exits with an error.
     * <li>The properties files specifies which modules to include when building
     * the documentation. If a module contains a "doc" folder, all XML files
     * within it are included when aggregating the chapters. If chapters with
     * the same name are joined together, the module order here determines in
     * which order the aggregated sections are written in. Chapters from modules
     * listed in this properties file are included regardless of whether or not
     * they are listed in the chapter order file.</li>
     * </ul>
     * <p>
     * In essence, chapters are included based on the order in the chapter order
     * file, and chapter sections are included based on the order in the
     * properties file. Chapters listed in the chapter order file are required,
     * whereas documentation belonging to the modules specified in the
     * properties file are always included.
     * 
     * @param args
     *            Expected arguments:
     *            <ul>
     *            <li>-d <Path> Destination file for the generated Docbook
     *            XML.</li>
     *            <li>-s <Path> Path to the root Docbook file.</li>
     *            <li>-p Path to the configuration file (typically
     *            build-set.properties).</li>
     *            <li>-m One or more paths to module source folders.</li>
     *            </ul>
     *            Optional arguments:
     *            <ul>
     *            <li>-c <Path> Path to a chapter order file (typically
     *            chapter.order).
     *            <li>-v <Boolean> Verbosity flag (boolean).</li>
     *            </ul>
     * @throws Exception
     *             if there was any error running the program.
     */
    public static void main(String[] args) throws Exception {
        if (!checkOptions(args)) {
            error("Usage: java org.jmodelica.util.DocumentationBuilder -d <DOCBOOK DESTINATION> -p <Properties file>"
                    + " -s <Docbook source> -m <Module sources...> -c [<Order source>] -v [<verbose>]");
        }

        Options options = new Options(args);
        File docSource = options.source;
        File docDest = options.destination;
        File properties = options.properties;
        File order = options.order;

        /*
         * Verify that paths are specified correctly.
         * TODO: mkdirs if not exists for docDest?
         */
        if (!docSource.exists()) {
            error("No such Docbook source: " + docSource.getAbsolutePath() + ".");
        }

        if (!docDest.exists()) {
            error("No destination folder for Docbook: " + docDest.getAbsolutePath() + ".");
        }

        if (!properties.exists()) {
            error("Could not locate properties file " + properties.getAbsolutePath() + ".");
        }

        if (!order.exists()) {
            error("Could not locate chapter order file " + order.getAbsolutePath() + ".");
        }

        log("Source: %s\nDestination: %s\nProperties: %s\nModule directories: %s\nChapter order: %s\n\n", docSource,
                docDest, properties, options.moduleDirs, order);

        List<File> images = new ArrayList<File>();
        List<String> orderList = getOrderList(order);

        new DocumentationBuilder(docSource, docDest, moduleFiles(properties, options.moduleDirs, images, docDest),
                orderList, images, options.replacements, options.verbose).writeDocumentation();
    }

    /**
     * Checks whether or not all the required options are accounted for.
     * 
     * @param args
     *            The program arguments.
     * @return
     *         {@code true} if all the required options were specified in the
     *         program arguments, {@code false} otherwise.
     */
    private static boolean checkOptions(String[] args) {
        int found = 0;
        for (String arg : args) {
            if (REQUIRED_OPTIONS.contains(arg)) {
                ++found;
            }
        }
        return found == REQUIRED_OPTIONS.size();
    }

    /**
     * Creates the list specifying the chapter order.
     * 
     * @param source
     *            The file containing the chapter order.
     * @return
     *         a list of chapter names specifying the chapter order.
     * @throws IOException
     *             if there was any error reading {@code source}.
     */
    private static List<String> getOrderList(File source) throws IOException {
        List<String> entries = FileUtil.fileAsLines(source);
        List<String> orderSet = new ArrayList<String>();
        List<String> duplicates = new ArrayList<String>();

        int i = 0;
        for (; i < entries.size(); ++i) {
            String entry = entries.get(i);
            if (isComment(entry)) {
                continue;
            }
            String name = StringUtil.conformWhiteSpace(entry);
            if (orderSet.contains(name)) {
                duplicates.add(name);
            }
            orderSet.add(name);
        }

        if (duplicates.size() <= 0) {
            return orderSet;
        }

        StringBuilder message = new StringBuilder("Duplicate chapter entries in " + source + ":\n");
        for (String entry : duplicates) {
            message.append("\t" + entry + "\n");
        }
        throw new DocumentationBuilderException(message.toString());
    }

    /**
     * Options class.
     */
    private static class Options {
        private boolean verbose;
        private List<String> modules;
        private List<File> moduleDirs;
        private Map<String, String> replacements;
        private File destination;
        private File order;
        private File properties;
        private File source;

        /**
         * Parses options.
         * 
         * @param args
         *            the program arguments to parse options from.
         */
        public Options(String[] args) {
            List<String> argsList = new ArrayList<String>();

            this.modules = new ArrayList<String>();
            this.moduleDirs = new ArrayList<File>();
            this.replacements = new HashMap<String, String>();

            char opt = '\0';
            for (int i = 0; i < args.length; i++) {
                switch (args[i].charAt(0)) {
                case '-':
                    if (args[i].length() != 2) {
                        throw new IllegalArgumentException("Not a valid argument: " + args[i] + ".");
                    }

                    if (argsList.size() > 0) {
                        addOption(opt, argsList);
                        argsList.clear();
                    }

                    opt = args[i].charAt(1);
                    break;
                default:
                    argsList.add(args[i]);
                    break;
                }
            }

            if (argsList.size() > 0) {
                addOption(opt, argsList);
            }
        }

        /**
         * Adds a specified option.
         * 
         * @param opt
         *            The option name.
         * @param args
         *            The arguments for the option.
         */
        private void addOption(char opt, List<String> args) {
            if (opt == '\0') {
                throw new IllegalArgumentException("No option specified for argument(s): " + args + ".");
            }

            /*
             * Additional options go here.
             */
            String firstArg = args.get(0);
            switch (opt) {
            case 'c':
                this.order = new File(firstArg);
                break;
            case 'd':
                this.destination = new File(firstArg);
                break;
            case 'm':
                for (String dir : args) {
                    this.moduleDirs.add(new File(dir));
                }
                break;
            case 'p':
                this.properties = new File(firstArg);
                break;
            case 'r':
                for (int i = 0; i < args.size(); i += 2) {
                    if (i + 1 >= args.size()) {
                        throw new IllegalArgumentException("Odd number of replacement parameters; pairs required.");
                    }
                    this.replacements.put(args.get(i), args.get(i + 1));
                }
                break;
            case 's':
                this.source = new File(firstArg);
                this.order = this.order == null
                        ? new File(this.source.getParent() + File.separator + CHAPTER_ORDER_FILE) : order;
                break;
            case 'v':
                this.verbose = Boolean.parseBoolean(firstArg);
                break;
            default:
                throw new IllegalArgumentException("Unknown option '-" + opt + "'.");
            }
        }
    }

    /**
     * Helper method dumping a message then exiting (with exit code 1).
     * 
     * @param message
     *            The (error) message to print.
     */
    private static void error(String message) {
        System.err.println(message);
        System.exit(1);
    }

    /**
     * "Logger" method, i.e. prints to the standard output if in verbose mode.
     * 
     * @param format
     *            The format string.
     * @param args
     *            The arguments.
     */
    private static void log(String format, Object... args) {
        if (verbose) {
            System.out.printf(format, args);
        }
    }

    /**
     * Builds a list of module directory paths that are to be included in the
     * documentation. Which modules to include is specified in a
     * .properties-file using a variable {@code module=mod1,mod2,...,modN}.
     * 
     * @param properties
     *            The file within which the modules to include are specified.
     * @param moduleDirs
     *            The source directory of the modules to include.
     * @param destination
     *            The destination folder of the build documentation.
     * @return
     *         a list of {@link File} objects pointing to directories from where
     *         documentation is to be included.
     * @throws IOException
     *             if there was any error reading the properties file.
     * @throws DocumentationBuilderException
     *             if the properties file is ill configured.
     */
    private static List<File> moduleFiles(File properties, List<File> moduleDirs, List<File> images, File destination)
            throws IOException, DocumentationBuilderException {

        /*
         * Parse all (<listType>=<listing>)s from the properties file.
         */
        Map<String, Set<String>> lists = new HashMap<String, Set<String>>();
        try(BufferedReader reader = new BufferedReader(new FileReader(properties))) {
            Pattern pattern = Pattern.compile("[\\s,;]+");

            String line = reader.readLine();

            while (line != null) {
                if (isComment(line) || !line.contains("=")) {
                    line = reader.readLine();
                    continue;
                }

                String[] parts = line.split("=");
                String listType = parts[0];
                Set<String> list = new LinkedHashSet<String>();
                if (parts.length > 1) {
                    list.addAll(Arrays.asList(pattern.split(parts[1])));
                }

                /*
                 * Continue adding to list in case of line breaks.
                 */
                while ((line = reader.readLine()) != null) {
                    if (line.contains("=")) {
                        break;
                    }
                    line = line.trim();
                    if (line.length() <= 0) {
                        continue;
                    }
                    list.addAll(Arrays.asList(pattern.split(line)));
                }

                lists.put(listType, list);
            }
        }

        /*
         * Parsing checks.
         */
        if (!lists.containsKey(MODULES)) {
            throw new DocumentationBuilderException("Module listing missing from properties file " + properties + ".");
        }
        Set<String> modules = lists.get(MODULES);

        if (modules.isEmpty()) {
            // TODO: Build better message.
            throw new DocumentationBuilderException(
                    "No modules from " + properties + " or sources " + moduleDirs + ".");
        }
        List<String> toInclude = filterModules(lists);

        /*
         * Get all source files and include all XML files from directories with names appearing among the modules.
         * Loop over them in module order to ensure that inclusion order is maintained.
         * <p>
         * If several module directories with the same name are not allowed, uncomment the break statement.
         */
        String fileSeparator = File.separator;
        List<File> includeFiles = new ArrayList<File>();
        List<File> filesToCopy = new ArrayList<File>();

        for (String module : toInclude) {
            for (File sourceDir : moduleDirs) {
                File docDir = new File(sourceDir.getAbsolutePath() + fileSeparator + module + fileSeparator + "doc");

                if (docDir.isDirectory()) {
                    File imageDir = new File(docDir.getAbsolutePath() + fileSeparator + "images");

                    if (imageDir.isDirectory()) {
                        images.addAll(Arrays.asList(imageDir.listFiles()));
                    }

                    for (File file : docDir.listFiles()) {
                        if (file.getName().endsWith(".xml")) {
                            includeFiles.add(file);
                        } else {
                            filesToCopy.add(file);
                        }
                    }
                    // break;
                }
            }
        }

        for (File file : filesToCopy) {
            // log("    Copied %s to %s.", file, destination);
            FileUtil.copyRecursive(file, destination, true);
        }
        return includeFiles;
    }

    /**
     * Filters the module list.
     * 
     * @param lists
     *            A map to the lists to aggregate modules from. The
     *            {@link #MODULES} key is expected to exist, whereas
     *            {@link #EXCLUDE}, {@link INCLUDE} or {@link #ORDER} may or may
     *            not exist.
     * @return
     *         a filtered, ordered module list. The modules paired with the key
     *         {@link #MODULES} are ordered according to the order of the values
     *         in the list paired with {@link #ORDER}. All modules in the list
     *         paired with {@link INCLUDE} are included as well, and
     *         <i>after</i> that the modules in the list paired with
     *         {@link #EXCLUDE} are removed.
     */
    private static List<String> filterModules(Map<String, Set<String>> lists) {
        Set<String> emptyList = Collections.<String> emptySet();
        Set<String> modules = lists.get(MODULES);
        Set<String> include = lists.containsKey(INCLUDE) ? lists.get(INCLUDE) : emptyList;
        Set<String> order = lists.containsKey(ORDER) ? lists.get(ORDER) : emptyList;
        Set<String> exclude = lists.containsKey(EXCLUDE) ? lists.get(EXCLUDE) : emptyList;

        Set<String> filtered = new LinkedHashSet<String>(order);
        Set<String> toRetain = new LinkedHashSet<String>(modules);
        toRetain.addAll(include);
        filtered.retainAll(toRetain);
        filtered.addAll(modules);
        filtered.addAll(include);
        filtered.removeAll(exclude);

        return new ArrayList<String>(filtered);
    }

    /**
     * Checks if a line is commented.
     * 
     * @param line
     *            The line to check.
     * @return
     *         {@code true} if the line should be regarded as a comment,
     *         {@code false} otherwise.
     * @see #COMMENTS
     */
    private static boolean isComment(String line) {
        String trimmed = line.trim();
        for (String comment : COMMENTS) {
            if (trimmed.startsWith(comment)) {
                return true;
            }
        }
        return false;
    }

}
