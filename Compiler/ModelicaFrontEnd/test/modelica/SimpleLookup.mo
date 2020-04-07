
/*
    Copyright (C) 2011-2013 Modelon AB

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
package SimpleLookup

model RelativeExtend
    model A
    end A;
    '!quoted!' a;
    
    package InnerExtends
        model B
        end B;
    end InnerExtends;
    package '!quoted!'
        model '.*symbol*.'
        end '.*symbol*.';
    end '!quoted!';
    
    model RelativeExtends
        extends A;
    end RelativeExtends;

    annotation(__JModelica(UnitTesting(tests={
        SourceMethodTestCase(
            name="RelativeExtend",
            description="Test the lookup of a components class",
            methodName=testFindMyClassDecl,
            arguments={"SimpleLookup.RelativeExtend"},
            methodResult="
'!quoted!' a : SimpleLookup.RelativeExtend.'!quoted!'
a : SimpleLookup.RelativeExtend.'!quoted!'
extends A : SimpleLookup.RelativeExtend.A
")})));
end RelativeExtend;

model Importing
    package 'dot.!quoted!'
        model Symbol
        end Symbol;
    end 'dot.!quoted!';
    
    model Unqualified
        import SimpleLookup.Importing.*;
        'dot.!quoted!'.Symbol symbol;
    end Unqualified;
    
    model Qualified
        import a = SimpleLookup.Importing;
        a.'dot.!quoted!'.Symbol symbol;
    end Qualified;
    
    annotation(__JModelica(UnitTesting(tests={
        SourceMethodTestCase(
            name="Importing",
            description="Verify that the import classes can be obtained unqualified or not.",
            methodName=testFindMyClassDecl,
            arguments={"SimpleLookup.Importing"},
            methodResult="
import SimpleLookup.Importing.*;
 : SimpleLookup.Importing
'dot.!quoted!'.Symbol symbol : SimpleLookup.Importing.'dot.!quoted!'.Symbol
symbol : SimpleLookup.Importing.'dot.!quoted!'.Symbol
import a = SimpleLookup.Importing;
 : SimpleLookup.Importing
a.'dot.!quoted!'.Symbol symbol : SimpleLookup.Importing.'dot.!quoted!'.Symbol
symbol : SimpleLookup.Importing.'dot.!quoted!'.Symbol

")})));
end Importing;

model DotQuotedExtend
    package 'dot.!quoted!'
        model 'symbol'
        end 'symbol';
    end 'dot.!quoted!';
    
    model DotQuotedExtends
        extends DotQuotedExtend.'dot.!quoted!'.'symbol';
    end DotQuotedExtends;
    annotation(__JModelica(UnitTesting(tests={
        SourceMethodTestCase(
            name="DotQuotedExtend",
            description="Test the lookup of extends class",
            methodName=testFindMyClassDecl,
            arguments={"SimpleLookup.DotQuotedExtend"},
            methodResult="
extends DotQuotedExtend.'dot.!quoted!'.'symbol' : SimpleLookup.DotQuotedExtend.'dot.!quoted!'.'symbol'
")})));
end DotQuotedExtend;

model ClassLookup
    model Extended
        extends WithComponent;
    end Extended;
    
    model Imported
       import SimpleLookup.ClassLookup.WithComponent.*; 
       model NoneImported
       end NoneImported;
    end Imported;
    
    package WithComponent
        '!quoted!' a;
        package '!quoted!'
            model '#//symbol%'
            end '#//symbol%';
        end '!quoted!';
    end WithComponent;
    
    annotation(__JModelica(UnitTesting(tests={
        SourceMethodTestCase(
            name="ClassLookup",
            description="Test the lookup of SimpleLookup of simple cases",
            methodName="testSimpleClassLookup",
            argumentTypes={"[Ljava.lang.String;"},
            arguments={{
                "SimpleLookup.ClassLookup", "SimpleLookup.ClassLookup",
                "SimpleLookup.ClassLookup", ".SimpleLookup.ClassLookup.Extended",
                "SimpleLookup.ClassLookup", "Extended",
                "SimpleLookup.ClassLookup.WithComponent", "'!quoted!'.'#//symbol%'",
                "SimpleLookup.ClassLookup.WithComponent.'!quoted!'",
                     ".SimpleLookup.ClassLookup.WithComponent.'!quoted!'",
                
                "SimpleLookup.ClassLookup.Extended", "'!quoted!'.'#//symbol%'",
                "SimpleLookup.ClassLookup.Imported", "'!quoted!'",
                "SimpleLookup.ClassLookup.Imported", "'!quoted!'.'#//symbol%'",
                "SimpleLookup.ClassLookup.Imported.NoneImported" , "'!quoted!'"
            }},
            methodResult="
SimpleLookup.ClassLookup
->
SimpleLookup.ClassLookup

SimpleLookup.ClassLookup
->
SimpleLookup.ClassLookup.Extended

SimpleLookup.ClassLookup
->
SimpleLookup.ClassLookup.Extended

SimpleLookup.ClassLookup.WithComponent
->
SimpleLookup.ClassLookup.WithComponent.'!quoted!'.'#//symbol%'

SimpleLookup.ClassLookup.WithComponent.'!quoted!'
->
SimpleLookup.ClassLookup.WithComponent.'!quoted!'

SimpleLookup.ClassLookup.Extended
->
SimpleLookup.ClassLookup.WithComponent.'!quoted!'.'#//symbol%'

SimpleLookup.ClassLookup.Imported
->
SimpleLookup.ClassLookup.WithComponent.'!quoted!'

SimpleLookup.ClassLookup.Imported
->
SimpleLookup.ClassLookup.WithComponent.'!quoted!'.'#//symbol%'

SimpleLookup.ClassLookup.Imported.NoneImported
->
SimpleLookup.ClassLookup.WithComponent.'!quoted!'


")})));
end ClassLookup;

model SurroundingLookup 
    model A
        model SurroundingTest
            annotation(__JModelica(UnitTesting(tests={
            SourceMethodTestCase(
                name="SurroundingTest",
                description="Check that lookup correctly looks in surrounding scopes",
                methodName="testSimpleClassLookup",
                argumentTypes={"[Ljava.lang.String;"},
                arguments={{"SimpleLookup.SurroundingLookup.A.SurroundingTest", "SimpleLookup.RelativeLookup", 
                            "SimpleLookup.SurroundingLookup.A.SurroundingTest", "A",
                            "SimpleLookup.SurroundingLookup.A.SurroundingTest", "SimpleLookup.SurroundingLookup",
                            "SimpleLookup.SurroundingLookup.A.SurroundingTest", "SurroundingLookup",
                            "SimpleLookup.SurroundingLookup.A.SurroundingTest", "ClassLookup"}
                },
                methodResult="
SimpleLookup.SurroundingLookup.A.SurroundingTest
->
SimpleLookup.RelativeLookup

SimpleLookup.SurroundingLookup.A.SurroundingTest
->
SimpleLookup.SurroundingLookup.A

SimpleLookup.SurroundingLookup.A.SurroundingTest
->
SimpleLookup.SurroundingLookup

SimpleLookup.SurroundingLookup.A.SurroundingTest
->
SimpleLookup.SurroundingLookup

SimpleLookup.SurroundingLookup.A.SurroundingTest
->
SimpleLookup.ClassLookup
        
        ")})));
        end SurroundingTest;
    end A;

end SurroundingLookup;

model EncapsulatedLookup 
    encapsulated model A
        model B
            model encapsulatedLookup
            annotation(__JModelica(UnitTesting(tests={
            SourceMethodTestCase(
                name="Encapsulated",
                description="Check that the lookup respects encapsulation",
                methodName="testSimpleClassLookup",
                argumentTypes={"[Ljava.lang.String;"},
                arguments={{"SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup", "EncapsulatedLookup",
                            "SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup", "A",
                            "SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup", "B",
                            "SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup", "SimpleLookup.EncapsulatedLookup.A.B",
                            "SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup", ".SimpleLookup.EncapsulatedLookup.A.B",
                            "SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup", "Real"
                            }
                },
                methodResult="
SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup
->
Unknown

SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup
->
Unknown

SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup
->
SimpleLookup.EncapsulatedLookup.A.B

SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup
->
Unknown

SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup
->
SimpleLookup.EncapsulatedLookup.A.B

SimpleLookup.EncapsulatedLookup.A.B.encapsulatedLookup
->
Real

        
            ")})));
            end encapsulatedLookup;
        end B;
    end A;

end EncapsulatedLookup;

model RelativeLookup
    model A 
        model B
        end B;
    end A;
    model C
        model D
        end D;
    end C;
        annotation(__JModelica(UnitTesting(tests={
        SourceMethodTestCase(
            name="Relative",
            description="External functions: simple func, all default",
            methodName="testSimpleClassLookup",
            argumentTypes={"[Ljava.lang.String;"},
            arguments={{"SimpleLookup.RelativeLookup", "A",
            "SimpleLookup.RelativeLookup.A", "RelativeLookup.C",
            "SimpleLookup.RelativeLookup.A", "C"}
            },
            methodResult="
SimpleLookup.RelativeLookup
->
SimpleLookup.RelativeLookup.A

SimpleLookup.RelativeLookup.A
->
SimpleLookup.RelativeLookup.C

SimpleLookup.RelativeLookup.A
->
SimpleLookup.RelativeLookup.C

")})));
end RelativeLookup; 


package FindConstant
    
    constant Real C = 1;
    
    package Constants
        constant Real[2] array = 1:2;
    end Constants;
    
    model TestFindConstant1
        Real a = C;
        annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="TestFindConstant1",
            description="Tests the method SrcAccess.resolveLookup",
            methodName="testSimpleLookup",
            arguments={"C"},
            methodResult="C=SimpleLookup.FindConstant.C"
        )})));
    end TestFindConstant1;
    
    model TestFindConstant2
        constant Real C = 1;
        Real a = C;
        annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="TestFindConstant2",
            description="Tests the method SrcAccess.resolveLookup",
            methodName="testSimpleLookup",
            arguments={"C"},
            methodResult="C=SimpleLookup.FindConstant.TestFindConstant2.C"
        )})));
    end TestFindConstant2;
    
    model TestFindConstant3
        extends TestFindConstant2;
        Real b = C;
        annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="TestFindConstant3",
            description="Tests the method SrcAccess.resolveLookup, inherited constant",
            methodName="testSimpleLookup",
            arguments={"C"},
            methodResult="C=SimpleLookup.FindConstant.TestFindConstant3.C"
        )})));
    end TestFindConstant3;
    
    model TestFindConstant4
        Real a;
    algorithm
        for C in 1:2 loop
            a := C;
        end for;
        annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="TestFindConstant4",
            description="Tests the method SrcAccess.resolveLookup, constant shadowed by loop variable",
            methodName="testSimpleLookup",
            arguments={"C"},
            methodResult="
                C=SimpleLookup.FindConstant.TestFindConstant4.C"
        )})));
    end TestFindConstant4;
    
    model TestFindConstant5
        constant Integer a = 1;
        Real b = Constants.array[a];
        annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="TestFindConstant5",
            description="Tests the method SrcAccess.resolveLookup, dot access with access in array subscripts",
            methodName="testSimpleLookup",
            arguments={"a, array"},
            methodResult="
                array=SimpleLookup.FindConstant.Constants.array
                a=SimpleLookup.FindConstant.TestFindConstant5.a"
        )})));
    end TestFindConstant5;
    
    model TestFindConstant6
        Real a = .SimpleLookup.FindConstant.C;
        annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="TestFindConstant6",
            description="Tests the method SrcAccess.resolveLookup, global access",
            methodName="testSimpleLookup",
            arguments={"C"},
            methodResult="C=SimpleLookup.FindConstant.C"
        )})));
    end TestFindConstant6;
    
    model TestFindConstant7
        extends TestFindConstant2(C = 2);
        annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="TestFindConstant7",
            description="Tests the method SrcAccess.resolveLookup, from extends",
            methodName="testSimpleLookup",
            arguments={"C"},
            methodResult="C=SimpleLookup.FindConstant.TestFindConstant7.C"
        )})));
    end TestFindConstant7;
    
    encapsulated package EncapulatedPackage
        
        model TestFindConstantEncapsulated
            Real a = C;
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="TestFindConstantEncapsulated",
                description="Tests the method SrcAccess.resolveLookup, constant outside encapsulation",
                methodName="testSimpleLookup",
                arguments={"C"},
                methodResult="C=Unknown"
            )})));
        end TestFindConstantEncapsulated;
        
        model TestFindConstantQualifiedImport
            import SimpleLookup.FindConstant.C;
            Real a = C;
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="TestFindConstantQualifiedImport",
                description="Tests the method SrcAccess.resolveLookup, imported constant",
                methodName="testSimpleLookup",
                arguments={"C"},
                methodResult="
                    C=SimpleLookup.FindConstant.C
                    C=SimpleLookup.FindConstant.C
                ")})));
        end TestFindConstantQualifiedImport;
        
        model TestFindConstantUnqualifiedImport
            import SimpleLookup.FindConstant.*;
            Real a = C;
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="TestFindConstantUnqualifiedImport",
                description="Tests the method SrcAccess.resolveLookup, imported constant",
                methodName="testSimpleLookup",
                arguments={"C"},
                methodResult="C=SimpleLookup.FindConstant.C"
            )})));
        end TestFindConstantUnqualifiedImport;
        
    end EncapulatedPackage;
    
    package HasConstant
        constant Integer C = 1;
        model HasParameter
            parameter Integer C;
            
            model LookupConstant
                Real x = C;
            annotation(__JModelica(UnitTesting(tests={InstClassMethodTestCase(
                name="LookupConstant",
                description="Tests that lookup does not skip non constant components in enclosing classes",
                methodName="testSimpleLookup",
                arguments={"C"},
                methodResult="C=SimpleLookup.FindConstant.HasConstant.HasParameter.C"
            )})));
            end LookupConstant;
        end HasParameter;
    end HasConstant;
    
end FindConstant;

package TestLookupInModifications
    model Test1
        Real x(start = 1);
    annotation(__JModelica(UnitTesting(tests={InstClassMethodTestCase(
        name="TestLookupInModifications.Test1",
        description="TODO",
        methodName="testSimpleLookup",
        arguments={"start"},
        methodResult="start=SimpleLookup.TestLookupInModifications.Test1.x.start"
    )})));
    end Test1;

    model Test2
        model A
            Real x = 0;
        end A;
        
        A a(x = 1);
    annotation(__JModelica(UnitTesting(tests={InstClassMethodTestCase(
        name="TestLookupInModifications.Test2",
        description="TODO",
        methodName="testSimpleLookup",
        arguments={"x"},
        methodResult="x=SimpleLookup.TestLookupInModifications.Test2.a.x"
    )})));
    end Test2;

    model Test3
        model A
            Real x = 0;
        end A;
        
        Real x = 2;
        A a(x = 1);
    annotation(__JModelica(UnitTesting(tests={InstClassMethodTestCase(
        name="TestLookupInModifications.Test3",
        description="TODO",
        methodName="testSimpleLookup",
        arguments={"x"},
        methodResult="x=SimpleLookup.TestLookupInModifications.Test3.a.x"
    )})));
    end Test3;

end TestLookupInModifications;

end SimpleLookup;
