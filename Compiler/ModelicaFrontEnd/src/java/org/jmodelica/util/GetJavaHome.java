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

public class GetJavaHome {

	public static void main(String[] args) {
		String home = System.getProperty("java.home");
		String sep = System.getProperty("file.separator");
		int pos = home.lastIndexOf(sep) + 1;
		if (home.substring(pos).equals("jre"))
			home = home.substring(0, pos);
		System.out.println(home);
	}

}
