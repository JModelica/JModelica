package DiscreteInputTestModels
  
    model boolInputInPreOperatorWithoutEdge
	
      input Boolean Bool_A;
      input Boolean Bool_B;

      protected Boolean Bool_C;  
      protected Real Real_A; 
      protected Real Real_B;

    algorithm
      
	  when Bool_A and (not pre(Bool_C)) then 
        Bool_C := true; 
        Real_A := time; 
      end when;
      when Bool_C and Bool_B==true and pre(Bool_B)==false then 
        Real_B := time; 

      end when;

  
	end boolInputInPreOperatorWithoutEdge; 

    model boolInputInPreOperatorWithEdge
	
      input Boolean Bool_A;
      input Boolean Bool_B;

      protected Boolean Bool_C;  
      protected Real Real_A; 
      protected Real Real_B;

    algorithm
      
	  when Bool_A and (not pre(Bool_C)) then 
        Bool_C := true; 
        Real_A := time; 
      end when;
      when Bool_C and edge(Bool_B) then 
        Real_B := time; 

      end when;

  
	end boolInputInPreOperatorWithEdge;  	
  

end DiscreteInputTest;
