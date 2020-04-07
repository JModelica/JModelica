/*
    Copyright (C) 2014 Modelon AB

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

within ;
model TestBrent

  partial model Sweep
    parameter Real y0 = -2;
    parameter Real y1 = 2;

    Real y;
    output Real x(start = 0, min = -10, max = 10, nominal=0.1);
  equation
    y = y0 * (1-time) + y1*time;
  end Sweep;

  model Cubic
    extends Sweep;
  equation
    (x - 1) * x * (x+1) = y;
  end Cubic;

  model Logarithmic
    extends Sweep;
  equation
    log(1 + x) = y;
  end Logarithmic;
  
  model LogarithmicAssert
    extends Sweep;
    function logXplus1
        input Real x;
        output Real y;
    algorithm
        assert(noEvent(x > -1), "x must be larger than -1");
        y:= log(1 + x);
    end logXplus1;
  equation
    logXplus1(x) = y;
  end LogarithmicAssert;
  
  model XLogX
    extends Sweep;
  equation
    (1 + x)*log(1 + x) = y;
  end XLogX;

  model XLogXNeg
    extends Sweep;
  equation
    (1 - x)*log(1 - x) = y;
  end XLogXNeg;

  model Arcsin
    extends Sweep;
  equation
    asin(x) = y;
  end Arcsin;
  
  model BrentWithBracketingFailure
    Real y(min=0, start=1), z(min=1, start=1e4, nominal=1e4);
    Real x(max = 0, nominal=1.0);
    parameter Real y0=160000;
  equation
    y^2+z^2=y0;
    abs(y)-abs(z)=-sqrt(y0);
    exp(x)= 1+abs(abs(z)-sqrt(y0));
  end BrentWithBracketingFailure;
  
   model NegativeNominal
	Real x(start = 0);
    Real y(start=1, nominal=-1);
    parameter Real a=2;
  equation
	if x > -1 then
		x = -10;
	else
		x = -11;
	end if;
    y^2+a^2=10;
  end NegativeNominal;
    
  model Bounds
    Real x(start=1.2, min=1, max=2);
  equation
    sin(x)^2=0.5;
  end Bounds;
end TestBrent;
