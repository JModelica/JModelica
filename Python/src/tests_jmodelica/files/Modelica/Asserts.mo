package Asserts

    model AssertEqu1
		Real x(start = 0);
	equation
		der(x) = time;
		assert(noEvent(x < 2), "X is too high.");
		assert(noEvent(x < 1), "X is a bit high.", level = AssertionLevel.warning);
	end AssertEqu1;
	
    model AssertEqu2
        Real x(start = 0);
    equation
        der(x) = time;
        assert(x < 2, "X is too high.");
        assert(x < 1, "X is a bit high.", level = AssertionLevel.warning);
    end AssertEqu2;
	
	model AssertFunc
		function f
			input Real x;
			output Real y;
		algorithm
			y := x;
	        assert(x < 2, "X is too high.");
	        assert(x < 1, "X is a bit high.", level = AssertionLevel.warning);
		end f;

        Real x(start = 0);
		Real y = f(x);
    equation
        der(x) = time;
	end AssertFunc;
	
	
	model ModelicaError
        function f
            input Real x;
            output Real y;
            external "C" y = func_with_ModelicaError(x) annotation(Library="useModelicaError",
                         Include="#include \"useModelicaError.h\"");
        end f;

        Real x(start = 0);
        Real y = f(x);
    equation
        der(x) = time;
	end ModelicaError;
	
	
    model TerminateWhen
        Real x(start = 0);
    equation
        der(x) = time;
		when x >= 2 then
			terminate("X is high enough.");
		end when;
    end TerminateWhen;
	
end Asserts;
