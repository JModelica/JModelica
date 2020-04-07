model NegatedAlias
    Real x(start=1);
    Real y=-x;
    Integer ix(start=1);
    Integer iy=-ix;
    Boolean bx(start=true);
    Boolean by = not bx;
equation
    der(x)=-x;
    ix = if time > 10 then 0 else 1;
    bx = if time > 10 then true else false;
end NegatedAlias;
