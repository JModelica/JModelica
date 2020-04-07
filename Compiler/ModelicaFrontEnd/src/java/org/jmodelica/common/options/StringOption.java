package org.jmodelica.common.options;

import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import org.jmodelica.common.options.AbstractOptionRegistry.Category;
import org.jmodelica.common.options.AbstractOptionRegistry.Default;
import org.jmodelica.common.options.AbstractOptionRegistry.OptionType;


public class StringOption extends Option<String> {
    protected Map<String,String> values;

    /**
     * Creates an option for string values.
     * 
     * @param key
     *          The key to (name of) the option.
     * @param type
     *          The type of option.
     * @param category
     *          The category of the option.
     * @param description
     *          A description of the option.
     * @param defaultValue
     *          The option's default value.
     * @param values
     *          The option's possible values (settings).
     */
    public StringOption(String key, OptionType type, Category category, String description,
            Default<String> defaultValue, String[] values) {

        super(key, type, category, description, defaultValue, null);

        this.value = null;
        if (values == null) {
            this.values = null;
        } else {
            this.values = new LinkedHashMap<String,String>(8);
            for (String v : values)
                this.values.put(v, v);
        }
    }

    @Override
    public void setValue(String value) {
        if (values != null) {
            String v = values.get(value);
            if (v != null) {
                this.value = v;
                isSet = true;
                return;
            }
            StringBuilder buf = new StringBuilder(", allowed values: ");
            Object[] arr = values.keySet().toArray();
            Arrays.sort(arr);
            buf.append(Arrays.toString(arr).substring(1));
            invalidValue(value, buf.substring(0, buf.length() - 1));
        } else {
            this.value = value;
            isSet = true;
        }
    }

    @Override
    public String getDefault() {
        if (values != null) {
            String d = defaultValue.value();
            String v = values.get(d);
            return (v == null) ? d : v;
        } else {
            return defaultValue.value();
        }
    }

    /**
     * Allows an additional value (setting) for this option.
     * 
     * @param value
     *          The value to allow.
     * @return
     *          the value to allow.
     */
    public String addAllowed(String value) {
        if (values == null)
            throw new IllegalArgumentException("This option allows any value.");
        if (values.containsKey(value)) {
            return values.get(value);
        } else {
            values.put(value, value);
            return value;
        }
    }

    /**
     * Retrieves the allowed values (settings) for this option.
     * 
     * @return
     *          the allowed values for this option.
     */
    public Set<String> getAllowed() {
        if (values == null) {
            return Collections.unmodifiableSet(Collections.<String> emptySet());
        }
        return Collections.<String> unmodifiableSet(values.keySet());
    }

    @Override
    public String getType() {
        return "string";
    }

    @Override
    public String getValueString() {
        return getValue();
    }

    /**
     * Retrieves the documentation string for this option's current value.
     */
    @Override
    public String getValueForDoc() {
        return (getValue() == null) ? "null" : String.format("'%s'", getValue());
    }

    @Override
    protected void copyTo(AbstractOptionRegistry reg, String key) {
        if (isSet) {
            reg.setStringOption(key, value);
        }
    }

}