package ExtFunctions

model addTwo
 Real a(start=1) = 1;
 Real b(start=2) = 2;
 Real c(start=3);

 algorithm
  c := add(a,b);

end addTwo;

function add
 input Real a;
 input Real b;
 output Real c;

 external "C" annotation(Library="addNumbers",
                         Include="#include \"addNumbers.h\"");
end add;

model sumArray
 Real sum(start=45.0);
 
 equation
  sum = sumArrayElements({1,2,3,4,5,6,7,8,9,time});
  
end sumArray;

function sumArrayElements
 input Real a[:];
 output Real sum;

 external "C" annotation(Library="arrayFunctions",
                         Include="#include \"arrayFunctions.h\"");

end sumArrayElements;

model transposeSquareMatrix
 Real b_out[2,2] (start={{1,3},{2,0}});
 
 equation
  b_out = transposeMatrix({{1,2},{3,4*time}});

end transposeSquareMatrix;

function transposeMatrix
 input Real a[:,:];
 output Real b[size(a,1),size(a,2)];
 
 external "C" annotation(Library="arrayFunctions",
                         Include="#include \"arrayFunctions.h\"");
end transposeMatrix;

end ExtFunctions;
