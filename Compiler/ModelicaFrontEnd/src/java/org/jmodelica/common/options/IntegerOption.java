/*
    Copyright (C) 2010-2019 Modelon AB

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

public class IntegerOption extends Option<Integer> {
    private int min;
    private int max;

    /**
     * Creates an option for real values.
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
     */
    public IntegerOption(String key, AbstractOptionRegistry.OptionType type, AbstractOptionRegistry.Category category, String description,
                         AbstractOptionRegistry.Default<Integer> defaultValue) {

        this(key, type, category, description, defaultValue, Integer.MIN_VALUE, Integer.MAX_VALUE);
    }

    /**
     * Creates an option for real values.
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
     * @param min
     *          The minimum allowed value for this option.
     * @param max
     *          The maximum allowed value for this option.
     */
    public IntegerOption(String key, AbstractOptionRegistry.OptionType type, AbstractOptionRegistry.Category category, String description,
                         AbstractOptionRegistry.Default<Integer> defaultValue, int min, int max) {

        super(key, type, category, description, defaultValue, null);
        this.min = min;
        this.max = max;
    }

    @Override
    public void setValue(Integer value) {
        if (value < min || value > max) {
            invalidValue(value, minMaxStr());
        }
        super.setValue(value);
    }

    @Override
    protected void setValue(String str) {
        try {
            setValue(Integer.parseInt(str));
        } catch (NumberFormatException e) {
            invalidValue(str, ", expecting integer value" + minMaxStr());
        }
    }

    private String minMaxStr() {
        return (min == Integer.MIN_VALUE ? "" : ", min: " + min) + (max == Integer.MAX_VALUE ? "" : ", max: " + max);
    }

    /**
     * Retrieves the minimum allowed value for this option.
     *
     * @return
     *          the minimum allowed value for this option.
     */
    public int getMin() {
        return min;
    }

    /**
     * Retrieves the maximum allowed value for this option.
     *
     * @return
     *          the maximum allowed value for this option.
     */
    public int getMax() {
        return max;
    }

    @Override
    public Boolean isLimited() {
        return (min != Integer.MIN_VALUE) || (max != Integer.MAX_VALUE);
    }

    /**
     * Lowers the minimum allowed value for this option. Will not raise it.
     *
     * @param val
     *          The new minimum allowed value.
     */
    public void expandMin(int val) {
        if (val < min)
            min = val;
    }

    /**
     * Raises the maximum allowed value for this option. Will not lower it.
     *
     * @param val
     *          The new minimum allowed value.
     */
    public void expandMax(int val) {
        if (val > max)
            max = val;
    }

    @Override
    public String getType() {
        return "integer";
    }

    @Override
    public String getValueString() {
        return Integer.toString(getValue());
    }

    @Override
    protected void copyTo(AbstractOptionRegistry reg, String key) {
        if (isSet) {
            reg.setIntegerOption(key, value);
        }
    }

}
