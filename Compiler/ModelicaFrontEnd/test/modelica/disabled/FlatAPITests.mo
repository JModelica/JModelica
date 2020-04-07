/*
    Copyright (C) 2009 Modelon AB

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


package FlatAPITests
	model Test1
		Real x[2];
		parameter Real p = 4;
		parameter Integer n1=1,n2=2;
	equation
		x[n1] = 3;
		x[n2] = 4;	
	end Test1;
	
	model Test2
		parameter Integer N = 2;
		Real x[N];
		Real y[N];
		parameter Real p = 4;
		parameter Integer n1=1,n2=2;
	equation
		x[n1] = 3;
		x[n2] = 4;	
	end Test2;

    model Test3
  		Real x,y,z,v;
  		parameter Real p=3;
    equation
        x=4+p;
        x+y+z=v;
        v+z=x;
        y=x; 
    end Test3;

end FlatAPITests;