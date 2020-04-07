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
package org.jmodelica.util;

public enum Solvability {
	ANALYTICALLY_SOLVABLE ,
	NUMERICALLY_SOLVABLE {
		@Override
		public boolean isAnalyticallySolvable() {
			return false;
		}
	},
	UNSOLVABLE {
		@Override
		public boolean isSolvable() {
			return false;
		}
	};
	
	public static Solvability least(Solvability a, Solvability b) {
		return a.compareTo(b) > 0 ? a : b;
	}
	
	public boolean isSolvable() {
		return true;
	}
	
	public boolean isAnalyticallySolvable() {
		return isSolvable();
	}
	
}