/*
    Copyright (C) 2010-2018 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.jmodelica.common.options;

import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.jmodelica.util.xml.DocBookColSpec;
import org.jmodelica.util.xml.DocBookPrinter;
import org.jmodelica.util.xml.XMLPrinter;

/**
 * Base class for storing compile options.
 *
 * <p>Options can be retrieved based on type: String, Integer etc.
 * AbstractOptionRegistry also provides methods for handling paths
 * to Modelica libraries.
 *
 * <p>Use {@link org.jmodelica.modelica.compiler.generated.OptionRegistry#buildOptions()}
 * to get an option registry populated with all available options.
 */
public abstract class AbstractOptionRegistry {

    public abstract static class Default<T> {
        public final Class<T> type;
        
        public Default(Class<T> type) {
            this.type = type;
        }
        
        public abstract T value();
    }

    public static class DefaultValue<T> extends Default<T> {
        private final T value;
        
        @SuppressWarnings("unchecked")
        public DefaultValue(T val) {
            super((Class<T>) val.getClass());
            value = val;
        }

        @Override
        public T value() {
            return value;
        }

        @Override
        public String toString() {
            return value.toString();
        }
    }

    public abstract class DefaultCopy<T> extends Default<T> {
        protected final String key;

        public DefaultCopy(String key, Class<T> type) {
            super(type);
            this.key = key;
        }
    }

    public class DefaultCopyInteger extends DefaultCopy<Integer> {
        public DefaultCopyInteger(String key) {
            super(key, Integer.class);
        }

        @Override
        public Integer value() {
            return getIntegerOption(key);
        }
    }

    public class DefaultCopyReal extends DefaultCopy<Double> {
        public DefaultCopyReal(String key) {
            super(key, Double.class);
        }

        @Override
        public Double value() {
            return getRealOption(key);
        }
    }

    public class DefaultCopyString extends DefaultCopy<String> {
        public DefaultCopyString(String key) {
            super(key, String.class);
        }

        @Override
        public String value() {
            return getStringOption(key);
        }
    }

    public class DefaultCopyBoolean extends DefaultCopy<Boolean> {
        public DefaultCopyBoolean(String key) {
            super(key, Boolean.class);
        }

        @Override
        public Boolean value() {
            return getBooleanOption(key);
        }
    }

    public class DefaultInvertBoolean extends Default<Boolean> {
        private final Default<Boolean> op;

        public DefaultInvertBoolean(Default<Boolean> operand) {
            super(Boolean.class);
            op = operand;
        }

        public DefaultInvertBoolean(String key) {
            this(new DefaultCopyBoolean(key));
        }

        @Override
        public Boolean value() {
            return !op.value();
        }
        
    }

    public interface Inlining {
        public static final String NONE    = "none";
        public static final String TRIVIAL = "trivial";
        public static final String ALL     = "all";
    }
    public interface Homotopy {
        public static final String SIMPLIFIED = "simplified";
        public static final String ACTUAL     = "actual";
        public static final String HOMOTOPY   = "homotopy";
    }
    public interface LocalIteration {
        public static final String OFF        = "off";
        public static final String ANNOTATION = "annotation";
        public static final String ALL        = "all";
    }
    public interface FMIVersion {
        public static final String FMI10  = "1.0";
        public static final String FMI20  = "2.0";
    }
    public interface CCompilerFiles {
        public static final String NONE      = "none";
        public static final String FUNCTIONS = "functions";
        public static final String ALL       = "all";
    }

    public enum OptionType { compiler, runtime }

    public enum Category { common, user, uncommon, experimental, debug, internal, deprecated }

    protected Map<String, Option<?>> optionsMap = new HashMap<>();

    /**
     * Create a copy of this AbstractOptionRegistry.
     * 
     * @return
     *          a new {@code AbstractOptionRegistry} with the same options and settings as {@code this}.
     */
    public abstract AbstractOptionRegistry copy();

    @SuppressWarnings({
        "unchecked", "rawtypes"
    })
    private List<Option> sortedOptions() {
        List<Option> opts = new ArrayList<Option>(optionsMap.values());
        Collections.<Option> sort(opts);
        return opts;
    }

    /**
     * Export all options as XML.
     * 
     * @param outStream  the stream to write to
     * @param maxCat     the maximum option category to display (as per order they are defined in)
     */
    public void exportXML(PrintStream outStream, Category maxCat) {
        XMLPrinter out = new XMLPrinter(outStream, "", "    ");
        out.enter("OptionsRegistry");
        out.enter("Options");
        for (Option<?> o : sortedOptions()) {
            if (o.getCategory().compareTo(maxCat) <= 0) {
                o.exportXML(out);
            }
        }
        out.exit(2);
    }

    /**
     * Export all options as a plain text table.
     * 
     * @param out     the stream to write to
     * @param maxCat  the maximum option category to display (as per order they are defined in)
     */
    public void exportPlainText(PrintStream out, Category maxCat) {
        out.format("%-30s  %-15s\n    Description\n", "Name", "Default value");
        for (Option<?> o : sortedOptions()) {
            if (o.getCategory().compareTo(maxCat) <= 0) {
                o.exportPlainText(out);
            }
        }
    }

    private static final String DB_TAB_IND = "        ";
    private static final String DB_TAB_ID = "models_tab_compiler_options";
    private static final String DB_TAB_TITLE = "Compiler options";
    private static final DocBookColSpec[] DB_TAB_COLS = new DocBookColSpec[] {
        new DocBookColSpec("Option",                      "left", "para",  "2.2*"),
        new DocBookColSpec("Option type / Default value", "left", "def",   "1.2*"),
        new DocBookColSpec("Description",                 "left", "descr", "3.6*")
    };

    /**
     * Export all options as a table in DockBook format.
     * 
     * @param outStream  the stream to write to
     * @param maxCat     the maximum option category to display (as per order they are defined in)
     */
    public void exportDocBook(PrintStream outStream, Category maxCat) {
        DocBookPrinter out = new DocBookPrinter(outStream, DB_TAB_IND);
        out.enter("table", "xml:id", DB_TAB_ID);
        out.oneLine("title", DB_TAB_TITLE);
        out.enter("tgroup", "cols", DB_TAB_COLS.length);
        for (DocBookColSpec s : DB_TAB_COLS) {
            s.printColspec(out);
        }
        out.enter("thead");
        out.enter("row");
        for (DocBookColSpec s : DB_TAB_COLS) {
            s.printTitle(out);
        }
        out.exit(2);
        out.enter("tbody");
        for (Option<?> o : sortedOptions()) {
            if (o.getCategory().compareTo(maxCat) <= 0) {
                o.exportDocBook(out);
            }
        }
        out.exit(3);
    }

    protected String unknownOptionMessage(String key) {
        String[] parts = key.split("_");
        for (int i = 0; i < parts.length; i++)
            parts[i] = parts[i].replaceAll("(ion|ing|s|e)$", "");
        String best = null;
        int bestScore = 0;
        for (Option<?> opt : sortedOptions()) {
            String name = opt.getKey();
            int score = -name.split("_").length;
            for (String part : parts)
                if (name.contains(part))
                    score += 1000 + part.length() * 10;
            if (score > bestScore) {
                best = name;
                bestScore = score;
            }
        }
        return (best == null) ? 
                String.format("Unknown option \"%s\"", key) : 
                String.format("Unknown option \"%s\", did you mean \"%s\"?", key, best);
    }

    /**
     * Checks whether or not an option with the specified key exists in this registry.
     * 
     * @param key
     *          The key to the option.
     * @return
     *          {@code true} if the option exists in this registry, {@code false} otherwise.
     */
    public boolean hasOption(String key) {
        return optionsMap.containsKey(key);
    }

    /** ================================================== **
     **  Addition, creation, and modification of options.  **
     **  via the {@code AbstractOptionRegistry} instance.          **
     ** ================================================== **/

    /* ========== *
     *  General.  *
     * ========== */

    /**
     * Sets the value of an option using the string representation of its new value.
     * 
     * @param key
     *          The key to the option.
     * @param value
     *          The string representation of the new value to set the option to.
     */
    public void setOption(String key, String value) {
        Option<?> o = optionsMap.get(key);
        if (o == null)
            throw new UnknownOptionException(unknownOptionMessage(key));
        o.setValue(value);
    }

    protected StringOption findStringOption(String key, boolean allowMissing) {
        Option<?> o = optionsMap.get(key);
        if (o instanceof StringOption)
            return (StringOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of string type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    public Boolean isLimited(String key) {
        Option<?> o = optionsMap.get(key);
        if (o == null) {
            throw new UnknownOptionException(unknownOptionMessage(key));
        }
        return o.isLimited();
    }

    public String getDescription(String key){
        Option<?> o = optionsMap.get(key);
        if(o == null) {
            throw new UnknownOptionException(unknownOptionMessage(key));
        }
        return o.getDescription();
    }

    public OptionType getOptionType(String key){
        Option<?> o = optionsMap.get(key);
        if(o == null) {
            throw new UnknownOptionException(unknownOptionMessage(key));
        }
        return o.getOptionType();
    }
    
    public Category getCategory(String key){
        Option<?> o = optionsMap.get(key);
        if(o == null) {
            throw new UnknownOptionException(unknownOptionMessage(key));
        }
        return o.getCategory();
    }

    private Set<Map.Entry<String, Option<?>>> getAllOptions() {
        return optionsMap.entrySet();
    }

    public Collection<String> getOptionKeys() {
        return getFilteredOptionName(NULL_OPTION_FILTER);
    }

    public Collection<String> getCompilerOptionKeys() {
        return getTypeOptionKeys(OptionType.compiler);
    }

    public Collection<String> getRuntimeOptionKeys() {
        return getTypeOptionKeys(OptionType.runtime);
    }

    public Collection<String> getTypeOptionKeys(OptionType type) {
        return getFilteredOptionName(new TypeOptionFilter(type));
    }

    public Collection<String> getFilteredOptionName(OptionFilter filter) {
        List<String> res = new ArrayList<>();
        for (Option<?> o : sortedOptions())
            if (filter.filter(o))
                res.add(o.key);
        Collections.sort(res);
        return res;
    }

    /**
     * Copies all of a registry's options to {@code this}'.
     * 
     * @param registry
     *          The {@code AbstractOptionRegistry} from which to copy options.
     * @throws UnknownOptionException
     *          if an unknown option was found in {@code registry}.
     */
    public void copyAllOptions(AbstractOptionRegistry registry) throws UnknownOptionException{
        /*
         * Copy all options in parameter registry to this option registry and overwrite it if it already exists.
         */
        for (Map.Entry<String, Option<?>> entry : registry.getAllOptions()) {
            entry.getValue().copyTo(this, entry.getKey());
        }
    }

    /* ================== *
     *  Boolean options.  *
     * ================== */

    public void setBooleanOption(String key, boolean value) {
        findBooleanOption(key, false).setValue(value);
    }

    public Boolean getBooleanOptionDefault(String key) {
        return findBooleanOption(key, false).getDefault();
    }

    public boolean getBooleanOption(String key) {
        return findBooleanOption(key, false).getValue();
    }

    public boolean isBooleanOption(String key) {
        return optionsMap.get(key) instanceof BooleanOption;
    }

    protected BooleanOption findBooleanOption(String key, boolean allowMissing) {
        Option<?> o = optionsMap.get(key);
        if (o instanceof BooleanOption)
            return (BooleanOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of boolean type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    /* ================== *
     *  Integer options.  *
     * ================== */

    public void setIntegerOption(String key, int value) {
        findIntegerOption(key, false).setValue(value);
    }

    public int getIntegerOptionDefault(String key) {
        return findIntegerOption(key, false).getDefault();
    }

    public int getIntegerOption(String key) {
        return findIntegerOption(key, false).getValue();
    }

    public boolean isIntegerOption(String key) {
        return optionsMap.get(key) instanceof IntegerOption;
    }

    protected IntegerOption findIntegerOption(String key, boolean allowMissing) {
        Option<?> o = optionsMap.get(key);
        if (o instanceof IntegerOption)
            return (IntegerOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of integer type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    /* =============== *
     *  Real options.  *
     * =============== */

    public void setRealOption(String key, double value) {
        findRealOption(key, false).setValue(value);
    }

    public double getRealOptionDefault(String key) {
        return findRealOption(key, false).getDefault();
    }

    public double getRealOption(String key) {
        return findRealOption(key, false).getValue();
    }

    public boolean isRealOption(String key) {
        return optionsMap.get(key) instanceof RealOption;
    }

    protected RealOption findRealOption(String key, boolean allowMissing) {
        Option<?> o = optionsMap.get(key);
        if (o instanceof RealOption)
            return (RealOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of real type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    public int getIntegerOptionMax(String key) {
        return findIntegerOption(key, false).getMax();
    }

    public int getIntegerOptionMin(String key) {
        return findIntegerOption(key, false).getMin();
    }

    public double getRealOptionMax(String key) {
        return findRealOption(key, false).getMax();
    }

    public double getRealOptionMin(String key) {
        return findRealOption(key, false).getMin();
    }

    /* ================= *
     *  String options.  *
     * ================= */

    public void setStringOption(String key, String value) {
        findStringOption(key, false).setValue(value);
    }

    public String getStringOptionDefault(String key) {
        return findStringOption(key, false).getDefault();
    }

    public Set<String> getStringOptionAllowed(String key) {
        return findStringOption(key, false).getAllowed();
    }

    public void addStringOptionAllowed(String key, String val) {
        findStringOption(key, false).addAllowed(val);
    }

    public String getStringOption(String key) {
        return findStringOption(key, false).getValue();
    }

    public boolean isStringOption(String key) {
        return optionsMap.get(key) instanceof StringOption;
    }

    /**
     * \brief Make the first letter in a string capital.
     * 
     * @param string
     *          The string to capitalize. 
     * @return
     *          {@code string} with its first character in upper case.
     */
    public static String capitalize(String string) {
        return string.substring(0, 1).toUpperCase() + string.substring(1);
    }
    
    /**
     * Give the exact name of a runtime option when encoded in FMU XML.
     * 
     * @param key
     *         The key to (name of) the runtime option.  
     * @return
     *         The exact name for {@code key} when encoded in
     *         the FMU XML.
     *          
     */
    public static String getFMUXMLName(String key) {
        return "_" + key;
    }


    public interface OptionFilter {
        public boolean filter(Option<?> o);
    }

    public class TypeOptionFilter implements OptionFilter {
        private OptionType type;

        public TypeOptionFilter(OptionType t) {
            type = t;
        }

        @Override
        public boolean filter(Option<?> o) {
            return o.isType(type);
        }
    }

    public static final OptionFilter NULL_OPTION_FILTER = new OptionFilter() {
        @Override
        public boolean filter(Option<?> o) {
            return true;
        }
    };

    public static class UnknownOptionException extends RuntimeException { 
        private static final long serialVersionUID = 3884972549318063140L;

        public UnknownOptionException(String message) {
            super(message);
        }
    }

    public static class InvalidOptionValueException extends RuntimeException { 
        private static final long serialVersionUID = 3884972549318063141L;

        public InvalidOptionValueException(String message) {
            super(message);
        }
    }
}
