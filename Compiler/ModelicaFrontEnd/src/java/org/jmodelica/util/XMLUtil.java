/*
    Copyright (C) 2016 Modelon AB

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
package org.jmodelica.util;

/**
 * Utility methods for XML formatting.
 */
public final class XMLUtil {

    /**
     * Hidden default constructor to prevent instantiation.
     */
    private XMLUtil() {}

    /**
     * Escapes XML characters in a string.
     * 
     * @param message   the string with XML characters to escape.
     * @return          {@code message} with escaped XML characters.
     */
    public static String escape(String message) {
        if (message == null)
            return message;
        StringBuffer sb = new StringBuffer(message.length());
        for (int i = 0; i < message.length(); i++) {
            char c = message.charAt(i);
            if (c == '"') {
                sb.append("&quot;");
            } else if (c == '&') {
                sb.append("&amp;");
            } else if (c ==  '\'') {
                sb.append("&apos;");
            } else if (c == '<') {
                sb.append("&lt;");
            } else if (c == '>') {
                sb.append("&gt;");
            } else if ((c >= 0x0 && c <= 0x8) || (c >= 0xB && c <= 0xC) || (c >= 0xE && c <= 0x1F)) {
                // These characters aren't allowed by the XML specification.
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }

    /**
     * Escapes XML characters in several messages.
     * 
     * @param messages  the strings to escape.
     * @return          {@code messages} with escaped XML characters.
     * @see             #escape(String)
     */
    public static String[] escape(String... messages) {
        String[] escaped = new String[messages.length];
        for (int i = 0; i < messages.length; i++)
            escaped[i] = escape(messages[i].toString());
        return escaped;
    }

}
