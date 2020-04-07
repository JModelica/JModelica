/*
 * Copyright (c) 2001-2004 Ant-Contrib project.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package net.sf.antcontrib.property;

import java.util.Enumeration;
import java.util.Vector;

/****************************************************************************
 * Regular Expression utilities
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 *
 ****************************************************************************/


public class RegexUtil
{

    /***
     * An abritrary node in a select expression
     */
    private static interface SelectNode
    {
        /***
         * Select the value based on the groups
         * @param groups The groups found in the match
         */
        public String select(Vector groups);
    }

    /***
     * A group node in a select expression
     */
    private static class GroupSelectNode
        implements SelectNode
    {
        private int groupNumber;

        public GroupSelectNode(int groupNumber)
        {
            this.groupNumber = groupNumber;
        }

        public String select(Vector groups)
        {
            if ( groupNumber < groups.size())
                return (String)groups.elementAt(groupNumber);
            else
                return "\\" + groupNumber;
        }

        public String toString()
        {
            return "group: " + groupNumber;
        }
    }

    /***
     * An abritrary node in a select expression
     */
    private static class StringSelectNode
        implements SelectNode
    {
        private String text;

        public StringSelectNode(String text)
        {
            this.text = text;
        }

        public String select(Vector groups)
        {
            return text;
        }

        public String toString()
        {
            return "string: " + text;
        }
    }

    /***
     * Parses a select string into a List of SelectNode objects.
     * These objects can then be merged with a group list to produce
     * an output string (using the "select" method)
     * @param input The select string
     * @return a List of SelectNode objects
     */
    private static Vector parseSelectString(String input)
    {
        Vector nodes = new Vector();
        StringBuffer buf = new StringBuffer();
        char c[] = input.toCharArray();
        for (int i=0;i<c.length;i++)
        {
            if (c[i] == '\\')
            {
                if (buf.length() > 0)
                {
                    nodes.addElement(new StringSelectNode(buf.toString()));
                    buf.setLength(0);
                }

                while (i+1 < c.length && Character.isDigit(c[i+1]))
                {
                    buf.append(c[i+1]);
                    i++;
                }

                int groupNum = Integer.parseInt(buf.toString());
                buf.setLength(0);
                nodes.addElement(new GroupSelectNode(groupNum));
            }
            else
            {
                buf.append(c[i]);
            }
        }


        if (buf.length() > 0)
        {
            nodes.addElement(new StringSelectNode(buf.toString()));
            buf.setLength(0);
        }

        return nodes;
    }

    /***
     * Parse a select string, and merge it with a match groups
     * vector to produce an output string.  Each group placehold
     * in the select string is replaced with the group at the
     * corresponding index in the match groups vector
     * @param select The select string
     * @param groups The match groups
     * @return The output string with the merged selection
     */
    public static String select(String select, Vector groups)
    {
        Vector nodes = parseSelectString(select);

        StringBuffer buf = new StringBuffer();
        Enumeration e = nodes.elements();
        SelectNode node = null;
        while (e.hasMoreElements())
        {
            node = (SelectNode)e.nextElement();
            buf.append(node.select(groups));
        }
        return buf.toString();
    }
}
