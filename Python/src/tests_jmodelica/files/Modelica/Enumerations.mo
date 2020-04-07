package Enumerations

model Enumeration1
    type enum = enumeration(one, two);
    Real x = noEvent(if y == enum.one then 7 else if y == enum.two then 9 else time);
    parameter enum y = enum.one;

end Enumeration1;

model Enumeration2
  Real x1(start=1);
  Real x2(start=1);
  
  type E = enumeration (A,B,C);
  
  E one(start = E.A);
  E two(start = E.B);
  E three(start = E.C);
  
  equation
    
    der(x1) = if (one == E.C) then x1 + x2 else x1 * 5 + x2 * 4;
    der(x2) = x1 * 3 + x2;
    
    when x1 > 2 then
      one = E.C;
      
      
      two = E.B;
      three = E.C;
      reinit(x1, 1);
    end when;
    
end Enumeration2;

model Enumeration3
    type numbers = enumeration(one, two);
    type cities  = enumeration(atlantis "Position unknown", berlin, chicago, delhi);
	type Temperature = Real(unit="K");
	
    parameter numbers y = numbers.one;
    parameter numbers x = numbers.two;
    parameter cities home = cities.atlantis;
    parameter cities vacation = cities.delhi;
    
	parameter Real z = 3;
	
	parameter Temperature temp = 100;

end Enumeration3;

model Enumeration4
    type Size = enumeration(small, medium, large, xlarge); 
    parameter Size tsize = Size.medium;
end Enumeration4;


end Enumerations;
