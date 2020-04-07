package ExtFunctionTests

model ExtFunctionTest1
 Real a(start=1) = 1;
 Real b(start=2) = 2;
 Real c(start=2);

equation
  c = add(a,b);

end ExtFunctionTest1;

function add
 input Real a;
 input Real b;
 output Real c;

 external "C" annotation(Library="addNumbers",
                         Include="#include \"addNumbers.h\"");
end add;

model ExtFunctionTest2
    
function extFunc1
    input Real m;
    input Real[:,:,:] a;
    input Integer[size(a,1),size(a,2),size(a,3)] b;
    input Boolean[size(a,1),size(a,2)] c;
    output Real sum;
    output Real[size(a,1),size(a,2),size(a,3)] o;
    output Real[size(a,1)*size(a,2)*size(a,3)] step;
    external "C" annotation(
        Library="arrayFunctions",
        Include="#include \"arrayFunctions.h\"");
end extFunc1;

Real[3,3,3] x;
Real s;
Real[27] step;

constant Real arg1 = 3.14;
constant Real[3,3,3] arg2 = {{{1e1,1e2,1e3},{1e4,1e5,1e6},{1e7,1e8,1e9}},{{1,1,1},{1,1,1},{1,1,1}},{{1e-1,1e-2,1e-3},{1e-4,1e-5,1e-6},{1e-7,1e-8,1e-9}}};
constant Integer[3,3,3] arg3 = {{{1,2,3},{4,5,6},{7,8,9}},{{11,12,13},{14,15,16},{17,18,19}},{{21,22,23},{24,25,26},{27,28,29}}};
constant Boolean[3,3] arg4 = {{true,true,true},{true, false, true},{false,true,false}};
equation
    (s,x,step) = extFunc1(arg1, arg2, arg3, arg4);

end ExtFunctionTest2;

model ExtFunctionBool
    
function copyBoolArray
    input Boolean[:] a;
    output Boolean[size(a,1)] b;
    external "C" annotation(
        Library="arrayFunctions",
        Include="#include \"arrayFunctions.h\"");
end copyBoolArray;

constant Boolean[8] arg = {true,true,true,false,true,false,false,true};
Boolean[8] res;
equation
    res = copyBoolArray(arg);
end ExtFunctionBool;

model ExtFunctionRecord
    record R
        Real x;
    end R;
    function fRecord
        input R r;
        output R y;
      external "C" fRecord(r,y) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
    end fRecord;
    R y = fRecord(R(time));
end ExtFunctionRecord;

model ExtFunctionRecordCeval
    record R
        Real x;
    end R;
    function fRecord
        input R r;
        output R y;
      external "C" fRecord(r,y) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
    end fRecord;
    constant R y1 = fRecord(R(3));
    R y2 = fRecord(R(3));
end ExtFunctionRecordCeval;

model ExtFunctionRecordObj
    record R1
        R2 r2;
    end R1;
    record R2
        Real x;
    end R2;
    
    model EO
        extends ExternalObject;
        function constructor
            input R1 r1;
            output EO eo;
            external "C" eo=eo_constructor_record(r1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end constructor;
        function destructor
            input EO eo;
            external "C" eo_destructor_record(eo) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end destructor;
    end EO;
    
    function f
        input EO eo;
        output Real y;
        external "C" y=eo_use_record(eo) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
    end f;
    
    parameter EO eo = EO(R1(R2(3)));
    parameter Real y = f(eo);
end ExtFunctionRecordObj;

model ExtFunctionRecordObjCeval
    extends ExtFunctionRecordObj;
    parameter Integer n = integer(y);
    Real[:] x = 1:n;
end ExtFunctionRecordObjCeval;

model ExtFunctionTest3
 Real a(start=10);
 Real b;
   
 equation
   b = testModelicaMessages(5);
   testModelicaErrorMessages();
   testModelicaAllocateStrings();
   der(a) = a;
 
end ExtFunctionTest3;

function testModelicaMessages
input Real a;
output Real b;
    external "C" annotation(Include="#include \"testModelicaUtilities.c\"");
end testModelicaMessages;

function testModelicaErrorMessages
    external "C" annotation(Include="#include \"testModelicaUtilities.c\"");
end testModelicaErrorMessages;

function testModelicaAllocateStrings
    external "C" annotation(Include="#include \"testModelicaUtilities.c\"");
end testModelicaAllocateStrings;

model ExtFunctionTest4
    Integer[3] myArray = {1,2,3};
    Integer[3] myResult = doubleArray(myArray);
    
end ExtFunctionTest4;

function doubleArray
    input Integer[3] arr;
    output Integer[3] res;

    external "C" multiplyAnArray(arr, res, 3, 2) annotation(Include="#include \"addNumbers.h\"", Library="addNumbers");
end doubleArray;

class FileOnDelete
    extends ExternalObject;
    
    function constructor
        input String name;
        output FileOnDelete out;
        external "C" out = constructor_string(name) 
            annotation(Library="extObjects", Include="#include \"extObjects.h\"");
    end constructor;
    
    function destructor
        input FileOnDelete obj;
        external "C" destructor_string_create_file(obj) 
            annotation(Library="extObjects", Include="#include \"extObjects.h\"");
    end destructor; 
end FileOnDelete;

function use_FOD
    input FileOnDelete obj;
    output Real x;
    external "C" x = constant_extobj_func(obj) 
        annotation(Library="extObjects", Include="#include \"extObjects.h\"");
end use_FOD;

model ExternalObjectTests1
    FileOnDelete obj = FileOnDelete("test_ext_object.marker");
    Real x = use_FOD(obj);
end ExternalObjectTests1;

model ExternalObjectTests2
    FileOnDelete myEOs[2] = { FileOnDelete("test_ext_object_array1.marker"), FileOnDelete("test_ext_object_array2.marker")};
    Real z;

 function get_y
    input FileOnDelete eos[:];
    output Real y;
 algorithm
    y := use_FOD(eos[1]);
 end get_y;
 
equation
    z = get_y(myEOs);  
end ExternalObjectTests2;

class ConstructorSingleCall
    extends ExternalObject;
    
    function constructor
        input String name;
        output ConstructorSingleCall out;
        external "C" out = constructor_error_multiple_calls(name) 
            annotation(Library="extObjects", Include="#include \"extObjects.h\"");
    end constructor;
    
    function destructor
        input ConstructorSingleCall obj;
        external "C" destructor(obj) 
            annotation(Library="extObjects", Include="#include \"extObjects.h\"");
    end destructor; 
end ConstructorSingleCall;

model ConstructorSingleCallTest
    ConstructorSingleCall obj = ConstructorSingleCall("test_ext_object.marker");
end ConstructorSingleCallTest;

model ConstructorSingleCallDepTest
    parameter String s = "test_ext_object.marker";
    ConstructorSingleCall obj = ConstructorSingleCall(s);
end ConstructorSingleCallDepTest;

model ExternalInfinityTest
function whileTrue
    input Real a;
    output Real b;
    external "C" annotation(
        Library="arrayFunctions",
        Include="#include \"arrayFunctions.h\"");
end whileTrue;
    Real x;
equation
    x = whileTrue(1);
end ExternalInfinityTest;

model ExternalInfinityTestCeval
function whileTrue
    input Real a;
    output Real b;
    external "C" annotation(
        Library="arrayFunctions",
        Include="#include \"arrayFunctions.h\"");
end whileTrue;
    constant Real x = whileTrue(1);
end ExternalInfinityTestCeval;

package CEval
  package C
    model RealTest
      function fRealScalar
        input  Real x_in;
        output Real x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fRealScalar;
      
      function fRealArray
        input  Real[2] x_in;
        output Real[size(x_in,1)] x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fRealArray;
      
      function fRealArrayUnknown
        input  Real[:] x_in;
        output Real[size(x_in,1)] x_out;
      external "C" fRealArray(x_in, size(x_in,1), x_out, size(x_in,1)) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fRealArrayUnknown;

      constant Real    xScalar        = fRealScalar(3);
      constant Real[2] xArray         = fRealArray({4,5});
      constant Real[2] xArrayUnknown  = fRealArrayUnknown({6,7});
    end RealTest;
    
    model IntegerTest
      function fIntegerScalar
        input  Integer x_in;
        output Integer x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fIntegerScalar;
      
      function fIntegerArray
        input  Integer[2] x_in;
        output Integer[size(x_in,1)] x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fIntegerArray;
      
      function fIntegerArrayUnknown
        input  Integer[:] x_in;
        output Integer[size(x_in,1)] x_out;
      external "C" fIntegerArray(x_in, size(x_in,1), x_out, size(x_in,1)) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fIntegerArrayUnknown;

      constant Integer    xScalar        = fIntegerScalar(3);
      constant Integer[2] xArray         = fIntegerArray({4,5});
      constant Integer[2] xArrayUnknown  = fIntegerArrayUnknown({6,7});
    end IntegerTest;
    
    model BooleanTest
      function fBooleanScalar
        input  Boolean x_in;
        output Boolean x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fBooleanScalar;
      
      function fBooleanArray
        input  Boolean[2] x_in;
        output Boolean[size(x_in,1)] x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fBooleanArray;
      
      function fBooleanArrayUnknown
        input  Boolean[:] x_in;
        output Boolean[size(x_in,1)] x_out;
      external "C" fBooleanArray(x_in, size(x_in,1), x_out, size(x_in,1)) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fBooleanArrayUnknown;

      constant Boolean    xScalar        = fBooleanScalar(true);
      constant Boolean[2] xArray         = fBooleanArray({false,false});
      constant Boolean[2] xArrayUnknown  = fBooleanArrayUnknown({false,true});
    end BooleanTest;
    
    model StringTest
      function fStringScalar
        input  String x_in;
        output String x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fStringScalar;
      
      function fStringScalarLit
        input  String x_in;
        output String x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fStringScalarLit;
      
      function fStringArray
        input  String[2] x_in;
        output String[size(x_in,1)] x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fStringArray;
      
      function fStringArrayUnknown
        input  String[:] x_in;
        output String[size(x_in,1)] x_out;
      external "C" fStringArray(x_in, size(x_in,1), x_out, size(x_in,1)) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fStringArrayUnknown;
      
      function fStrlen
        input String s;
        output Integer n;
      external "C" n = fStrlen(s) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fStrlen;

      constant Integer   len            = fStrlen("abcde");
      constant String    xScalar        = fStringScalar("abcde");
      constant String    xScalarLit     = fStringScalarLit("abcde");
      constant String[2] xArray         = fStringArray({"abc","def"});
      constant String[2] xArrayUnknown  = fStringArrayUnknown({"abc","def"});
    end StringTest;
    
    model EnumTest
      type E = enumeration(E1,E2);
      function fEnumScalar
        input  E x_in;
        output E x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fEnumScalar;
      
      function fEnumArray
        input  E[2] x_in;
        output E[size(x_in,1)] x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fEnumArray;
    
      function fEnumArrayUnknown
        input  E[:] x_in;
        output E[size(x_in,1)] x_out;
      external "C" fEnumArray(x_in, size(x_in,1), x_out, size(x_in,1)) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fEnumArrayUnknown;
      
      constant E    xScalar        = fEnumScalar(E.E1);
      constant E[2] xArray         = fEnumArray({E.E2,E.E1});
      constant E[2] xArrayUnknown  = fEnumArrayUnknown({E.E1,E.E2});
    end EnumTest;
    
    model ShortClass
        function f1
            input Real x;
            output Real y;
          external y = fRealScalar(x) annotation(
            Library="externalFunctionsC",
            Include="#include \"externalFunctionsC.h\"");
        end f1;
        function f2 = f1(x(min=1));
        function f3 = f2;
        function f4 = f3(x(max=2));
        constant Real a1 = f1(1) + f2(2) + f3(3) + f4(4);
    end ShortClass;
    
    model PackageConstantTest
      constant Real[2] c = {4,5};
      
      function f
        output Real[2] x_out;
      external "C" fRealArray(c, size(c,1), x_out, size(x_out,1)) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end f;
    
      constant Real[2] x  = f();
    end PackageConstantTest;
    
  end C;
  
  package Fortran
    model RealTest
      function frealscalar
        input  Real x_in;
        output Real x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end frealscalar;
      
      function frealarray
        input  Real[2] x_in;
        output Real[size(x_in,1)] x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end frealarray;
    
      function frealarrayunknown
        input  Real[:] x_in;
        output Real[size(x_in,1)] x_out;
      external "FORTRAN 77" frealarray(x_in, size(x_in,1), x_out, size(x_in,1)) annotation(
        Library="externalFunctionsFortran");
      end frealarrayunknown;
      
      constant Real    xScalar        = frealscalar(3);
      constant Real[2] xArray         = frealarray({4,5});
      constant Real[2] xArrayUnknown  = frealarrayunknown({6,7});
    end RealTest;
    
    model RealTestMatrix
      function frealmatrix
        input  Real[:,:] x_in;
        output Real[size(x_in,1), size(x_in,2)] x_out;
      external "FORTRAN 77" frealmatrix(size(x_in,1), size(x_in,2), x_in, x_out) annotation(
        Library="externalFunctionsFortran");
      end frealmatrix;
      
      constant Real[1,1] y1  = frealmatrix({{1}});
      constant Real[2,2] y2  = frealmatrix({{6,7},{8,9}});
    end RealTestMatrix;
    
    model IntegerTest
      function fintegerscalar
        input  Integer x_in;
        output Integer x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fintegerscalar;
      
      function fintegerarray
        input  Integer[2] x_in;
        output Integer[size(x_in,1)] x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fintegerarray;
    
      function fintegerarrayunknown
        input  Integer[:] x_in;
        output Integer[size(x_in,1)] x_out;
      external "FORTRAN 77" fintegerarray(x_in, size(x_in,1), x_out, size(x_in,1)) annotation(
        Library="externalFunctionsFortran");
      end fintegerarrayunknown;
      
      constant Integer    xScalar        = fintegerscalar(3);
      constant Integer[2] xArray         = fintegerarray({4,5});
      constant Integer[2] xArrayUnknown  = fintegerarrayunknown({6,7});
    end IntegerTest;
    
    model BooleanTest
      function fbooleanscalar
        input  Boolean x_in;
        output Boolean x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fbooleanscalar;
      
      function fbooleanarray
        input  Boolean[2] x_in;
        output Boolean[size(x_in,1)] x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fbooleanarray;
    
      function fbooleanarrayunknown
        input  Boolean[:] x_in;
        output Boolean[size(x_in,1)] x_out;
      external "FORTRAN 77" fbooleanarray(x_in, size(x_in,1), x_out, size(x_in,1)) annotation(
        Library="externalFunctionsFortran");
      end fbooleanarrayunknown;
      
      constant Boolean    xScalar        = fbooleanscalar(true);
      constant Boolean[2] xArray         = fbooleanarray({false,false});
      constant Boolean[2] xArrayUnknown  = fbooleanarrayunknown({false,true});
    end BooleanTest;

    model EnumTest
      type E = enumeration(E1,E2);
      function fenumscalar
        input  E x_in;
        output E x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fenumscalar;
      
      function fenumarray
        input  E[2] x_in;
        output E[size(x_in,1)] x_out;
      external "FORTRAN 77" annotation(
        Library="externalFunctionsFortran");
      end fenumarray;
    
      function fenumarrayunknown
        input  E[:] x_in;
        output E[size(x_in,1)] x_out;
      external "FORTRAN 77" fenumarray(x_in, size(x_in,1), x_out, size(x_in,1)) annotation(
        Library="externalFunctionsFortran");
      end fenumarrayunknown;
      
      constant E    xScalar        = fenumscalar(E.E1);
      constant E[2] xArray         = fenumarray({E.E2,E.E1});
      constant E[2] xArrayUnknown  = fenumarrayunknown({E.E1,E.E2});
    end EnumTest;
  end Fortran;
  
  package Utility
    model LogTest
      function func_with_ModelicaError
        input  Real x_in;
        output Real x_out;
      external "C" annotation(Library="useModelicaError",
                         Include="#include \"useModelicaError.h\"");
      end func_with_ModelicaError;

      Real xLog   = func_with_ModelicaError(1.1);
      Real xError = func_with_ModelicaError(2.1);
    end LogTest;
  end Utility;
  
  package Advanced
    model DgelsxTest
      function dgelsx
        "Computes the minimum-norm solution to a real linear least squares problem with rank deficient A"
        input Real A[3, 2];
        input Real B[size(A, 1), 3];
        input Real rcond=0.0 "Reciprocal condition number to estimate rank";
        output Real X[max(size(A, 1), size(A, 2)), size(B, 2)]=cat(
                1,
                B,
                zeros(max(nrow, ncol) - nrow, nrhs))
        "Solution is in first size(A,2) rows";
        output Integer info;
        output Integer rank "Effective rank of A";
      protected
        Integer nrow=size(A, 1);
        Integer ncol=size(A, 2);
        Integer nx=max(nrow, ncol);
        Integer nrhs=size(B, 2);
        Real work[max(min(size(A, 1), size(A, 2)) + 3*size(A, 2), 2*min(size(A, 1),
          size(A, 2)) + size(B, 2))];
        Real Awork[size(A, 1), size(A, 2)]=A;
        Integer jpvt[size(A, 2)]=zeros(ncol);
      external"FORTRAN 77" dgelsx(
                nrow,
                ncol,
                nrhs,
                Awork,
                nrow,
                X,
                nx,
                jpvt,
                rcond,
                rank,
                work,
                info);
      end dgelsx;
      
      Real[3,3] out;
      Real a;
      Real b;
    equation
      (out,a,b) = dgelsx({{1,2},{3,4}, {5,6}},{{7,8,9},{10,11,12}, {13,14,15}});
      
    end DgelsxTest;
    package Os
    model Obj1
        extends ExternalObject;
        function constructor
            input Real x;
            input Integer y;
            input Boolean b;
            input String s;
            output Obj1 o1;
            external "C" o1 = my_constructor1(x,y,b,s)
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end constructor;
        function destructor
            input Obj1 o1;
            external "C"
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end destructor;
    end Obj1;
    end Os;
    model Obj2
        extends ExternalObject;
        function constructor
            input Real[:] x;
            input Integer[2] y;
            input Boolean[:] b;
            input String[:] s;
            output Obj2 o2;
            external "C" my_constructor2(x,y,o2,b,s)
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end constructor;
        function destructor
            input Obj2 o2;
            external "C"
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end destructor;
    end Obj2;
    model Obj3
        extends ExternalObject;
        function constructor
            input Os.Obj1 o1;
            input Obj2[:] o2;
            output Obj3 o3;
            external "C" my_constructor3(o1,o2,o3)
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end constructor;
        function destructor
            input Obj3 o3;
            external "C"
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end destructor;
    end Obj3;
    model ExtObjTest1
        function use1
            input  Os.Obj1 o1;
            output Real x;
            external annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use1;
        Os.Obj1 o1 = Os.Obj1(3.13, 3, true, "A message");
        Real x = use1(o1); 
    end ExtObjTest1;
    model ExtObjTest2
        function use2
            input  Obj2 o2;
            output Real x;
            external annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use2;
        Obj2 o2 = Obj2({3.13,3.14}, {3,4}, {false, true}, {"A message 1", "A message 2"});
        constant Real x = use2(o2); 
    end ExtObjTest2;
    model ExtObjTest3
        function use3
            input  Obj3 o3;
            output Real x;
            external annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use3;
        Os.Obj1 o1 = Os.Obj1(3.13, 3, true, "A message");
        Obj2 o2 = Obj2({3.13,3.14}, {3,4}, {false, true}, {"A message 1", "A message 2"});
        Obj3 o3 = Obj3(o1,{o2,o2});
        constant Real x = use3(o3); 
    end ExtObjTest3;
    
    model UnknownInput
      // Should fail
      function f
        input  Real x;
        input  Real t;
        output Real y = t;
        output Real dummy=1;
      external "C" y=fRealScalar(x) annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end f;
     
      Real y;
    equation
      (y, ) = f(3, time);
    end UnknownInput;
  end Advanced;
  
  package Caching
    model CacheExtObj
        model EO
            extends ExternalObject;
            function constructor
                input Integer x;
                output EO o1;
                external "C" o1 = inc_int_con(x) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end constructor;
            function destructor
                input EO o1;
                external "C" inc_int_decon(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end destructor;
        end EO;
        function use
            input  EO o1;
            output Integer x;
            external x = inc_int_use(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use;
        parameter EO o1 = EO(1);
        parameter Integer n1 = use(o1);
        parameter Integer n2 = use(o1);
        parameter Integer n3 = n1 + n2;
        Real[n3] x = (1:n3)*time;
        Integer nn1,nn2,nn3;
      equation
        nn1 = use(o1);
        nn2 = use(o1);
        nn3 = nn1 + nn2;
    end CacheExtObj;
    
    model CacheExtObjLimit
        model EO
            extends ExternalObject;
            function constructor
                input Integer x;
                output EO o1;
                external "C" o1 = inc_int_con(x) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end constructor;
            function destructor
                input EO o1;
                external "C" inc_int_decon(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end destructor;
        end EO;
        function use1
            input  EO o1;
            output Integer x;
            external x = inc_int_use(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use1;
        function use2
            input  EO o1;
            output Integer x;
            external x = inc_int_use2(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use2;
        parameter EO o1 = EO(1);
        parameter EO o2 = EO(1);
        parameter Integer n1 = use1(o1) + use2(o1) + use1(o2) + use2(o1);
        parameter Integer n2 = use2(o2) + use2(o1) + use2(o2) + use1(o1);
        parameter Integer n3 = n1 + n2;
        Real[n3] x = (1:n3)*time;
    end CacheExtObjLimit;
    
    model ConError
        model EO
            extends ExternalObject;
            function constructor
                input Integer x;
                output EO o1;
                external "C" o1 = error_con(x) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end constructor;
            function destructor
                input EO o1;
                external "C" inc_int_decon(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end destructor;
        end EO;
        function use
            input  EO o1;
            output Integer x;
            external x = inc_int_use(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use;
        parameter EO o1 = EO(1) annotation(Evaluate=true);
        parameter Integer n1 = use(o1);
        parameter Integer n2 = use(o1);
        parameter Integer n3 = n1 + n2;
    end ConError;
    
    model DeconError
        model EO
            extends ExternalObject;
            function constructor
                input Integer x;
                output EO o1;
                external "C" o1 = inc_int_con(x) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end constructor;
            function destructor
                input EO o1;
                external "C" error_decon(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end destructor;
        end EO;
        function use
            input  EO o1;
            output Integer x;
            external x = inc_int_use(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use;
        parameter EO o1 = EO(1) annotation(Evaluate=true);
        parameter Integer n1 = use(o1);
        parameter Integer n2 = use(o1);
        parameter Integer n3 = n1 + n2;
    end DeconError;
    
    model UseError
        model EO
            extends ExternalObject;
            function constructor
                input Integer x;
                output EO o1;
                external "C" o1 = inc_int_con(x) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end constructor;
            function destructor
                input EO o1;
                external "C" inc_int_decon(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end destructor;
        end EO;
        function use
            input  EO o1;
            output Integer x;
            external x = error_use(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use;
        parameter EO o1 = EO(1) annotation(Evaluate=true);
        parameter Integer n1 = use(o1);
        parameter Integer n2 = use(o1);
        parameter Integer n3 = n1 + n2;
    end UseError;
    
    model ConCrash
        model EO
            extends ExternalObject;
            function constructor
                input Integer x;
                output EO o1;
                external "C" o1 = crash_con(x) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end constructor;
            function destructor
                input EO o1;
                external "C" inc_int_decon(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end destructor;
        end EO;
        function use
            input  EO o1;
            output Integer x;
            external x = inc_int_use(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use;
        parameter EO o1 = EO(1) annotation(Evaluate=true);
        parameter Integer n1 = use(o1);
        parameter Integer n2 = use(o1);
        parameter Integer n3 = n1 + n2;
    end ConCrash;
    
    model DeconCrash
        model EO
            extends ExternalObject;
            function constructor
                input Integer x;
                output EO o1;
                external "C" o1 = inc_int_con(x) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end constructor;
            function destructor
                input EO o1;
                external "C" crash_decon(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end destructor;
        end EO;
        function use
            input  EO o1;
            output Integer x;
            external x = inc_int_use(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use;
        parameter EO o1 = EO(1) annotation(Evaluate=true);
        parameter Integer n1 = use(o1);
        parameter Integer n2 = use(o1);
        parameter Integer n3 = n1 + n2;
    end DeconCrash;
    
    model UseCrash
        model EO
            extends ExternalObject;
            function constructor
                input Integer x;
                output EO o1;
                external "C" o1 = inc_int_con(x) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end constructor;
            function destructor
                input EO o1;
                external "C" inc_int_decon(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
            end destructor;
        end EO;
        function use
            input  EO o1;
            output Integer x;
            external x = crash_use(o1) annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end use;
        parameter EO o1 = EO(1) annotation(Evaluate=true);
        parameter Integer n1 = use(o1);
        parameter Integer n2 = use(o1);
        parameter Integer n3 = n1 + n2;
    end UseCrash;
  end Caching;
end CEval;

model PrintsControlCharacters
    "This model prints some control characters using ModelicaMessage during compilation"
    function f
        input Real i;
        output Real o;
        external "C" o = f(i) annotation(Include="double f(double i) {ModelicaMessage(\"\\1\\2\\3\\4\");return i;}");
    end f;
    constant Real c = f(2);
end PrintsControlCharacters;

model StructuralAsserts
    function f
        output Integer n;
        external "C" n = get_time() annotation(Library="externalFunctionsC", Include="#include \"externalFunctionsC.h\"");
    end f;
    
    parameter Integer n = f() annotation(Evaluate=true);
end StructuralAsserts;


model TestString
    import Modelica.Utilities.Strings.*;
    function Str1
        input  Real x;
        output Real y;
    protected
        String str;
    algorithm
        str := Str2(x);
        y := length(str);
        assert(str == "Hej", "Failed to provide the correct string, was: "+str);
        annotation(Inline=false);
    end Str1;
    function Str2
        input  Real x;
        output String str;
    algorithm
        str := fStringScalarLit("jeH");
        assert(str == "Hej", "Failed to provide the correct string, was: "+str);
        annotation(Inline=false);
    end Str2;
    function fStringScalarLit
        input  String x_in;
        output String x_out;
      external "C" annotation(
        Library="externalFunctionsC",
        Include="#include \"externalFunctionsC.h\"");
      end fStringScalarLit;
    parameter Real x(fixed=false);
initial equation
    x = Str1(1.0);
end TestString;


model ExternalObjectTests3
    class ModelicaMsgOnDelete
        extends ExternalObject;
        
        function constructor
            input String name;
            output ModelicaMsgOnDelete out;
            external "C" out = constructor_modelica_msg(name) 
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end constructor;
        
        function destructor
            input ModelicaMsgOnDelete obj;
            external "C" destructor_modelica_msg(obj) 
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end destructor; 
    end ModelicaMsgOnDelete;

    function use_MMOD
        input ModelicaMsgOnDelete obj;
        output Real x;
        external "C" x = constant_extobj_func(obj) 
            annotation(Library="extObjects", Include="#include \"extObjects.h\"");
    end use_MMOD;
    
    ModelicaMsgOnDelete obj = ModelicaMsgOnDelete("test_ext_object.marker");
    Real x = use_MMOD(obj);
end ExternalObjectTests3;

model MultiUse1
    function f1
        input Real x;
        output Real y;
        external "C" y = add(x,1) annotation(Library="addNumbers",
                                           Include="#include \"addNumbers.h\"");
    end f1;
    function f2
        input Real x;
        output Real y;
        external "C" y = add(x,2) annotation(Library="addNumbers",
                                           Include="#include \"addNumbers.h\"");
    end f2;
    
    Real y = f1(1) + f2(1);
end MultiUse1;

end ExtFunctionTests;
