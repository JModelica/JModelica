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

import java.awt.Dimension;
import java.io.File;
import java.io.IOException;
import java.util.regex.Pattern;

import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JScrollPane;
import javax.swing.JTree;
import javax.swing.filechooser.FileFilter;

public class SizeTree extends JFrame {
    private static final long serialVersionUID = 1L;

    public SizeTree(String file) throws IOException {
		super("Profiler size file viewer - " + file);
		SizeNode data = SizeNode.readTree(file);
		JTree tree = new JTree(data);
		JScrollPane treeView = new JScrollPane(tree);
		treeView.setPreferredSize(new Dimension(300, 500));
		add(treeView);
		pack();

		setDefaultCloseOperation(EXIT_ON_CLOSE);
	}

	public static void main(String[] args) throws IOException {
		JFileChooser chooser = new JFileChooser(args.length > 0 ? args[0] : ".");
		chooser.setFileFilter(new ProfileSizeFileFilter());
		int returnVal = chooser.showOpenDialog(null);
		if (returnVal == JFileChooser.APPROVE_OPTION) {
			SizeTree window = new SizeTree(chooser.getSelectedFile().getPath());
			window.setVisible(true);
		} else {
			System.exit(0);
		}
	}
	
	private static class ProfileSizeFileFilter extends FileFilter {
		
		private static final Pattern pat = Pattern.compile("size_.*\\.txt");

		@Override
		public boolean accept(File pathname) {
			return pathname.isDirectory() || pat.matcher(pathname.getName()).matches();
		}

		@Override
		public String getDescription() {
			return "Profiling size files";
		}
		
	}
}
