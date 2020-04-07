package Algorithm "Some tests for algorithms" 
model AlgoTest1
	Boolean b;
	Integer i;
	Real r;
algorithm
	b := i >= 2 and i < 4;
equation
	r = time*time + 1;
	i = integer(r);
end AlgoTest1;

model AlgoTest2
	Real x;
	Real y(start=0);
	Real z(start=0);
	discrete Real a(start=0.05);
algorithm
	x := der(y);
	if x < 0.2 then
		x := -1;
	end if;
	when a < x then
        while noEvent(a < x) loop
			a := a + 0.01;
		end while;
	end when;
equation
	der(y) = time;
	der(z) = x;
end AlgoTest2;

model AlgoTest3
	function f
		input Real a;
		input Real b;
		output Real o;
	algorithm
		o := sqrt(a*a + b*b);
	end f;

	constant Integer is[10] = {3,6,4,2,-1,8,-10,10,-20,37};
	Integer n;
	Real r;
algorithm
	n := integer(time*10);
	for i in is loop
		n := n + 1;
	end for;
algorithm
	for i in is loop
		r := f(r,i) / n;
	end for;
end AlgoTest3;

model AlgoTest4
	Real x(start = 1);
	Real y(start = 0);
	discrete Real d;
initial equation
	d = -1;
algorithm
	assert(x > y,"Fail");
	if y > 1.4 then
		terminate("Stop");
	end if;
equation
	der(x) = y;
	der(y) = 1;
	when y > 1.5 then
		d = x - 0.5;
	end when;
end AlgoTest4;

model AlgoTest5
  model R
    Boolean inside(start = false);
    Integer target;
    Real r_pos;
    Integer d_pos;
    Integer i_pos(start=-1);
	Real[10] intervals = linspace(-1,1,10);
  algorithm
    assert(r_pos >= min(intervals) or r_pos < max(intervals), "Outside of intervals");
    for i in 1:(size(intervals,1)-1) loop
      if intervals[i] <= r_pos and intervals[i+1] > r_pos then
        i_pos := i;
      end if;
    end for;
    inside := i_pos == target;
    d_pos := integer(r_pos);
  end R;

  Integer[5] targets = {5,1,3,4,3};
  Real[5] positions,_p;
  R[5] rs;

algorithm
  positions := {
    max(_p),
    min(_p),
    sin(sum(_p) / size(_p,1)),
    _p[3] + time,
    _p[3] - 0.5*time
  };

equation
  rs[:].target = targets[:];
  rs[:].r_pos = positions[:];

  positions = der(_p);
end AlgoTest5;

model AlgoTest6
  Real x;
  discrete Real a,b;
equation
  x = sin(time*10);
algorithm
  when {initial(), x >= 0.7} then
    a := pre(a) + 1;
  elsewhen {x < 0.7} then
    a := a - 1;
  elsewhen {x >= 0.7, x >= 0.8, x < 0.8, x < 0.7} then
    b := b + 1;
  end when;
end AlgoTest6;

end Algorithm;
