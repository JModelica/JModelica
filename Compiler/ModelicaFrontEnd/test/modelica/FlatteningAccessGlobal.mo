/*
  Copyright (C) 2019 Modelon AB

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

within;

package FlatteningAccessGlobal


model InSubscripts1
    package P
        constant Integer[:] is = {1,2,3};
    end P;
    
    function f
        input Real[:] x;
        input Integer i;
        output Real y = x[P.is[i]];
    algorithm
    end f;

    Real y = f({1,2,3}, 2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="InSubscripts1",
            description="",
            flatModel="
fclass FlatteningAccessGlobal.InSubscripts1
 Real y = FlatteningAccessGlobal.InSubscripts1.f({1, 2, 3}, 2);
global variables
 constant Integer FlatteningAccessGlobal.InSubscripts1.P.is[3] = {1, 2, 3};

public
 function FlatteningAccessGlobal.InSubscripts1.f
  input Real[:] x;
  input Integer i;
  output Real y;
 algorithm
  y := x[global(FlatteningAccessGlobal.InSubscripts1.P.is[i])];
  return;
 end FlatteningAccessGlobal.InSubscripts1.f;

end FlatteningAccessGlobal.InSubscripts1;
")})));
end InSubscripts1;

model CompositeAccessArray1
    package P
        constant Integer[:] is = {1,2,3};
    end P;
    
    function f
        output Real[:] y = P.is;
    algorithm
    end f;

    Real[:] y = f();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="CompositeAccessArray1",
            description="Composite constants in functions should be flattened as global variables and uses not folded",
            flatModel="
fclass FlatteningAccessGlobal.CompositeAccessArray1
 Real y[3] = FlatteningAccessGlobal.CompositeAccessArray1.f();
global variables
 constant Integer FlatteningAccessGlobal.CompositeAccessArray1.P.is[3] = {1, 2, 3};

public
 function FlatteningAccessGlobal.CompositeAccessArray1.f
  output Real[:] y;
 algorithm
  init y as Real[3];
  y := global(FlatteningAccessGlobal.CompositeAccessArray1.P.is[1:3]);
  return;
 end FlatteningAccessGlobal.CompositeAccessArray1.f;

end FlatteningAccessGlobal.CompositeAccessArray1;
")})));
end CompositeAccessArray1;

model CompositeAccessRecord1
    record R
        Real x;
    end R;

    package P
        constant R r(x=1);
    end P;
    
    function f
        output R r = P.r;
    algorithm
    end f;

    R y = f();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="CompositeAccessRecord1",
            description="Composite constants in functions should be flattened as global variables and uses not folded",
            flatModel="
fclass FlatteningAccessGlobal.CompositeAccessRecord1
 FlatteningAccessGlobal.CompositeAccessRecord1.R y = FlatteningAccessGlobal.CompositeAccessRecord1.f();
global variables
 constant FlatteningAccessGlobal.CompositeAccessRecord1.R FlatteningAccessGlobal.CompositeAccessRecord1.P.r = FlatteningAccessGlobal.CompositeAccessRecord1.R(1);

public
 function FlatteningAccessGlobal.CompositeAccessRecord1.f
  output FlatteningAccessGlobal.CompositeAccessRecord1.R r;
 algorithm
  r := global(FlatteningAccessGlobal.CompositeAccessRecord1.P.r);
  return;
 end FlatteningAccessGlobal.CompositeAccessRecord1.f;

 record FlatteningAccessGlobal.CompositeAccessRecord1.R
  Real x;
 end FlatteningAccessGlobal.CompositeAccessRecord1.R;

end FlatteningAccessGlobal.CompositeAccessRecord1;
")})));
end CompositeAccessRecord1;


end FlatteningAccessGlobal;