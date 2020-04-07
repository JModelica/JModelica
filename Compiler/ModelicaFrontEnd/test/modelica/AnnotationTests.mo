/*
  Copyright (C) 2009-2013 Modelon AB

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

package AnnotationTests


model ShortClassConstrainedBy1
    model A end A;
    model B extends A; end B;
    replaceable model C = B annotation(a = b) constrainedby A "A";

    annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="ShortClassConstrainedBy1",
            description="Tests annotations on replaceable constrainedby declarations.",
            methodName="printClassAnnotations",
            arguments={""},
            methodResult="
(a = b)
")})));
end ShortClassConstrainedBy1;

model ShortClassConstrainedBy2
    model A end A;
    model B extends A; end B;
    replaceable model C = B constrainedby A "A" annotation(a = b);

    annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="ShortClassConstrainedBy2",
            description="Tests annotations on replaceable constrainedby declarations.",
            methodName="printClassAnnotations",
            arguments={""},
            methodResult="
(a = b)
")})));
end ShortClassConstrainedBy2;

model ShortClassConstrainedBy3
    model A end A;
    model B extends A; end B;
    replaceable model C = B annotation(a = b) constrainedby A "A" annotation(b = c);

    annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="ShortClassConstrainedBy3",
            description="Tests annotations on replaceable constrainedby declarations.",
            methodName="printClassAnnotations",
            arguments={""},
            methodResult="
(a = b, b = c)
")})));
end ShortClassConstrainedBy3;

model ComponentConstrainedByOnlyNormal
    model A
    end A;
    replaceable A a annotation(a = b) constrainedby A;
    annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="ComponentConstrainedByOnlyNormal",
            description="Tests annotations on replaceable constrainedby declarations.",
            methodName="printComponentAnnotations",
            methodResult="
(a = b)
")})));
end ComponentConstrainedByOnlyNormal;
model ComponentConstrainedByOnlyConstrained
    model A
    end A;
    replaceable A a constrainedby A annotation(a = b);
    annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="ComponentConstrainedByOnlyConstrained",
            description="Tests annotations on replaceable constrainedby declarations.",
            methodName="printComponentAnnotations",
            methodResult="
(a = b)
")})));
end ComponentConstrainedByOnlyConstrained;
model ComponentConstrainedByBoth
    model A
    end A;
    replaceable A a annotation(a = b) constrainedby A annotation(b = c);
    annotation(__JModelica(UnitTesting(tests={
        InstClassMethodTestCase(
            name="ComponentConstrainedByBoth",
            description="Tests annotations on replaceable constrainedby declarations.",
            methodName="printComponentAnnotations",
            methodResult="
(a = b, b = c)
")})));
end ComponentConstrainedByBoth;

package inheritance
    package classes 
        package BaseNoAnnotation
        end BaseNoAnnotation;

        model ModelNoAnnotation
        end ModelNoAnnotation;
        
        model FunctionTest
        	replaceable function BaseFunction
        		input Real i;
        		input Real k;
        		output Real o;
        	algorithm
            	o := i + k + 20;
            	annotation(Inline=true, X="A");
        	end BaseFunction;
        end FunctionTest;
        
        model ExtendedFunction
        	extends FunctionTest(redeclare function BaseFunction = BaseFunction(i=200)); 
                annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendedFunction",
                description="Check that the annotation is from the replaceable.",
                methodName="testElementAnnotations",
                arguments={"BaseFunction"},
                methodResult="
    ")})));        	
        end ExtendedFunction;
        
        model ReplacedFunction
        	extends FunctionTest(redeclare function BaseFunction = BaseFunction(i=200) annotation(Inline=false, X="B")); 
                annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="replacedFunction",
                description="Check that the annotation is from the replaceable.",
                methodName="testElementAnnotations",
                arguments={"BaseFunction"},
                methodResult="
Inline=false
    ")})));             	
        end ReplacedFunction;
        
        model BaseWithAnnotation
            replaceable package testPackage = BaseNoAnnotation annotation(Dialog(tab="a", group="b"));
            replaceable BaseNoAnnotation testComponent() annotation(Dialog(tab="ac", group="b")); 
                annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="instAnnotationFromRedeclare",
                description="Check that the annotation is from the replaceable.",
                methodName="testElementAnnotations",
                arguments={"testPackage"},
                methodResult="
    Dialog(tab = \"a\", group = \"b\")
    ")})));
        end BaseWithAnnotation;
        
        model B
            extends BaseWithAnnotation;
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendedHaveAnnotation",
                description="Check that the annotation is inherited.",
                methodName="testElementAnnotations",
                arguments={"testPackage"},
                methodResult="
    Dialog(tab = \"a\", group = \"b\")
    ")})));
        end B;
        
        model C
            extends BaseWithAnnotation(
                redeclare replaceable package testPackage 
                    = BaseNoAnnotation annotation(Dialog(tab="c", group="new")), 
                redeclare replaceable BaseNoAnnotation testComponent() 
                    annotation(Dialog(tab="cc", group="new")));
                    
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="replacedInExtend",
                description="Check that the new annotation is used.",
                methodName="testElementAnnotations",	
                arguments={"testPackage"},
                methodResult="Dialog(tab = \"c\", group = \"new\")")})));
        end C;
        
        model C2
            extends C(redeclare replaceable BaseNoAnnotation testComponent(),
            		  redeclare replaceable package testPackage = BaseNoAnnotation);
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendNoRedeclare",
                description="Check that the inherited annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testPackage"},
                methodResult="Dialog(tab = \"c\", group = \"new\")")})));
        end C2;
        
        model A2
            package BaseAnnotation
                replaceable model TestModel = ModelNoAnnotation;
            end BaseAnnotation;
            BaseAnnotation.TestModel testModel;
        end A2;
        
        package BaseAnnotationAlt
                replaceable model TestModel = ModelNoAnnotation annotation(Dialog(group="altPackage"));
            end BaseAnnotationAlt;
        
        model AnnotationFromReplacedContainingPackage
            extends A2(redeclare replaceable package BaseAnnotation = BaseAnnotationAlt);
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="AnnotationFromReplacedContainingPackage",
                description="Check that the annotation from the alt class is used.",
                methodName="testElementAnnotations",
                arguments={"BaseAnnotation.TestModel"},
                methodResult="Dialog(group=\"altPackage\")")})));
        end AnnotationFromReplacedContainingPackage; 
        
        model C3
            extends C(
                        redeclare replaceable BaseNoAnnotation testComponent() annotation(),
                        redeclare replaceable package testPackage = BaseNoAnnotation annotation()
                     );
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendsEmptyReplace",
                description="Check that the empty annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testPackage"},
                methodResult="")})));
        end C3;
        
        model C4
            extends C(
                redeclare replaceable package testPackage 
                    = BaseNoAnnotation annotation(Dialog(tab="c4", group="extends")), 
                redeclare replaceable BaseNoAnnotation testComponent() 
                    annotation(Dialog(tab="cc4", group="extends"))
                    );
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendedReplacement",
                description="Check that the latest annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testPackage"},
                methodResult="Dialog(tab = \"c4\", group = \"extends\")")})));
        end C4;
            
        model C5
            extends C4;
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendExtendReplacement",
                description="Check that the latest annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testPackage"},
                methodResult="Dialog(tab = \"c4\", group = \"extends\")")})));
        end C5;
        
        model D
            extends BaseWithAnnotation(
                redeclare replaceable package testPackage = BaseNoAnnotation annotation());
            
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="emptyExtendReplace",
                description="Check that the latest annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testPackage"},
                methodResult="")})));
        end D;
        
        model D2
            extends D;
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendEmptyFromExtend",
                description="Check that the latest annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testPackage"},
                methodResult="")})));
        end D2;
        
        model E
            extends BaseWithAnnotation(
                redeclare replaceable package testPackage = BaseNoAnnotation
                );
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="noneReplacingRedeclaration",
                description="Check that the latest inherited annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testPackage"},
                methodResult="
    Dialog(tab = \"a\", group = \"b\")
    ")})));
        end E;
    
        model E2
            extends E;
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendNoneReplacingRedeclaration",
                description="Check that the latest inherited annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testPackage"},
                methodResult="
    Dialog(tab = \"a\", group = \"b\")
    ")})));
        end E2;
    end classes;
    
    package classesGetComponents
        package BaseNoAnnotation
        end BaseNoAnnotation;

        model ModelNoAnnotation
        end ModelNoAnnotation;
        
        model BaseWithAnnotation
            replaceable package testPackage = BaseNoAnnotation annotation(Dialog(tab="a", group="b"));
            replaceable BaseNoAnnotation testComponent() annotation(Dialog(tab="ac", group="b")); 
                annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="instAnnotationFromRedeclare",
                description="Check that the annotation is from the replaceable.",
                methodName="testElementAnnotations",
                arguments={"testComponent"},
                methodResult="
    Dialog(tab = \"ac\", group = \"b\")
    ")})));
        end BaseWithAnnotation;
        
        model B
            extends BaseWithAnnotation;
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendedHaveAnnotation",
                description="Check that the annotation is inherited.",
                methodName="testElementAnnotations",
                arguments={"testComponent"},
                methodResult="
    Dialog(tab = \"ac\", group = \"b\")
    ")})));
        end B;
        
        model C
            extends BaseWithAnnotation(
                redeclare replaceable package testPackage 
                    = BaseNoAnnotation annotation(Dialog(tab="c", group="new")), 
                redeclare replaceable BaseNoAnnotation testComponent() 
                    annotation(Dialog(tab="cc", group="new")));
                    
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="replacedInExtend",
                description="Check that the new annotation is used.",
                methodName="testElementAnnotations",	
                arguments={"testComponent"},
                methodResult="Dialog(tab = \"cc\", group = \"new\")")})));
        end C;
        
        model C2
            extends C(redeclare replaceable BaseNoAnnotation testComponent(),
            		  redeclare replaceable package testPackage = BaseNoAnnotation);
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendNoRedeclare",
                description="Check that the inherited annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testComponent"},
                methodResult="Dialog(tab = \"cc\", group = \"new\")")})));
        end C2;
        
        model A2
            package BaseAnnotation
                replaceable model TestModel = ModelNoAnnotation;
            end BaseAnnotation;
            BaseAnnotation.TestModel testModel;
        end A2;
        
        package BaseAnnotationAlt
                replaceable model TestModel = ModelNoAnnotation annotation(Dialog(group="altPackage"));
            end BaseAnnotationAlt;
        
        model AnnotationFromReplacedContainingPackage
            extends A2(redeclare replaceable package BaseAnnotation = BaseAnnotationAlt);
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="AnnotationFromReplacedContainingPackage",
                description="Check that the annotation from the alt class is used.",
                methodName="testElementAnnotations",
                arguments={"BaseAnnotation.TestModel"},
                methodResult="Dialog(group=\"altPackage\")")})));
        end AnnotationFromReplacedContainingPackage; 
        
        model C3
            extends C(
                        redeclare replaceable BaseNoAnnotation testComponent() annotation(),
                        redeclare replaceable package testPackage = BaseNoAnnotation annotation()
                     );
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendsEmptyReplace",
                description="Check that the empty annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testComponent"},
                methodResult="")})));
        end C3;
        
        model C4
            extends C(
                redeclare replaceable package testPackage 
                    = BaseNoAnnotation annotation(Dialog(tab="c4", group="extends")), 
                redeclare replaceable BaseNoAnnotation testComponent() 
                    annotation(Dialog(tab="cc4", group="extends"))
                    );
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendedReplacement",
                description="Check that the latest annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testComponent"},
                methodResult="Dialog(tab = \"cc4\", group = \"extends\")")})));
        end C4;
            
        model C5
            extends C4;
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendExtendReplacement",
                description="Check that the latest annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testComponent"},
                methodResult="Dialog(tab = \"cc4\", group = \"extends\")")})));
        end C5;
        
        model D
            extends BaseWithAnnotation(
                redeclare replaceable BaseNoAnnotation testComponent() annotation(),
                redeclare replaceable package testPackage = BaseNoAnnotation annotation());
            
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="emptyExtendReplace",
                description="Check that the latest annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testComponent"},
                methodResult="")})));
        end D;
        
        model D2
            extends D;
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendEmptyFromExtend",
                description="Check that the latest annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testComponent"},
                methodResult="")})));
        end D2;
        
        model E
            extends BaseWithAnnotation(
                redeclare replaceable package testPackage = BaseNoAnnotation, 
                redeclare replaceable BaseNoAnnotation testComponent()
                );
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="noneReplacingRedeclaration",
                description="Check that the latest inherited annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testComponent"},
                methodResult="
    Dialog(tab = \"ac\", group = \"b\")
    ")})));
        end E;
    
        model E2
            extends E;
            annotation(__JModelica(UnitTesting(tests={
            InstClassMethodTestCase(
                name="extendNoneReplacingRedeclaration",
                description="Check that the latest inherited annotation is used.",
                methodName="testElementAnnotations",
                arguments={"testComponent"},
                methodResult="
    Dialog(tab = \"ac\", group = \"b\")
    ")})));
        end E2;    
    end classesGetComponents; 
    
    package components
        import AnnotationTests.inheritance.classes.*;
        model redeclaredWithAnnotationInExtends
            C redeclaredWithAnnotationInExtends;
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredClassWithAnnotationInExtends",
                    description="Annotation from Extends for class inside component.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredWithAnnotationInExtends.testPackage"},
                    methodResult="
        Dialog(tab = \"c\", group = \"new\")
        ")})));  
        end  redeclaredWithAnnotationInExtends;
        
        model redeclaredWithNoAnnotationInExtends
            C2 redeclaredWithNoAnnotationInExtends;
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredClassWithNoAnnotationInExtends",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredWithNoAnnotationInExtends.testPackage"},
                    methodResult="
        Dialog(tab = \"c\", group = \"new\")
        ")})));  
        end redeclaredWithNoAnnotationInExtends;
        
        model redeclaredWithEmptyAnnotationInExtends
            C3 redeclaredWithEmptyAnnotationInExtends;
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredClassWithEmptyAnnotationInExtends",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredWithEmptyAnnotationInExtends.testPackage"},
                    methodResult="

        ")})));              
        end redeclaredWithEmptyAnnotationInExtends;
        
        model redeclaredInOwnAndAncestorsExtends
            C4 redeclaredInOwnAndAncestorsExtends;
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredClassInOwnAndAncestorsExtends",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredInOwnAndAncestorsExtends.testPackage"},
                    methodResult="
        Dialog(tab = \"c4\", group = \"extends\")
        ")})));              
        end redeclaredInOwnAndAncestorsExtends;
        
        model redeclaredInParentExtends
            C5 redeclaredInParentExtends;
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredClassInParentExtends",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredInParentExtends.testPackage"},
                    methodResult="
        Dialog(tab = \"c4\", group = \"extends\")
        ")})));  
        end redeclaredInParentExtends;
        
        model redeclaredInDeclarationNoAnnotation
            C5 redeclaredInDeclarationNoAnnotation(
                    redeclare replaceable package testPackage = BaseNoAnnotation,
                    redeclare replaceable BaseNoAnnotation testComponent());
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredClassInDeclarationNoAnnotation",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredInDeclarationNoAnnotation.testPackage"},
                    methodResult="
        Dialog(tab=\"c4\", group=\"extends\")
        ")})));                  
        end redeclaredInDeclarationNoAnnotation;
        
        model redeclaredInDeclarationWithEmptyAnnotation
            C5 redeclaredInDeclarationWithEmptyAnnotation(
                    redeclare replaceable package testPackage = BaseNoAnnotation annotation(),
                    redeclare replaceable BaseNoAnnotation testComponent() annotation());
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredClassInDeclarationWithEmptyAnnotation",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredInDeclarationWithEmptyAnnotation.testPackage"},
                    methodResult="

        ")})));            
        end redeclaredInDeclarationWithEmptyAnnotation;
        
        model redeclaredInDeclaration
            C5  redeclaredInDeclaration(
                    redeclare replaceable package testPackage = BaseNoAnnotation
                        annotation(Dialog(tab="redeclaredInDeclaration", group="extends")),
                    redeclare replaceable BaseNoAnnotation testComponent()
                        annotation(Dialog(tab="redeclaredInDeclaration", group="component"))
                    );
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredClassInDeclaration",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredInDeclaration.testPackage"},
                    methodResult="
        Dialog(tab = \"redeclaredInDeclaration\", group = \"extends\")
        ")})));  
        end redeclaredInDeclaration;
         
    end components;
        
    package componentsGetComponents
        import AnnotationTests.inheritance.classes.*;
        model redeclaredWithAnnotationInExtends
            C redeclaredWithAnnotationInExtends;
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredWithAnnotationInExtends",
                    description="Annotation from Extends for component inner component.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredWithAnnotationInExtends.testComponent"},
                    methodResult="
        Dialog(tab = \"cc\", group = \"new\")
        ")})));  
        end  redeclaredWithAnnotationInExtends;
        
        model redeclaredWithNoAnnotationInExtends
            C2 redeclaredWithNoAnnotationInExtends;
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredWithNoAnnotationInExtends",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredWithNoAnnotationInExtends.testComponent"},
                    methodResult="
        Dialog(tab = \"cc\", group = \"new\")
        ")})));  
        end redeclaredWithNoAnnotationInExtends;
        
        model redeclaredWithEmptyAnnotationInExtends
            C3 redeclaredWithEmptyAnnotationInExtends;
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredWithEmptyAnnotationInExtends",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredWithEmptyAnnotationInExtends.testComponent"},
                    methodResult="

        ")})));              
        end redeclaredWithEmptyAnnotationInExtends;
        
        model redeclaredInOwnAndAncestorsExtends
            C4 redeclaredInOwnAndAncestorsExtends;
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredInOwnAndAncestorsExtends",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredInOwnAndAncestorsExtends.testComponent"},
                    methodResult="
        Dialog(tab = \"cc4\", group = \"extends\")
        ")})));              
        end redeclaredInOwnAndAncestorsExtends;
        
        model redeclaredInParentExtends
            C5 redeclaredInParentExtends;
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredInParentExtends",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredInParentExtends.testComponent"},
                    methodResult="
        Dialog(tab = \"cc4\", group = \"extends\")
        ")})));  
        end redeclaredInParentExtends;
        
        model redeclaredInDeclarationNoAnnotation
            C5 redeclaredInDeclarationNoAnnotation(
                    redeclare replaceable package testPackage = BaseNoAnnotation,
                    redeclare replaceable BaseNoAnnotation testComponent());
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredInDeclarationNoAnnotation",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredInDeclarationNoAnnotation.testComponent"},
                    methodResult="
        Dialog(tab=\"cc4\", group=\"extends\")
        ")})));                  
        end redeclaredInDeclarationNoAnnotation;
        
        model redeclaredInDeclarationWithEmptyAnnotation
            C5 redeclaredInDeclarationWithEmptyAnnotation(
                    redeclare replaceable package testPackage = BaseNoAnnotation annotation(),
                    redeclare replaceable BaseNoAnnotation testComponent() annotation());
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredInDeclarationWithEmptyAnnotation",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredInDeclarationWithEmptyAnnotation.testComponent"},
                    methodResult="

        ")})));            
        end redeclaredInDeclarationWithEmptyAnnotation;
        
        model redeclaredInDeclaration
            C5  redeclaredInDeclaration(
                    redeclare replaceable package testPackage = BaseNoAnnotation
                        annotation(Dialog(tab="redeclaredInDeclaration", group="extends")),
                    redeclare replaceable BaseNoAnnotation testComponent()
                        annotation(Dialog(tab="redeclaredInDeclaration", group="component"))
                    );
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="redeclaredInDeclaration",
                    description="Check that the components have correct annotation.",
                    methodName="testElementAnnotations",
                    arguments={"redeclaredInDeclaration.testComponent"},
                    methodResult="
        Dialog(tab = \"redeclaredInDeclaration\", group = \"component\")
        ")})));  
        end redeclaredInDeclaration;
        
        model ComponentNotAnnotationFromClassTest
            model ComponentAnnotTest
                annotation(Dialog(group="alt"));
            end ComponentAnnotTest;
            ComponentAnnotTest testComponent;
        end ComponentNotAnnotationFromClassTest;
        
       
        
        model componentNoAnnotationFromClass
            ComponentNotAnnotationFromClassTest componentNoAnnotationFromClass;
            annotation(__JModelica(UnitTesting(tests={
                InstClassMethodTestCase(
                    name="componentNoAnnotationFromClass",
                    description="Annotation from Extends for component inner component.",
                    methodName="testElementAnnotations",
                    arguments={"componentNoAnnotationFromClass.testComponent"},
                    methodResult="
        ")})));  
        end componentNoAnnotationFromClass;
    end componentsGetComponents;
end inheritance;

end AnnotationTests;