/*
    Copyright (C) 2015 Modelon AB

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
package org.jmodelica.util.test;

import java.util.ArrayList;
import java.util.Iterator;

public class TestTree implements GenericTestTreeNode, Iterable<GenericTestTreeNode> {
    private String name;
    private ArrayList<GenericTestTreeNode> children;
    private TestTree parent;
    private int parentIndex;

    public TestTree(String name) {
        this.name = name;
        parent = null;
        parentIndex = -1;
        children = new ArrayList<GenericTestTreeNode>();
    }

    public TestTree enter(String childName) {
        TestTree child = new TestTree(childName);
        child.parent = this;
        child.parentIndex = children.size();
        children.add(child);
        return child;
    }

    public TestTree exit() {
        if (children.isEmpty() && parent != null) 
            parent.children.remove(parentIndex);
        return parent;
    }

    public void add(GenericTestCase tc) {
        children.add(tc);
    }

    @Override
    public String getName() {
        return name;
    }

    public int numChildren() {
        return children.size();
    }

    @Override
    public Iterator<GenericTestTreeNode> iterator() {
        return children.iterator();
    }
}
