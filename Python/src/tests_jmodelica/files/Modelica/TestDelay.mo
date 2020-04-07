/*
    Copyright (C) 2014 Modelon AB

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

model TestDelayTime
    Real x;
equation
    x = delay(time, 1);
end TestDelayTime;

model TestDelayQuadratic
    Real x;
equation
    x = delay(time^2+1, 1);
end TestDelayQuadratic;

model TestIntegrateDelayedTime
    Real x(start = 0, fixed = true);
equation
    der(x) = delay(time, 1);
end TestIntegrateDelayedTime;

model TestIntegrateDelayedQuadratic
    Real x(start = 0, fixed = true);
equation
    der(x) = delay(time^2, 1);
end TestIntegrateDelayedQuadratic;

model TestSinusoid
    Real x(start = 1, fixed = true);
equation
    der(x) = -Modelica.Constants.pi/2*delay(x, 1);
end TestSinusoid;

model TestSinusoidNoEvent
    Real x(start = 1, fixed = true);
equation
    der(x) = -Modelica.Constants.pi/2*noEvent(delay(x, 1));
end TestSinusoidNoEvent;

model TestShortDelay
    parameter Real d=1;
    Real x(start = 1, fixed = true);
equation
    der(x) = -delay(x, d);
end TestShortDelay;

model TestCommute
    Real x, v, x_delay, delay_x;
initial equation
    x = 1;
    v = 0;
    x_delay = 1;
equation
    der(x) = v;
    der(v) = -x;
    der(x_delay) = delay(v, 1);
    delay_x      = delay(x, 1);
end TestCommute;

model TestRepeatingEvents
    parameter Real d=1;
    Real x(start=0);
equation
    x = if time < d then time else delay(x, d);
end TestRepeatingEvents;

model TestRepeatNoEvent
    parameter Real d=1;
    Real x(start=0);
equation
    x = if time < d then time else noEvent(delay(x, d));
end TestRepeatNoEvent;

model TestVariablyDelayedTime
    Real x;
equation
    x = delay(time, sin(5*time)*0.5+0.5, 1);
end TestVariablyDelayedTime;

model TestStateDependentDelay
    Real x(start = 1, fixed = true);
equation
    der(x) = -delay(x, x, 1);
end TestStateDependentDelay;

model TestDelayStartingAtZero
    Real x(start = 1, fixed = true);
equation
    der(x) = -delay(x, time/2, 1e2)^2;
end TestDelayStartingAtZero;

model TestDelayStartingAtZeroNoEvent
    Real x(start = 1, fixed = true);
equation
    der(x) = -noEvent(delay(x, time/2, 1e2))^2;
end TestDelayStartingAtZeroNoEvent;

model TestVariableDelayEvents
    Real x, y;
equation
    y = if time < 1 then 0 else 1;
    x = delay(y, cos(5*time)+1, 2);
end TestVariableDelayEvents;

model TestDelayGoingToZero
    Real x(start = 1, fixed = true);
equation
    der(x) = -delay(x, if time < 1 then 1-time else 0, 1);
end TestDelayGoingToZero;

model TestZenoRepeat
    parameter Real d=1;
    Real x(start=0);
equation
    x = if time <= 0 then 0 else if time < d*(1-sqrt(0.5)) then 1 else delay(x, if time < d then d-time else 0, d);
end TestZenoRepeat;

model TestZenoRepeatNoEvent
    parameter Real d=1;
    Real x(start=0);
equation
    x = if time <= 0 then 0 else if time < d*(1-sqrt(0.5)) then 1 else noEvent(delay(x, if time < d then d-time else 0, d));
end TestZenoRepeatNoEvent;

model TestMultipleDelays
    parameter Real phi = (1+sqrt(5))/2;
    TestRepeatingEvents rep;
    TestRepeatNoEvent rep_ne(d = phi);
    TestZenoRepeat zeno(d = 5);
    TestZenoRepeatNoEvent zeno_ne(d = 5*phi);
end TestMultipleDelays;

model TestNextEvent
    Boolean b = time > 2;
    Real x = if time < 1 then 1 else time;
    Real y = if b then delay(x,1) else time;
end TestNextEvent;
