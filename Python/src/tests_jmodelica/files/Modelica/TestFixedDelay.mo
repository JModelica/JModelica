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

partial block BaseFixedDelay
    parameter Real d = 1; /* > 0 */
    parameter Boolean noevent = false;    
    input Real u;
    output Real y;
end BaseFixedDelay;

block FixedDelay
    extends BaseFixedDelay;
equation
    if noevent then
        y = noEvent(delay(u, d));
    else
        y = delay(u, d);
    end if;
end FixedDelay;

block FixedDelaySD
    extends BaseFixedDelay;
equation
    // Disable noevent functionality until noEvent is supported with multiple return values
/*    if noevent then
        (, y) = noEvent(spatialDistribution(u, 0, time/d, true,
                                            initialPoints = {0.0, 1.0},
                                            initialValues = {u, u}));
    else*/
        (, y) = spatialDistribution(u, 0, time/d, true,
                                    initialPoints = {0.0, 1.0},
                                    initialValues = {u, u});
//    end if;
end FixedDelaySD;

block FixedDelaySDReverse
    extends BaseFixedDelay;
equation
    if noevent then
        y = noEvent(spatialDistribution(0, u, -time/d, false,
                                        initialPoints = {0.0, 1.0},
                                        initialValues = {u, u}));
    else
        (y, ) = spatialDistribution(0, u, -time/d, false,
                                    initialPoints = {0.0, 1.0},
                                    initialValues = {u, u});
    end if;
end FixedDelaySDReverse;


model TestDelayTime
    replaceable block FD = FixedDelay constrainedby BaseFixedDelay;
    FD fd;
    Real x;
equation
    fd.u = time;
    x = fd.y;
end TestDelayTime;

model TestDelayQuadratic
    replaceable block FD = FixedDelay constrainedby BaseFixedDelay;
    FD fd;
    Real x;
equation
    fd.u = time^2+1;
    x = fd.y;
end TestDelayQuadratic;

model TestIntegrateDelayedTime
    replaceable block FD = FixedDelay constrainedby BaseFixedDelay;
    FD fd;
    Real x(start = 0, fixed = true);
equation
    fd.u = time;
    der(x) = fd.y;
end TestIntegrateDelayedTime;

model TestIntegrateDelayedQuadratic
    replaceable block FD = FixedDelay constrainedby BaseFixedDelay;
    FD fd;
    Real x(start = 0, fixed = true);
equation
    fd.u = time^2;
    der(x) = fd.y;
end TestIntegrateDelayedQuadratic;

model TestSinusoid
    replaceable block FD = FixedDelay constrainedby BaseFixedDelay;
    FD fd;
    Real x(start = 1, fixed = true);
equation
    fd.u = x;
    der(x) = -Modelica.Constants.pi/2*fd.y;
end TestSinusoid;

model TestSinusoidNoEvent = TestSinusoid(fd(noevent = true));

model TestShortDelay
    replaceable block FD = FixedDelay constrainedby BaseFixedDelay;
    FD fd(d=d);
    parameter Real d=1;
    Real x(start = 1, fixed = true);
equation
    fd.u = x;
    der(x) = -fd.y;
end TestShortDelay;

model TestCommute
    replaceable block FD = FixedDelay constrainedby BaseFixedDelay;
    FD fdv, fdx;
    Real x, v, x_delay, delay_x;
initial equation
    x = 1;
    v = 0;
    x_delay = 1;
equation
    fdv.u = v;
    fdx.u = x;
    der(x) = v;
    der(v) = -x;
    der(x_delay) = fdv.y;
    delay_x      = fdx.y;
end TestCommute;

model TestRepeatingEvents
    replaceable block FD = FixedDelay constrainedby BaseFixedDelay;
    FD fd(d=d, y(start=0));
    parameter Real d=1;
    Real x(start=0);
equation
    fd.u = x;
    x = if time < d then time else fd.y;
end TestRepeatingEvents;

model TestRepeatNoEvent = TestRepeatingEvents(fd(noevent = true));
