package org.jmodelica.common.options;

import org.jmodelica.common.options.AbstractOptionRegistry.Category;
import org.jmodelica.common.options.AbstractOptionRegistry.Default;
import org.jmodelica.common.options.AbstractOptionRegistry.OptionType;

public class BooleanOption extends Option<Boolean> {

    public BooleanOption(String key, OptionType type, Category cat, String description,
            Default<Boolean> def) {

        super(key, type, cat, description, def, false);
    }

    @Override
    protected void setValue(String str) {
        if (str.equals("true") || str.equals("yes") || str.equals("on"))
            setValue(true);
        else if (str.equals("false") || str.equals("no") || str.equals("off"))
            setValue(false);
        else
            invalidValue(str, ", expecting boolean value.");
    }

    @Override
    public String getType() {
        return "boolean";
    }

    @Override
    public String getValueString() {
        return Boolean.toString(getValue());
    }

    @Override
    protected void copyTo(AbstractOptionRegistry reg, String key) {
        if (isSet) {
            reg.setBooleanOption(key, value);
        }
    }

}