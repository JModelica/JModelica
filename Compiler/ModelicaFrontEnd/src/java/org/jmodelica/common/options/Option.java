package org.jmodelica.common.options;

import java.io.PrintStream;

import org.jmodelica.common.options.AbstractOptionRegistry.Category;
import org.jmodelica.common.options.AbstractOptionRegistry.Default;
import org.jmodelica.common.options.AbstractOptionRegistry.InvalidOptionValueException;
import org.jmodelica.common.options.AbstractOptionRegistry.OptionType;
import org.jmodelica.util.StringUtil;
import org.jmodelica.util.xml.DocBookPrinter;
import org.jmodelica.util.xml.XMLPrinter;

/**
 * Base class for options.
 *
 * @param <T>
 *          The type of option ({@code Boolean}, {@code Double} (real), {@code Integer}, or {@code String}).
 */
public abstract class Option<T> implements Comparable<Option<T>> {
    protected final String key;
    protected Default<T> defaultValue;
    protected T value;

    private OptionType type;
    private Category category;
    private String description;

    protected boolean isSet;
    private boolean descriptionChanged = false;
    private boolean defaultChanged = false;

    /**
     * Creates an option with an initial value, as well as a different default value to use when under test.
     * 
     * @param key
     *          The key to (name of) the option.
     * @param optionType
     *          The type of option.
     * @param category
     *          The category of the option.
     * @param description
     *          A description of the option.
     * @param defaultValue
     *          The option's default value.
     * @param value
     *          The initial value of the option.
     */
    public Option(String key, OptionType optionType, Category category, String description,
            Default<T> defaultValue, T value) {

        this.key = key;
        this.description = description;
        this.type = optionType;
        this.category = category;
        this.value = value;
        this.defaultValue = defaultValue;
        this.isSet = false;
    }

    /* =========== *
     *  Abstract.  *
     * =========== */

    /**
     * Retrieves the name of the option's type.
     * 
     * @return
     *           the name of the option's type.
     */
    public abstract String getType();

    /**
     * Retrieves the string representation of the option's value.
     * 
     * @return
     *           the string representation of the option's value.
     */
    public abstract String getValueString();

    protected abstract void copyTo(AbstractOptionRegistry registry, String key);
    protected abstract void setValue(String string);

    /**
     * Resets the option, enabling resetting its value.
     */
    public void clear() {
        this.isSet = false;
    }

    /**
     * Prints the option's DocBook documentation entry.
     * 
     * @param out
     *          The {@link DocBookPrinter} to which to print this option's entry.
     */
    public void exportDocBook(DocBookPrinter out) {
        out.enter("row");
        
        out.enter("entry");
        out.printLiteral(StringUtil.wrapUnderscoreName(key, 26));
        out.exit();
        
        out.enter("entry");
        out.printLiteral(getType());
        out.text("/", 80);
        out.printLiteral(getValueForDoc());
        out.exit();
        
        out.printWrappedPreFormatedText("entry", description);
        
        out.exit();
    }

    /**
     * Prints a string representation of the option to a {@link PrintStream}.
     * 
     * @param out
     *          The print stream to which to print the option.
     */
    public void exportPlainText(PrintStream out) {
        out.format("%-30s  %-15s\n", key, getValueForDoc());
        StringUtil.wrapText(out, description, "    ", 80);
    }

    /**
     * Prints the option's XML entry.
     * 
     * @param out
     *          The {@link XMLPrinter} to which to print this option's entry.
     */
    public void exportXML(XMLPrinter out) {
        String type = getType();
        out.enter("Option", "type", type);
        String tag = AbstractOptionRegistry.capitalize(type) + "Attributes";
        if (description == null || description.equals("")) {
            out.single(tag, "key", key, "value", getValueString());
        } else {
            out.enter(tag, "key", key, "value", getValueString());
            out.enter("Description");
            out.text(description, 80);
            out.exit(2);
        }
        out.exit();
    }

    /**
     * Retrieves the default value of this option.
     * 
     * @return
     *          the default value of this option.
     */
    public T getDefault() {
        return defaultValue.value();
    }

    /**
     * Sets the default value of this option.
     * 
     * @param newDefault
     *          the new default value of this option.
     */
    public void setDefault(Default<T> newDefault) {
        changeDefault();
        this.defaultValue = newDefault;
    }

    /**
     * Retrieves this option's current value.
     * 
     * @return
     *          this option's current value.
     */
    public T getValue() {
        return isSet ? value : defaultValue.value();
    }

    /**
     * Sets this option's value to a new value.
     * 
     * @param value
     *          the new value to set the option to.
     */
    public void setValue(T value) {
        this.isSet = true;
        this.value = value;
    }

    /**
     * Retrieves the key to this option.
     * 
     * @return
     *          the key to this option.
     */
    public String getKey() {
        return key;
    }

    /**
     * Retrieves the description text of this option.
     * 
     * @return
     *          the description text of this option.
     */
    public String getDescription() {
        return description;
    }

    /**
     * Retrieves the option type of this option.
     * 
     * @return
     *          the option type of this option.
     */
    public OptionType getOptionType() {
        return type;
    }

    /**
     * Checks whether or not this option's possible values are limited.
     * 
     * @return
     *          {@code true} if this option's values are limited, {@code false} otherwise.
     */
    public Boolean isLimited() {
        return false;
    }

    /**
     * Retrieves this option's category.
     * 
     * @return
     *          this option's category.
     */
    public Category getCategory() {
        return category;
    }

    /**
     * Retrieves the option values' string representation as to be used within documentation.
     * 
     * @return
     *          a string of the option values' representation as to be used within documentation.
     */
    public String getValueForDoc() {
        return getValueString();
    }

    @Override
    public int compareTo(Option<T> o) {
        int res = type.compareTo(o.type);
        if (res != 0) {
            return res;
        }
        if ((res = category.compareTo(o.category)) != 0) {
            return res;
        }
        return key.compareTo(o.key);
    }

    /**
     * Sets a new description for this option.
     * 
     * @param newDescription
     *          The new description of this option.
     */
    public void changeDescription(String newDescription) {
        if (descriptionChanged)
            throw new UnsupportedOperationException("Description of " + key + " has already been changed.");
        descriptionChanged = true;
        this.description = newDescription;
    }

    @Override
    public String toString() {
        return "\'"+key+"\': " + description; 
    }

    protected void invalidValue(Object value, String allowedMessage) {
        throw new InvalidOptionValueException("Option '" + key + "' does not allow the value '" +
                value + "'" + allowedMessage);
    }

    protected void changeDefault() {
        if (defaultChanged) {
            throw new IllegalArgumentException("Default value for " + key + " has already been changed.");
        }
        defaultChanged = true;
    }

    public boolean isType(OptionType type) {
        return this.type == type;
    }
}
