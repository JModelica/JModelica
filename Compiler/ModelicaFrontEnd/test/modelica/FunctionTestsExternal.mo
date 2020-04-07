/*
    Copyright (C) 2009-2017 Modelon AB

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


package FunctionTestsExternal

model ExternalFuncEmpty1
 function f
 external;
 end f;
equation
 f();

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFuncEmpty1",
            description="External functions: No IO",
            flatModel="
fclass FunctionTestsExternal.ExternalFuncEmpty1
equation
 FunctionTestsExternal.ExternalFuncEmpty1.f();

public
 function FunctionTestsExternal.ExternalFuncEmpty1.f
 algorithm
  external \"C\" f();
  return;
 end FunctionTestsExternal.ExternalFuncEmpty1.f;

end FunctionTestsExternal.ExternalFuncEmpty1;
")})));
end ExternalFuncEmpty1;

model ExternalFunc1
 function f
  input Real x;
  output Real y;
 external;
 end f;
 
 Real x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc1",
            description="External functions: simple func, all default",
            variability_propagation=false,
            flatModel="
fclass FunctionTestsExternal.ExternalFunc1
 Real x = FunctionTestsExternal.ExternalFunc1.f(2);

public
 function FunctionTestsExternal.ExternalFunc1.f
  input Real x;
  output Real y;
 algorithm
  external \"C\" y = f(x);
  return;
 end FunctionTestsExternal.ExternalFunc1.f;

end FunctionTestsExternal.ExternalFunc1;
")})));
end ExternalFunc1;


model ExternalFunc2
 function f
  input Real x[:,2];
  input Real y;
  output Real z;
  output Real q;
  protected Real a = y + 2;
 external;
 end f;
 
 Real x = f({{1,2},{3,4}}, 5);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc2",
            description="External functions: complex func, all default",
            variability_propagation=false,
            flatModel="
fclass FunctionTestsExternal.ExternalFunc2
 Real x = FunctionTestsExternal.ExternalFunc2.f({{1, 2}, {3, 4}}, 5);

public
 function FunctionTestsExternal.ExternalFunc2.f
  input Real[:,:] x;
  input Real y;
  output Real z;
  output Real q;
  Real a;
 algorithm
  assert(2 == size(x, 2), \"Mismatching sizes in function 'FunctionTestsExternal.ExternalFunc2.f', component 'x', dimension '2'\");
  a := y + 2;
  external \"C\" f(x, size(x, 1), size(x, 2), y, z, q, a);
  return;
 end FunctionTestsExternal.ExternalFunc2.f;

end FunctionTestsExternal.ExternalFunc2;
")})));
end ExternalFunc2;


model ExternalFunc3
 function f
  input Real x[:,2];
  input Real y;
  output Real z;
  output Real q;
 external foo(size(x,1), 2, x, z, y, q);
 end f;
 
 Real x = f({{1,2},{3,4}}, 5);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc3",
            description="External functions: complex func, call set",
            variability_propagation=false,
            flatModel="
fclass FunctionTestsExternal.ExternalFunc3
 Real x = FunctionTestsExternal.ExternalFunc3.f({{1, 2}, {3, 4}}, 5);

public
 function FunctionTestsExternal.ExternalFunc3.f
  input Real[:,:] x;
  input Real y;
  output Real z;
  output Real q;
 algorithm
  assert(2 == size(x, 2), \"Mismatching sizes in function 'FunctionTestsExternal.ExternalFunc3.f', component 'x', dimension '2'\");
  external \"C\" foo(size(x, 1), 2, x, z, y, q);
  return;
 end FunctionTestsExternal.ExternalFunc3.f;

end FunctionTestsExternal.ExternalFunc3;
")})));
end ExternalFunc3;


model ExternalFunc4
 function f
  input Real x[:,2];
  input Real y;
  output Real z;
  output Real q;
 external q = foo(size(x,1), 2, x, z, y);
 end f;
 
 Real x = f({{1,2},{3,4}}, 5);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc4",
            description="External functions: complex func, call and return set",
            variability_propagation=false,
            flatModel="
fclass FunctionTestsExternal.ExternalFunc4
 Real x = FunctionTestsExternal.ExternalFunc4.f({{1, 2}, {3, 4}}, 5);

public
 function FunctionTestsExternal.ExternalFunc4.f
  input Real[:,:] x;
  input Real y;
  output Real z;
  output Real q;
 algorithm
  assert(2 == size(x, 2), \"Mismatching sizes in function 'FunctionTestsExternal.ExternalFunc4.f', component 'x', dimension '2'\");
  external \"C\" q = foo(size(x, 1), 2, x, z, y);
  return;
 end FunctionTestsExternal.ExternalFunc4.f;

end FunctionTestsExternal.ExternalFunc4;
")})));
end ExternalFunc4;


model ExternalFunc5
 function f
  input Real x;
  output Real y;
 external "C";
 end f;
 
 Real x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc5",
            description="External functions: simple func, language \"C\"",
            variability_propagation=false,
            flatModel="
fclass FunctionTestsExternal.ExternalFunc5
 Real x = FunctionTestsExternal.ExternalFunc5.f(2);

public
 function FunctionTestsExternal.ExternalFunc5.f
  input Real x;
  output Real y;
 algorithm
  external \"C\" y = f(x);
  return;
 end FunctionTestsExternal.ExternalFunc5.f;

end FunctionTestsExternal.ExternalFunc5;
")})));
end ExternalFunc5;


model ExternalFunc6
 function f
  input Real x;
  output Real y;
 external "FORTRAN 77";
 end f;
 
 Real x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="ExternalFunc6",
            description="External functions: simple func, language \"FORTRAN 77\"",
            variability_propagation=false,
            flatModel="
fclass FunctionTestsExternal.ExternalFunc6
 Real x = FunctionTestsExternal.ExternalFunc6.f(2);

public
 function FunctionTestsExternal.ExternalFunc6.f
  input Real x;
  output Real y;
 algorithm
  external \"FORTRAN 77\" y = f(x);
  return;
 end FunctionTestsExternal.ExternalFunc6.f;

end FunctionTestsExternal.ExternalFunc6;
")})));
end ExternalFunc6;


model ExternalFunc7
 function f
  input Real x;
  output Real y;
 external "C++";
 end f;
 
 Real x = f(2);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExternalFunc7",
            description="External functions: simple func, language \"C++\"",
            variability_propagation=false,
            errorMessage="
2 errors found:

Error at line 2, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTestsExternal.mo':
  The external language specification \"C++\" is not supported

Error at line 5, column 2, in file 'Compiler/ModelicaFrontEnd/test/modelica/FunctionTestsExternal.mo':
  The external language specification \"C++\" is not supported
")})));
end ExternalFunc7;



model ExternalFuncLibs1
 function f1
  input Real x;
  output Real y;
 external annotation(Library="foo");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Library="bar");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Library={"bar", "m"});
 end f3;
 
 function f4
  input Real x;
  output Real y;
 external;
 end f4;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
 Real x4 = f4(4);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs1",
            description="External function annotations, Library",
            variability_propagation=false,
            methodName="externalLibraries",
            methodResult="[foo, bar, m]"
 )})));
end ExternalFuncLibs1;


model ExternalFuncLibs2
 function f1
  input Real x;
  output Real y;
 external annotation(Include="#include \"foo.h\"");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Include="#include \"foo.h\"");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"");
 end f3;
 
 function f4
  input Real x;
  output Real y;
 external;
 end f4;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
 Real x4 = f4(4);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs2",
            description="External function annotations, Include",
            variability_propagation=false,
            methodName="externalIncludes",
            methodResult="[#include \"foo.h\", #include \"bar.h\"]"
 )})));
end ExternalFuncLibs2;


model ExternalFuncLibs3
 function f1
  input Real x;
  output Real y;
 external annotation(LibraryDirectory="file:///c:/foo/lib");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external;
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Library="bar", 
                     LibraryDirectory="file:///c:/bar/lib");
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs3",
            description="External function annotations, LibraryDirectory",
            variability_propagation=false,
            methodName="externalLibraryDirectories",
            methodResult="[/c:/foo/lib, /c:/bar/lib]"
 )})));
end ExternalFuncLibs3;


model ExternalFuncLibs4
 function f1
  input Real x;
  output Real y;
 external annotation(Library="foo");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Library="bar");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external;
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs4",
            description="External function annotations, LibraryDirectory",
            variability_propagation=false,
            methodName="externalLibraryDirectories",
            filter=true,
            methodResult="
[%dir%/Resources/Library]"
 )})));
end ExternalFuncLibs4;


model ExternalFuncLibs5
 function f1
  input Real x;
  output Real y;
 external annotation(IncludeDirectory="file:///c:/foo/inc");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"", 
                     IncludeDirectory="file:///c:/bar/inc");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external;
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs5",
            description="External function annotations, IncludeDirectory",
            variability_propagation=false,
            methodName="externalIncludeDirectories",
            filter=true,
            methodResult="[/c:/foo/inc, /c:/bar/inc]"
 )})));
end ExternalFuncLibs5;


model ExternalFuncLibs6
 function f1
  input Real x;
  output Real y;
 external annotation(Include="#include \"foo.h\"");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external;
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs6",
            description="External function annotations, IncludeDirectory",
            variability_propagation=false,
            methodName="externalIncludeDirectories",
            filter=true,
            methodResult="
[%dir%/Resources/Include]"
 )})));
end ExternalFuncLibs6;


model ExternalFuncLibs7
 function f1
  input Real x;
  output Real y;
 external annotation(LibraryDirectory="file:///c:/std/lib", 
                     IncludeDirectory="file:///c:/std/inc");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Library="foo",
                     LibraryDirectory="file:///c:/foo/lib",  
                     Include="#include \"foo.h\"", 
                     IncludeDirectory="file:///c:/foo/inc");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"", 
                     IncludeDirectory="file:///c:/bar/inc", 
                     Library="bar", 
                     LibraryDirectory="file:///c:/bar/lib");
 end f3;
 
 function f4
  input Real x;
  output Real y;
 external;
 end f4;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
 Real x4 = f4(4);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs7",
            description="External function annotations, compiler args",
            variability_propagation=false,
            methodName="externalCompilerArgs",
            methodResult=" -lfoo -lbar -L/c:/std/lib -L/c:/foo/lib -L/c:/bar/lib -I/c:/std/inc -I/c:/foo/inc -I/c:/bar/inc"
 )})));
end ExternalFuncLibs7;

model ExternalFuncLibs8
 function f
  input Real x;
  output Real y;
 external annotation(Library="foo", 
                     Include="#include \"foo.h\"");
 end f;
 
 Real x = f(1);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs8",
            description="External function annotations, compiler args",
            variability_propagation=false,
            methodName="externalCompilerArgs",
            filter=true,
            methodResult=" -lfoo -L%dir%/Resources/Library -I%dir%/Resources/Include"
 )})));
end ExternalFuncLibs8;

model ExternalFuncLibs9
 constant String LIBS[:] = { "foo", "bar", "m" };
 
 function f1
  input Real x;
  output Real y;
 external annotation(Library=LIBS[1]);
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Library=LIBS[2]);
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Library=LIBS[2:3]);
 end f3;
 
 function f4
  input Real x;
  output Real y;
 external;
 end f4;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
 Real x4 = f4(4);

    annotation(__JModelica(UnitTesting(tests={
        FClassMethodTestCase(
            name="ExternalFuncLibs9",
            description="External function annotations, Library, using constants",
            variability_propagation=false,
            methodName="externalLibraries",
            methodResult="[foo, bar, m]"
 )})));
end ExternalFuncLibs9;

model InvalidAnnotation1
 function f
  input Real x;
  output Real y;
 external annotation(IncludeDirectory=true, LibraryDirectory={"string"});
 end f;
 
 Real x = f(1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InvalidAnnotation1",
            description="External function annotations, invalid annotation",
            errorMessage="
Error at line 5, column 2, in file '...', EXTERNAL_DIRECTORY_ANNOTATION_TYPE:
  IncludeDirectory annotation only allows scalar string values

Error at line 5, column 2, in file '...', EXTERNAL_DIRECTORY_ANNOTATION_TYPE:
  LibraryDirectory annotation only allows scalar string values
")})));
end InvalidAnnotation1;

model InvalidURI1
 function f
  input Real x;
  output Real y;
 external annotation(IncludeDirectory="]modelica://NoSuchPackage/",
                     LibraryDirectory="]modelica://NoSuchPackage/");
 end f;
 
 Real x = f(1);

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InvalidURI1",
            description="External function annotations, missing modelica package",
            errorMessage="
Error at line 5, column 2, in file '...', EXTERNAL_DIRECTORY_ANNOTATION:
  IncludeDirectory annotation could not be resolved
  Illegal character in scheme name at index 0: ]modelica://NoSuchPackage/

Error at line 5, column 2, in file '...', EXTERNAL_DIRECTORY_ANNOTATION:
  LibraryDirectory annotation could not be resolved
  Illegal character in scheme name at index 0: ]modelica://NoSuchPackage/
")})));
end InvalidURI1;

end FunctionTestsExternal;
