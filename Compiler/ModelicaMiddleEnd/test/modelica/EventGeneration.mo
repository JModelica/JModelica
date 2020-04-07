/*
    Copyright (C) 2009-2017 Modelon AB

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

package EventGeneration


model Nested
  Real x;
equation
  1 + x = integer(3 + floor((time * 0.3) + 4.2) * 4);

  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="EventGeneration_Nested",
      event_output_vars=true,
      description="Tests extraction of nested event generating expressions
      into when equations.",
      flatModel="
fclass EventGeneration.Nested
 Real x;
 discrete Real temp_1;
 discrete Integer temp_2;
 output Real _eventIndicator_1;
 output Real _eventIndicator_2;
 output Real _eventIndicator_3;
 output Real _eventIndicator_4;
initial equation
 pre(temp_1) = 0.0;
 pre(temp_2) = 0;
equation
 1 + x = temp_2;
 temp_1 = if time * 0.3 + 4.2 < pre(temp_1) or time * 0.3 + 4.2 >= pre(temp_1) + 1 or initial() then floor(time * 0.3 + 4.2) else pre(temp_1);
 temp_2 = if 3 + temp_1 * 4 < pre(temp_2) or 3 + temp_1 * 4 >= pre(temp_2) + 1 or initial() then integer(3 + temp_1 * 4) else pre(temp_2);
 _eventIndicator_1 = time * 0.3 + 4.2 - pre(temp_1);
 _eventIndicator_2 = time * 0.3 + 4.2 - (pre(temp_1) + 1);
 _eventIndicator_3 = 3 + temp_1 * 4 - pre(temp_2);
 _eventIndicator_4 = _eventIndicator_3 + -1;
end EventGeneration.Nested;
")})));
end Nested;

model InAlgorithm
  Real x;
algorithm
  x := integer(3 + floor((time * 0.3) + 4.2) * 4);

  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="EventGeneration_InAlgorithm",
      event_output_vars=true,
      description="Tests extraction of event generating expressions in algorithms.",
      flatModel="
fclass EventGeneration.InAlgorithm
 Real x;
 discrete Real temp_1;
 discrete Integer temp_2;
 output Real _eventIndicator_1;
 output Real _eventIndicator_2;
 output Real _eventIndicator_3;
 output Real _eventIndicator_4;
initial equation
 pre(temp_1) = 0.0;
 pre(temp_2) = 0;
algorithm
 temp_1 := if time * 0.3 + 4.2 < pre(temp_1) or time * 0.3 + 4.2 >= pre(temp_1) + 1 or initial() then floor(time * 0.3 + 4.2) else pre(temp_1);
 _eventIndicator_3 := 3 + temp_1 * 4 - pre(temp_2);
 _eventIndicator_4 := 3 + temp_1 * 4 - (pre(temp_2) + 1);
 temp_2 := if 3 + temp_1 * 4 < pre(temp_2) or 3 + temp_1 * 4 >= pre(temp_2) + 1 or initial() then integer(3 + temp_1 * 4) else pre(temp_2);
 x := temp_2;
equation
 _eventIndicator_1 = time * 0.3 + 4.2 - pre(temp_1);
 _eventIndicator_2 = time * 0.3 + 4.2 - (pre(temp_1) + 1);
end EventGeneration.InAlgorithm;
")})));
end InAlgorithm;

model InFunctionCall

  function f
    input Real x;
    output Real y;
  algorithm
   y := mod(x,2);
   return;
  end f;
  
  Real x;
equation
  x = f(integer(0.9 + time/10) * 3.14);

  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="EventGeneration_InFunctionCall",
      event_output_vars=true,
      description="Tests event generating expressions in function calls.",
      flatModel="
fclass EventGeneration.InFunctionCall
 Real x;
 discrete Integer temp_1;
 output Real _eventIndicator_1;
 output Real _eventIndicator_2;
 discrete Real temp_2;
initial equation
 pre(temp_1) = 0;
 pre(temp_2) = 0.0;
equation
 temp_2 = temp_1 * 3.14;
 x = temp_2 - noEvent(floor(temp_2 / 2)) * 2;
 temp_1 = if 0.9 + time / 10 < pre(temp_1) or 0.9 + time / 10 >= pre(temp_1) + 1 or initial() then integer(0.9 + time / 10) else pre(temp_1);
 _eventIndicator_1 = 0.9 + time / 10 - pre(temp_1);
 _eventIndicator_2 = 0.9 + time / 10 - (pre(temp_1) + 1);
end EventGeneration.InFunctionCall;
")})));
end InFunctionCall;


model InWhenClauses1
       Real x;
equation
    when integer(time*3) + noEvent(integer(time*3)) > 1 then
        x = floor(time * 0.3 + 4.2);
    end when;

  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="EventGeneration_InWhenClauses1",
      event_output_vars=true,
      description="Tests event generating expressions in a when equation.",
      flatModel="
fclass EventGeneration.InWhenClauses1
 discrete Real x;
 discrete Integer temp_1;
 discrete Real temp_2;
 output Real _eventIndicator_1;
 output Real _eventIndicator_2;
 output Real _eventIndicator_3;
 output Real _eventIndicator_4;
 discrete Boolean temp_3;
initial equation
 pre(temp_1) = 0;
 pre(temp_2) = 0.0;
 pre(x) = 0.0;
 pre(temp_3) = false;
equation
 temp_3 = temp_1 + noEvent(integer(time * 3)) > 1;
 x = if temp_3 and not pre(temp_3) then temp_2 else pre(x);
 temp_1 = if time * 3 < pre(temp_1) or time * 3 >= pre(temp_1) + 1 or initial() then integer(time * 3) else pre(temp_1);
 temp_2 = if time * 0.3 + 4.2 < pre(temp_2) or time * 0.3 + 4.2 >= pre(temp_2) + 1 or initial() then floor(time * 0.3 + 4.2) else pre(temp_2);
 _eventIndicator_1 = time * 3 - pre(temp_1);
 _eventIndicator_2 = time * 3 - (pre(temp_1) + 1);
 _eventIndicator_3 = time * 0.3 + 4.2 - pre(temp_2);
 _eventIndicator_4 = time * 0.3 + 4.2 - (pre(temp_2) + 1);
end EventGeneration.InWhenClauses1;
")})));
end InWhenClauses1;

model InWhenClauses2
       Real x;
algorithm
    when integer(time * 3) + noEvent(integer(time * 3)) > 1 then
        x := floor(time * 0.3 + 4.2);
    end when;

  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="EventGeneration_InWhenClauses2",
      event_output_vars=true,
      description="Tests event generating expressions in a when statement.",
      flatModel="
fclass EventGeneration.InWhenClauses2
 discrete Real x;
 discrete Real temp_1;
 discrete Integer temp_2;
 output Real _eventIndicator_1;
 output Real _eventIndicator_2;
 output Real _eventIndicator_3;
 output Real _eventIndicator_4;
 discrete Boolean temp_3;
initial equation
 pre(temp_1) = 0.0;
 pre(temp_2) = 0;
 pre(x) = 0.0;
 pre(temp_3) = false;
algorithm
 temp_2 := if time * 3 < pre(temp_2) or time * 3 >= pre(temp_2) + 1 or initial() then integer(time * 3) else pre(temp_2);
 temp_3 := temp_2 + noEvent(integer(time * 3)) > 1;
 if temp_3 and not pre(temp_3) then
  temp_1 := if time * 0.3 + 4.2 < pre(temp_1) or time * 0.3 + 4.2 >= pre(temp_1) + 1 or initial() then floor(time * 0.3 + 4.2) else pre(temp_1);
  x := temp_1;
 end if;
equation
 _eventIndicator_1 = time * 3 - pre(temp_2);
 _eventIndicator_2 = time * 3 - (pre(temp_2) + 1);
 _eventIndicator_3 = time * 0.3 + 4.2 - pre(temp_1);
 _eventIndicator_4 = time * 0.3 + 4.2 - (pre(temp_1) + 1);
end EventGeneration.InWhenClauses2;
")})));
end InWhenClauses2;

model InInitialAlgorithm
       Integer x;
initial algorithm
  x := integer(time);
equation
  when (time >= 1) then
    x = integer(time);
  end when;

  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="EventGeneration_InInitialAlgorithm",
      description="Tests event generating expressions in a when equation.",
      flatModel="
fclass EventGeneration.InInitialAlgorithm
 discrete Integer x;
 discrete Integer temp_1;
 discrete Boolean temp_2;
initial equation 
 algorithm
  x := integer(time);
;
 pre(temp_1) = 0;
 pre(temp_2) = false;
equation
 temp_2 = time >= 1;
 x = if temp_2 and not pre(temp_2) then temp_1 else pre(x);
 temp_1 = if time < pre(temp_1) or time >= pre(temp_1) + 1 or initial() then integer(time) else pre(temp_1);
end EventGeneration.InInitialAlgorithm;
")})));
end InInitialAlgorithm;

model InInitialEquation
       Real x;
initial equation
  x = integer(time);
equation
  when (time >= 1) then
    x = integer(time);
  end when;

  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="EventGeneration_InInitialEquation",
      description="Tests event generating expressions in a when equation.",
      flatModel="
fclass EventGeneration.InInitialEquation
 discrete Real x;
 discrete Integer temp_1;
 discrete Boolean temp_2;
initial equation 
 x = integer(time);
 pre(temp_1) = 0;
 pre(temp_2) = false;
equation
 temp_2 = time >= 1;
 x = if temp_2 and not pre(temp_2) then temp_1 else pre(x);
 temp_1 = if time < pre(temp_1) or time >= pre(temp_1) + 1 or initial() then integer(time) else pre(temp_1);
end EventGeneration.InInitialEquation;
")})));
end InInitialEquation;

model OutputVarsTime1
    Real t;
  algorithm
    when time > 1 then
        t := 1;
    end when;

  annotation(__JModelica(UnitTesting(tests={
      TransformCanonicalTestCase(
          name="EventGeneration_OutputVarsTime1",
          event_output_vars=true,
          description="Time event generating expressions should not generate event indicator equations.",
          flatModel="
fclass EventGeneration.OutputVarsTime1
 discrete Real t;
 discrete Boolean temp_1;
initial equation
 pre(t) = 0.0;
 pre(temp_1) = false;
equation
 temp_1 = time > 1;
algorithm
 if temp_1 and not pre(temp_1) then
  t := 1;
 end if;
end EventGeneration.OutputVarsTime1;
")})));
end OutputVarsTime1;

model OutputVarsTime2
    Real t;
  algorithm
    when time > t then
        t := 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EventGeneration_OutputVarsTime2",
            event_output_vars=true,
            description="Time event generating expressions should generate event indicator statements when they have
                a variable referenced in the LHS.",
            flatModel="
fclass EventGeneration.OutputVarsTime2
 discrete Real t;
 output Real _eventIndicator_1;
 discrete Boolean temp_1;
initial equation
 pre(t) = 0.0;
 pre(temp_1) = false;
algorithm
 _eventIndicator_1 := time - t;
 temp_1 := time > t;
 if temp_1 and not pre(temp_1) then
  t := 1;
 end if;
end EventGeneration.OutputVarsTime2;
")})));
end OutputVarsTime2;

model OutputVarsState1
    input Integer i;
    Real t;
  algorithm
    when sin(i) > 1 then
        t := 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EventGeneration_OutputVarsState1",
            event_output_vars=true,
            description="State event generating expressions should generate indicator equations.",
            flatModel="
fclass EventGeneration.OutputVarsState1
 discrete input Integer i;
 discrete Real t;
 output Real _eventIndicator_1;
 discrete Boolean temp_1;
initial equation
 pre(t) = 0.0;
 pre(temp_1) = false;
equation
 temp_1 = sin(i) > 1;
algorithm
 if temp_1 and not pre(temp_1) then
  t := 1;
 end if;
equation
 _eventIndicator_1 = sin(i) - 1;
end EventGeneration.OutputVarsState1;
")})));
end OutputVarsState1;

model OutputVarsState2
    input Integer i;
    Real t;
  algorithm
    when sin(i) > t then
        t := 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EventGeneration_OutputVarsState2",
            event_output_vars=true,
            description="State event generating expressions should generate indicator statements when they have a
                variable referenced in the LHS.",
            flatModel="
fclass EventGeneration.OutputVarsState2
 discrete input Integer i;
 discrete Real t;
 output Real _eventIndicator_1;
 discrete Boolean temp_1;
initial equation
 pre(t) = 0.0;
 pre(temp_1) = false;
algorithm
 _eventIndicator_1 := sin(i) - t;
 temp_1 := sin(i) > t;
 if temp_1 and not pre(temp_1) then
  t := 1;
 end if;
end EventGeneration.OutputVarsState2;
")})));
end OutputVarsState2;

model OnlyStateEvents1
    Real t;
  algorithm
    when time > 1 then
        t := 1;
    end when;

annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
        name="OnlyStateEvents1",
        description="Time event generating expressions should generate event indicator equations when the option time_events=false",
        event_output_vars=true,
        time_events=false,
        flatModel="
fclass EventGeneration.OnlyStateEvents1
 discrete Real t;
 output Real _eventIndicator_1;
 discrete Boolean temp_1;
initial equation
 pre(t) = 0.0;
 pre(temp_1) = false;
equation
 temp_1 = time > 1;
algorithm
 if temp_1 and not pre(temp_1) then
  t := 1;
 end if;
equation
 _eventIndicator_1 = time - 1;
end EventGeneration.OnlyStateEvents1;
")})));
end OnlyStateEvents1;

model AliasIndicator
  Real a;
  Real b;

equation
  if a > 0 then
    a = 1;
  else
    a = 2;
  end if;

  if a > 1 then
    b = 1;
  else
    b = 2;
  end if;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EventGeneration_AliasIndicator",
            event_output_vars=true,
            description="Checks that event indicator equations are alias eliminated.",
            flatModel="
fclass EventGeneration.AliasIndicator
 Real a;
 Real b;
 output Real _eventIndicator_1;
 output Real _eventIndicator_2;
equation
 a = if a > 0 then 1 else 2;
 b = if a > 1 then 1 else 2;
 _eventIndicator_1 = a;
 _eventIndicator_2 = a - 1;
end EventGeneration.AliasIndicator;
")})));
end AliasIndicator;

model DelayStateEvents1
    discrete Real x(start=0.0, fixed=true);
    output Real y;
equation
    when (time >= 0.5) then
        x = 2;
    end when;
    y = delay(x, 1);

annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
        name="DelayStateEvents1",
        description="",
        time_events=false,
        event_output_vars=true,
        flatModel="
fclass EventGeneration.DelayStateEvents1
 discrete Real x(start = 0.0,fixed = true);
 output Real y;
 output Real _eventIndicator_1;
 output Real _eventIndicator_2;
 output Real _eventIndicator_3;
 discrete Boolean temp_1;
initial equation
 pre(x) = 0.0;
 pre(temp_1) = false;
equation
 temp_1 = time >= 0.5;
 x = if temp_1 and not pre(temp_1) then 2 else pre(x);
 y = delay(x, 1);
 _eventIndicator_1 = time - 0.5;
 _eventIndicator_2 = delayIndicatorFirst(x, 1);
 _eventIndicator_3 = delayIndicatorSecond(x, 1);
end EventGeneration.DelayStateEvents1;
")})));
end DelayStateEvents1;

model DelayStateEvents2
    discrete Real x(start=0.0, fixed=true);
    output Real y;
    Real tmp;
equation
    tmp = sin(time * 100);
    when (time >= 0.5) then
        x = 2;
    end when;
    y = delay(x, tmp, 1);

annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
        name="DelayStateEvents2",
        description="
Tests extraction of nested event generating expressions
            into when equations.
",
        relational_time_events=false,
        event_output_vars=true,
        flatModel="
fclass EventGeneration.DelayStateEvents2
 discrete Real x(start = 0.0,fixed = true);
 output Real y;
 Real tmp;
 output Real _eventIndicator_1;
 output Real _eventIndicator_2;
 output Real _eventIndicator_3;
 discrete Boolean temp_1;
initial equation
 pre(x) = 0.0;
 pre(temp_1) = false;
equation
 tmp = sin(time * 100);
 temp_1 = time >= 0.5;
 x = if temp_1 and not pre(temp_1) then 2 else pre(x);
 y = delay(x, tmp, 1);
 _eventIndicator_1 = time - 0.5;
 _eventIndicator_2 = delayIndicatorFirst(x, tmp, 1);
 _eventIndicator_3 = delayIndicatorSecond(x, tmp, 1);
end EventGeneration.DelayStateEvents2;
")})));
end DelayStateEvents2;

model SpatialDist1
    Real x1,x2,x3,x4;
  equation
    (x1,x2) = spatialDistribution(time+1, time+2, time+3, true, initialPoints={1,2}, initialValues={3,4});
    (,x3) = spatialDistribution(time+1, time+2, time+3, false, initialPoints={1,2}, initialValues={3,4});
    x4 = noEvent(spatialDistribution(time+1, time+2, time+3, true));

annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
        name="SpatialDist1",
        description="SpatialDistribution event indicator in flat model",
        generate_ode=true,
        equation_sorting=true,
        flatModel="
fclass EventGeneration.SpatialDist1
 Real x1;
 Real x2;
 Real x3;
 Real x4;
 Real _eventIndicator_1;
 Real _eventIndicator_2;
equation
 (x1, x2) = spatialDistribution(time + 1, time + 2, time + 3, true,  {1, 2}, {3, 4});
 (, x3) = spatialDistribution(time + 1, time + 2, time + 3, false, {1, 2}, {3, 4});
 x4 = noEvent(spatialDistribution(time + 1, time + 2, time + 3, true, {0.0, 1.0}, {0.0, 0.0}));
 _eventIndicator_1 = spatialDistIndicator(time + 1, time + 2, time + 3, true, {1, 2}, {3, 4});
 _eventIndicator_2 = spatialDistIndicator(time + 1, time + 2, time + 3, false, {1, 2}, {3, 4});
end EventGeneration.SpatialDist1;
")})));
end SpatialDist1;

end EventGeneration;
