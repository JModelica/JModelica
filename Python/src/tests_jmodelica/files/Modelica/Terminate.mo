model Terminate
	Real x(start=0);
equation
	der(x) = 1;
	if x > 0.5 then
		terminate("Time to fail...");
	end if;
end Terminate;

model AssertFail
    Real x(start=1);
equation
    der(x) = -1;
    assert(x > 0.5, "Time to report an error...");
end AssertFail;
