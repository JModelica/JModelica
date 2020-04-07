/*
    Copyright (C) 2010 Modelon AB

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

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;

import javax.swing.tree.TreeNode;

public class SizeNode implements TreeNode {

	private int level;
	private String node;
	private String size;
	
	private ArrayList<SizeNode> children;
	private SizeNode parent;
	
	private static final String DIV = ": ";

	public static SizeNode readTree(String file) throws IOException {
		BufferedReader in = new BufferedReader(new FileReader(file));
		SizeNode root = new SizeNode(in.readLine());
		if (root.level == 0) {
            root.fill(in);
        } else {
            root = fillRev(in, root, 1);
        }
		return root;
	}

	public SizeNode(String line) {
		String trim = line.trim();
		level = line.length() - trim.length();
		int pos = trim.indexOf(DIV);
		node = trim.substring(0, pos);
		size = trim.substring(pos + DIV.length());
	}
	
	public static SizeNode fillRev(BufferedReader in, SizeNode next, int level) throws IOException {
		ArrayList<SizeNode> siblings = new ArrayList<SizeNode>();
		do {
			if (level < next.level) {
                next = fillRev(in, next, level + 1);
            }
			if (level == next.level) {
				siblings.add(0, next);
				next = readNode(in);
			}
		} while (level <= next.level);
		if (next.children == null) {
            next.children = siblings;
        }
		return next;
	}

	public SizeNode fill(BufferedReader in) throws IOException {
		SizeNode next = readNode(in);
		int childLevel = level + 1;
		while (next != null) {
			if (next.level > childLevel) {
				SizeNode last = children.get(children.size() - 1);
				last.add(next);
				next = last.fill(in);
			} else if (next.level == childLevel) {
				add(next);
				next = readNode(in);
			} else {
				return next;
			}
		}
		return null;
	}

	private static SizeNode readNode(BufferedReader in) throws IOException {
		String line = in.readLine();
		if (line == null) {
            return null;
        }
		return new SizeNode(line);
	}

	private void add(SizeNode child) {
		if (children == null) {
            children = new ArrayList<SizeNode>();
        }
		children.add(child);
		child.parent = this;
	}

	@Override
    public TreeNode getChildAt(int childIndex) {
		return children.get(childIndex);
	}

	@Override
    public int getChildCount() {
		return children != null ? children.size() : 0;
	}

	@Override
    public TreeNode getParent() {
		return parent;
	}

	@Override
    public int getIndex(TreeNode node) {
		return children != null ? children.indexOf(node) : -1;
	}

	@Override
    public boolean getAllowsChildren() {
		return true;
	}

	@Override
    public boolean isLeaf() {
		return getChildCount() == 0;
	}

	@Override
    public Enumeration<SizeNode> children() {
		return Collections.enumeration(children);
	}
	
	@Override
    public String toString() {
		return size + " - " + node;
	}

}
