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
package LibraryTests

model LibraryTest1
        extends TestLib.M;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="LibraryTest1",
            description="Test compiling with a custom library",
            modelicaLibraries="TestLib",
            flatModel="
fclass LibraryTests.LibraryTest1
 Real x;
equation
 x = time;
end LibraryTests.LibraryTest1;
")})));
end LibraryTest1;

model LibraryTest2
        extends TestLib.Sub.M;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="LibraryTest2",
            description="Test compiling with a custom library",
            modelicaLibraries="TestLib",
            flatModel="
fclass LibraryTests.LibraryTest2
 Real x;
equation
 x = time;
end LibraryTests.LibraryTest2;
")})));
end LibraryTest2;

model LibraryTest3
        extends EmptyLib.M;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="LibraryTest3",
            description="Empty top level package file",
            modelicaLibraries="EmptyLib",
            errorMessage="
2 errors found:

Error in file 'Compiler/ModelicaCompiler/test/modelica/EmptyLib/package.mo', LIBRARY_FILE_CONTENTS:
  Class 'EmptyLib' must be alone at top level of library file, but the file was empty.

Error at line 2, column 26, in file 'Compiler/ModelicaCompiler/test/modelica/LibraryTests.mo':
  Cannot find class declaration for M
")})));
end LibraryTest3;


model LibraryTest4
    extends WrongContent.A1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="LibraryTest4",
            description="Several classes in library file",
            modelicaLibraries="WrongContent",
            errorMessage="
1 errors found:

Error at line 16, column 1, in file 'Compiler/ModelicaCompiler/test/modelica/WrongContent/A1.mo', LIBRARY_FILE_CONTENTS:
  Class 'A1' must be alone at top level of library file, but the file also contains 'A2', 'A3' and 'A4'.
")})));
end LibraryTest4;


model LibraryTest5
    extends WrongContent.B1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="LibraryTest5",
            description="Several classes in library file",
            modelicaLibraries="WrongContent",
            errorMessage="
1 errors found:

Error at line 16, column 1, in file 'Compiler/ModelicaCompiler/test/modelica/WrongContent/B1.mo', LIBRARY_FILE_CONTENTS:
  Class 'B1' must be alone at top level of library file, but the file contains 2 classes of that name, and also 'B2', 'B3' and 'B4'.
")})));
end LibraryTest5;


model LibraryTest6
    extends WrongContent.C1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="LibraryTest6",
            description="Several classes in library file",
            modelicaLibraries="WrongContent",
            errorMessage="
1 errors found:

Error at line 16, column 1, in file 'Compiler/ModelicaCompiler/test/modelica/WrongContent/C1.mo', LIBRARY_FILE_CONTENTS:
  Class 'C1' must be alone at top level of library file, but the file contains 'C2', 'C3' and 'C4' instead.
")})));
end LibraryTest6;


model LibraryTest7
    extends WrongContent.D1;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="LibraryTest7",
            description="Several classes in library file",
            modelicaLibraries="WrongContent",
            errorMessage="
1 errors found:

Error at line 16, column 1, in file 'Compiler/ModelicaCompiler/test/modelica/WrongContent/D1.mo', LIBRARY_FILE_CONTENTS:
  Class 'D1' must be alone at top level of library file, but the file contains 2 classes of that name.
")})));
end LibraryTest7;


model LibraryTest8
    extends WrongContent.Ee;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="LibraryTest8",
            description="File name and class differ only in case",
            modelicaLibraries="WrongContent",
            errorMessage="
1 warnings found:

Warning at line 16, column 1, in file 'Compiler/ModelicaCompiler/test/modelica/WrongContent/EE.mo', LIBRARY_FILE_CONTENTS:
  Class 'EE' must be alone at top level of library file, but the file contains 'Ee' instead.
")})));
end LibraryTest8;


model LibraryTest9
    extends WrongContent.EE;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="LibraryTest9",
            description="File name and class differ only in case",
            modelicaLibraries="WrongContent",
            errorMessage="
1 errors and 1 warnings found:

Error at line 2, column 26, in file 'Compiler/ModelicaCompiler/test/modelica/LibraryTests.mo':
  Cannot find class declaration for EE

Warning at line 16, column 1, in file 'Compiler/ModelicaCompiler/test/modelica/WrongContent/EE.mo', LIBRARY_FILE_CONTENTS:
  Class 'EE' must be alone at top level of library file, but the file contains 'Ee' instead.
")})));
end LibraryTest9;

end LibraryTests;
