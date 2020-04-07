within ;
package CombinedCycle
  package Substances
    model Gas
      input Types.Pressure p(start=pstart);
      input Types.Temperature T(start=Tstart);
      Types.GasDensity d(start=dstart);
      Types.SpecificEnthalpy h(start=hstart);
      Types.SpecificEnergy u(start=u_start);
      Real dd_dT(start=-dstart/Tstart,nominal = 0.1);
      Real dd_dp(start=dstart/pstart,nominal = 1e-5);
      constant Real R=Modelica.Constants.R;
      parameter Types.Pressure pstart = 101325;
      parameter Types.Temperature Tstart = 300;
      parameter Types.GasDensity dstart = 200;
      parameter Types.SpecificEnthalpy hstart = cp*(Tstart-T0);
      parameter Types.SpecificEnergy u_start = cv*(Tstart-T0);
      parameter Real MM = 0.029;
      parameter Types.Temperature T0 = 298;
      parameter Types.SpecificHeatCapacity cp = 1000;
      final parameter Types.SpecificHeatCapacity cv = cp - R/MM;
    equation
      p/pstart = (d*R/MM*T)/pstart;
      h/hstart = (cp*(T-T0))/hstart;
      u/u_start = (cv*(T-T0))/u_start;
      dd_dT = -d/T;
      dd_dp = d/p;
    end Gas;

    model Liquid
      input Types.Pressure p(start=pstart,fixed=false);
      input Types.Temperature T(start=Tstart,fixed=false);
      Types.LiquidDensity d(start=d_start);
      Types.SpecificEnthalpy h(start=h_start);
      Types.SpecificEnergy u(start=u_start);
      parameter Types.Pressure pstart = 101325;
      parameter Types.Temperature Tstart = 300;
      parameter Types.LiquidDensity d_start = (1 +(pstart-reference_p)*kappa_const-(Tstart-reference_T)*beta_const)*reference_d;
      parameter Types.SpecificEnthalpy h_start = reference_h+(Tstart-reference_T)*cp_const+(pstart-reference_p)*(1-beta_const*reference_T)/d_start;
      parameter Types.SpecificEnergy u_start = h_start - pstart/d_start;
      parameter Types.Pressure reference_p=101325;
      parameter Types.Temperature reference_T=278.15;
      parameter Types.LiquidDensity reference_d=997.05;
      parameter Types.SpecificEnthalpy reference_h=104929;
      parameter Real reference_s=100.0;
      parameter Types.SpecificHeatCapacity cp_const=4000;
      parameter Real beta_const=2.5713e-4;
      parameter Modelica.SIunits.IsothermalCompressibility kappa_const=4.5154e-10;
    equation
      d/d_start = ((1 +(p-reference_p)*kappa_const-(T-reference_T)*beta_const)*reference_d)/d_start;
      h/h_start = (reference_h+(T-reference_T)*cp_const+(p-reference_p)*(1-beta_const*reference_T)/d)/h_start;
      u/u_start = (h - p/d)/u_start;
    end Liquid;

    model WaterLiquid
      extends CombinedCycle.Substances.Interfaces.LinearizedSubstance(p(start=pstart));
      input Types.Temperature T(start=Tstart);
      Types.Temperature T_s(start=T_s_start);
      Types.LiquidDensity d(start=dstart);
      Types.SpecificEnthalpy h(start=h_start);
      Types.SpecificEnthalpy h_ls(start=h_ls_start);
      Types.SpecificEnergy u(start=u_start);
      parameter Types.LiquidDensity dstart = 1000;
      parameter Types.Pressure pstart = 101325;
      parameter Types.Temperature Tstart = 300;
      parameter Types.SpecificEnthalpy h_ls_start = ((+(-95283.5))*pstart/p_nom+(598763))*pstart/p_nom+(860172);
      parameter Types.SpecificEnthalpy h_start = h_ls_start+(Tstart-T_s_start)*cp;
      parameter Types.Temperature T_s_start = ((+(-27.7273))*pstart/p_nom+(127.337))*pstart/p_nom+(476.887);
      parameter Types.SpecificEnergy u_start = h_start-pstart/dstart;
      parameter Types.Pressure reference_p=101325;
      parameter Types.LiquidDensity reference_d=997.05;
      parameter Real reference_s=100.0;
      parameter Types.SpecificHeatCapacity cp=4000;
      parameter Types.SpecificHeatCapacity cv=cp;
      parameter Real beta_const=2.5713e-4;
      parameter Modelica.SIunits.IsothermalCompressibility kappa_const=4.5154e-10;
    equation
      h_ls = (((+(-95283.5))*p/p_nom+(598763))*p/p_nom+(860172));
      T_s = (((+(-27.7273))*p/p_nom+(127.337))*p/p_nom+(476.887));
      d = ((1 +(p-reference_p)*kappa_const-(T-T_s)*beta_const)*reference_d);
      h/h_start = (h_ls+(T-T_s)*cp)/h_start;
      u/u_start = (h - p/d)/u_start;
      assert(T<=T_s,"This model is valid only if T<=T saturation.\nSaturation temperature is: "+String(T_s)+"[K], while the temperature is: "+String(T)+"[K].");
    end WaterLiquid;

    model WaterSaturation
    extends CombinedCycle.Substances.Interfaces.LinearizedSubstance(p(start=pstart));
      //Start parameters
      parameter Types.Pressure pstart = 101325;
      parameter Types.Temperature T_s_start = (((+(20.31))*pstart/6e+006+(-91.2087))*pstart/6e+006+(186.107))*pstart/6e+006+(433.8);
      parameter Real de_ls_start = (((+(6.7412e+007))*pstart/6e+006+(-3.09753e+008))*pstart/6e+006+(5.27973e+008))*pstart/6e+006+(6.29324e+008);
      parameter Real de_vs_start = (((+(1.30191))*pstart/6e+006+(0.432043))*pstart/6e+006+(28.7046))*pstart/6e+006+(0.377505);
      parameter Types.SpecificEnthalpy h_ls_start = (((+(87156.9))*pstart/6e+006+(-382184))*pstart/6e+006+(837267))*pstart/6e+006+(672632);
      parameter Types.SpecificEnthalpy h_vs_start = (((+(25274.6))*pstart/6e+006+(-125274))*pstart/6e+006+(108335))*pstart/6e+006+(2.77663e+006);
      parameter Real d_T_s_dp_start = ((+(1.0155e-005))*pstart/6e+006+(-3.04029e-005))*pstart/6e+006+(3.10178e-005);
      parameter Real d_d_ls_dp_start = ((+(-9.92635e-006))*pstart/6e+006+(2.79053e-005))*pstart/6e+006+(-3.66374e-005);
      parameter Real d_d_vs_dp_start = ((+(6.50955e-007))*pstart/6e+006+(1.44014e-007))*pstart/6e+006+(4.7841e-006);
      parameter Real d_de_ls_dp_start = ((+(33.706))*pstart/6e+006+(-103.251))*pstart/6e+006+(87.9954);
      parameter Real d_de_vs_dp_start = ((+(1.19451))*pstart/6e+006+(0.462225))*pstart/6e+006+(12.5438);
      parameter Types.SpecificEnergy u_ls_start = h_ls_start - pstart/d_ls_start;
      parameter Types.SpecificEnergy u_vs_start = h_vs_start - pstart/d_vs_start;
      parameter Types.LiquidDensity d_ls_start = 1000;
      parameter Types.GasDensity d_vs_start = 100;
      //Saturation properties
      Types.Temperature T_s(start=T_s_start) "Saturation temperature";
      Types.LiquidDensity d_ls(start=d_ls_start)
        "Density of liquid at saturation";
      Types.GasDensity d_vs(start=d_vs_start) "Density of vapour at saturation";
      Real de_ls(start=de_ls_start,nominal = 1e9)
        "Density-specific energy product for liquid at saturation condition";
      Real de_vs(start=de_vs_start,nominal = 1e7)
        "Density-specific energy product for vapour at saturation condition";
      Types.SpecificEnthalpy h_ls(start=h_ls_start);
      Types.SpecificEnthalpy h_vs(start=h_vs_start);
      Real d_T_s_dp(start=d_T_s_dp_start,nominal = 1e-5);
      Real d_d_ls_dp(start=d_d_ls_dp_start,nominal = 1e-3);
      Real d_d_vs_dp(start=d_d_vs_dp_start,nominal = 1e-6);
      Real d_de_ls_dp(start=d_de_ls_dp_start,nominal = 1e3);
      Real d_de_vs_dp(start=d_de_vs_dp_start,nominal = 10);
      Types.SpecificEnergy u_ls(start=u_ls_start,nominal = 1e6);
      Types.SpecificEnergy u_vs(start=u_vs_start,nominal = 1e6);
    equation
      T_s = ((((+(20.31))*p/6e+006+(-91.2087))*p/6e+006+(186.107))*p/6e+006+(433.8));
      d_ls = ((((+(-19.8527))*p/6e+006+(83.716))*p/6e+006+(-219.824))*p/6e+006+(913.719));
      d_vs = ((((+(1.30191))*p/6e+006+(0.432043))*p/6e+006+(28.7046))*p/6e+006+(0.377505));
      de_ls = ((((+(6.7412e+007))*p/6e+006+(-3.09753e+008))*p/6e+006+(5.27973e+008))*p/6e+006+(6.29324e+008));
      de_vs = ((((+(2.38902e+006))*p/6e+006+(1.38667e+006))*p/6e+006+(7.5263e+007))*p/6e+006+(772937));
      h_ls = ((((+(87156.9))*p/6e+006+(-382184))*p/6e+006+(837267))*p/6e+006+(672632));
      h_vs = ((((+(25274.6))*p/6e+006+(-125274))*p/6e+006+(108335))*p/6e+006+(2.77663e+006));
      d_T_s_dp = ((+(1.0155e-005))*p/6e+006+(-3.04029e-005))*p/6e+006+(3.10178e-005);
      d_d_ls_dp = (((+(-9.92635e-006))*p/6e+006+(2.79053e-005))*p/6e+006+(-3.66374e-005));
      d_d_vs_dp = (((+(6.50955e-007))*p/6e+006+(1.44014e-007))*p/6e+006+(4.7841e-006));
      d_de_ls_dp = (((+(33.706))*p/6e+006+(-103.251))*p/6e+006+(87.9954));
      d_de_vs_dp = (((+(1.19451))*p/6e+006+(0.462225))*p/6e+006+(12.5438));
      u_ls = (h_ls - p/d_ls);
      u_vs = (h_vs - p/d_vs);
    end WaterSaturation;

    model WaterVapour
    extends CombinedCycle.Substances.Interfaces.LinearizedSubstance(p(start=pstart));
      input Types.Temperature T(start=Tstart);
      Types.Temperature T_s(start=T_s_start);
      Types.GasDensity d(start=dstart);
      Types.SpecificEnthalpy h(start=h_start);
      Types.SpecificEnthalpy h_vs(start=h_vs_start);
      Types.SpecificEnergy u(start=u_start);
      parameter Types.LiquidDensity dstart = 900;
      parameter Types.Pressure pstart = 101325;
      parameter Types.Temperature Tstart = 300;
      parameter Types.Temperature T_s_start = ((+(-27.7273))*pstart/p_nom+(127.337))*pstart/p_nom+(476.887);
      parameter Types.SpecificEnthalpy h_start = h_vs_start+(Tstart-T_s_start)*cp;
      parameter Types.SpecificEnthalpy h_vs_start = ((+(-68021.4))*pstart/p_nom+(-13108.2))*pstart/p_nom+(2.82401e+06);
      parameter Types.SpecificEnergy u_start =  h_start - pstart/dstart;
      parameter Types.Pressure reference_p=80e5;
      parameter Types.LiquidDensity reference_d=23;
      parameter Real reference_s=100.0;
      parameter Types.SpecificHeatCapacity cp=2500;
      parameter Types.SpecificHeatCapacity cv=1800;
      parameter Real beta_const=2.5713e-4;
      parameter Modelica.SIunits.IsothermalCompressibility kappa_const=4.5154e-10;
    equation
      h_vs = (((+(-68021.4))*p/p_nom+(-13108.2))*p/p_nom+(2.82401e+06));
      T_s = (((+(-27.7273))*p/p_nom+(127.337))*p/p_nom+(476.887));
      d = ((1 +(p-reference_p)*kappa_const-(T-T_s)*beta_const)*reference_d);
      h/h_start = (h_vs+(T-T_s)*cp)/h_start;
      u/u_start = (h - p/d)/u_start;
      //assert(T+1e-3>T_s,"This model is valid only if T>=T saturation.\nSaturation temperature is: "+String(T_s)+"[K], while the temperature is: "+String(T)+"[K].");
    end WaterVapour;

    package Interfaces
      partial model LinearizedSubstance
        import Modelica.SIunits.*;
        //Fitting parameters
        parameter Types.Pressure p_min = 80e5;
        parameter Types.Pressure p_max = 100e5;
        parameter Types.Pressure p_nom = (p_min+p_max)/2;
        input Types.Pressure p;
      equation
        assert(p<p_max or p>p_min,
        "Saturation properties have been calculated for a specific range of pressures: "+
         String(p_min)+"[Pa] : "+String(p_max)+"[Pa], but pressure now is equal to: "+
         String(p)+".\nPlease reload functions or check your model.");
      end LinearizedSubstance;
    end Interfaces;
  end Substances;

  package Connectors
  connector FlangeA "A-type flange connector for gas flows"
    Types.Pressure p(start=1e5) "Pressure";
    flow Types.MassFlowRate w "Mass flowrate";
    input Types.SpecificEnthalpy h "Specific enthalpy of fluid";
    annotation (Icon(graphics={Ellipse(
              extent={{-100,100},{100,-100}},
              lineColor={159,159,223},
              fillColor={159,159,223},
              fillPattern=FillPattern.Solid)}),
                              Documentation(info="<HTML>
<p> Must always be connected to a single type-B connector <tt>FlangeB</tt>.
</HTML>", revisions="<html>
<ul>
<li><i>20 Dec 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
  end FlangeA;

  connector FlangeB "B-type flange connector for gas flows"
    Types.Pressure p(start=1e5) "Pressure";
    flow Types.MassFlowRate w "Mass flowrate";
    output Types.SpecificEnthalpy h "Specific enthalpy of fluid";
       annotation (Icon(graphics={Ellipse(
            extent={{-100,100},{100,-100}},
            lineColor={159,159,223},
            fillColor={159,159,223},
            fillPattern=FillPattern.Solid), Ellipse(
            extent={{-42,44},{44,-40}},
            lineColor={159,159,223},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid)}),
                              Documentation(info="<HTML>
<p> Must always be connected to a single type-A connector <tt>FlangeA</tt>.
</HTML>", revisions="<html>
<ul>
<li><i>20 Dec 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
  end FlangeB;

    connector HeatPort_a
      "Thermal port for 1-dim. heat transfer (filled rectangular icon)"
      Types.Temperature T "Port temperature";
      flow Types.HeatFlowRate Q_flow
        "Heat flow rate (positive if flowing from outside into the component)";
      annotation(defaultComponentName = "port_a",
        Documentation(info="<HTML>
<p>This connector is used for 1-dimensional heat flow between components.
The variables in the connector are:</p>
<pre>   
   T       Temperature in [Kelvin].
   Q_flow  Heat flow rate in [Watt].
</pre>
<p>According to the Modelica sign convention, a <b>positive</b> heat flow
rate <b>Q_flow</b> is considered to flow <b>into</b> a component. This
convention has to be used whenever this connector is used in a model
class.</p>
<p>Note, that the two connector classes <b>HeatPort_a</b> and
<b>HeatPort_b</b> are identical with the only exception of the different
<b>icon layout</b>.</p></HTML>
"),     Icon(graphics={Rectangle(
              extent={{-100,100},{100,-100}},
              lineColor={191,0,0},
              fillColor={191,0,0},
              fillPattern=FillPattern.Solid)}),
        Diagram(graphics={Rectangle(
              extent={{-50,50},{50,-50}},
              lineColor={191,0,0},
              fillColor={191,0,0},
              fillPattern=FillPattern.Solid), Text(
              extent={{-120,120},{100,60}},
              lineColor={191,0,0},
              textString=
                   "%name")}));
    end HeatPort_a;

    connector HeatPort_b
      "Thermal port for 1-dim. heat transfer (unfilled rectangular icon)"
      Types.Temperature T "Port temperature";
      flow Types.HeatFlowRate Q_flow
        "Heat flow rate (positive if flowing from outside into the component)";
      annotation(defaultComponentName = "port_b",
        Documentation(info="<HTML>
<p>This connector is used for 1-dimensional heat flow between components.
The variables in the connector are:</p>
<pre>
   T       Temperature in [Kelvin].
   Q_flow  Heat flow rate in [Watt].
</pre>
<p>According to the Modelica sign convention, a <b>positive</b> heat flow
rate <b>Q_flow</b> is considered to flow <b>into</b> a component. This
convention has to be used whenever this connector is used in a model
class.</p>
<p>Note, that the two connector classes <b>HeatPort_a</b> and
<b>HeatPort_b</b> are identical with the only exception of the different
<b>icon layout</b>.</p></HTML>
"),     Diagram(graphics={Rectangle(
              extent={{-50,50},{50,-50}},
              lineColor={191,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid), Text(
              extent={{-100,120},{120,60}},
              lineColor={191,0,0},
              textString=
                   "%name")}),
        Icon(graphics={Rectangle(
              extent={{-100,100},{100,-100}},
              lineColor={191,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid)}));
    end HeatPort_b;

    connector DHT "Distributed Heat Terminal"
      parameter Integer N(min=1)=2 "Number of nodes";
      Types.Temperature T[N] "Temperature at the nodes";
      flow Types.HeatFlux phi[N] "Heat flux at the nodes";
      annotation (Icon(graphics={Rectangle(
              extent={{-100,100},{100,-100}},
              lineColor={255,127,0},
              fillColor={255,127,0},
              fillPattern=FillPattern.Solid)}));
    end DHT;

    connector DHT_N1 "Distributed Heat Terminal"
      Types.Temperature T "Temperature at the nodes";
      flow Types.HeatFlux phi "Heat flux at the nodes";
      annotation (Icon(graphics={Rectangle(
              extent={{-100,100},{100,-100}},
              lineColor={255,127,0},
              fillColor={255,127,0},
              fillPattern=FillPattern.Solid)}));
    end DHT_N1;
  end Connectors;

  package Components
    package Gas
      model SourceP "Pressure source for gas flows"
        extends CombinedCycle.Icons.Gas.SourceP;
        parameter Types.Pressure pnom=101325 "Nominal pressure";
        parameter Real Res=1 "Hydraulic resistance";
        parameter Types.Temperature Tnom=300 "Nominal temperature";
        CombinedCycle.Substances.Gas gas(p = pnom, T = Tnom);
        CombinedCycle.Connectors.FlangeB flange
          annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
      equation
        flange.p = gas.p + flange.w*Res;
        flange.h = gas.h;
        annotation (Icon(graphics),
                          Diagram(graphics),
          Documentation(info="<html>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package.In the case of multiple componet, variable composition gases, the nominal gas composition is given by <tt>Xnom</tt>, whose default value is <tt>Medium.reference_X</tt> .
<p>If <tt>R</tt> is set to zero, the pressure source is ideal; otherwise, the outlet pressure decreases proportionally to the outgoing flowrate.</p>
<p>If the <tt>in_p</tt> connector is wired, then the source pressure is given by the corresponding signal, otherwise it is fixed to <tt>p0</tt>.</p>
<p>If the <tt>in_T</tt> connector is wired, then the source temperature is given by the corresponding signal, otherwise it is fixed to <tt>T</tt>.</p>
<p>If the <tt>in_X</tt> connector is wired, then the source massfraction is given by the corresponding signal, otherwise it is fixed to <tt>Xnom</tt>.</p>
</html>",     revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Removed <tt>p0fix</tt> and <tt>Tfix</tt> and <tt>Xfix</tt>; the connection of external signals is now detected automatically.</li> <br> Adapted to Modelica.Media
<li><i>1 Oct 2003</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>
"));
      end SourceP;

      model SinkP "Pressure sink for gas flows"
        extends CombinedCycle.Icons.Gas.SourceP;
        parameter Types.Pressure pnom=101325 "Nominal pressure";
        parameter Types.Temperature Tnom=300 "Nominal temperature";
        parameter Real Res=1 "Hydraulic Resistance";
        CombinedCycle.Substances.Gas gas(p = pnom, T = Tnom);
        CombinedCycle.Connectors.FlangeA flange
          annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
      equation
        flange.p = gas.p + flange.w*Res;
        annotation (Icon(graphics),
          DymolaStoredErrors,
          Diagram(graphics),
          Documentation(info="<html>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the nominal gas composition is given by <tt>Xnom</tt>, whose default value is <tt>Medium.reference_X</tt> .
<p>If <tt>R</tt> is set to zero, the pressure sink is ideal; otherwise, the inlet pressure increases proportionally to the outgoing flowrate.</p>
<p>If the <tt>in_p</tt> connector is wired, then the source pressure is given by the corresponding signal, otherwise it is fixed to <tt>p0</tt>.</p>
<p>If the <tt>in_T</tt> connector is wired, then the source temperature is given by the corresponding signal, otherwise it is fixed to <tt>T</tt>.</p>
<p>If the <tt>in_X</tt> connector is wired, then the source massfraction is given by the corresponding signal, otherwise it is fixed to <tt>Xnom</tt>.</p>
</html>",     revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Removed <tt>p0fix</tt> and <tt>Tfix</tt> and <tt>Xfix</tt>; the connection of external signals is now detected automatically.</li>
<br> Adapted to Modelica.Media
<li><i>1 Oct 2003</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end SinkP;

      model SourceW "Flowrate source for gas flows"
        extends CombinedCycle.Icons.Gas.SourceW;
        parameter Types.Pressure pnom=101325 "Nominal pressure";
        parameter Types.Temperature Tnom=300 "Nominal temperature";
        parameter Types.MassFlowRate wnom=0 "Nominal mass flowrate";
        parameter Real G=1 "HydraulicConductance";
        Types.MassFlowRate w;
        CombinedCycle.Substances.Gas gas(pstart=pnom,Tstart=Tnom);
        CombinedCycle.Connectors.FlangeB flange(w(start=wnom))
          annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
      equation
        flange.w = -w + (flange.p - pnom)*G;
        w = wnom "Flow rate set by parameter";
        gas.p = flange.p;
        gas.h = flange.h;
        gas.T  = Tnom "Temperature set by parameter";
        annotation (Icon(graphics),
          Documentation(info="<html>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the nominal gas composition is given by <tt>Xnom</tt>,whose default value is <tt>Medium.reference_X</tt> .
<p>If <tt>G</tt> is set to zero, the flowrate source is ideal; otherwise, the outgoing flowrate decreases proportionally to the outlet pressure.</p>
<p>If the <tt>in_w0</tt> connector is wired, then the source massflowrate is given by the corresponding signal, otherwise it is fixed to <tt>w0</tt>.</p>
<p>If the <tt>in_T</tt> connector is wired, then the source temperature is given by the corresponding signal, otherwise it is fixed to <tt>T</tt>.</p>
<p>If the <tt>in_X</tt> connector is wired, then the source massfraction is given by the corresponding signal, otherwise it is fixed to <tt>Xnom</tt>.</p>
</html>",     revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Removed <tt>w0fix</tt> and <tt>Tfix</tt> and <tt>Xfix</tt>; the connection of external signals is now detected automatically.</li> <br> Adapted to Modelica.Media
<li><i>1 Oct 2003</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end SourceW;

      model SinkW "Flowrate sink for gas flows"
        extends CombinedCycle.Icons.Gas.SourceW;
        parameter Types.Pressure pnom=101325 "Nominal pressure";
        parameter Types.Temperature Tnom=300 "Nominal Temperature";
        parameter Types.MassFlowRate wnom=0 "Nominal mass flowrate";
        parameter Real G=1 "Hydraulic Conductance";
        Types.MassFlowRate w;
        CombinedCycle.Substances.Gas gas(pstart=pnom,Tstart=Tnom);
        CombinedCycle.Connectors.FlangeA flange(w(start=wnom))
          annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
      equation
        flange.w = w + (flange.p - pnom)*G;
        w = wnom "Flow rate set by parameter";
        gas.T = Tnom "Temperature set by parameter";
        flange.p = gas.p;
        annotation (Icon(graphics),
                          Diagram(graphics),
          Documentation(info="<html>
<p>The actual gas used in the component is determined by the replaceable <tt>GasModel</tt> model. In the case of multiple component, variable composition gases, the nominal gas composition is given by <tt>Xnom</tt>, whose default value is <tt>Medium.reference_X</tt> .
<p>If <tt>G</tt> is set to zero, the flowrate source is ideal; otherwise, the incoming flowrate increases proportionally to the outlet pressure.</p>
<p>If the <tt>in_w0</tt> connector is wired, then the source massflowrate is given by the corresponding signal, otherwise it is fixed to <tt>w0</tt>.</p>
<p>If the <tt>in_T</tt> connector is wired, then the source temperature is given by the corresponding signal, otherwise it is fixed to <tt>T</tt>.</p>
<p>If the <tt>in_X</tt> connector is wired, then the source massfraction is given by the corresponding signal, otherwise it is fixed to <tt>Xnom</tt>.</p>
</html>",     revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Removed <tt>w0fix</tt> and <tt>Tfix</tt> and <tt>Xfix</tt>; the connection of external signals is now detected automatically.</li> <br> Adapted to Modelica.Media
<li><i>1 Oct 2003</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end SinkW;

      model PressDrop "Pressure drop for gas flows"
        extends CombinedCycle.Icons.Gas.Tube;
          import CombinedCycle.Choices.PressDrop.FFtypes;
        parameter Types.Pressure pstart=101325 "Start pressure value";
        parameter Types.Temperature Tstart=300 "Start temperature value";
        parameter Types.GasDensity dstart=40 "Start density value";
        parameter Types.MassFlowRate wnom "Nominal mass flowrate";
        parameter Real Kf=1000 "Hydraulic resistance coefficient";
        parameter Real wnf=0.01
          "Fraction of nominal flow rate at which linear friction equals turbulent friction";
      protected
        parameter Real Kfl = wnom*wnf*Kf "Linear friction factor";
      public
        CombinedCycle.Connectors.FlangeA inlet(w(start=wnom, nominal = wnom))
                                              annotation (Placement(
              transformation(extent={{-120,-20},{-80,20}}, rotation=0)));
        CombinedCycle.Connectors.FlangeB outlet(w(start=-wnom, nominal = wnom))
                                              annotation (Placement(
              transformation(extent={{80,-20},{120,20}}, rotation=0)));
      public
        CombinedCycle.Substances.Gas gas(pstart=pstart,Tstart=Tstart);
      equation
        // Set fluid properties
        gas.p = inlet.p;
        gas.h = inlet.h;
        // Momentum balance
        inlet.p - outlet.p = Kf*inlet.w^2/gas.d + Kfl*inlet.w/gas.d;
        // Mass balance
        inlet.w + outlet.w = 0;
        // Energy balance
        inlet.h = outlet.h;
        annotation (Icon(graphics={
              Text(extent={{-100,-40},{100,-80}}, textString=      "%name"),
              Rectangle(
                extent={{-60,4},{22,0}},
                lineColor={0,0,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{22,12},{22,-8},{42,2},{22,12}},
                lineColor={0,0,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid)}),
          Diagram(graphics),
         Documentation(info="<html>
<p>The pressure drop across the inlet and outlet connectors is computed according to a turbulent friction model, i.e. is proportional to the squared velocity of the fluid. The friction coefficient can be specified directly, or by giving an operating point, or as a multiple of the kinetic pressure. The correction coefficient <tt>Kfc</tt> can be used to modify the friction coefficient, e.g. to fit some experimental operating point.</p>
<p>A small linear pressure drop is added to avoid numerical singularities at low or zero flowrate. The <tt>wnom</tt> parameter must be always specified; the additional linear pressure drop is such that it is equal to the turbulent pressure drop when the flowrate is equal to <tt>wnf*wnom</tt> (the default value is 1% of the nominal flowrate).
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>, whose default value is <tt>Medium.reference_X</tt>.
<p>The following options are available to specify the friction coefficient:
<ul><li><tt>FFtype = 0</tt>: the hydraulic friction coefficient <tt>Kf</tt> is used directly.</li>
<li><tt>FFtype = 1</tt>: the hydraulic friction coefficient is specified by the nominal operating point (<tt>wnom</tt>,<tt>dpnom</tt>, <tt>rhonom</tt>).</li>
<li><tt>FFtype = 2</tt>: the pressure drop is <tt>K</tt> times the kinetic pressure.</li></ul>
</html>",     revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<br> <tt>Kfnom</tt> removed, <tt>Kf</tt> can now be set directly.</li> 
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end PressDrop;

        model Header "Header with metal walls for gas flows"
          extends CombinedCycle.Icons.Gas.Mixer;
          parameter Types.Pressure pstart=101325 "Pressure start value";
          parameter Types.Temperature Tstart=300 "Temperature start value";
          parameter Types.Temperature Tmstart=300
          "Metal wall start temperature";
          parameter Modelica.SIunits.Volume V "Inner volume";
          parameter Modelica.SIunits.Area S=0 "Inner surface";
          parameter Modelica.SIunits.CoefficientOfHeatTransfer gamma=0
          "Heat Transfer Coefficient"                                                              annotation(Evaluate = true);
          parameter Modelica.SIunits.HeatCapacity Cm=1 "Metal Heat Capacity" annotation(Evaluate = true);
          Types.Pressure p(start=pstart);
          Types.Temperature T(start=Tstart);
          Modelica.SIunits.Mass M(nominal = 30*V) "Gas total mass";
          Types.Temperature Tm(start=Tmstart) "Wall temperature";
          CombinedCycle.Substances.Gas gas(pstart=pstart,Tstart=Tstart);
          Real drho_dp(nominal = 30/1e6);
          Real drho_dT(nominal = 30/500);
          Real der_M;
          Real der_E;
          CombinedCycle.Connectors.FlangeA inlet
            annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
          CombinedCycle.Connectors.FlangeB outlet
            annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
        equation
          //Definitions
          M = gas.d*V;
          p = gas.p;
          T = gas.T;
          der_M = V*(drho_dp*der(p)+drho_dT*der(T));
          der_E = der_M*gas.u + gas.cv*der(T)*M;
          drho_dp = gas.d/gas.p;
          drho_dT = -gas.d/gas.T;
          der_M = inlet.w + outlet.w "Mass balance";
          der_E = inlet.w*inlet.h + outlet.w*outlet.h - gamma*S*(gas.T - Tm)
          "Energy balance";
          Cm*der(Tm) = gamma*S*(gas.T - Tm) "Metal wall energy balance";
          // Boundary conditions
          inlet.p = outlet.p;
          inlet.h = gas.h;
          inlet.p = gas.p;
          assert(Cm > 0 and gamma > 0, "Cm and gamma must be positive");
          annotation (Icon(graphics),
                            Documentation(info="<html>
<p>This model describes a constant volume buffer with metal walls. The metal wall temperature and the heat transfer coefficient between the wall and the fluid are uniform. The wall is thermally insulated from the outside.</p>
<p>If the inlet or the outlet are connected to a bank of tubes, the model can actually represent a collector or a distributor.</p>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>, whose default value is <tt>Medium.reference_X</tt> .
</html>",       revisions="<html>
<ul>
<li><i>30 May 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Initialisation support added.</li>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>
"));
        end Header;

      model FlowJoin "Joins two gas flows"
        extends CombinedCycle.Icons.Gas.FlowJoin;
        constant Types.MassFlowRate wzero=1e-9
          "Small flowrate to avoid singularity in computing the outlet enthalpy and composition";
        CombinedCycle.Connectors.FlangeA inlet1
          annotation (Placement(transformation(extent={{-80,20},{-40,60}},
                rotation=0)));
        CombinedCycle.Connectors.FlangeA inlet2
          annotation (Placement(transformation(extent={{-80,-60},{-40,-20}},
                rotation=0)));
        CombinedCycle.Connectors.FlangeB outlet
          annotation (Placement(transformation(extent={{40,-20},{80,20}},
                rotation=0)));
      equation
        inlet1.w + inlet2.w + outlet.w = 0 "Mass balance";
        // Momentum balance
        inlet1.p = outlet.p;
        inlet2.p = outlet.p;
        // Energy balance
        outlet.hBA = if inlet2.w < 0 then inlet1.hBA else if inlet1.w < 0 then inlet2.hBA else (
          inlet1.hBA*(inlet1.w + wzero) + inlet2.hBA*inlet2.w)/(inlet1.w + wzero + inlet2.w);
        inlet1.hAB = if inlet2.w < 0 then outlet.hAB else if outlet.w < 0 then inlet2.hBA else (
          outlet.hAB*(outlet.w + wzero) + inlet2.hBA*inlet2.w)/(outlet.w + wzero + inlet2.w);
        inlet2.hAB = if inlet1.w < 0 then outlet.hAB else if outlet.w < 0 then inlet1.hBA else (
          outlet.hAB*(outlet.w + wzero) + inlet1.hBA*inlet1.w)/(outlet.w + wzero + inlet1.w);
        // Independent component mass balances
        outlet.XBA = if inlet2.w < 0 then inlet1.XBA else if inlet1.w < 0 then inlet2.XBA else (
          inlet1.XBA*(inlet1.w + wzero) + inlet2.XBA*inlet2.w)/(inlet1.w + wzero + inlet2.w);
        inlet1.XAB = if inlet2.w < 0 then outlet.XAB else if outlet.w < 0 then inlet2.XBA else (
          outlet.XAB*(outlet.w + wzero) + inlet2.XBA*inlet2.w)/(outlet.w + wzero + inlet2.w);
        inlet2.XAB = if inlet1.w < 0 then outlet.XAB else if outlet.w < 0 then inlet1.XBA else (
          outlet.XAB*(outlet.w + wzero) + inlet1.XBA*inlet1.w)/(outlet.w + wzero + inlet1.w);
        annotation (Icon(graphics),
      Documentation(info="<html>
<p>This component allows to join two separate flows into one. The model is based on mass and energy balance equations, without any mass or energy buildup, and without any pressure drop between the inlet and the outlets.
<p>All the physically meaningful combinations of flow directions are allowed.
</html>",     revisions="<html>
<ul>
<li><i>20 Dec 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end FlowJoin;

      model FlowSplit "Splits a gas flow in two"
        extends CombinedCycle.Icons.Gas.FlowSplit;
        constant Modelica.SIunits.MassFlowRate wzero=1e-9
          "Small flowrate to avoid singularity in computing the outlet enthalpy and composition";
        CombinedCycle.Connectors.FlangeA inlet
          annotation (Placement(transformation(extent={{-80,-20},{-40,20}},
                rotation=0)));
        CombinedCycle.Connectors.FlangeB outlet1
          annotation (Placement(transformation(extent={{40,20},{80,60}},
                rotation=0)));
        CombinedCycle.Connectors.FlangeB outlet2
          annotation (Placement(transformation(extent={{40,-60},{80,-20}},
                rotation=0)));
      equation
        inlet.w+outlet1.w+outlet2.w=0 "Mass balance";
        // Momentum balance
        outlet1.p=inlet.p;
        outlet2.p=inlet.p;
        // Energy balance
        outlet1.hBA= if inlet.w<0 then outlet2.hAB else if outlet2.w<0 then inlet.hBA else
          (inlet.hBA*(inlet.w+wzero)+outlet2.hAB*outlet2.w)/(inlet.w+wzero+outlet2.w);
        outlet2.hBA= if inlet.w<0 then outlet1.hAB else if outlet1.w<0 then inlet.hBA else
          (inlet.hBA*(inlet.w+wzero)+outlet1.hAB*outlet1.w)/(inlet.w+wzero+outlet1.w);
        inlet.hAB= if outlet1.w<0 then outlet2.hAB else if outlet2.w<0 then outlet1.hAB else
          (outlet1.hAB*(outlet1.w+wzero)+outlet2.hAB*outlet2.w)/(outlet1.w+wzero+outlet2.w);
        // Independent component mass balances
        outlet1.XBA= if inlet.w<0 then outlet2.XAB else if outlet2.w<0 then inlet.XBA else
          (inlet.XBA*(inlet.w+wzero)+outlet2.XAB*outlet2.w)/(inlet.w+wzero+outlet2.w);
        outlet2.XBA= if inlet.w<0 then outlet1.XAB else if outlet1.w<0 then inlet.XBA else
          (inlet.XBA*(inlet.w+wzero)+outlet1.XAB*outlet1.w)/(inlet.w+wzero+outlet1.w);
        inlet.XAB= if outlet1.w<0 then outlet2.XAB else if outlet2.w<0 then outlet1.XAB else
          (outlet1.XAB*(outlet1.w+wzero)+outlet2.XAB*outlet2.w)/(outlet1.w+wzero+outlet2.w);
        annotation (Icon(graphics),
                          Documentation(info="<html>
<p>This component allows to split a single flow in two ones. The model is based on mass and energy balance equations, without any mass or energy buildup, and without any pressure drop between the inlet and the outlets.
<p>All the physically meaningful combinations of flow directions are allowed.
</html>",     revisions="<html>
<ul>
<li><i>20 Dec 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end FlowSplit;

      model Valve "Valve for gas flow"
        extends CombinedCycle.Icons.Gas.Valve;
        import CombinedCycle.Choices.Valve.CvTypes;
        parameter Types.Pressure pnom=101325 "Nominal inlet pressure";
        parameter Types.Temperature Tstart=300 "Start temperature";
        parameter Types.MassFlowRate wnom=0 "Nominal mass flowrate";
        parameter Types.Pressure dpnom "Nominal pressure drop";
        parameter Modelica.SIunits.Area Av(min=0,
          fixed=if CvData == CvTypes.Av then true else false)=0
          "Av (metric) flow coefficient";
        parameter Real Kv=0 "Kv (metric) flow coefficient [m^3/h]";
        parameter Real Cv=0 "Cv (US) flow coefficient [USG/min]";
        parameter Real b=0.01 "Regularisation factor";
        parameter Real Fxtnom=0.5 "Nominal Fk*xt critical ratio";
        parameter CvTypes.Temp CvData "Selection of flow coefficient";
        parameter Boolean CheckValve=false "Reverse flow stopped";
        replaceable function FlowChar=CombinedCycle.Functions.linear
          "Flow characteristic";
        replaceable function xtfun=CombinedCycle.Functions.one
          "Critical ratio characteristic";
        function sqrtR = CombinedCycle.Functions.sqrtReg (delta=b*dpnom);
        Types.MassFlowRate w;
        Real Fxt;
        Real x "Pressure drop ratio";
        Real xs "Saturated pressure drop ratio";
        Real Y "Compressibility factor";
        CombinedCycle.Substances.Gas gas(pstart=pnom,Tstart=Tstart);
        CombinedCycle.Connectors.FlangeA inlet(    w(start=wnom),p(start=pnom))
          annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
        CombinedCycle.Connectors.FlangeB outlet(    w(start=-wnom),p(start=pnom - dpnom))
          annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
        Modelica.Blocks.Interfaces.RealInput theta
          annotation (Placement(transformation(
              origin={0,72},
              extent={{-10,-10},{10,10}},
              rotation=270)));
      equation
        inlet.w + outlet.w = 0 "Mass balance";
        w = inlet.w;
        // Fluid properties
        gas.p = inlet.p;
        gas.h = inlet.h;
        Fxt = Fxtnom*xtfun(theta);
        x = (inlet.p - outlet.p)/inlet.p;
        xs = smooth(0, if x < -Fxt then -Fxt else if x > Fxt then Fxt else x);
        Y = 1 - abs(xs)/(3*Fxt);
        if CheckValve then
          w = FlowChar(theta)*Av*Y*sqrt(gas.d)*
              smooth(0, if xs>=0 then sqrtR(inlet.p*xs) else 0);
        else
          w = FlowChar(theta)*Av*Y*sqrt(gas.d)*sqrtR(inlet.p*xs);
        end if;
        // Energy balance
        inlet.h = outlet.h;
       annotation (Icon(graphics={Text(extent={{-100,-40},{100,-80}},
                  textString=                                     "%name")}),
          Diagram(graphics),
                   Documentation(info="<html>
<p>This model is based on the IEC 534/ISA S.75 standards for valve sizing, compressible fluid.
<p>The model optionally supports reverse flow conditions (assuming symmetrical behaviour) or check valve operation, and has been suitably modified to avoid numerical singularities at zero pressure drop. 
<p>The model operating range include choked flow operation, due to sonic conditions in the vena contracta. 
<p>The flow characteristic can be customised.
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>,whose default value is <tt>Medium.reference_X</tt>.
<p>The following options are available to specify the valve flow coefficient in fully open conditions:
<ul><li><tt>CvData = 0</tt>: the flow coefficient is given by the metric Av coefficient <tt>Av</tt> (m^2).
<li><tt>CvData = 1</tt>: the flow coefficient is given by the metric Kv coefficient <tt>Kv</tt> (m^3/h).
<li><tt>CvData = 2</tt>: the flow coefficient is given by the US Cv coefficient <tt>Cv</tt> (USG/min).
<li><tt>CvData = 3</tt>: the flow coefficient must be specified by an additional initial equation (e.g. w=0.5); the start value given by Av is used to initialise the numerical solution of the equation. 
</ul>
<p>The nominal inlet pressure <tt>pnom</tt> and pressure drop <tt>dpnom</tt> must always be specified; to avoid numerical singularities, the flow characteristic is modified for pressure drops less than <tt>b*dpnom</tt> (the default value is 1% of the nominal pressure drop). Increase this parameter if numerical instabilities occur in valves with very low pressure drops.
<p>If <tt>CheckValve</tt> is true, then the flow is stopped when the outlet pressure is higher than the inlet pressure; otherwise, reverse flow takes place.
<p>The default flow characteristic <tt>FlowChar</tt> is linear; this can be replaced by any user-defined function (e.g. equal percentage, quick opening, etc.).
<p>The product Fk*xt is given by the parameter <tt>Fxtnom</tt>, and is assumed constant by default. The relative change of the xt coefficient with the valve opening can be specified by customising the <tt>xtfun</tt> function.
</html>",     revisions="<html>
<ul>
<li><i>15 Mar 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Rewritten with sqrtReg.</li>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<br> <tt>Avnom</tt> removed, <tt>Av</tt> can now be set directly. <tt>Kvnom</tt> and <tt>Cvnom</tt> renamed to <tt>Kv</tt> and <tt>Cv</tt>.
<br><tt>CvData=3</tt> no longer uses <tt>dpnom</tt>,<tt>wnom</tt> and <tt>rhonom</tt>, and requires an additional initial equation to set the flow coefficient based on the initial working conditions.
</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>
"),       DymolaStoredErrors);
      end Valve;

      model Turbine "Gas Turbine"
        extends CombinedCycle.Components.Gas.TurbineBase;
        import CombinedCycle.Choices.TurboMachinery.TableTypes;
        parameter Modelica.SIunits.AngularVelocity Ndesign "Design speed";
        parameter Real tablePhic[:,:]=fill(0,0,2) "Table for phic(N_T,PR)";
        parameter Real tableEta[:,:]=fill(0,0,2) "Table for eta(N_T,PR)";
        parameter String fileName="NoName" "File where matrix is stored";
        parameter TableTypes.Temp Table
          "Selection of the way of definition of table matrix";
        Real N_T "Referred speed";
        Real N_T_design "Referred design speed";
        Real phic "Flow number";
        Modelica.Blocks.Tables.CombiTable2D Phic(tableOnFile= if (Table==0) then false else true,
                    table=tablePhic, tableName= if (Table==0) then "NoName" else "tabPhic",
                    fileName= if (Table==0) then "NoName" else  fileName,
          smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative)
          annotation (Placement(transformation(extent={{-10,10},{10,30}},
                rotation=0)));
        Modelica.Blocks.Tables.CombiTable2D Eta(tableOnFile= if (Table==0) then false else true,
                    table=tableEta, tableName= if (Table==0) then "NoName" else "tabEta",
                    fileName= if (Table==0) then "NoName" else  fileName,
          smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative)
          annotation (Placement(transformation(extent={{-10,50},{10,70}},
                rotation=0)));
      equation
        N_T_design=Ndesign/sqrt(Tdes_in) "Referred design velocity";
        N_T = 100*omega/(sqrt(gas_in.T)*N_T_design)
          "Referred speed definition as percentage of design velocity";
        phic = w*sqrt(gas_in.T)/(gas_in.p) "Flow number definition";
        // phic = Phic(PR, N_T)
        Phic.u1=PR;
        Phic.u2=N_T;
        phic=(Phic.y);
        // eta = Eta(PR, N_T)
        Eta.u1=PR;
        Eta.u2=N_T;
        eta=Eta.y;
        annotation (Documentation(info="<html>
This model adds the performance characteristics to the Turbine_Base model, by means of 2D interpolation tables.
<p>The performance characteristics are described by two characteristic equations: the first relates the flow number <tt>phic</tt>, the pressure ratio <tt>PR</tt> and the referred speed <tt>N_T</tt>; the second relates the efficiency <tt>eta</tt>, the flow number <tt>phic</tt>, and the referred speed <tt>N_T</tt> [1]. </p> 
<p>The performance maps are tabulated into two differents tables, <tt>tablePhic</tt> and <tt>tableEta</tt> which express <tt>phic</tt> and <tt>eta</tt> as a function of <tt>N_T</tt> and <tt>PR</tt> respectively, where <tt>N_T</tt> represents the first row and <tt>PR</tt> the first column [2]. The referred speed <tt>N_T</tt> is defined as a percentage of the design referred speed.
<p>The <tt>Modelica.Blocks.Tables.CombiTable2D</tt> interpolates the tables to obtain values of referred flow and efficiency at given levels of referred speed.
<p><b>Modelling options</b></p>
<p>The following options are available to determine how the table is defined:
<ul><li><tt>Table = 0</tt>: the table is explicitly supplied as matrix parameter.
<li><tt>Table = 1</tt>: the table is read from a file; the string <tt>fileName</tt> contains the path to the files where tables are stored, either in ASCII or Matlab binary format.
</ul>
<p><b>References:</b></p>
<ol>
<li>S. L. Dixon: <i>Fluid mechanics, thermodynamics of turbomachinery</i>, Oxford, Pergamon press, 1966, pp. 213.
<li>P. P. Walsh, P. Fletcher: <i>Gas Turbine Performance</i>, 2nd ed., Oxford, Blackwell, 2004, pp. 646.
</ol> 
</html>",       revisions="<html>
<ul>
<li><i>13 Apr 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       New method for calculating performance parameters using tables.</li>
</li>
<li><i>14 Jan 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<br> Turbine model restructured using inheritance.
</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"),Diagram(graphics));
      end Turbine;

      partial model TurbineBase "Gas Turbine"
        extends CombinedCycle.Icons.Gas.Turbine;
          import Modelica.SIunits.*;
        parameter Real eta_mech=0.98 "mechanical efficiency";
        parameter Pressure pstart_in "inlet start pressure"
          annotation(Dialog(tab = "Initialisation"));
        parameter Pressure pstart_out "outlet start pressure"
          annotation(Dialog(tab = "Initialisation"));
        parameter Temperature Tdes_in "inlet design temperature";
        parameter Temperature Tstart_in = Tdes_in "inlet start temperature"
                                    annotation(Dialog(tab = "Initialisation"));
        parameter Temperature Tstart_out "outlet start temperature"
                                     annotation(Dialog(tab = "Initialisation"));
        Angle phi "shaft rotation angle";
        Torque tau "net torque acting on the turbine";
        AngularVelocity omega "shaft angular velocity";
        MassFlowRate w "Gas flow rate";
        SpecificEntropy s_in "Inlet specific entropy";
        SpecificEnthalpy hout_iso "Outlet isentropic enthalpy";
        SpecificEnthalpy hout "Outlet enthalpy";
        AbsolutePressure pout(start=pstart_out) "Outlet pressure";
        Real PR "pressure ratio";
        Real eta "isoentropic efficiency";
        CombinedCycle.Substances.Gas gas_in(pstart(fixed=true)=pstart_in,Tstart(fixed=true)=Tstart_in);
        CombinedCycle.Substances.Gas gas_iso(pstart(fixed=true)=pstart_out,Tstart(fixed=true)=Tstart_out);
        //From simulation of the ThermoPower example it changes of about 1% aroud 1.3.
        parameter Real gamma= 1.3 "Isoentropic expoenent";
        Modelica.Mechanics.Rotational.Interfaces.Flange_a shaft_a
        annotation (Placement(transformation(extent={{-88,-14},{-58,14}},
                rotation=0)));
        Modelica.Mechanics.Rotational.Interfaces.Flange_b shaft_b
        annotation (Placement(transformation(extent={{58,-14},{88,14}},
                rotation=0)));
        CombinedCycle.Connectors.FlangeA inlet
                           annotation (Placement(transformation(extent={{-100,
                  60},{-60,100}}, rotation=0)));
        CombinedCycle.Connectors.FlangeB outlet
                           annotation (Placement(transformation(extent={{60,60},
                  {100,100}}, rotation=0)));
      equation
        w = inlet.w;
        assert(w >= 0, "The turbine model does not support flow reversal");
        inlet.w + outlet.w = 0 "Mass balance";
        // Set inlet gas properties
        gas_in.p = inlet.p;
        gas_in.h = inlet.h;
        // Set outlet gas properties
        outlet.p = pout;
        outlet.h = hout;
        //explicitIsentropicEnthalpy
        hout_iso = gas_in.h+gamma/(gamma-1.0)*gas_in.p/gas_in.d*((outlet.p/gas_in.p)^((gamma-1)/gamma)-1.0)
          "Approximated isentropic enthalpy";
        hout - gas_in.h = eta*(hout_iso-gas_in.h) "Enthalpy change";
        //dummy assignments
        s_in=0;
        gas_iso.p=1e5;
        gas_iso.T=300;
        w*(hout - gas_in.h)*eta_mech = tau*omega "Energy balance";
        PR=gas_in.p/pout "Pressure ratio";
        // Mechanical boundary conditions
        shaft_a.phi = phi;
        shaft_b.phi = phi;
        shaft_a.tau + shaft_b.tau = tau;
        der(phi) = omega;
        annotation (Documentation(info="<html>
<p>This is the base model for a turbine, including the interface and all equations except the actual computation of the performance characteristics. Reverse flow conditions are not supported.</p> 
<p>This model does not include any shaft inertia by itself; if that is needed, connect a Modelica.Mechanics.Rotational.Inertia model to one of the shaft connectors.</p> 
<p>As a base-model, it can be used both for axial and radial turbines. 
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>, whose default value is <tt>Medium.reference_X</tt>.
<p>The following options are available to calculate the enthalpy of the outgoing gas:
<ul><li><tt>explicitIsentropicEnthalpy = true</tt>: the isentropic enthalpy <tt>hout_iso</tt> is calculated by the <tt>Medium.isentropicEnthalpy</tt> function. <li><tt>explicitIsentropicEnthalpy = false</tt>: the isentropic enthalpy is determined by equating the specific entropy of the inlet gas <tt>gas_in</tt> and of a fictious gas state <tt>gas_iso</tt>, with the same pressure of the outgoing gas; both are computed with the function <tt>Medium.specificEntropy</tt>.</pp></ul>
</html>",     revisions="<html>
<ul>
<li><i>13 Apr 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Medium.BaseProperties <tt>gas_out</tt>removed.</li>
</li>
<li><i>14 Jan 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<br> Turbine model restructured using inheritance.
</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"),     Icon(graphics={Text(
                extent={{-128,-60},{128,-100}},
                lineColor={0,0,255},
                textString=
                     "%name")}));
      end TurbineBase;

      partial model CombustionChamberBase "Combustion Chamber"
        extends CombinedCycle.Icons.Gas.Mixer;
          import Modelica.SIunits.*;
        parameter Pressure pstart=101325 "Pressure start value";
        parameter Temperature Tstart=300 "Temperature start value";
        parameter Volume V "Inner volume";
        parameter Area S=0 "Inner surface";
        parameter CoefficientOfHeatTransfer gamma=0 "Heat Transfer Coefficient"
                                                                                annotation(Evaluate = true);
        parameter HeatCapacity Cm=0 "Metal Heat Capacity" annotation(Evaluate = true);
        parameter Temperature Tmstart=300 "Metal wall start temperature";
        parameter SpecificEnthalpy HH "Lower Heating value of fuel";
        Mass M "Gas total mass";
        Mass MX "Partial flue gas masses";
        InternalEnergy E "Gas total energy";
        Temperature Tm(start=Tmstart) "Wall temperature";
        SpecificEnthalpy hia "Air specific enthalpy";
        SpecificEnthalpy hif "Fuel specific enthalpy";
        SpecificEnthalpy ho "Outlet specific enthalpy";
        Power HR "Heat rate";
        Time Tr "Residence time";
        CombinedCycle.Substances.Gas gas(pstart=pstart,Tstart=Tstart);
        CombinedCycle.Connectors.FlangeA ina "inlet air"
          annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
        CombinedCycle.Connectors.FlangeA inf "inlet fuel"
          annotation (Placement(transformation(extent={{-20,80},{20,120}},
                rotation=0)));
        CombinedCycle.Connectors.FlangeB out "flue gas"
          annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
      equation
        M=gas.d*V "Gas mass";
        E=gas.u*M "Gas energy";
        HR = inf.w*HH;
        der(M) = ina.w+inf.w+out.w "Gas mass balance";
        der(E) = ina.w*ina.h+inf.w*inf.h+out.w*out.h+HR-gamma*S*(gas.T - Tm)
          "Gas energy balance";
        Cm*der(Tm) = gamma*S*(gas.T - Tm) "Metal wall energy balance";
        // Set gas properties
        out.p=gas.p;
        out.h=gas.h;
        // Boundary conditions
        ina.p   = gas.p;
        ina.h = 0;
        inf.p   = gas.p;
        inf.h = 0;
        assert(ina.w >= 0,"The model does not support flow reversal");
         hia = ina.h;
        assert(inf.w >=0, "The model does not support flow reversal");
         hif = inf.h;
        assert(out.w <=0, "The model does not support flow reversal");
         ho = h;
        Tr=noEvent(M/max(abs(out.w),Modelica.Constants.eps));
        assert( not
                   ( Cm > 0 and gamma > 0), "Cm and gamma must be positive");
        annotation (Icon(graphics),
          Documentation(info="<html>
This is the model-base of a Combustion Chamber, with a constant volume. 
<p>The metal wall temperature and the heat transfer coefficient between the wall and the fluid are uniform. The wall is thermally insulated from the outside. It has been assumed that inlet gases are premixed before entering in the volume.
<p><b>Modelling options</b></p>
<p>This model has three different Medium models to characterize the inlet air, fuel, and flue gas exhaust.
<p>If <tt>gamma = 0</tt>, the thermal effects of the surrounding walls are neglected.
</p>
</html>",     revisions="<html>
<ul>
<li><i>30 May 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Initialisation support added.</li>
<li><i>31 Jan 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
    CombustionChamber model restructured using inheritance.   
<p> First release.</li>
</ul>
</html>
"));
      end CombustionChamberBase;

      model Plenum "Rigid adiabatic volume"
        extends CombinedCycle.Icons.Gas.Mixer;
          import Modelica.SIunits.*;
        parameter Pressure pstart=101325 "Pressure start value";
        parameter Temperature Tstart=300 "Temperature start value";
        parameter MassFraction Xstart "Start gas composition";
        parameter Volume V "Inner volume";
        parameter CombinedCycle.Choices.Init.Options.Temp initOpt=CombinedCycle.Choices.
            Init.Options.noInit "Initialisation option";
        Mass M "Total mass";
        InternalEnergy E "Total internal energy";
        SpecificEnthalpy hi "Inlet specific enthalpy";
        SpecificEnthalpy ho "Outlet specific enthalpy";
        MassFraction Xi_i "Inlet composition";
        MassFraction Xi_o "Outlet composition";
        Time Tr "Residence Time";
        CombinedCycle.Connectors.FlangeA inlet
          annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
        CombinedCycle.Connectors.FlangeB outlet
          annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
        Pressure p(start=pstart);
        MassFraction Xi(start=Xstart);
        Temperature T(start=Tstart);
        Density d;
        SpecificEnthalpy h;
        SpecificEnergy u;
        constant Real R=Modelica.Constants.R;
        constant Real MM = 1 "CHANGE HERE";
        constant Temperature T0 = 0 "CHANGE HERE";
        constant Real cp = 1 "CHANGE HERE";
      equation
        //Fluid properties definition
        p = d*R/MM*T;
        h = cp*(T-T0);
        u = cp*T;
        M = d*V "Gas mass";
        E = M*u "Gas internal energy";
        der(M) = inlet.w + outlet.w "Mass balance";
        der(E) = inlet.w*hi + outlet.w*ho "Energy balance";
        M*der(Xi) = inlet.w*(Xi_i - Xi) + outlet.w*(Xi_o - Xi);
        // Boundary conditions
        if inlet.w >= 0 then
          hi = inlet.hBA;
          Xi_i = inlet.XBA;
        else
          hi = h;
          Xi_i = Xi;
        end if;
        if outlet.w >= 0 then
          ho = inlet.hAB;
          Xi_o = inlet.XAB;
        else
          ho = h;
          Xi_o = Xi;
        end if;
        inlet.hAB = h;
        inlet.XAB = Xi;
        outlet.hBA = h;
        outlet.XBA = Xi;
        inlet.p = p;
        outlet.p = p;
        Tr=noEvent(M/max(abs(outlet.w),Modelica.Constants.eps))
          "Residence time";
      initial equation
        // Initial conditions
        if initOpt == CombinedCycle.Choices.Init.Options.noInit then
          // do nothing
        elseif initOpt == CombinedCycle.Choices.Init.Options.steadyState then
          der(p) = 0;
          der(T) = 0;
          der(Xi)=0;
        elseif initOpt == CombinedCycle.Choices.Init.Options.steadyStateNoP then
          der(T) = 0;
          der(Xi)=0;
        else
          assert(false, "Unsupported initialisation option");
        end if;
        annotation (Documentation(info="<html>
<p>This model describes a rigid, adiabatic control volume. 
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>, whose default value is <tt>Medium.reference_X</tt> .
</html>",     revisions="<html>
<ul>
<li><i>30 May 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Initialisation support added.</li>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"),       Icon(graphics));
      end Plenum;

      model Mixer "Mixer with metal walls for gas flows"
        extends CombinedCycle.Icons.Gas.Mixer;
          import Modelica.SIunits.*;
        parameter Pressure pstart=101325 "Pressure start value";
        parameter Temperature Tstart=300 "Temperature start value";
        parameter MassFraction Xstart "Start gas composition";
        parameter Volume V "Inner volume";
        parameter Area S=0 "Inner surface";
        parameter Real gamma=0 "Heat Transfer Coefficient"                      annotation(Evaluate = true);
        parameter HeatCapacity Cm=0 "Metal heat capacity" annotation(Evaluate = true);
        parameter Temperature Tmstart=300 "metal wall start temperature";
        parameter CombinedCycle.Choices.Init.Options.Temp initOpt=CombinedCycle.Choices.
            Init.Options.noInit "Initialisation option";
        Mass M "Gas total mass";
        InternalEnergy E "Gas total energy";
        Temperature Tm(start=Tmstart) "Wall temperature";
        SpecificEnthalpy hi1 "Inlet 1 specific enthalpy";
        SpecificEnthalpy hi2 "Inlet 2 specific enthalpy";
        SpecificEnthalpy ho "Outlet specific enthalpy";
        MassFraction Xi1 "Inlet 1 composition";
        MassFraction Xi2 "Inlet 2 composition";
        MassFraction Xo "Outlet composition";
        Time Tr "Residence time";
        CombinedCycle.Connectors.FlangeA in1
          annotation (Placement(transformation(extent={{-100,40},{-60,80}},
                rotation=0)));
        CombinedCycle.Connectors.FlangeB out
          annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
        CombinedCycle.Connectors.FlangeA in2
          annotation (Placement(transformation(extent={{-100,-80},{-60,-40}},
                rotation=0)));
        Pressure p(start=pstart);
        MassFraction X(start=Xstart);
        Temperature T(start=Tstart);
        Density d;
        SpecificEnthalpy h;
        SpecificEnergy u;
        constant Real R=Modelica.Constants.R;
        constant Real MM = 1 "CHANGE HERE";
        constant Temperature T0 = 0 "CHANGE HERE";
        constant Real cp = 1 "CHANGE HERE";
      equation
        //Fluid properties definition
        p = d*R/MM*T;
        h = cp*(T-T0);
        u = cp*T;
        M = d*V "Gas mass";
        E = M*u "Gas internal energy";
        der(M) = in1.w + in2.w + out.w "Mass balance";
        der(E) = in1.w*hi1 + in2.w*hi2 + out.w*ho - gamma*S*(T - Tm)
          "Energy balance";
        M*der(X) = in1.w*(Xi1 - X) + in2.w*(Xi2 - X) + out.w*(Xo - X)
          "Independent component mass balance";
        if Cm > 0 and gamma > 0 then
          Cm*der(Tm) = gamma*S*(T - Tm) "Metal wall energy balance";
        else
          Tm = T;
        end if;
        // Boundary conditions
        if in1.w >= 0 then
          hi1 = in1.hBA;
          Xi1 = in1.XBA;
        else
          hi1 = h;
          Xi1 = X;
        end if;
        if in2.w >= 0 then
          hi2 = in2.hBA;
          Xi2 = in2.XBA;
        else
          hi2 = h;
          Xi2 = X;
        end if;
        if out.w >= 0 then
          ho = out.hAB;
          Xo = out.XAB;
        else
          ho = h;
          Xo = X;
        end if;
        in1.p   = p;
        in1.hAB = h;
        in1.XAB = X;
        in2.p   = p;
        in2.hAB = h;
        in2.XAB = X;
        out.p   = p;
        out.hBA = h;
        out.XBA = X;
        Tr=noEvent(M/max(abs(out.w),Modelica.Constants.eps)) "Residence time";
      initial equation
        // Initial conditions
        if initOpt == CombinedCycle.Choices.Init.Options.noInit then
          // do nothing
        elseif initOpt == CombinedCycle.Choices.Init.Options.steadyState then
          der(p) = 0;
          der(T) = 0;
          der(X)=0;
          if (Cm > 0 and gamma >0) then
            der(Tm) = 0;
          end if;
        elseif initOpt == CombinedCycle.Choices.Init.Options.steadyStateNoP then
          der(T) = 0;
          der(X)=0;
          if (Cm > 0 and gamma >0) then
            der(Tm) = 0;
          end if;
        else
          assert(false, "Unsupported initialisation option");
        end if;
        annotation (
          Documentation(info="<html>
<p>This model describes a constant volume mixer with metal walls. The metal wall temperature and the heat transfer coefficient between the wall and the fluid are uniform. The wall is thermally insulated from the outside.</p>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>, whose default value is <tt>Medium.reference_X</tt>.
</html>",     revisions="<html>
<ul>
<li><i>30 May 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Initialisation support added.</li>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end Mixer;

        partial model CompressorBase "Gas compressor"
          extends CombinedCycle.Icons.Gas.Compressor;
          import Modelica.SIunits.*;
          parameter Real eta_mech=0.98 "mechanical efficiency";
          parameter Pressure pstart_in "inlet start pressure"
            annotation(Dialog(tab = "Initialisation"));
          parameter Pressure pstart_out "outlet start pressure"
            annotation(Dialog(tab = "Initialisation"));
          parameter Temperature Tdes_in "inlet design temperature";
          parameter Temperature Tstart_in = Tdes_in "inlet start temperature"
                                      annotation(Dialog(tab = "Initialisation"));
          parameter Temperature Tstart_out "outlet start temperature"
                                       annotation(Dialog(tab = "Initialisation"));
          CombinedCycle.Substances.Gas gas_in(pstart=pstart_in,Tstart=Tstart_in);
          CombinedCycle.Substances.Gas gas_iso(pstart=pstart_out,Tstart=Tstart_out);
          SpecificEnthalpy hout_iso "Outlet isentropic enthalpy";
          SpecificEnthalpy hout "Outlet enthaply";
          SpecificEntropy s_in "Inlet specific entropy";
          AbsolutePressure pout(start=pstart_out) "Outlet pressure";
          MassFlowRate w "Gas flow rate";
          Angle phi "shaft rotation angle";
          AngularVelocity omega "shaft angular velocity";
          Torque tau "net torque acting on the compressor";
          Real eta "isentropic efficiency";
          Real PR "pressure ratio";
          //From simulation of the ThermoPower example it does not change.
          parameter Real gamma= 1.3981 "Isoentropic expoenent";
          CombinedCycle.Connectors.FlangeA inlet annotation (Placement(
              transformation(extent={{-100,60},{-60,100}}, rotation=0)));
          CombinedCycle.Connectors.FlangeB outlet annotation (Placement(
              transformation(extent={{60,60},{100,100}}, rotation=0)));
          Modelica.Mechanics.Rotational.Interfaces.Flange_a shaft_a
            annotation (Placement(transformation(extent={{-72,-12},{-48,12}},
                rotation=0)));
          Modelica.Mechanics.Rotational.Interfaces.Flange_b shaft_b
            annotation (Placement(transformation(extent={{48,-12},{72,12}},
                rotation=0)));
        equation
          w = inlet.w;
          assert(w >= 0, "The compressor model does not support flow reversal");
          inlet.w + outlet.w = 0 "Mass balance";
          // Set inlet gas properties
          gas_in.p = inlet.p;
          gas_in.h = inlet.h;
          // Set outlet gas properties
          outlet.p = pout;
          outlet.h = hout;
          hout_iso=   gas_in.h + gamma/(gamma - 1.0)*gas_in.p/gas_in.d*((outlet.p/gas_in.p)^((gamma - 1)/gamma) - 1.0)
          "Approximated isentropic enthalpy";
          hout-gas_in.h= 1/eta*(hout_iso-gas_in.h);
          // dummy assignments
          s_in=0;
          gas_iso.p=1e5;
          gas_iso.T=300;
          w*(hout - gas_in.h)*eta_mech = tau*omega "Energy balance";
          PR=pout/gas_in.p "Pressure ratio";
          // Mechanical boundary conditions
          shaft_a.phi = phi;
          shaft_b.phi = phi;
          shaft_a.tau + shaft_b.tau = tau;
          der(phi) = omega;
          annotation (Documentation(info="<html>
<p>This is the base model for a compressor, including the interface and all equations except the actual computation of the performance characteristics. Reverse flow conditions are not supported.</p> 
<p>This model does not include any shaft inertia by itself; if that is needed, connect a Modelica.Mechanics.Rotational.Inertia model to one of the shaft connectors.</p> 
<p>As a base-model, it can be used both for axial and centrifugal compressors. 
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>, whose default value is <tt>Medium.reference_X</tt>.
<p>The following options are available to calculate the enthalpy of the outgoing gas:
<ul><li><tt>explicitIsentropicEnthalpy = true</tt>: the isentropic enthalpy <tt>hout_iso</tt> is calculated by the <tt>Medium.isentropicEnthalpy</tt> function. <li><tt>explicitIsentropicEnthalpy = false</tt>: the isentropic enthalpy is obtained by equating the specific entropy of the inlet gas <tt>gas_in</tt> and of a fictious gas state <tt>gas_iso</tt>, with the same pressure of the outgoing gas; both are computed with the function <tt>Medium.specificEntropy</tt>.</pp></ul>
</html>",       revisions="<html>
<ul>
<li><i>13 Apr 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Medium.BaseProperties <tt>gas_out</tt>removed.</li>
</li>
<li><i>14 Jan 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<br> Compressor model restructured using inheritance.
</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>
"),                Diagram(graphics),
            Icon(graphics={Text(
                extent={{-128,-60},{128,-100}},
                lineColor={0,0,255},
                textString=
                       "%name")}));
        end CompressorBase;

        model Compressor "Gas compressor"
         extends CompressorBase;
          import CombinedCycle.Choices.TurboMachinery.TableTypes;
          import Modelica.SIunits.*;
         parameter AngularVelocity Ndesign "Design velocity";
         parameter Real tablePhic[:,:]= fill(0,0,2) "Table for phic(N_T,beta)";
         parameter Real tableEta[:,:]=fill(0,0,2) "Table for eta(N_T,beta)";
         parameter Real tablePR[:,:]=fill(0,0,2) "Table for eta(N_T,beta)";
         parameter String fileName="noName" "File where matrix is stored";
         parameter TableTypes.Temp Table
          "Selection of the way of definition of table matrix";
         Modelica.Blocks.Tables.CombiTable2D Eta(tableOnFile= if (Table==0) then false else true,
                        table=tableEta,tableName=if (Table==0) then "NoName" else "tabEta",
                        fileName=if (Table==0) then "NoName" else fileName,
            smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative)
                                                 annotation (Placement(
              transformation(extent={{-12,60},{8,80}}, rotation=0)));
         Modelica.Blocks.Tables.CombiTable2D PressRatio(tableOnFile= if (Table==0) then false else true,
                        table=tablePR, tableName=if (Table==0) then "NoName" else "tabPR",
                        fileName=if (Table==0) then "NoName" else fileName,
            smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative)
            annotation (Placement(transformation(extent={{-12,0},{8,20}},
                rotation=0)));
         Modelica.Blocks.Tables.CombiTable2D Phic(tableOnFile= if (Table==0) then false else true,
                        table=tablePhic, tableName=if (Table==0) then "NoName" else "tabPhic",
                        fileName=if (Table==0) then "NoName" else fileName,
            smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative)
            annotation (Placement(transformation(extent={{-12,30},{8,50}},
                rotation=0)));
         Real N_T "Referred speed ";
         Real N_T_design "Referred design velocity";
         Real phic(final unit = "(kg/s)*(T^0.5)/Pa") "Flow number ";
         Real beta(start=integer(size(tablePhic,1)/2)) "Number of beta line";
        equation
          N_T_design=Ndesign/sqrt(Tdes_in) "Referred design velocity";
          N_T = 100*omega/(sqrt(gas_in.T)*N_T_design)
          "Referred speed definition, as percentage of design velocity";
          phic = w*sqrt(gas_in.T)/(gas_in.p) "Flow number definition";
          // phic = Phic(beta, N_T)
          Phic.u1=beta;
          Phic.u2=N_T;
          phic=Phic.y;
          // eta = Eta(beta, N_T)
          Eta.u1=beta;
          Eta.u2=N_T;
          eta=Eta.y;
          // PR = PressRatio(beta, N_T)
          PressRatio.u1=beta;
          PressRatio.u2=N_T;
          PR=PressRatio.y;
          annotation (uses(Modelica(version="2.2.1")), Diagram(graphics),
            Documentation(info="<html>
This model adds the performance characteristics to the Compressor_Base model, by means of 2D interpolation tables.</p>
<p>The perfomance characteristics are specified by two characteristic equations: the first relates the flow number <tt>phic</tt>, the pressure ratio <tt>PR</tt> and the referred speed <tt>N_T</tt>; the second relates the efficiency <tt>eta</tt>, the flow number <tt>phic</tt>, and the referred speed <tt>N_T</tt> [1]. To avoid singularities, the two characteristic equations are expressed in parametric form by adding a further variable <tt>beta</tt> (method of beta lines [2]). 
<p>The performance maps are thus tabulated into three differents tables, <tt>tablePhic</tt>,  <tt>tablePR</tt> and <tt>tableEta</tt>, which express <tt>phic</tt>, <tt>PR</tt> and <tt>eta</tt> as a function of <tt>N_T</tt> and <tt>beta</tt>, respectively, where <tt>N_T</tt> is the first row while <tt>beta</tt> is the first column. The referred speed <tt>N_T</tt> is defined as a percentage of the design referred speed and <tt>beta</tt> are arbitrary lines, usually drawn parallel to the surge-line on the performance maps.
<p><tt>Modelica.Blocks.Tables.CombiTable2D</tt> interpolates the tables to obtain values of referred flow, pressure ratio and efficiency at given levels of referred speed and beta.
<p><b>Modelling options</b></p>
<p>The following options are available to determine how the table is defined:
<ul><li><tt>Table = 0</tt>: the table is explicitly supplied as matrix parameter.
<li><tt>Table = 1</tt>: the table is read from a file; the string <tt>fileName</tt> contains the path to the files where the tables are stored, either in ASCII or Matlab binary format.
</ul>
<p><b>References:</b></p>
<ol>
<li>S. L. Dixon: <i>Fluid mechanics, thermodynamics of turbomachinery</i>, Oxford, Pergamon press, 1966, pp. 213.
<li>P. P. Walsh, P. Fletcher: <i>Gas Turbine Performance</i>, 2nd ed., Oxford, Blackwell, 2004, pp. 646.
</ol> 
</html>",       revisions="<html>
<ul>
<li><i>13 Apr 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       New method for calculating performance parameters using tables.</li>
</li>
<li><i>14 Jan 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<br> Compressor model restructured using inheritance.
</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
        end Compressor;

        model HeaderThermal "Header with metal walls for gas flows"
          extends CombinedCycle.Icons.Gas.Mixer;
          import Modelica.SIunits.*;
          parameter Pressure pstart=101325 "Pressure start value";
          parameter Temperature Tstart=300 "Temperature start value";
          parameter Temperature Tmstart=300 "Metal wall start temperature";
          parameter Volume V "Inner volume";
          parameter Area S=0 "Inner surface";
          parameter CoefficientOfHeatTransfer gamma=0
          "Heat Transfer Coefficient"                                             annotation(Evaluate = true);
          parameter HeatCapacity Cm=1 "Metal Heat Capacity" annotation(Evaluate = true);
          Pressure p(start=pstart);
          Temperature T(start=pstart);
          Mass M "Gas total mass";
          Temperature Tm(start=Tmstart) "Wall temperature";
          CombinedCycle.Substances.Gas gas(pstart=pstart,Tstart=Tstart);
          Real drho_dp;
          Real drho_dT;
          Real der_M;
          Real der_E;
          CombinedCycle.Connectors.FlangeA inlet
            annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
          CombinedCycle.Connectors.FlangeB outlet
            annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
          Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a wall
            annotation (Placement(transformation(extent={{-12,78},{8,98}},
                rotation=0)));
        equation
          //Definitions
          M = gas.d*V;
          p = gas.p;
          T = gas.T;
          der_M = V*(drho_dp*der(p)+drho_dT*der(T));
          der_E = der_M*gas.u + gas.cv*der(T)*M;
          drho_dp = gas.d/gas.p;
          drho_dT = -gas.d/gas.T;
          der_M = inlet.w + outlet.w "Mass balance";
          der_E = inlet.w*inlet.h + outlet.w*outlet.h - gamma*S*(gas.T - Tm) + wall.Q_flow
          "Energy balance";
          Cm*der(Tm) = gamma*S*(gas.T - Tm) "Metal wall energy balance";
          // Boundary conditions
          inlet.p = outlet.p;
          inlet.h = gas.h;
          inlet.p + outlet.p = gas.p;
          wall.T = Tm;
          assert(Cm > 0 and gamma > 0, "Cm and gamma must be positive");
          annotation (Icon(graphics),
                            Documentation(info="<html>
<p>This model describes a constant volume buffer with metal walls. The metal wall temperature and the heat transfer coefficient between the wall and the fluid are uniform. The wall is thermally insulated from the outside.</p>
<p>If the inlet or the outlet are connected to a bank of tubes, the model can actually represent a collector or a distributor.</p>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>, whose default value is <tt>Medium.reference_X</tt> .
</html>",       revisions="<html>
<ul>
<li><i>30 May 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Initialisation support added.</li>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>
"),         Diagram(graphics));
        end HeaderThermal;

        model Flow1DGasPConst "Model for gas flows - no mass storage"
          extends CombinedCycle.Icons.Gas.Tube;
          import Modelica.SIunits.*;
          parameter Pressure pstart=101325
          "Pressure start value of outgoing gas";
          parameter Temperature Tstart=300
          "Temperature start value of outgoing gas";
          parameter Temperature Tmstart=300 "Metal wall start temperature";
          parameter Volume V= 1 "Inner volume";
          Modelica.SIunits.Mass M(start=30*V, nominal = 30*V) "Gas total mass";
          CombinedCycle.Substances.Gas gas_in;
          CombinedCycle.Substances.Gas gas_out(pstart=pstart,Tstart=Tstart);
          Real der_E(nominal=1e6);
          CombinedCycle.Connectors.FlangeA inlet
            annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
          CombinedCycle.Connectors.FlangeB outlet
            annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
          Connectors.HeatPort_a wall(T(start=Tstart))
                                                     annotation (Placement(transformation(extent={{-20,42},
                    {20,82}},
                rotation=0), iconTransformation(extent={{-40,40},{40,60}})));
        equation
          //Definitions
          M = gas_out.d*V;
          der_E = der(gas_out.T)*(gas_out.cv*M);
          0 = inlet.w + outlet.w "Mass balance";
          der_E = inlet.w*inlet.h + outlet.w*outlet.h + wall.Q_flow
          "Energy balance";
          inlet.p = outlet.p "Momentum balance";
          // Boundary conditions
          inlet.p = gas_in.p;
          outlet.p = gas_out.p;
          inlet.h = gas_in.h;
          outlet.h = gas_out.h;
          wall.T = (gas_out.T+gas_in.T)/2;
            annotation (Placement(transformation(extent={{-60,40},{60,60}},
                rotation=0)),
                      Icon(graphics={Rectangle(
                extent={{-50,4},{32,0}},
                lineColor={0,0,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid), Polygon(
                points={{32,12},{32,-8},{52,2},{32,12}},
                lineColor={0,0,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid)}),
                            Documentation(info="<html>
<p>This model describes a constant volume buffer with metal walls. The metal wall temperature and the heat transfer coefficient between the wall and the fluid are uniform. The wall is thermally insulated from the outside.</p>
<p>If the inlet or the outlet are connected to a bank of tubes, the model can actually represent a collector or a distributor.</p>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>, whose default value is <tt>Medium.reference_X</tt> .
</html>",       revisions="<html>
<ul>
<li><i>30 May 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Initialisation support added.</li>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>
"),         Diagram(graphics));
        end Flow1DGasPConst;

        model BraytonJoule_exhaustGases
        "Flowrate source for modeling Brayton Joule exhaust gases, depending on the usage percentage"
          extends CombinedCycle.Icons.Gas.SourceW;
          parameter Types.Pressure pstart = 101325 "Starting pressure";
          parameter Types.Temperature T_min "Temperature at zero load";
          parameter Types.Temperature T_max "Max temperature";
          parameter Types.MassFlowRate w_min "Minimum flow rate";
          parameter Types.MassFlowRate w_max "Mass Flow rate at full load";
          parameter Real load_min_w = 0.5 "Load factor at minimum flow rate";
          parameter Types.MassFlowRate wstart=0 "Starting mass flowrate";
          parameter Types.Temperature Tstart=300 "Starting temperature";
          parameter Real sf = 1e2 "Smoothing factor (higher->steeper)";
          constant Real pi = Modelica.Constants.pi;
          Types.MassFlowRate w;
          CombinedCycle.Substances.Gas gas(pstart=pstart,Tstart=Tstart);
          CombinedCycle.Connectors.FlangeB flange(w(start=wstart, nominal = w_min))
            annotation (Placement(transformation(extent={{80,-20},{120,20}}, rotation=0)));
          Modelica.Blocks.Interfaces.RealInput load "Percentage of usage"
            annotation (Placement(transformation(extent={{-120,-20},{-80,20}}, rotation=
                   0)));
          Real lambda(start=1)
          "One above load_min_w, zero below load_min_w, with smoothing";
        equation
          lambda = (atan(sf*(load-load_min_w))+pi/2)/pi;
          flange.w = -w;
          w = (w_min*(1-lambda)+ (w_min+(w_max-w_min)*(load-load_min_w)*2)*lambda);
          gas.T = (T_min+(T_max-T_min)*(load*2))*(1-lambda) + T_max*lambda;
          flange.p = gas.p;
          flange.h = gas.h;
          annotation (Icon(graphics),
            Documentation(info="<html>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the nominal gas composition is given by <tt>Xnom</tt>,whose default value is <tt>Medium.reference_X</tt> .
<p>If <tt>G</tt> is set to zero, the flowrate source is ideal; otherwise, the outgoing flowrate decreases proportionally to the outlet pressure.</p>
<p>If the <tt>in_w0</tt> connector is wired, then the source massflowrate is given by the corresponding signal, otherwise it is fixed to <tt>w0</tt>.</p>
<p>If the <tt>in_T</tt> connector is wired, then the source temperature is given by the corresponding signal, otherwise it is fixed to <tt>T</tt>.</p>
<p>If the <tt>in_X</tt> connector is wired, then the source massfraction is given by the corresponding signal, otherwise it is fixed to <tt>Xnom</tt>.</p>
</html>",       revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Removed <tt>w0fix</tt> and <tt>Tfix</tt> and <tt>Xfix</tt>; the connection of external signals is now detected automatically.</li> <br> Adapted to Modelica.Media
<li><i>1 Oct 2003</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"),Diagram(graphics));
        end BraytonJoule_exhaustGases;
    end Gas;

    package Water
        model Flow1DVapourPConstWall
        "Header with metal walls for gas flows. Effects of der p neglected."
          extends CombinedCycle.Icons.Water.Tube;
          parameter Types.Pressure pstart=101325
          "Pressure start value of outgoing gas";
          parameter Types.Temperature Tstart=300
          "Temperature start value of outgoing gas";
          parameter Types.Temperature Tmstart=300
          "Metal wall start temperature";
          parameter Modelica.SIunits.Volume V = 15 "Inner volume";
          parameter Modelica.SIunits.HeatCapacity Cm=1 "Metal Heat Capacity" annotation(Evaluate = true);
          Modelica.SIunits.Mass M(nominal = 30*V) "Gas total mass";
          CombinedCycle.Substances.WaterVapour wat_vap_in;
          CombinedCycle.Substances.WaterVapour wat_vap_out(pstart=pstart,Tstart=Tstart);
          Real der_E(nominal=1e6);
          CombinedCycle.Connectors.FlangeA inlet
            annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
          CombinedCycle.Connectors.FlangeB outlet
            annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
          Connectors.HeatPort_a wall
            annotation (Placement(transformation(extent={{-60,40},{60,60}},
                rotation=0)));
        equation
          //Definitions
           M = wat_vap_out.d*V;
          der_E = der(wat_vap_out.T)*(wat_vap_out.cv*M+Cm);
          0 = inlet.w + outlet.w "Mass balance";
          der_E = inlet.w*inlet.h + outlet.w*outlet.h + wall.Q_flow
          "Energy balance";
          inlet.p = outlet.p "Momentum balance";
          // Boundary conditions
          inlet.p  = wat_vap_in.p;
          outlet.p = wat_vap_out.p;
          inlet.h  = wat_vap_in.h;
          outlet.h = wat_vap_out.h;
          wall.T = (wat_vap_out.T+wat_vap_in.T)/2;
          annotation (Icon(graphics={Rectangle(
                extent={{-52,4},{30,0}},
                lineColor={0,0,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid), Polygon(
                points={{30,12},{30,-8},{50,2},{30,12}},
                lineColor={0,0,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid)}),
                            Documentation(info="<html>
<p>This model describes a constant volume buffer with metal walls. The metal wall temperature and the heat transfer coefficient between the wall and the fluid are uniform. The wall is thermally insulated from the outside.</p>
<p>If the inlet or the outlet are connected to a bank of tubes, the model can actually represent a collector or a distributor.</p>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>, whose default value is <tt>Medium.reference_X</tt> .
</html>",       revisions="<html>
<ul>
<li><i>30 May 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Initialisation support added.</li>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>
"),         Diagram(graphics));
        end Flow1DVapourPConstWall;

        model Drum
        "Header with metal walls for gas flows. Effects of der p neglected."
          extends CombinedCycle.Icons.Water.Drum;
          import SI = Modelica.SIunits;
          parameter Types.Pressure pstart=101325
          "Pressure start value of outgoing gas";
          parameter Types.Temperature Tstart=300
          "Temperature start value of outgoing gas";
          parameter Types.Temperature Tmstart=300
          "Metal wall start temperature";
          parameter SI.Mass M_start = Mv_start + Ml_start;
          parameter SI.Mass Mv_start = V*alphastart*sat.d_vs_start;
          parameter SI.Mass Ml_start = V*(1-alphastart)*sat.d_ls_start;
          parameter SI.Volume Vv_start = V - Vl_start;
          parameter SI.Volume Vl_start = 1;
          parameter Real alphastart=0.5;
          parameter SI.Volume V = 15 "Inner volume";
          parameter SI.HeatCapacity Cm=1 "Metal Heat Capacity" annotation(Evaluate = true);
          SI.Mass M(start=M_start,nominal = 700*V/2) "Total mass";
          SI.Mass Mv(start=Mv_start,nominal = 30*V/2) "Vapour mass";
          SI.Mass Ml(start=Ml_start,nominal = 700*V/2) "Liquid mass";
          SI.Volume Vv(start=Vv_start,nominal = V/2) "Vapour volume";
          SI.Volume Vl(start=Vl_start,nominal = V/2) "Liquid volume";
          Real alpha(start=alphastart) "Liquid/Vapour volumes ratio";
          Types.Pressure p(start=pstart);
          CombinedCycle.Substances.WaterSaturation sat(pstart=pstart);
          //Dummy variables
          Real der_E(nominal=1e6);
          Real der_M;
          CombinedCycle.Connectors.FlangeA inlet
            annotation (Placement(transformation(extent={{-100,-78},{-60,-38}},
                rotation=0), iconTransformation(extent={{-100,-78},{-60,-38}})));
          CombinedCycle.Connectors.FlangeB outlet
            annotation (Placement(transformation(extent={{40,40},{80,80}},
                rotation=0), iconTransformation(extent={{40,40},{80,80}})));
          Connectors.HeatPort_a wall(T(start=sat.T_s_start)) annotation (Placement(transformation(extent={{-18,-96},
                  {22,-56}},
                rotation=0), iconTransformation(extent={{-40,-100},{40,-78}})));
        Blocks.Interfaces.RealOutput voidFraction
          annotation (Placement(transformation(extent={{66,-70},{86,-50}},
                rotation=0)));
        equation
          //HP. liquid and vapour are at saturation condition.
          //Definitions
          alpha = Vv/V;
          V  = Vl + Vv;
          Mv = V*alpha*sat.d_vs;
          Ml = V*(1-alpha)*sat.d_ls;
          M  = Mv + Ml;
          der_M = V*(-der(alpha)*sat.d_ls + (1-alpha)*sat.d_d_ls_dp*der(p)+
                      der(alpha)*sat.d_vs +     alpha*sat.d_d_vs_dp*der(p));
          der_E = V*(-der(alpha)*sat.d_ls*sat.u_ls+(1-alpha)*sat.d_de_ls_dp*der(p)+
                      der(alpha)*sat.d_vs*sat.u_vs+(1-alpha)*sat.d_de_vs_dp*der(p))+
                  Cm * sat.d_T_s_dp*der(p);
          der_M = inlet.w + outlet.w "Mass balance";
          der_E = inlet.w*inlet.h + outlet.w*outlet.h + wall.Q_flow
          "Energy balance";
          inlet.p = outlet.p "Momentum balance";
          inlet.p = p;
          p = sat.p;
          // Boundary conditions
          outlet.h = sat.h_vs;
          wall.T = sat.T_s;
          voidFraction=alpha;
          assert(alpha<1 and alpha>0,"The vapour volume shouldn't be more of the total volume or less than zero.");
            annotation (Placement(transformation(extent={{-60,80},{60,100}},
                rotation=0)),
                      Icon(graphics),
                            Documentation(info="<html>
<p>This model describes a constant volume buffer with metal walls. The metal wall temperature and the heat transfer coefficient between the wall and the fluid are uniform. The wall is thermally insulated from the outside.</p>
<p>If the inlet or the outlet are connected to a bank of tubes, the model can actually represent a collector or a distributor.</p>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>, whose default value is <tt>Medium.reference_X</tt> .
</html>",       revisions="<html>
<ul>
<li><i>30 May 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Initialisation support added.</li>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>
"),         Diagram(graphics));
        end Drum;

        model Flow1DLiquidPConstWall
          extends CombinedCycle.Icons.Water.Tube;
          import Modelica.SIunits.*;
          parameter Pressure pstart=101325
          "Pressure start value of outgoing gas";
          parameter Temperature Tstart=300
          "Temperature start value of outgoing gas";
          parameter Temperature Tmstart=300 "Metal wall start temperature";
          parameter MassFlowRate wnom = 1 "Nominal mass flow rate";
          parameter HeatCapacity Cm=1 "Metal Heat Capacity" annotation(Evaluate = true);
          parameter Volume V = 15 "Inner volume";
          parameter Mass M_start = wat_liq_out.dstart*V;
          Mass M(start=M_start,nominal=M_start) "Gas total mass";
          CombinedCycle.Substances.WaterLiquid wat_liq_in(pstart=pstart,Tstart=Tstart);
          CombinedCycle.Substances.WaterLiquid wat_liq_out(pstart=pstart,Tstart=Tstart);
          //Dummy variables
          Real der_E(nominal=1e7);
          CombinedCycle.Connectors.FlangeA inlet(h(start=wat_liq_in.h_start))
            annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
          CombinedCycle.Connectors.FlangeB outlet(h(start=wat_liq_out.h_start))
            annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
          Connectors.HeatPort_a wall(T(start=(wat_liq_out.Tstart+wat_liq_in.Tstart)/2))
            annotation (Placement(transformation(extent={{-60,40},{60,60}},
                rotation=0)));
        equation
          //Definitions
          M = wat_liq_out.d*V;
          der_E = der(wat_liq_out.T)*(wat_liq_out.cv*M+Cm);
          0 = inlet.w + outlet.w "Mass balance";
          der_E = inlet.w*inlet.h + outlet.w*outlet.h + wall.Q_flow
          "Energy balance";
          inlet.p = outlet.p "Momentum balance";
          // Boundary conditions
          inlet.p = wat_liq_in.p;
          outlet.p = wat_liq_out.p;
          inlet.h = wat_liq_in.h;
          outlet.h = wat_liq_out.h;
          wall.T = (wat_liq_out.T+wat_liq_in.T)/2;
          annotation (Icon(graphics={Rectangle(
                extent={{-48,6},{34,2}},
                lineColor={0,0,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid), Polygon(
                points={{34,14},{34,-6},{54,4},{34,14}},
                lineColor={0,0,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid)}),
                            Documentation(info="<html>
<p>This model describes a constant volume buffer with metal walls. The metal wall temperature and the heat transfer coefficient between the wall and the fluid are uniform. The wall is thermally insulated from the outside.</p>
<p>If the inlet or the outlet are connected to a bank of tubes, the model can actually represent a collector or a distributor.</p>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the start composition is given by <tt>Xstart</tt>, whose default value is <tt>Medium.reference_X</tt> .
</html>",       revisions="<html>
<ul>
<li><i>30 May 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Initialisation support added.</li>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Adapted to Modelica.Media.</li>
<li><i>5 Mar 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>
"),         Diagram(graphics));
        end Flow1DLiquidPConstWall;

      model Turbine
       extends CombinedCycle.Icons.Gas.Turbine;
          import Modelica.SIunits.*;
        parameter SpecificEnthalpy h_iso=2.3e5;
        parameter Real eta_iso = 0.92;
        parameter Real k=10;
        parameter SpecificEnthalpy h_start = 3.7e6;
        parameter Power P_start = eta_iso *w_start*(h_start-h_iso);
        parameter MassFlowRate w_start = k*1e5;
        output Power P(start=eta_iso * w_start * (h_start-h_iso),nominal=1.2e7);
        Connectors.FlangeA inlet(w(
                                 start = w_start))
                                                  annotation (Placement(transformation(extent={{
                  80,-10},{100,10}}, rotation=0)));
      equation
        inlet.w/w_start = k * inlet.p/w_start;
        P/P_start = (eta_iso * inlet.w * (inlet.h-h_iso))/P_start;
        annotation (Diagram(graphics),
                             Icon(graphics));
      end Turbine;

      model TurbineThermalPort
       extends CombinedCycle.Components.Water.Turbine;
        parameter Modelica.SIunits.CoefficientOfHeatTransfer Gamma=1000;
        Types.HeatFlux HF(start=HF_start);
        parameter Types.Pressure pstart = 3e5;
        parameter Types.HeatFlux HF_start = Gamma*(wat_vap.Tstart-750);
        parameter Modelica.SIunits.Power W_start = w_start*(h_start - hout);
        parameter Types.SpecificEnthalpy hout = 2e6 "Exhaust specific enthalpy";
        CombinedCycle.Substances.WaterVapour wat_vap(p(start=pstart));
        Modelica.SIunits.Power W(start=W_start,nominal = 300e6);
        Connectors.DHT_N1 dHT(T(start=750),phi(start=-1e-4))         annotation (Placement(transformation(
                extent={{-10,-52},{10,-32}}, rotation=0)));
      equation
        // Mechanical power
        W = inlet.w*(inlet.h - hout);
        //Boundary conditions
        wat_vap.p = inlet.p;
        wat_vap.h = inlet.h;
        HF=Gamma*(wat_vap.T-dHT.T);
        dHT.phi = -HF;
        annotation (Diagram(graphics),
                             Icon(graphics));
      end TurbineThermalPort;

      model SourceW_waterLiquid "Flowrate source for gas flows"
        extends CombinedCycle.Icons.Water.SourceW;
        import Modelica.SIunits.*;
        parameter Real Tnom=300 "Nominal temperature";
        parameter Pressure pnom=101325 "Nominal pressure";
        parameter MassFlowRate wnom=0 "Nominal mass flowrate";
        MassFlowRate w;
        CombinedCycle.Substances.WaterLiquid wat_liq(pstart=pnom,Tstart=Tnom);
        CombinedCycle.Connectors.FlangeB flange(w(start=wnom))
          annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
      equation
        flange.w = -w;
        w = wnom "Flow rate set by parameter";
        wat_liq.T  = Tnom "Temperature set by parameter";
        flange.p = wat_liq.p;
        flange.h = wat_liq.h;
        annotation (Icon(graphics),
          Documentation(info="<html>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the nominal gas composition is given by <tt>Xnom</tt>,whose default value is <tt>Medium.reference_X</tt> .
<p>If <tt>G</tt> is set to zero, the flowrate source is ideal; otherwise, the outgoing flowrate decreases proportionally to the outlet pressure.</p>
<p>If the <tt>in_w0</tt> connector is wired, then the source massflowrate is given by the corresponding signal, otherwise it is fixed to <tt>w0</tt>.</p>
<p>If the <tt>in_T</tt> connector is wired, then the source temperature is given by the corresponding signal, otherwise it is fixed to <tt>T</tt>.</p>
<p>If the <tt>in_X</tt> connector is wired, then the source massfraction is given by the corresponding signal, otherwise it is fixed to <tt>Xnom</tt>.</p>
</html>",     revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Removed <tt>w0fix</tt> and <tt>Tfix</tt> and <tt>Xfix</tt>; the connection of external signals is now detected automatically.</li> <br> Adapted to Modelica.Media
<li><i>1 Oct 2003</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end SourceW_waterLiquid;

      model SourceW_waterVapour "Flowrate source for gas flows"
        extends CombinedCycle.Icons.Water.SourceW;
        import Modelica.SIunits.*;
        parameter Pressure pnom=101325 "Nominal pressure";
        parameter Real Tnom=300 "Nominal temperature";
        parameter MassFlowRate wnom=0 "Nominal mass flowrate";
        MassFlowRate w;
        CombinedCycle.Substances.WaterVapour wat_vap(pstart=pnom,Tstart=Tnom);
        CombinedCycle.Connectors.FlangeB flange(w(start=wnom))
          annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
      equation
        flange.w = -w;
        w = wnom "Flow rate set by parameter";
        wat_vap.T  = Tnom "Temperature set by parameter";
        flange.p = wat_vap.p;
        flange.h = wat_vap.h;
        annotation (Icon(graphics),
          Documentation(info="<html>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the nominal gas composition is given by <tt>Xnom</tt>,whose default value is <tt>Medium.reference_X</tt> .
<p>If <tt>G</tt> is set to zero, the flowrate source is ideal; otherwise, the outgoing flowrate decreases proportionally to the outlet pressure.</p>
<p>If the <tt>in_w0</tt> connector is wired, then the source massflowrate is given by the corresponding signal, otherwise it is fixed to <tt>w0</tt>.</p>
<p>If the <tt>in_T</tt> connector is wired, then the source temperature is given by the corresponding signal, otherwise it is fixed to <tt>T</tt>.</p>
<p>If the <tt>in_X</tt> connector is wired, then the source massfraction is given by the corresponding signal, otherwise it is fixed to <tt>Xnom</tt>.</p>
</html>",     revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Removed <tt>w0fix</tt> and <tt>Tfix</tt> and <tt>Xfix</tt>; the connection of external signals is now detected automatically.</li> <br> Adapted to Modelica.Media
<li><i>1 Oct 2003</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end SourceW_waterVapour;

      model SourceW_waterVapour_Input "Flowrate source for gas flows"
        extends CombinedCycle.Icons.Water.SourceW;
        import Modelica.SIunits.*;
        parameter Pressure pstart=101325 "Start pressure";
        parameter Real Tnom=300 "Nominal temperature";
        parameter MassFlowRate wstart "Start mass flow rate";
        CombinedCycle.Substances.WaterVapour wat_vap(pstart=pstart,Tstart=Tnom);
        CombinedCycle.Connectors.FlangeB flange(w(start=wstart))
          annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
        Modelica.Blocks.Interfaces.RealInput w
          annotation (Placement(transformation(
              origin={-62,60},
              extent={{-20,-20},{20,20}},
              rotation=270)));
      equation
        flange.w = -w;
        wat_vap.T  = Tnom "Temperature set by parameter";
        flange.p = wat_vap.p;
        flange.h = wat_vap.h;
        annotation (Icon(graphics),
          Documentation(info="<html>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the nominal gas composition is given by <tt>Xnom</tt>,whose default value is <tt>Medium.reference_X</tt> .
<p>If <tt>G</tt> is set to zero, the flowrate source is ideal; otherwise, the outgoing flowrate decreases proportionally to the outlet pressure.</p>
<p>If the <tt>in_w0</tt> connector is wired, then the source massflowrate is given by the corresponding signal, otherwise it is fixed to <tt>w0</tt>.</p>
<p>If the <tt>in_T</tt> connector is wired, then the source temperature is given by the corresponding signal, otherwise it is fixed to <tt>T</tt>.</p>
<p>If the <tt>in_X</tt> connector is wired, then the source massfraction is given by the corresponding signal, otherwise it is fixed to <tt>Xnom</tt>.</p>
</html>",     revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Removed <tt>w0fix</tt> and <tt>Tfix</tt> and <tt>Xfix</tt>; the connection of external signals is now detected automatically.</li> <br> Adapted to Modelica.Media
<li><i>1 Oct 2003</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end SourceW_waterVapour_Input;

      model SourceW_waterLiquid_Input "Flowrate source for gas flows"
        extends CombinedCycle.Icons.Water.SourceW;
        parameter Types.Pressure pstart=101325 "Start pressure";
        parameter Types.Temperature Tnom=300 "Nominal temperature";
        parameter Types.MassFlowRate wstart = 70 "Start mass flow rate";
        CombinedCycle.Substances.WaterLiquid wat_liq(pstart=pstart,Tstart=Tnom);
        CombinedCycle.Connectors.FlangeB flange(w(start=wstart))
          annotation (Placement(transformation(extent={{80,-20},{120,20}},
                rotation=0)));
        Modelica.Blocks.Interfaces.RealInput w
          annotation (Placement(transformation(
              origin={-62,60},
              extent={{-20,-20},{20,20}},
              rotation=270)));
      equation
        flange.w = -w;
        wat_liq.T  = Tnom "Temperature set by parameter";
        flange.p = wat_liq.p;
        flange.h = wat_liq.h;
        annotation (Icon(graphics),
          Documentation(info="<html>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the nominal gas composition is given by <tt>Xnom</tt>,whose default value is <tt>Medium.reference_X</tt> .
<p>If <tt>G</tt> is set to zero, the flowrate source is ideal; otherwise, the outgoing flowrate decreases proportionally to the outlet pressure.</p>
<p>If the <tt>in_w0</tt> connector is wired, then the source massflowrate is given by the corresponding signal, otherwise it is fixed to <tt>w0</tt>.</p>
<p>If the <tt>in_T</tt> connector is wired, then the source temperature is given by the corresponding signal, otherwise it is fixed to <tt>T</tt>.</p>
<p>If the <tt>in_X</tt> connector is wired, then the source massfraction is given by the corresponding signal, otherwise it is fixed to <tt>Xnom</tt>.</p>
</html>",     revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Removed <tt>w0fix</tt> and <tt>Tfix</tt> and <tt>Xfix</tt>; the connection of external signals is now detected automatically.</li> <br> Adapted to Modelica.Media
<li><i>1 Oct 2003</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end SourceW_waterLiquid_Input;

      model SinkP_waterVapour "Pressure sink for gas flows"
        extends CombinedCycle.Icons.Water.SourceP;
        import Modelica.SIunits.*;
        parameter Pressure pnom=101325 "Nominal pressure";
        parameter Temperature Tnom=300 "Nominal temperature";
        parameter Real Res=1 "Hydraulic Resistance";
        CombinedCycle.Substances.WaterVapour wat_vap;
        CombinedCycle.Connectors.FlangeA flange
          annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
      equation
        flange.p = wat_vap.p + flange.w*Res;
        wat_vap.p = pnom "Pressure set by parameter";
        wat_vap.T = Tnom "Temperature set by parameter";
        annotation (Icon(graphics),
          DymolaStoredErrors,
          Diagram(graphics),
          Documentation(info="<html>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the nominal gas composition is given by <tt>Xnom</tt>, whose default value is <tt>Medium.reference_X</tt> .
<p>If <tt>R</tt> is set to zero, the pressure sink is ideal; otherwise, the inlet pressure increases proportionally to the outgoing flowrate.</p>
<p>If the <tt>in_p</tt> connector is wired, then the source pressure is given by the corresponding signal, otherwise it is fixed to <tt>p0</tt>.</p>
<p>If the <tt>in_T</tt> connector is wired, then the source temperature is given by the corresponding signal, otherwise it is fixed to <tt>T</tt>.</p>
<p>If the <tt>in_X</tt> connector is wired, then the source massfraction is given by the corresponding signal, otherwise it is fixed to <tt>Xnom</tt>.</p>
</html>",     revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Removed <tt>p0fix</tt> and <tt>Tfix</tt> and <tt>Xfix</tt>; the connection of external signals is now detected automatically.</li>
<br> Adapted to Modelica.Media
<li><i>1 Oct 2003</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end SinkP_waterVapour;

      model SinkP_waterLiquid "Pressure sink for gas flows"
        extends CombinedCycle.Icons.Water.SourceP;
        import Modelica.SIunits.*;
        parameter Pressure pnom=101325 "Nominal pressure";
        parameter Temperature Tnom=300 "Nominal temperature";
        parameter Real Res=1 "Hydraulic Resistance";
        CombinedCycle.Substances.WaterLiquid wat_liq;
        CombinedCycle.Connectors.FlangeA flange
          annotation (Placement(transformation(extent={{-120,-20},{-80,20}},
                rotation=0)));
      equation
        flange.p = wat_liq.p + flange.w*Res;
        wat_liq.p = pnom "Pressure set by parameter";
        wat_liq.T = Tnom "Temperature set by parameter";
        annotation (Icon(graphics),
          DymolaStoredErrors,
          Diagram(graphics),
          Documentation(info="<html>
<p><b>Modelling options</b></p>
<p>The actual gas used in the component is determined by the replaceable <tt>Medium</tt> package. In the case of multiple component, variable composition gases, the nominal gas composition is given by <tt>Xnom</tt>, whose default value is <tt>Medium.reference_X</tt> .
<p>If <tt>R</tt> is set to zero, the pressure sink is ideal; otherwise, the inlet pressure increases proportionally to the outgoing flowrate.</p>
<p>If the <tt>in_p</tt> connector is wired, then the source pressure is given by the corresponding signal, otherwise it is fixed to <tt>p0</tt>.</p>
<p>If the <tt>in_T</tt> connector is wired, then the source temperature is given by the corresponding signal, otherwise it is fixed to <tt>T</tt>.</p>
<p>If the <tt>in_X</tt> connector is wired, then the source massfraction is given by the corresponding signal, otherwise it is fixed to <tt>Xnom</tt>.</p>
</html>",     revisions="<html>
<ul>
<li><i>19 Nov 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Removed <tt>p0fix</tt> and <tt>Tfix</tt> and <tt>Xfix</tt>; the connection of external signals is now detected automatically.</li>
<br> Adapted to Modelica.Media
<li><i>1 Oct 2003</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</html>"));
      end SinkP_waterLiquid;
    end Water;

    package Thermal
      model ThermalConductor
        "Lumped thermal element transporting heat without storing it"
        import CombinedCycle.Connectors.*;
        Types.HeatFlowRate Q_flow "Heat flow rate from port_a -> port_b";
        Types.Temperature dT(min=-1e20) "port_a.T - port_b.T";
      public
        HeatPort_a port_a annotation (Placement(transformation(extent={{-110,
                  -10},{-90,10}}, rotation=0)));
        HeatPort_b port_b annotation (Placement(transformation(extent={{90,-10},
                  {110,10}}, rotation=0)));
        parameter Modelica.SIunits.ThermalConductance G=1
          "Constant thermal conductance of material";
      equation
        Q_flow = G*dT;
        dT = port_a.T - port_b.T;
        port_a.Q_flow = Q_flow;
        port_b.Q_flow = -Q_flow;
        annotation (
          Icon(graphics={
              Rectangle(
                extent={{-90,70},{90,-70}},
                lineColor={0,0,0},
                pattern=LinePattern.None,
                fillColor={192,192,192},
                fillPattern=FillPattern.Backward),
              Line(
                points={{-90,70},{-90,-70}},
                color={0,0,0},
                thickness=0.5),
              Line(
                points={{90,70},{90,-70}},
                color={0,0,0},
                thickness=0.5),
              Text(extent={{-139,134},{141,74}}, textString=
                                                     "%name"),
              Text(
                extent={{-115,-76},{113,-116}},
                lineColor={0,0,0},
                textString=
                     "G=%G")}),
          Diagram(graphics={
              Line(
                points={{-80,0},{80,0}},
                color={255,0,0},
                thickness=0.5,
                arrow={Arrow.None,Arrow.Filled}),
              Text(
                extent={{-26,-10},{27,-39}},
                lineColor={255,0,0},
                textString=
                     "Q_flow"),
              Text(
                extent={{-80,50},{80,20}},
                lineColor={0,0,0},
                textString=
                     "dT = port_a.T - port_b.T")}),
          Documentation(info="<HTML>
<p>
This is a model for transport of heat without storing it.
It may be used for complicated geometries where
the thermal conductance G (= inverse of thermal resistance)
is determined by measurements and is assumed to be constant
over the range of operations. If the component consists mainly of
one type of material and a regular geometry, it may be calculated,
e.g., with one of the following equations:
</p>
<ul>
<li><p>
    Conductance for a <b>box</b> geometry under the assumption
    that heat flows along the box length:</p>
    <pre>
    G = k*A/L
    k: Thermal conductivity (material constant)
    A: Area of box
    L: Length of box
    </pre>
    </li>
<li><p>
    Conductance for a <b>cylindrical</b> geometry under the assumption
    that heat flows from the inside to the outside radius
    of the cylinder:</p>
    <pre>
    G = 2*pi*k*L/log(r_out/r_in)
    pi   : Modelica.Constants.pi
    k    : Thermal conductivity (material constant)
    L    : Length of cylinder
    log  : Modelica.Math.log;
    r_out: Outer radius of cylinder
    r_in : Inner radius of cylinder
    </pre>
    </li>
</li>
</ul>
<pre>
    Typical values for k at 20 degC in W/(m.K):
      aluminium   220
      concrete      1
      copper      384
      iron         74
      silver      407
      steel        45 .. 15 (V2A)
      wood         0.1 ... 0.2
</pre>
</HTML>
"));
      end ThermalConductor;

      model HeatCapacitor "Lumped thermal element storing heat"
        parameter Modelica.SIunits.HeatCapacity C
          "Heat capacity of part (= cp*m)";
        parameter Boolean steadyStateStart=false
          "true, if component shall start in steady state";
        Types.Temperature T(start=Modelica.SIunits.Conversions.from_degC(
              20)) "Temperature of part";
        CombinedCycle.Connectors.HeatPort_a port
                                   annotation (Placement(transformation(
              origin={0,-100},
              extent={{-10,-10},{10,10}},
              rotation=90)));
      equation
        T = port.T;
        C*der(T) = port.Q_flow;
      initial equation
        if steadyStateStart then
          der(T) = 0;
        end if;
        annotation (
          Icon(graphics={
              Text(extent={{-129,121},{131,70}}, textString=
                                                     "%name"),
              Polygon(
                points={{0,67},{-20,63},{-40,57},{-52,43},{-58,35},{-68,25},{
                    -72,13},{-76,-1},{-78,-15},{-76,-31},{-76,-43},{-76,-53},{
                    -70,-65},{-64,-73},{-48,-77},{-30,-83},{-18,-83},{-2,-85},{
                    8,-89},{22,-89},{32,-87},{42,-81},{54,-75},{56,-73},{66,-61},
                    {68,-53},{70,-51},{72,-35},{76,-21},{78,-13},{78,3},{74,15},
                    {66,25},{54,33},{44,41},{36,57},{26,65},{0,67}},
                lineColor={160,160,164},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{-58,35},{-68,25},{-72,13},{-76,-1},{-78,-15},{-76,-31},
                    {-76,-43},{-76,-53},{-70,-65},{-64,-73},{-48,-77},{-30,-83},
                    {-18,-83},{-2,-85},{8,-89},{22,-89},{32,-87},{42,-81},{54,
                    -75},{42,-77},{40,-77},{30,-79},{20,-81},{18,-81},{10,-81},
                    {2,-77},{-12,-73},{-22,-73},{-30,-71},{-40,-65},{-50,-55},{
                    -56,-43},{-58,-35},{-58,-25},{-60,-13},{-60,-5},{-60,7},{
                    -58,17},{-56,19},{-52,27},{-48,35},{-44,45},{-40,57},{-58,
                    35}},
                lineColor={0,0,0},
                fillColor={160,160,164},
                fillPattern=FillPattern.Solid),
              Text(
                extent={{-69,7},{71,-24}},
                lineColor={0,0,0},
                textString=
                     "%C")}),
          Diagram(graphics={
              Polygon(
                points={{0,67},{-20,63},{-40,57},{-52,43},{-58,35},{-68,25},{
                    -72,13},{-76,-1},{-78,-15},{-76,-31},{-76,-43},{-76,-53},{
                    -70,-65},{-64,-73},{-48,-77},{-30,-83},{-18,-83},{-2,-85},{
                    8,-89},{22,-89},{32,-87},{42,-81},{54,-75},{56,-73},{66,-61},
                    {68,-53},{70,-51},{72,-35},{76,-21},{78,-13},{78,3},{74,15},
                    {66,25},{54,33},{44,41},{36,57},{26,65},{0,67}},
                lineColor={160,160,164},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{-58,35},{-68,25},{-72,13},{-76,-1},{-78,-15},{-76,-31},
                    {-76,-43},{-76,-53},{-70,-65},{-64,-73},{-48,-77},{-30,-83},
                    {-18,-83},{-2,-85},{8,-89},{22,-89},{32,-87},{42,-81},{54,
                    -75},{42,-77},{40,-77},{30,-79},{20,-81},{18,-81},{10,-81},
                    {2,-77},{-12,-73},{-22,-73},{-30,-71},{-40,-65},{-50,-55},{
                    -56,-43},{-58,-35},{-58,-25},{-60,-13},{-60,-5},{-60,7},{
                    -58,17},{-56,19},{-52,27},{-48,35},{-44,45},{-40,57},{-58,
                    35}},
                lineColor={0,0,0},
                fillColor={160,160,164},
                fillPattern=FillPattern.Solid),
              Ellipse(
                extent={{-6,-1},{6,-12}},
                lineColor={255,0,0},
                fillColor={191,0,0},
                fillPattern=FillPattern.Solid),
              Text(
                extent={{11,13},{50,-25}},
                lineColor={0,0,0},
                textString=
                     "T"),
              Line(points={{0,-12},{0,-96}}, color={255,0,0})}),
          Documentation(info="<HTML>
<p>
This is a generic model for the heat capacity of a material.
No specific geometry is assumed beyond a total volume with
uniform temperature for the entire volume.
Furthermore, it is assumed that the heat capacity
is constant (indepedent of temperature).
</p>
<p>
The temperature T [Kelvin] of this component is a <b>state</b>.
A default of T = 25 degree Celsius (= SIunits.Conversions.from_degC(25))
is used as start value for initialization.
This usually means that at start of integration the temperature of this
component is 25 degrees Celsius. You may, of course, define a different
temperature as start value for initialization. Alternatively, it is possible
to set parameter <b>steadyStateStart</b> to <b>true</b>. In this case
the additional equation '<b>der</b>(T) = 0' is used during
initialization, i.e., the temperature T is computed in such a way that
the component starts in <b>steady state</b>. This is useful in cases,
where one would like to start simulation in a suitable operating
point without being forced to integrate for a long time to arrive
at this point.
</p>
<p>
Note, that parameter <b>steadyStateStart</b> is not available in
the parameter menue of the simulation window, because its value
is utilized during translation to generate quite different
equations depending on its setting. Therefore, the value of this
parameter can only be changed before translating the model.
</p>
<p>
This component may be used for complicated geometries where
the heat capacity C is determined my measurements. If the component
consists mainly of one type of material, the <b>mass m</b> of the
component may be measured or calculated and multiplied with the
<b>specific heat capacity cp</b> of the component material to
compute C:
</p>
<pre>
   C = cp*m.
   Typical values for cp at 20 degC in J/(kg.K):
      aluminium   896
      concrete    840
      copper      383
      iron        452
      silver      235
      steel       420 ... 500 (V2A)
      wood       2500
</pre>
</HTML>
"));
      end HeatCapacitor;

    model CylinderFourier_Nr3_uniform_noVector
        "Thermal model of a hollow cylinder by Fourier's equation - 1 axial node and Nr radial nodes"
      import CombinedCycle.Choices.CylinderFourier.NodeDistribution;
      import SI = Modelica.SIunits;
      extends Icons.MetalWall;
      parameter SI.Length rint "Internal radius";
      parameter SI.Length rext "External radius";
      parameter Types.Temperature Tstartint=300
          "Temperature start value at rint (first node)"
        annotation(Dialog(tab = "Initialisation"));
      parameter Types.Temperature Tstartext=300
          "Temperature start value at rext (last node)"
        annotation(Dialog(tab = "Initialisation"));
      parameter SI.Density rho "Density of the material";
      parameter SI.SpecificHeatCapacity c
          "Specific heat capacity of the material";
      parameter SI.ThermalConductivity lambda "Thermal conductivity";
      parameter SI.Length r__1=r_lin__1 "Node radii";
      parameter SI.Length r__2=r_lin__2 "Node radii";
      parameter SI.Length r__3=r_lin__3 "Node radii";
      final parameter SI.Length r1_2__1=(r__2+r__1)/2 "Slice mean radii";
      final parameter SI.Length r1_2__2=(r__3+r__2)/2 "Slice mean radii";
      final parameter SI.Length r_lin__1=rint "Linearly distributed radii";
      final parameter SI.Length r_lin__2=(rint+rext)/2
          "Linearly distributed radii";
      final parameter SI.Length r_lin__3=rext "Linearly distributed radii";
      final parameter Real A__1=0;
      final parameter Real A__2=r1_2__1 / (r__2*( r__2  - r__1)*(r1_2__2-r1_2__1));
      final parameter Real A__3=0;
      final parameter Real B__1=0;
      final parameter Real B__2=- A__2 - C__2;
      final parameter Real B__3=0;
      final parameter Real C__1=0;
      final parameter Real C__2=r1_2__2 / (r__2*( r__3 -  r__2)*(r1_2__2-r1_2__1));
      final parameter Real C__3=0;
      Types.Temperature T__1(start=Tstartint) "Nodal temperature";
      Types.Temperature T__2(start=Tstartext) "Nodal temperature";
      Types.Temperature T__3(start=Tstartext) "Nodal temperature";
      Types.Temperature Tm "Mean temperature";
      Connectors.DHT_N1 internalBoundary
        annotation (Placement(transformation(extent={{-20,20},{20,40}},
                rotation=0)));
      Connectors.DHT_N1 externalBoundary
        annotation (Placement(transformation(extent={{-20,-40},{20,-20}},
                rotation=0)));
    equation
      rho*c/lambda*der(T__2) = A__2*T__1 + B__2*T__2 + C__2*T__3
          "Fourier's equation";
      // Thermal boundary conditions
      internalBoundary.T = T__1;
      externalBoundary.T = T__3;
      internalBoundary.phi = -lambda*(T__2 -  T__1) /(r__2 -  r__1);
      externalBoundary.phi = lambda*(T__3 - T__2)/(r__3 - r__2);
      // Mean temperature
      Tm = 1/(rext^2-rint^2)*((T__1*r__1+T__2*r__2)*(r__2-r__1)+(T__2*r__2+T__3*r__3)*(r__3-r__2));
      annotation (uses(Modelica(version="2.2.1")),Diagram(graphics),
        Icon(graphics={
              Text(
                extent={{-94,52},{-42,24}},
                lineColor={0,0,0},
                fillColor={128,128,128},
                fillPattern=FillPattern.Forward,
                textString=
                   "Int"),
              Text(
                extent={{-90,-24},{-42,-50}},
                lineColor={0,0,0},
                fillColor={128,128,128},
                fillPattern=FillPattern.Forward,
                textString=
                   "Ext"),
              Text(
                extent={{-98,-44},{102,-72}},
                lineColor={191,95,0},
                textString=
                   "%name")}),
        DymolaStoredErrors,
          Documentation(info="<html>
This is the 1D thermal model of a solid hollow cylinder by Fourier's equations. 
<p>The model is axis-symmetric, has one node in the longitudinal direction, and <tt>Nr</tt> nodes in the radial direction. The two connectors correspond to the internal and external surfaces; if one of the surface is thermally insulated, just leave the connector unconnected (no connection on a <tt>DHT</tt> connector means zero heat flux). The temperature-dependent properties of the material are described by the replaceable <tt>MaterialModel</tt> model.
<p><b>Modelling options</b></p>
The radial distribution of the nodes can be chosen by selecting the value of <tt>nodeDistribution</tt>:
<ul>
<li> <tt>Choices.CylinderFourier.NodeDistribution.uniform</tt> uniform distribution, nodes are equally spaced; 
<li> <tt>Choices.CylinderFourier.NodeDistribution.thickInternal</tt> quadratic distribution, nodes are thickest near the internal surface; 
<li> <tt>Choices.CylinderFourier.NodeDistribution.thickExternal</tt> quadratic distribution, nodes are thickest near the external surface; 
<li> <tt>Choices.CylinderFourier.NodeDistribution.thickBoth</tt> quadratic distribution, nodes are thickest near both surfaces.
</ul>
</html>",     revisions="<html>
<ul>
<li><i>30 Dec 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Bugs fixed in boundary condition and node distribution.</li>
<li><i>1 May 2005</i>
    by <a href=\"mailto:luca.bascetta@polimi.it\">Luca Bascetta</a>:<br>
       First release.</li>
</ul>
</html>"));
    end CylinderFourier_Nr3_uniform_noVector;

      model CylinderThermalStress_radial_noVector
        "Thermal stress model in a hollow cylinder"
        extends
          CombinedCycle.Components.Thermal.CylinderFourier_Nr3_uniform_noVector;
        import Modelica.SIunits.*;
        Types.Stress extThermalStress
          "Thermal stress at the external surface (radial only)";
        Types.Stress intThermalStress
          "Thermal stress at the internal surface (radial only)";
        parameter Real linearExpansionCoefficient(final unit="1/K");
        parameter Pressure youngModulus;
        parameter Real poissonRatio;
      equation
        // Thermal stresses
        intThermalStress = linearExpansionCoefficient*youngModulus
                     /(1-poissonRatio)*(Tm-T__1);
      //This should be constrained.
        extThermalStress = linearExpansionCoefficient*youngModulus
                     /(1-poissonRatio)*(Tm-T__3);
        annotation (Diagram(graphics),
                             Icon(graphics={Text(
                extent={{-80,20},{80,-20}},
                lineColor={255,255,255},
                textString=
                       "sigma")}),
          Documentation(info="<html>
This model extends <tt>CylinderFourier</tt> by adding the computation of the three components of the thermal stress at the internal and external surfaces.
</html>",       revisions="<html>
<ul>
<li><i>10 May 2005</i>
    by <a href=\"mailto:luca.bascetta@polimi.it\">Luca Bascetta</a>:<br>
       First release.</li>
</ul>
</html>"));
      end CylinderThermalStress_radial_noVector;

      model CylinderFourierConstant
        "Thermal model of a hollow cylinder by Fourier's equation - 1 axial node and Nr radial nodes"
        import Modelica.SIunits.*;
        import CombinedCycle.Choices.CylinderFourier.NodeDistribution;
        extends Icons.MetalWall;
        //  replaceable model MaterialModel = MaterialProperties.Metals.StandardSteel constrainedby
        //    MaterialProperties.Interfaces.PartialMaterial "Metal model";
        parameter Integer Nr=3 "Number of radial nodes";
        parameter NodeDistribution nodeDistribution = NodeDistribution.uniform
          "Node distribution";
        parameter Length rint "Internal radius";
        parameter Length rext "External radius";
        parameter Density rho "Density of the material";
        parameter SpecificHeatCapacity c "Specific heat capacity of material";
        parameter ThermalConductivity lambda
          "Thermal conductivity of the material";
        parameter Temperature Tstartint=300
          "Temperature start value at rint (first node)"
          annotation(Dialog(tab = "Initialisation"));
        parameter Temperature Tstartext=300
          "Temperature start value at rext (last node)"
          annotation(Dialog(tab = "Initialisation"));
        parameter Choices.Init.Options initOpt=Choices.Init.Options.noInit
          "Initialisation option" annotation(Dialog(tab = "Initialisation"));
        /*
  Length r[Nr](each fixed=false) "Node radii";
  Length r1_2[Nr-1](each fixed=false) "Slice mean radii";
  Length r_lin[Nr](each fixed=false) "Linearly distributed radii";
  */
        final parameter Length r[Nr] = r_lin "Node radii";
        final parameter Length r1_2[Nr-1] = {(r[i+1]+r[i])/2 for i in 1:Nr-1}
          "Slice mean radii";
        final parameter Length r_lin[Nr] = linspace(rint,rext,Nr)
          "Linearly distributed radii";

        Real A[Nr](each fixed=false);
        Real B[Nr](each fixed=false);
        Real C[Nr](each fixed=false);
        Temperature T[Nr](start=linspace(Tstartint,Tstartext,Nr))
          "Nodal temperatures";
        Temperature Tm "Mean temperature";
        // MaterialModel metal[Nr] "Metal properties at the nodes";
        Connectors.DHT_N1 internalBoundary
          annotation (Placement(transformation(extent={{-20,20},{20,40}}, rotation=0)));
        Connectors.DHT_N1 externalBoundary
          annotation (Placement(transformation(extent={{-20,-40},{20,-20}}, rotation=
                    0)));
      equation
        // Generation of the temperature node distribution
        /*
  r_lin = linspace(rint,rext,Nr) "Linearly distributed node radii";
  for i in 1:Nr loop
    r[i]= r_lin[i] "Uniform distribution of node radii";
  end for;
  */
        /* unsupported in JModelica 1.5
  for i in 1:Nr loop
    if nodeDistribution == NodeDistribution.uniform then
      r[i]= r_lin[i] "Uniform distribution of node radii";
    elseif nodeDistribution == NodeDistribution.thickInternal then
      r[i]= rint + 1/(rext-rint)*(r_lin[i]-rint)^2 
        "Quadratically distributed node radii - thickest at rint";
    elseif nodeDistribution == NodeDistribution.thickExternal then
      r[i]= rext - 1/(rext-rint)*(rext-r_lin[i])^2 
        "Quadratically distributed node radii - thickest at rext";
    elseif nodeDistribution == NodeDistribution.thickBoth then
      if r_lin[i] <= (rint+rext)/2 then
        r[i]=  2/(rext-rint)*(r_lin[i]-rint)^2+rint 
          "Quadratically distributed node radii - thickest at rint";
      else
        r[i]= -2/(rext-rint)*(r_lin[i]-rext)^2+rext 
          "Quadratically distributed node radii - thickest at rext";
      end if;
      else
        r[i] = 0;
      assert(true,"Unsupported NodeDistribution type");
    end if;
  end for;
  */
        /*
  for i in 1:Nr-1 loop
    r1_2[i] = (r[i+1]+r[i])/2;
  end for;
  */
        // Spatially discretized coefficients of Fourier's equation
        for i in 2:Nr-1 loop
          A[i] = r1_2[i-1] / (r[i]*( r[i]  - r[i-1])*(r1_2[i]-r1_2[i-1]));
          C[i] =  r1_2[i]  / (r[i]*(r[i+1] -  r[i]) *(r1_2[i]-r1_2[i-1]));
          B[i] = - A[i] - C[i];
        end for;
        // Not used by Fourier equations
        A[1] = 0;
        B[1] = 0;
        C[1] = 0;
        A[Nr] = 0;
        B[Nr] = 0;
        C[Nr] = 0;
        // Thermal field
        for i in 2:Nr-1 loop
          rho*c/lambda*der(T[i]) = A[i]*T[i-1] + B[i]*T[i] + C[i]*T[i+1]
            "Fourier's equation";
        end for;
        // Thermal boundary conditions
        internalBoundary.T = T[1];
        externalBoundary.T = T[Nr];
        internalBoundary.phi = -lambda*(T[2] -  T[1]) /(r[2] -  r[1]);
        externalBoundary.phi = lambda*(T[Nr] - T[Nr-1])/(r[Nr] - r[Nr-1]);
        // Mean temperature
        Tm = 1/(rext^2-rint^2) * sum((T[i]*r[i]+T[i+1]*r[i+1])*(r[i+1]-r[i]) for i in 1:Nr-1);
      //  Tm = sum(T)/Nr;
      initial equation
        // Initial conditions
        if initOpt == Choices.Init.Options.noInit then
          // do nothing
        elseif initOpt == Choices.Init.Options.steadyState then
          der(T[2:Nr-1]) = zeros(Nr-2);
        else
          assert(false, "Unsupported initialisation option");
        end if;
        annotation (
          Icon(graphics={
                Text(
                  extent={{-94,52},{-42,24}},
                  lineColor={0,0,0},
                  fillColor={128,128,128},
                  fillPattern=FillPattern.Forward,
                  textString=
                     "Int"),
                Text(
                  extent={{-90,-24},{-42,-50}},
                  lineColor={0,0,0},
                  fillColor={128,128,128},
                  fillPattern=FillPattern.Forward,
                  textString=
                     "Ext"),
                Text(
                  extent={{-98,-44},{102,-72}},
                  lineColor={191,95,0},
                  textString=
                     "%name")}));
      end CylinderFourierConstant;

      model CylinderThermalStressConstant
        "Thermal stress model in a hollow cylinder - constant conductivity"
        extends CylinderFourierConstant;
        import Modelica.SIunits.*;
        Types.Stress extThermalStress
          "Thermal stress at the external surface (radial only)";
        Types.Stress intThermalStress
          "Thermal stress at the internal surface (radial only)";
        parameter Real linearExpansionCoefficient(final unit="1/K");
        parameter Pressure youngModulus;
        parameter Real poissonRatio;
      equation
        // Thermal stresses
        intThermalStress = linearExpansionCoefficient*youngModulus
                     /(1 - poissonRatio)*(Tm - T[1]);
        extThermalStress = linearExpansionCoefficient*youngModulus
                     /(1 - poissonRatio)*(Tm - T[Nr]);
        annotation (Diagram(graphics),
                             Icon(graphics={Text(
                extent={{-80,20},{80,-20}},
                lineColor={255,255,255},
                textString=
                       "sigma")}),
          Documentation(info="<html>
This model extends <tt>CylinderFourier</tt> by adding the computation of the three components of the thermal stress at the internal and external surfaces.
</html>",       revisions="<html>
<ul>
<li><i>10 May 2005</i>
    by <a href=\"mailto:luca.bascetta@polimi.it\">Luca Bascetta</a>:<br>
       First release.</li>
</ul>
</html>"));
      end CylinderThermalStressConstant;

      model FixedHeatFlow "Fixed heat flow boundary condition"
        parameter Modelica.SIunits.HeatFlowRate Q_flow = 1000
          "Fixed heat flow rate at port";
        CombinedCycle.Connectors.HeatPort_b port
                                   annotation (Placement(transformation(extent=
                  {{90,-10},{110,10}}, rotation=0)));
      equation
        port.Q_flow = -Q_flow;
        annotation (
          Icon(graphics={
              Text(extent={{-134,120},{132,60}}, textString=
                                                     "%name"),
              Text(
                extent={{-137,-52},{133,-100}},
                lineColor={0,0,0},
                textString=
                     "Q_flow=%Q_flow"),
              Line(
                points={{-100,-20},{48,-20}},
                color={191,0,0},
                thickness=0.5),
              Line(
                points={{-100,20},{46,20}},
                color={191,0,0},
                thickness=0.5),
              Polygon(
                points={{40,0},{40,40},{70,20},{40,0}},
                lineColor={191,0,0},
                fillColor={191,0,0},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{40,-40},{40,0},{70,-20},{40,-40}},
                lineColor={191,0,0},
                fillColor={191,0,0},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{70,40},{90,-40}},
                lineColor={191,0,0},
                fillColor={191,0,0},
                fillPattern=FillPattern.Solid)}),
          Diagram(graphics={
              Text(
                extent={{-100,40},{0,-36}},
                lineColor={0,0,0},
                textString=
                     "Q_flow=const."),
              Line(
                points={{-48,-20},{60,-20}},
                color={191,0,0},
                thickness=0.5),
              Line(
                points={{-48,20},{60,20}},
                color={191,0,0},
                thickness=0.5),
              Polygon(
                points={{60,0},{60,40},{90,20},{60,0}},
                lineColor={191,0,0},
                fillColor={191,0,0},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{60,-40},{60,0},{90,-20},{60,-40}},
                lineColor={191,0,0},
                fillColor={191,0,0},
                fillPattern=FillPattern.Solid)}),
          Documentation(info="<HTML>
<p>
This model allows a specified amount of heat flow rate to be \"injected\"
into a thermal system at a given port.  The constant amount of heat
flow rate Q_flow is given as a parameter. The heat flows into the
component to which the component FixedHeatFlow is connected,
if parameter Q_flow is positive.
</p>
<p>
If parameter alpha is > 0, the heat flow is mulitplied by (1 + alpha*(port.T - T_ref)) 
in order to simulate temperature dependent losses (which are given an reference temperature T_ref).
</p>
</HTML>
"));
      end FixedHeatFlow;

      model FixedHeatFlow_DHT_N1 "Fixed heat flow boundary condition"
        parameter Modelica.SIunits.HeatFlowRate Q_flow = 1000
          "Fixed heat flow rate at port";
        Connectors.DHT_N1 port     annotation (Placement(transformation(extent=
                  {{90,-10},{110,10}}, rotation=0)));
      equation
        port.phi = -Q_flow;
        annotation (
          Icon(graphics={
              Text(extent={{-134,120},{132,60}}, textString=
                                                     "%name"),
              Text(
                extent={{-137,-52},{133,-100}},
                lineColor={0,0,0},
                textString=
                     "Q_flow=%Q_flow"),
              Line(points={{-100,-20},{48,-20}}, color={255,128,0}),
              Line(points={{-100,20},{46,20}}, color={255,128,0}),
              Polygon(
                points={{40,0},{40,40},{70,20},{40,0}},
                lineColor={191,0,0},
                fillColor={255,128,0},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{40,-40},{40,0},{70,-20},{40,-40}},
                lineColor={191,0,0},
                fillColor={255,128,0},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{70,40},{90,-40}},
                lineColor={191,0,0},
                fillColor={255,128,0},
                fillPattern=FillPattern.Solid)}),
          Diagram(graphics={
              Text(
                extent={{-100,40},{0,-36}},
                lineColor={0,0,0},
                textString=
                     "Q_flow=const."),
              Line(
                points={{-48,-20},{60,-20}},
                color={255,128,0},
                thickness=0.5),
              Line(
                points={{-48,20},{60,20}},
                color={255,128,0},
                thickness=0.5),
              Polygon(
                points={{60,0},{60,40},{90,20},{60,0}},
                lineColor={191,0,0},
                fillColor={255,128,0},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{60,-40},{60,0},{90,-20},{60,-40}},
                lineColor={191,0,0},
                fillColor={255,128,0},
                fillPattern=FillPattern.Solid)}),
          Documentation(info="<HTML>
<p>
This model allows a specified amount of heat flow rate to be \"injected\"
into a thermal system at a given port.  The constant amount of heat
flow rate Q_flow is given as a parameter. The heat flows into the
component to which the component FixedHeatFlow is connected,
if parameter Q_flow is positive.
</p>
<p>
If parameter alpha is > 0, the heat flow is mulitplied by (1 + alpha*(port.T - T_ref)) 
in order to simulate temperature dependent losses (which are given an reference temperature T_ref).
</p>
</HTML>
"));
      end FixedHeatFlow_DHT_N1;
    end Thermal;
  end Components;

  package Icons "Icons for ThermoPower library"
    extends Modelica.Icons.Library;
    package Water "Icons for component using water/steam as working fluid"
      extends Modelica.Icons.Library;
      partial model SourceP
        annotation (Icon(graphics={
              Ellipse(extent={{-80,80},{80,-80}}, lineColor={0,0,0}),
              Text(
                extent={{-20,34},{28,-26}},
                lineColor={255,255,255},
                textString=
                     "P"),
              Text(extent={{-100,-78},{100,-106}}, textString=
                                                       "%name")}));
      end SourceP;

      partial model SourceW
        annotation (Icon(graphics={
              Rectangle(extent={{-80,40},{80,-40}}, lineColor={0,0,0}),
              Polygon(
                points={{-12,-20},{66,0},{-12,20},{34,0},{-12,-20}},
                lineColor={255,255,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid),
              Text(extent={{-100,-52},{100,-80}}, textString=
                                                      "%name")}));
      end SourceW;

      partial model Tube
        annotation (Icon(graphics={Rectangle(
                extent={{-80,40},{80,-40}},
                lineColor={0,0,0},
                fillPattern=FillPattern.HorizontalCylinder)}),
                                 Diagram(graphics));
      end Tube;

      partial model Mixer
        annotation (Icon(graphics={Ellipse(extent={{80,80},{-80,-80}},
                  lineColor={0,0,0}), Text(extent={{-100,-84},{100,-110}},
                  textString=
                  "%name")}),Diagram(graphics));
      end Mixer;

      partial model Tank
        annotation (Icon(graphics={
              Rectangle(
                extent={{-60,60},{60,-80}},
                lineColor={0,0,0},
                fillColor={0,0,0},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-54,60},{54,12}},
                lineColor={255,255,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid),
              Rectangle(extent={{-54,12},{54,-72}}, lineColor={0,0,255})}));
      end Tank;

      partial model Valve
        annotation (Icon(graphics={
              Line(
                points={{0,40},{0,0}},
                color={0,0,0},
                thickness=0.5),
              Polygon(
                points={{-80,40},{-80,-40},{0,0},{-80,40}},
                lineColor={0,0,0},
                lineThickness=0.5),
              Polygon(
                points={{80,40},{0,0},{80,-40},{80,40}},
                lineColor={0,0,0},
                lineThickness=0.5),
              Rectangle(
                extent={{-20,60},{20,40}},
                lineColor={0,0,0},
                fillColor={0,0,0},
                fillPattern=FillPattern.Solid)}),
                                  Diagram(graphics));
      end Valve;

      model FlowJoin
        annotation (Diagram(graphics),
                             Icon(graphics={Polygon(points={{-40,60},{0,20},{40,
                    20},{40,-20},{0,-20},{-40,-60},{-40,-20},{-20,0},{-40,20},{
                    -40,60}}, lineColor={0,0,0})}));
      end FlowJoin;

      model FlowSplit
        annotation (Diagram(graphics),
                             Icon(graphics={Polygon(points={{40,60},{0,20},{-40,
                    20},{-40,-20},{0,-20},{40,-60},{40,-20},{22,0},{40,20},{40,
                    60}}, lineColor={0,0,0})}));
      end FlowSplit;

      model SensThrough
        annotation (Icon(graphics={
              Rectangle(extent={{-40,-20},{40,-60}}, lineColor={0,0,0}),
              Line(points={{0,20},{0,-20}}, color={0,0,0}),
              Ellipse(extent={{-40,100},{40,20}}, lineColor={0,0,0}),
              Line(points={{40,60},{60,60}}),
              Text(extent={{-100,-76},{100,-100}}, textString=
                                                       "%name")}));
      end SensThrough;

      model SensP
        annotation (Icon(graphics={
              Line(points={{0,20},{0,-20}}, color={0,0,0}),
              Ellipse(extent={{-40,100},{40,20}}, lineColor={0,0,0}),
              Line(points={{40,60},{60,60}}),
              Text(extent={{-100,-52},{100,-86}}, textString=
                                                      "%name")}));
      end SensP;

      model Drum
        annotation (Icon(graphics={
              Ellipse(
                extent={{-80,80},{80,-80}},
                lineColor={128,128,128},
                fillColor={128,128,128},
                fillPattern=FillPattern.Solid),
              Polygon(points={{-60,0},{-60,-6},{-58,-16},{-52,-30},{-44,-42},{
                    -38,-46},{-32,-50},{-22,-56},{-16,-58},{-8,-60},{-6,-60},{0,
                    -60},{6,-60},{12,-58},{22,-56},{30,-52},{36,-48},{42,-42},{
                    48,-36},{52,-28},{58,-18},{60,-8},{60,0},{-60,0}},
                  lineColor={128,128,128}),
              Polygon(
                points={{-60,0},{-58,16},{-50,34},{-36,48},{-26,54},{-16,58},{
                    -6,60},{0,60},{10,60},{20,56},{30,52},{36,48},{46,40},{52,
                    30},{56,22},{58,14},{60,6},{60,0},{-60,0}},
                lineColor={128,128,128},
                fillColor={159,191,223},
                fillPattern=FillPattern.Solid)}));
      end Drum;

      partial model Pump
        annotation (Icon(graphics={
              Polygon(
                points={{-40,-24},{-60,-60},{60,-60},{40,-24},{-40,-24}},
                lineColor={0,0,255},
                pattern=LinePattern.None,
                fillColor={0,0,191},
                fillPattern=FillPattern.Solid),
              Ellipse(
                extent={{-60,80},{60,-40}},
                lineColor={0,0,0},
                fillPattern=FillPattern.Sphere),
              Polygon(
                points={{-30,52},{-30,-8},{48,20},{-30,52}},
                lineColor={0,0,0},
                pattern=LinePattern.None,
                fillPattern=FillPattern.HorizontalCylinder,
                fillColor={255,255,255}),
              Text(extent={{-100,-64},{100,-90}}, textString=
                                                      "%name")}));
      end Pump;

      partial model Accumulator
        annotation (Icon(graphics={
              Rectangle(
                extent={{-60,80},{60,-40}},
                lineColor={0,0,255},
                pattern=LinePattern.None,
                fillColor={128,128,128},
                fillPattern=FillPattern.Solid),
              Ellipse(
                extent={{-60,100},{60,60}},
                lineColor={0,0,255},
                pattern=LinePattern.None,
                fillColor={128,128,128},
                fillPattern=FillPattern.Solid),
              Ellipse(
                extent={{-60,-20},{60,-60}},
                lineColor={0,0,255},
                pattern=LinePattern.None,
                fillColor={128,128,128},
                fillPattern=FillPattern.Solid),
              Ellipse(
                extent={{-52,94},{52,64}},
                lineColor={0,0,191},
                pattern=LinePattern.None,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-52,22},{52,-40}},
                lineColor={0,0,191},
                fillColor={0,0,191},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-52,80},{52,20}},
                lineColor={0,0,255},
                pattern=LinePattern.None,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Ellipse(
                extent={{-52,-24},{52,-54}},
                lineColor={0,0,191},
                pattern=LinePattern.None,
                fillColor={0,0,191},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-4,-58},{4,-86}},
                lineColor={0,0,255},
                pattern=LinePattern.None,
                fillColor={128,128,128},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-26,-86},{26,-94}},
                lineColor={0,0,255},
                pattern=LinePattern.None,
                fillColor={128,128,128},
                fillPattern=FillPattern.Solid),
              Text(extent={{-62,-100},{64,-122}}, textString=
                                                      "%name"),
              Polygon(
                points={{-74,86},{-60,72},{-54,78},{-68,92},{-74,86}},
                lineColor={0,0,255},
                pattern=LinePattern.None,
                fillColor={128,128,128},
                fillPattern=FillPattern.Solid)}),
                                  Diagram(graphics));
      end Accumulator;

      partial model PumpMech
        annotation (Icon(graphics={
              Rectangle(
                extent={{54,28},{80,12}},
                lineColor={0,0,0},
                fillPattern=FillPattern.HorizontalCylinder,
                fillColor={160,160,164}),
              Polygon(
                points={{-40,-24},{-60,-60},{60,-60},{40,-24},{-40,-24}},
                lineColor={0,0,255},
                pattern=LinePattern.None,
                fillColor={0,0,191},
                fillPattern=FillPattern.Solid),
              Ellipse(
                extent={{-60,80},{60,-40}},
                lineColor={0,0,0},
                fillPattern=FillPattern.Sphere),
              Polygon(
                points={{-30,52},{-30,-8},{48,20},{-30,52}},
                lineColor={0,0,0},
                pattern=LinePattern.None,
                fillPattern=FillPattern.HorizontalCylinder,
                fillColor={255,255,255}),
              Text(extent={{-100,-64},{100,-90}}, textString=
                                                      "%name")}));
      end PumpMech;

      partial model PressDrop
        annotation (Icon(graphics={Rectangle(
                extent={{-80,40},{80,-40}},
                lineColor={0,0,0},
                fillPattern=FillPattern.HorizontalCylinder), Polygon(
                points={{-80,40},{-42,40},{-20,12},{20,12},{40,40},{80,40},{80,
                    -40},{40,-40},{20,-12},{-20,-12},{-40,-40},{-80,-40},{-80,
                    40}},
                lineColor={0,0,0},
                fillPattern=FillPattern.HorizontalCylinder,
                fillColor={0,0,255})}),                                                   Diagram(graphics));
      end PressDrop;

      partial model SteamTurbineUnit
        annotation (Icon(graphics={
              Line(
                points={{14,20},{14,42},{38,42},{38,20}},
                color={0,0,0},
                thickness=0.5),
              Rectangle(
                extent={{-100,8},{100,-8}},
                lineColor={0,0,0},
                fillPattern=FillPattern.HorizontalCylinder,
                fillColor={160,160,164}),
              Polygon(
                points={{-14,48},{-14,-48},{14,-20},{14,20},{-14,48}},
                lineColor={0,0,0},
                lineThickness=0.5,
                fillColor={0,0,255},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{38,20},{38,-20},{66,-46},{66,48},{38,20}},
                lineColor={0,0,0},
                lineThickness=0.5,
                fillColor={0,0,255},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{-66,20},{-66,-20},{-40,-44},{-40,48},{-66,20}},
                lineColor={0,0,0},
                lineThickness=0.5,
                fillColor={0,0,255},
                fillPattern=FillPattern.Solid),
              Line(
                points={{-100,70},{-100,70},{-66,70},{-66,20}},
                color={0,0,0},
                thickness=0.5),
              Line(
                points={{-40,46},{-40,70},{26,70},{26,42}},
                color={0,0,0},
                thickness=0.5),
              Line(
                points={{-14,-46},{-14,-70},{66,-70},{66,-46}},
                color={0,0,0},
                thickness=0.5),
              Line(
                points={{66,-70},{100,-70}},
                color={0,0,255},
                thickness=0.5)}),
                                Diagram(graphics));
      end SteamTurbineUnit;

      partial model Header
        annotation (Icon(graphics={
              Ellipse(
                extent={{-80,80},{80,-80}},
                lineColor={95,95,95},
                fillColor={95,95,95},
                fillPattern=FillPattern.Solid),
              Ellipse(extent={{70,70},{-70,-70}}, lineColor={95,95,95}),
              Text(extent={{-100,-84},{100,-110}}, textString=
                  "%name")}),Diagram(graphics));
      end Header;
    end Water;

    partial model HeatFlow
      annotation (Icon(graphics={Rectangle(
              extent={{-80,20},{80,-20}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Forward)}));
    end HeatFlow;

    partial model MetalWall
      annotation (Icon(graphics={Rectangle(
              extent={{-80,20},{80,-20}},
              lineColor={0,0,0},
              fillColor={128,128,128},
              fillPattern=FillPattern.Solid)}));
    end MetalWall;

    package Gas "Icons for component using water/steam as working fluid"
      extends Modelica.Icons.Library;
      partial model SourceP
        annotation (Icon(graphics={
              Ellipse(
                extent={{-80,80},{80,-80}},
                lineColor={128,128,128},
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Text(
                extent={{-20,34},{28,-26}},
                lineColor={255,255,255},
                textString=
                     "P"),
              Text(extent={{-100,-78},{100,-106}}, textString=
                                                       "%name")}));
      end SourceP;

      partial model SourceW
        annotation (Icon(graphics={
              Rectangle(
                extent={{-80,40},{80,-40}},
                lineColor={128,128,128},
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{-12,-20},{66,0},{-12,20},{34,0},{-12,-20}},
                lineColor={128,128,128},
                fillColor={0,0,0},
                fillPattern=FillPattern.Solid),
              Text(extent={{-100,-52},{100,-80}}, textString=
                                                      "%name")}));
      end SourceW;

      partial model Tube
        annotation (Icon(graphics={Rectangle(
                extent={{-80,40},{80,-40}},
                lineColor={0,0,0},
                fillPattern=FillPattern.HorizontalCylinder,
                fillColor={159,159,223})}),
                               Diagram(graphics));
      end Tube;

      partial model Mixer
        annotation (Icon(graphics={Ellipse(
                extent={{80,80},{-80,-80}},
                lineColor={128,128,128},
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid), Text(extent={{-100,-84},{100,
                    -110}}, textString=
                  "%name")}),Diagram(graphics));
      end Mixer;

      partial model Valve
        annotation (Icon(graphics={
              Line(
                points={{0,40},{0,0}},
                color={0,0,0},
                thickness=0.5),
              Polygon(
                points={{-80,40},{-80,-40},{0,0},{-80,40}},
                lineColor={128,128,128},
                lineThickness=0.5,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{80,40},{0,0},{80,-40},{80,40}},
                lineColor={128,128,128},
                lineThickness=0.5,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-20,60},{20,40}},
                lineColor={0,0,0},
                fillColor={0,0,0},
                fillPattern=FillPattern.Solid)}),
                                  Diagram(graphics));
      end Valve;

      model FlowJoin
        annotation (Diagram(graphics),
                             Icon(graphics={Polygon(
                points={{-40,60},{0,20},{40,20},{40,-20},{0,-20},{-40,-60},{-40,
                    -20},{-20,0},{-40,20},{-40,60}},
                lineColor={128,128,128},
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid)}));
      end FlowJoin;

      model FlowSplit
        annotation (Diagram(graphics),
                             Icon(graphics={Polygon(
                points={{40,60},{0,20},{-40,20},{-40,-20},{0,-20},{40,-60},{40,
                    -20},{22,0},{40,20},{40,60}},
                lineColor={128,128,128},
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid)}));
      end FlowSplit;

      model SensThrough
        annotation (Icon(graphics={
              Rectangle(
                extent={{-40,-20},{40,-60}},
                lineColor={128,128,128},
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Line(points={{0,20},{0,-20}}, color={0,0,0}),
              Ellipse(extent={{-40,100},{40,20}}, lineColor={0,0,0}),
              Line(points={{40,60},{60,60}}),
              Text(extent={{-100,-76},{100,-100}}, textString=
                                                       "%name")}));
      end SensThrough;

      model SensP
        annotation (Icon(graphics={
              Line(points={{0,20},{0,-20}}, color={0,0,0}),
              Ellipse(extent={{-40,100},{40,20}}, lineColor={0,0,0}),
              Line(points={{40,60},{60,60}}),
              Text(extent={{-100,-52},{100,-86}}, textString=
                                                      "%name")}));
      end SensP;

      partial model Compressor
        annotation (Icon(graphics={
              Polygon(
                points={{24,26},{30,26},{30,76},{60,76},{60,82},{24,82},{24,26}},
                lineColor={128,128,128},
                lineThickness=0.5,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{-30,76},{-30,56},{-24,56},{-24,82},{-60,82},{-60,76},{
                    -30,76}},
                lineColor={128,128,128},
                lineThickness=0.5,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-60,8},{60,-8}},
                lineColor={0,0,0},
                fillPattern=FillPattern.HorizontalCylinder,
                fillColor={160,160,164}),
              Polygon(
                points={{-30,60},{-30,-60},{30,-26},{30,26},{-30,60}},
                lineColor={128,128,128},
                lineThickness=0.5,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid)}),
                                  Diagram(graphics));
      end Compressor;

      partial model Turbine
        annotation (Icon(graphics={
              Polygon(
                points={{-28,76},{-28,28},{-22,28},{-22,82},{-60,82},{-60,76},{
                    -28,76}},
                lineColor={128,128,128},
                lineThickness=0.5,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{26,56},{32,56},{32,76},{60,76},{60,82},{26,82},{26,56}},
                lineColor={128,128,128},
                lineThickness=0.5,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-60,8},{60,-8}},
                lineColor={0,0,0},
                fillPattern=FillPattern.HorizontalCylinder,
                fillColor={160,160,164}),
              Polygon(
                points={{-28,28},{-28,-26},{32,-60},{32,60},{-28,28}},
                lineColor={128,128,128},
                lineThickness=0.5,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid)}),
                                  Diagram(graphics));
      end Turbine;

      partial model GasTurbineUnit
        annotation (Icon(graphics={
              Line(
                points={{-22,26},{-22,48},{22,48},{22,28}},
                color={0,0,0},
                thickness=2.5),
              Rectangle(
                extent={{-100,8},{100,-8}},
                lineColor={0,0,0},
                fillPattern=FillPattern.HorizontalCylinder,
                fillColor={160,160,164}),
              Polygon(
                points={{-80,60},{-80,-60},{-20,-26},{-20,26},{-80,60}},
                lineColor={128,128,128},
                lineThickness=0.5,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{20,28},{20,-26},{80,-60},{80,60},{20,28}},
                lineColor={128,128,128},
                lineThickness=0.5,
                fillColor={159,159,223},
                fillPattern=FillPattern.Solid),
              Ellipse(
                extent={{-16,64},{16,32}},
                lineColor={0,0,0},
                fillPattern=FillPattern.Sphere,
                fillColor={255,0,0})}),
                                Diagram(graphics));
      end GasTurbineUnit;
    end Gas;
  end Icons;

  package Choices "Choice enumerations for ThermoPower models"
    package CylinderFourier
      type NodeDistribution = enumeration(
          uniform "Uniform distribution of node radii",
          thickInternal
            "Quadratically distributed node radii - thickest at rint",
          thickExternal
            "Quadratically distributed node radii - thickest at rext",
          thickBoth
            "Quadratically distributed node radii - thickest at both extremes")
        "Type, constants and menu choices for node distribution";
    end CylinderFourier;

    package CylinderMechanicalStress
      type MechanicalStandard = enumeration(
          TRDstandard "TRD standard",
          ASMEstandard "Laborelec-ASME standard")
        "Types, constants and menu choices for mechanical standard";
    end CylinderMechanicalStress;

    package Flow1D
      type FFtypes = enumeration(
          Kfnom "Kfnom friction factor",
          OpPoint "Friction factor defined by operating point",
          Cfnom "Cfnom friction factor",
          Colebrook "Colebrook's equation",
          NoFriction "No friction")
        "Type, constants and menu choices to select the friction factor";
      type HCtypes = enumeration(
          Middle "Middle of the pipe",
          Upstream "At the inlet",
          Downstream "At the outlet")
        "Type, constants and menu choices to select the location of the hydraulic capacitance";
    end Flow1D;

    package PressDrop
      type FFtypes = enumeration(
          Kf "Kf friction factor",
          OpPoint "Friction factor defined by operating point",
          Kinetic "Kinetic friction factor")
        "Type, constants and menu choices to select the friction factor";
    end PressDrop;

    package Valve
      type CvTypes = enumeration(
          Av "Av (metric) flow coefficient",
          Kv "Kv (metric) flow coefficient",
          Cv "Cv (US) flow coefficient",
          OpPoint "Av defined by nominal operating point")
        "Type, constants and menu choices to select the type of Cv data";
    end Valve;

    package TurboMachinery
      type TableTypes = enumeration(
          matrix "Explicitly supplied as parameter matrix table",
          file "Read from a file")
        "Type, constants and menu choices to select the representation of table matrix";
    end TurboMachinery;

    package Init "Options for initialisation"
      type Options = enumeration(
          noInit "No initial equations",
          steadyState "Steady-state initialisation",
          steadyStateNoP "Steady-state initialisation except pressures",
          steadyStateNoT "Steady-state initialisation except temperatures",
          steadyStateNoPT
            "Steady-state initialisation except pressures and temperatures")
        "Type, constants and menu choices to select the initialisation options";
    end Init;

    package FlowReversal "Options for flow reversal support"
      type Options = enumeration(
          fullFlowReversal "Full flow reversal support",
          smallFlowReversal "Small flow reversal allowed (approx. model)",
          noFlowReversal "Flow reversal is not allowed")
        "Type, constants and menu choices to select the flow reversal support options";
    end FlowReversal;

    package System
    type Dynamics = enumeration(
          DynamicFreeInitial
            "DynamicFreeInitial -- Dynamic balance, Initial guess value",
          FixedInitial "FixedInitial -- Dynamic balance, Initial value fixed",
          SteadyStateInitial
            "SteadyStateInitial -- Dynamic balance, Steady state initial with guess value",

          SteadyState
            "SteadyState -- Steady state balance, Initial guess value")
        "Enumeration to define definition of balance equations";

    end System;

    package FluidPhase
      type FluidPhases = enumeration(
          Liquid "Liquid",
          Steam "Steam",
          TwoPhases "Two Phases")
        "Type, constants and menu choices to select the fluid phase";
    end FluidPhase;
  end Choices;

  package Functions "Miscellaneous functions"
    extends Modelica.Icons.Library;
    function linear
      extends Modelica.Icons.Function;
      input Real x;
      output Real y;
    algorithm
      y := x;
      annotation (derivative=Functions.linear_der);
    end linear;

    function linear_der
      extends Modelica.Icons.Function;
      input Real x;
      input Real der_x;
      output Real der_y;
    algorithm
      der_y := der_x;
    end linear_der;

    function one
      extends Modelica.Icons.Function;
      input Real x;
      output Real y;
    algorithm
      y := 1;
      annotation (derivative=Functions.one_der);
    end one;

    function one_der
      extends Modelica.Icons.Function;
      input Real x;
      input Real der_x;
      output Real der_y;
    algorithm
      der_y := 0;
    end one_der;

    function sqrtReg
      "Symmetric square root approximation with finite derivative in zero"
      extends Modelica.Icons.Function;
      input Real x;
      input Real delta=0.01 "Range of significant deviation from sqrt(x)";
      output Real y;
    algorithm
      y := x/sqrt(sqrt(x*x+delta*delta));
      annotation(derivative(zeroDerivative=delta)=Functions.sqrtReg_der,
        Documentation(info="<html>
This function approximates sqrt(x)*sign(x), such that the derivative is finite and smooth in x=0. 
</p>
<p>
<table border=1 cellspacing=0 cellpadding=2> 
<tr><th>Function</th><th>Approximation</th><th>Range</th></tr>
<tr><td>y = sqrtReg(x)</td><td>y ~= sqrt(abs(x))*sign(x)</td><td>abs(x) &gt;&gt delta</td></tr>
<tr><td>y = sqrtReg(x)</td><td>y ~= x/sqrt(delta)</td><td>abs(x) &lt;&lt  delta</td></tr>
</table>
<p>
With the default value of delta=0.01, the difference between sqrt(x) and sqrtReg(x) is 16% around x=0.1, 0.25% around x=0.1 and 0.0025% around x=1.
</p> 
</html>", revisions="<html>
<ul>
<li><i>15 Mar 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Created. </li>
</ul>
</html>"),      Documentation(info="<html>
This function approximates sqrt(x)*sign(x), such that the derivative is finite and smooth in x=0. 
</p>
<p>
<table border=1 cellspacing=0 cellpadding=2> 
<tr><th>Function</th><th>Approximation</th><th>Range</th></tr>
<tr><td>y = sqrtReg(x)</td><td>y ~= sqrt(abs(x))*sign(x)</td><td>abs(x) &gt;&gt delta</td></tr>
<tr><td>y = sqrtReg(x)</td><td>y ~= x/delta</td><td>abs(x) &lt;&lt  delta</td></tr>
</table>
<p>
With the default value of delta=0.01, the difference between sqrt(x) and sqrtReg(x) is 0.5% around x=0.1 and 0.005% around x=1.
</p> 
</html>", revisions="<html>
<ul>
<li><i>15 Mar 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Created. </li>
</ul>
</html>"));
    end sqrtReg;

    function sqrtReg_der "Derivative of sqrtReg"
      extends Modelica.Icons.Function;
      input Real x;
      input Real delta=0.01 "Range of significant deviation from sqrt(x)";
      input Real dx "Derivative of x";
      output Real dy;
    algorithm
      dy := dx*0.5*(x*x+2*delta*delta)/((x*x+delta*delta)^1.25);
    annotation (Documentation(info="<html>
</html>", revisions="<html>
<ul>
<li><i>15 Mar 2005</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       Created. </li>
</ul>
</html>"));
    end sqrtReg_der;

    block OffsetController "Offset computation for steady-state conditions"
      extends Modelica.Blocks.Interfaces.BlockIcon;
      parameter Real steadyStateGain=0.0
        "0.0: Adds offset to input - 1.0: Closed loop action to find steady state";
      parameter Real SP0 "Initial setpoint for the controlled variable";
      parameter Real deltaSP=0
        "Variation of the setpoint for the controlled variable";
      parameter Modelica.SIunits.Time Tstart=0
        "Start time of the setpoint ramp change";
      parameter Modelica.SIunits.Time Tend=0
        "End time of the setpoint ramp change";
      parameter Real Kp "Proportional gain";
      parameter Real Ti "Integral time constant";
      parameter Real biasCO
        "Bias value of the control variable when computing the steady state";
    protected
      Real SP;
      Real error;
      Real integralError;
    public
      Modelica.Blocks.Interfaces.RealInput deltaCO
        annotation (Placement(transformation(extent={{-140,62},{-100,100}},
              rotation=0)));
      Modelica.Blocks.Interfaces.RealInput PV
        annotation (Placement(transformation(extent={{-140,-100},{-100,-60}},
              rotation=0)));
      Modelica.Blocks.Interfaces.RealOutput CO
        annotation (Placement(transformation(extent={{100,-20},{140,20}},
              rotation=0)));
    equation
      SP = if time <= Tstart then SP0 else if time >= Tend then SP0 + deltaSP else
              SP0 + (time - Tstart)/(Tend - Tstart)*deltaSP;
      error = (SP -PV)           *steadyStateGain;
      der(integralError) = error;
      CO           = Kp*(error + integralError/Ti) + biasCO + (1.0 -
        steadyStateGain)*deltaCO;
      annotation (
        Documentation(info="<HTML>
<p>This model is useful to compute the steady state value of a control variable corresponding to some specified setpoint of an output variable, and to reuse it later to perform simulations starting from this steady state condition.
<p>The block has two different behaviours, depending on the value of the <tt>steadyState</tt> parameter.
<p>When <tt>steadyState = 1</tt>, the <tt>deltaCO</tt> input is ignored, and the block acts as a standard PI controller with transfer function Kp*(1+1/sTi) to bring the process variable connected to the <tt>PV</tt> input at the setpoint value, by acting on the control variable connected to the <tt>CO</tt> output. The setpoint value is <tt>SP0</tt> at time zero, and may change by <tt>deltaSP</tt> from <tt>Tstart</tt> to <tt>Tend</tt>; this can be useful to bring the process far away from the tentative start values of the transient without any inconvenience. The control variable can be biased by <tt>biasCO</tt> to start near the expected steady state value of <tt>CO</tt>.
<p>When <tt>steadyState = 0</tt>, the <tt>PV</tt> input is ignored, and the <tt>CO</tt> output is simply the sum of the <tt>deltaCO</tt> input and of the freezed steady-state output of the controller.
<p>To perform a steady state computation:
<ol>
<li>Set <tt>steadyState = 1</tt> and suitably tune <tt>Kp</tt>, <tt>Ti</tt> and <tt>biasCO</tt>
<li>Simulate a transient until the desired steady state is achieved.
<li>Set <tt>steadyState = 0</tt> and continue the simulation for 0 s
<li>Save the final state of the simulation, which contains the initial steady-state values of all the variables for subsequent transient simulations
</ol>
<p>To perform experiments starting from a steady state:
<ol>
<li>Load a previously saved steady state, to be used as initial state
<li>Perform the simulation of the desired transient. The <tt>offsetCO</tt> input value will be automatically added to the previously computed steady state value.
</ol>
<p><b>Revision history:</b></p>
<ul>
<li><i>15 Feb 2004</i>
    by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
       First release.</li>
</ul>
</HTML>"),
        Diagram(graphics),
        Icon(graphics={Text(extent={{-90,90},{94,-92}}, textString=
                                                    "SS Offset")}));
    end OffsetController;
    annotation (Documentation(info="<HTML>
This package contains general-purpose functions and models
</HTML>"));
  end Functions;

  package Utils
    model VapourCorrelation
      import Modelica.SIunits.*;
      import Poly = Modelica.Media.Incompressible.TableBased.Polynomials_Temp;
      import Modelica.Utilities.Streams.*;
       parameter Pressure p_min = 20e5;
       parameter Pressure p_max = 100e5;
       parameter Pressure p_nom = (p_max+p_min)/2;
       parameter Integer N = 50;
       parameter Integer ord_T = 3;
       parameter Integer ord_rhols = 3;
       parameter Integer ord_rhovs = 3;
       parameter Integer ord_rels = 3;
       parameter Integer ord_revs = 3;
       parameter Integer ord_hls = 3;
       parameter Integer ord_hvs = 3;
       parameter Integer ord_drhols_dp = ord_rhols-1;
       parameter Integer ord_drhovs_dp = ord_rhovs-1;
       parameter Integer ord_drels_dp = ord_rels-1;
       parameter Integer ord_drevs_dp = ord_revs-1;
       package Medium = Modelica.Media.Water.WaterIF97_ph;
       Medium.SaturationProperties sat;
       Pressure p;
       Temperature T;
       Temperature T_approx;
       Density rhols;
       Density rhols_approx;
       Density rhovs;
       Density rhovs_approx;
       Real rels;
       Real rels_approx;
       Real revs;
       Real revs_approx;
       Real hls;
       Real hls_approx;
       Real hvs;
       Real hvs_approx;
       Real dT_dp;
       Real dT_dp_approx;
       Real drhols_dp;
       Real drhols_dp_approx;
       Real drhovs_dp;
       Real drhovs_dp_approx;
       Real drels_dp;
       Real drels_dp_approx;
       Real drevs_dp;
       Real drevs_dp_approx;
       Real r;
    protected
       parameter Pressure p_data[:] = linspace(p_min, p_max,N);
       parameter Density T_data[:]=
                          {Medium.saturationTemperature(p_data[i]) for i in 1:N};
       parameter Density rhols_data[:]=
                          {Medium.bubbleDensity(Medium.setSat_p(p_data[i])) for i in 1:N};
       parameter Density rhovs_data[:]=
                          {Medium.dewDensity(Medium.setSat_p(p_data[i])) for i in 1:N};
       parameter Density rels_data[:]=
                          {Medium.bubbleDensity(Medium.setSat_p(p_data[i]))*
                           Medium.bubbleEnthalpy(Medium.setSat_p(p_data[i])) - p_data[i] for i in 1:N};
       parameter Density revs_data[:]=
                          {Medium.dewDensity(Medium.setSat_p(p_data[i])) *
                           Medium.dewEnthalpy(Medium.setSat_p(p_data[i])) - p_data[i] for i in 1:N};
       parameter SpecificEnthalpy hls_data[:]=
                          {Medium.bubbleEnthalpy(Medium.setSat_p(p_data[i])) for i in 1:N};
       parameter SpecificEnthalpy hvs_data[:]=
                          {Medium.dewEnthalpy(Medium.setSat_p(p_data[i])) for i in 1:N};
       parameter Real coeff_T[:] =         Poly.fitting(p_data/p_nom,T_data,         ord_T);
       parameter Real coeff_rhols[:] =     Poly.fitting(p_data/p_nom,rhols_data,     ord_rhols);
       parameter Real coeff_rhovs[:] =     Poly.fitting(p_data/p_nom,rhovs_data,     ord_rhovs);
       parameter Real coeff_rels[:] =      Poly.fitting(p_data/p_nom,rels_data,      ord_rels);
       parameter Real coeff_revs[:] =      Poly.fitting(p_data/p_nom,revs_data,      ord_revs);
       parameter Real coeff_hls[:] =       Poly.fitting(p_data/p_nom,hls_data,       ord_hls);
       parameter Real coeff_hvs[:] =       Poly.fitting(p_data/p_nom,hvs_data,       ord_hvs);
       parameter Real coeff_T_dp[:] = {coeff_T[i]*(size(coeff_T,1)-i) for i in 1:size(coeff_T,1)-1}/p_nom;
       parameter Real coeff_drhols_dp[:] = {coeff_rhols[i]*(size(coeff_rhols,1)-i) for i in 1:size(coeff_rhols,1)-1}/p_nom;
       parameter Real coeff_drhovs_dp[:] = {coeff_rhovs[i]*(size(coeff_rhovs,1)-i) for i in 1:size(coeff_rhols,1)-1}/p_nom;
       parameter Real coeff_drels_dp[:] =  {coeff_rels[i]*(size(coeff_rels,1)-i) for i in 1:size(coeff_rels,1)-1}/p_nom;
       parameter Real coeff_drevs_dp[:] =  {coeff_revs[i]*(size(coeff_revs,1)-i) for i in 1:size(coeff_revs,1)-1}/p_nom;
       //Dummy variables
    public
       Temperature T_s;
       Real d_ls;
       Real d_vs;
       Real de_ls;
       Real de_vs;
       Real h_ls;
       Real h_vs;
       Real d_T_s_dp;
       Real d_d_ls_dp;
       Real d_d_vs_dp;
       Real d_de_ls_dp;
       Real d_de_vs_dp;
       //Real dummy_rhols;
       //Real dummy_drhols_dp;
    equation
         p = p_min + (p_max - p_min)*time;
         sat.psat = p;
         sat.Tsat = Medium.saturationTemperature(p);
         T = sat.Tsat;
         rhols = Medium.bubbleDensity(sat);
         rhovs = Medium.dewDensity(sat);
         rels = Medium.bubbleDensity(sat)*Medium.bubbleEnthalpy(sat) - p;
         revs = Medium.dewDensity(sat)*Medium.dewEnthalpy(sat) - p;
         hvs = Medium.dewEnthalpy(sat);
         hls = Medium.bubbleEnthalpy(sat);
         dT_dp = Medium.saturationTemperature_derp(p);
         drhols_dp = Medium.dBubbleDensity_dPressure(sat);
         drhovs_dp = Medium.dDewDensity_dPressure(sat);
         drels_dp = Medium.dBubbleDensity_dPressure(sat)*Medium.bubbleEnthalpy(sat) + Medium.bubbleDensity(sat)*Medium.dBubbleEnthalpy_dPressure(sat) - 1;
         drevs_dp = Medium.dDewDensity_dPressure(sat)*Medium.dewEnthalpy(sat) + Medium.dewDensity(sat)*Medium.dDewEnthalpy_dPressure(sat) - 1;
         r = hvs - hls;
         T_approx        = Poly.evaluate(coeff_T, p/p_nom);
         rhols_approx    = Poly.evaluate(coeff_rhols, p/p_nom);
         rhovs_approx    = Poly.evaluate(coeff_rhovs, p/p_nom);
         rels_approx     = Poly.evaluate(coeff_rels, p/p_nom);
         revs_approx     = Poly.evaluate(coeff_revs, p/p_nom);
         hls_approx      = Poly.evaluate(coeff_hls, p/p_nom);
         hvs_approx      = Poly.evaluate(coeff_hvs, p/p_nom);
         dT_dp_approx = Poly.evaluate(coeff_T_dp, p/p_nom);
         drhols_dp_approx = Poly.evaluate(coeff_drhols_dp, p/p_nom);
         drhovs_dp_approx = Poly.evaluate(coeff_drhovs_dp, p/p_nom);
         drels_dp_approx  = Poly.evaluate(coeff_drels_dp,p/p_nom);
         drevs_dp_approx = Poly.evaluate(coeff_drevs_dp,p/p_nom);
       //dummy variables for checking
    T_s = (((+(20.31))*p/6e+006+(-91.2087))*p/6e+006+(186.107))*p/6e+006+(433.8);
    d_ls = (((+(-19.8527))*p/6e+006+(83.716))*p/6e+006+(-219.824))*p/6e+006+(913.719);
    d_vs = (((+(1.30191))*p/6e+006+(0.432043))*p/6e+006+(28.7046))*p/6e+006+(0.377505);
    de_ls = (((+(6.7412e+007))*p/6e+006+(-3.09753e+008))*p/6e+006+(5.27973e+008))*p/6e+006+(6.29324e+008);
    de_vs = (((+(2.38902e+006))*p/6e+006+(1.38667e+006))*p/6e+006+(7.5263e+007))*p/6e+006+(772937);
    h_ls = (((+(87156.9))*p/6e+006+(-382184))*p/6e+006+(837267))*p/6e+006+(672632);
    h_vs = (((+(25274.6))*p/6e+006+(-125274))*p/6e+006+(108335))*p/6e+006+(2.77663e+006);
    d_T_s_dp = ((+(1.0155e-005))*p/6e+006+(-3.04029e-005))*p/6e+006+(3.10178e-005);
    d_d_ls_dp = ((+(-9.92635e-006))*p/6e+006+(2.79053e-005))*p/6e+006+(-3.66374e-005);
    d_d_vs_dp = ((+(6.50955e-007))*p/6e+006+(1.44014e-007))*p/6e+006+(4.7841e-006);
    d_de_ls_dp = ((+(33.706))*p/6e+006+(-103.251))*p/6e+006+(87.9954);
    d_de_vs_dp = ((+(1.19451))*p/6e+006+(0.462225))*p/6e+006+(12.5438);
       when (terminal()) then
         //Polynomials
         print("\n\n\nPolynomials:\n");
         //Saturation temperature
         print(PolynomialFunction("T_s",coeff_T,"p/"+String(p_nom)));
         //Liquid density at saturation
         print(PolynomialFunction("d_ls",coeff_rhols,"p/"+String(p_nom)));
         //Vapour density at saturation
         print(PolynomialFunction("d_vs",coeff_rhovs,"p/"+String(p_nom)));
         //Liquid density - specific energy product at saturation
         print(PolynomialFunction("de_ls",coeff_rels,"p/"+String(p_nom)));
         //Vapour density - specific energy product at saturation
         print(PolynomialFunction("de_vs",coeff_revs,"p/"+String(p_nom)));
         //Liquid enthalpy at saturation
         print(PolynomialFunction("h_ls",coeff_hls,"p/"+String(p_nom)));
         //Vapour enthalpy at saturation
         print(PolynomialFunction("h_vs",coeff_hvs,"p/"+String(p_nom)));
         //Derivative of the saturation temperature with respect to the pressure
         print(PolynomialFunction("d_T_s_dp",coeff_T_dp,"p/"+String(p_nom)));
         //Derivative of the liquid density with respect to the pressure
         print(PolynomialFunction("d_d_ls_dp",coeff_drhols_dp,"p/"+String(p_nom)));
         //Derivative of the vapour density with respect to the pressure
         print(PolynomialFunction("d_d_vs_dp",coeff_drhovs_dp,"p/"+String(p_nom)));
         //Derivative of the liquid density - specific energy product at saturation with respect to the pressure
         print(PolynomialFunction("d_de_ls_dp",coeff_drels_dp,"p/"+String(p_nom)));
         //Derivative of the vapour density - specific energy product at saturation with respect to the pressure
         print(PolynomialFunction("d_de_vs_dp",coeff_drevs_dp,"p/"+String(p_nom)));
      end when;
       annotation (uses(Modelica(version="2.2.1")),
         experiment,
         experimentSetupOutput);
    end VapourCorrelation;

    function PolynomialFunction
      input String variable;
      input Real coeff[:];
      input String independent_var;
      output String res;
    protected
      Integer coeff_size;
    algorithm
      coeff_size:=size(coeff, 1);
      res:=variable + " = ";
      for i in 1:coeff_size-1 loop
        res:= res+"(";
      end for;
      for i in 1:coeff_size loop
          if (i<coeff_size) then
                 res:= res + "+("+String(coeff[i])+"))*"+ independent_var;
            else
                 res:= res + "+("+String(coeff[i])+");";
          end if;
        end for;
    //    res:= res+"\n";
    end PolynomialFunction;
  end Utils;

  package Blocks
    package Continuous
      block PI "Proportional-Integral controller"
        parameter Real k=1 "Gain";
        parameter Modelica.SIunits.Time T=1 "Time Constant (T>0 required)";
        parameter Real x_start=0 "Initial or guess value of state"
          annotation (Dialog(group="Initialization"));
        parameter Real y_start=0 "Initial value of output"
          annotation(Dialog(enable=initType == Init.SteadyState or initType == Init.InitialOutput, group=
                "Initialization"));
        extends CombinedCycle.Blocks.Interfaces.SISO;
        output Real x(start=x_start) "State of block";
      equation
        der(x) = u/T;
        y = k*(x + u);
        annotation (defaultComponentName="PI",
          Window(
            x=0.24,
            y=0.13,
            width=0.56,
            height=0.5),
          Documentation(info="
<HTML>
<p>
This blocks defines the transfer function between the input u and
the output y (element-wise) as <i>PI</i> system:
</p>
<pre>
                 1
   y = k * (1 + ---) * u
                T*s
           T*s + 1
     = k * ------- * u
             T*s
</pre>
<p>
If you would like to be able to change easily between different
transfer functions (FirstOrder, SecondOrder, ... ) by changing
parameters, use the general model class <b>TransferFunction</b>
instead and model a PI SISO system with parameters<br>
b = {k*T, k}, a = {T, 0}.
</p>
<pre>
Example:
 
   parameter: k = 0.3,  T = 0.4
 
   results in:
               0.4 s + 1
      y = 0.3 ----------- * u
                 0.4 s
</pre>

<p>
It might be difficult to initialize the PI component in steady state
due to the integrator part.
This is discussed in the description of package
<a href=\"Modelica://Modelica.Blocks.Continuous#info\">Continuous</a>.
</p>
 
</HTML>
"),       Icon(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={2,2}), graphics={
              Line(points={{-80,78},{-80,-90}}, color={192,192,192}),
              Polygon(
                points={{-80,90},{-88,68},{-72,68},{-80,88},{-80,90}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-90,-80},{82,-80}}, color={192,192,192}),
              Polygon(
                points={{90,-80},{68,-72},{68,-88},{90,-80}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(
                points={{-80,-80},{-80,-20},{60,80}},
                color={0,0,255},
                thickness=0.25),
              Text(
                extent={{0,6},{60,-56}},
                lineColor={192,192,192},
                textString=
                     "PI"),
              Text(
                extent={{-150,-150},{150,-110}},
                lineColor={0,0,0},
                textString=
                     "T=%T")}),
          Diagram(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={2,2}), graphics={
              Rectangle(extent={{-60,60},{60,-60}}),
              Text(
                extent={{-68,24},{-24,-18}},
                lineColor={0,0,0},
                textString=
                     "k"),
              Text(
                extent={{-32,48},{60,0}},
                lineColor={0,0,0},
                textString=
                     "T s + 1"),
              Text(
                extent={{-30,-8},{52,-40}},
                lineColor={0,0,0},
                textString=
                     "T s"),
              Line(points={{-24,0},{54,0}}, color={0,0,0}),
              Line(points={{-100,0},{-60,0}}),
              Line(points={{62,0},{100,0}})}));
      end PI;

      block FirstOrder "First order transfer function block (= 1 pole)"
        parameter Real k=1 "Gain";
        parameter Modelica.SIunits.Time T=1 "Time Constant";
        parameter Real y_start=0 "Initial or guess value of output (= state)"
          annotation (Dialog(group="Initialization"));
        extends CombinedCycle.Blocks.Interfaces.SISO(y(start=y_start));
      initial equation
        der(y) = 0;
      equation
        der(y) = (k*u - y)/T;
        annotation (
          Documentation(info="<HTML>
<p>
This blocks defines the transfer function between the input u
and the output y (element-wise) as <i>first order</i> system:
</p>
<pre>
               k
     y = ------------ * u
            T * s + 1
</pre>
<p>
If you would like to be able to change easily between different
transfer functions (FirstOrder, SecondOrder, ... ) by changing
parameters, use the general block <b>TransferFunction</b> instead
and model a first order SISO system with parameters<br>
b = {k}, a = {T, 1}.
</p>
<pre>
Example:
   parameter: k = 0.3, T = 0.4
   results in:
             0.3
      y = ----------- * u
          0.4 s + 1.0
</pre>

</HTML>
"),       Icon(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={2,2}), graphics={
              Line(points={{-80,78},{-80,-90}}, color={192,192,192}),
              Polygon(
                points={{-80,90},{-88,68},{-72,68},{-80,88},{-80,90}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-90,-80},{82,-80}}, color={192,192,192}),
              Polygon(
                points={{90,-80},{68,-72},{68,-88},{90,-80}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-80,-80},{-70,-45.11},{-60,-19.58},{-50,-0.9087},{
                    -40,12.75},{-30,22.75},{-20,30.06},{-10,35.41},{0,39.33},{
                    10,42.19},{20,44.29},{30,45.82},{40,46.94},{50,47.76},{60,
                    48.36},{70,48.8},{80,49.12}}),
              Text(
                extent={{0,0},{60,-60}},
                lineColor={192,192,192},
                textString=
                     "PT1"),
              Text(
                extent={{-150,-150},{150,-110}},
                lineColor={0,0,0},
                textString=
                     "T=%T")}),
          Diagram(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={2,2}), graphics={
              Text(
                extent={{-48,52},{50,8}},
                lineColor={0,0,0},
                textString=
                     "k"),
              Text(
                extent={{-54,-6},{56,-56}},
                lineColor={0,0,0},
                textString=
                     "T s + 1"),
              Line(points={{-50,0},{50,0}}, color={0,0,0}),
              Rectangle(extent={{-60,60},{60,-60}}),
              Line(points={{-100,0},{-60,0}}),
              Line(points={{60,0},{100,0}})}),
          Window(
            x=0.15,
            y=0.04,
            width=0.52,
            height=0.55));
      end FirstOrder;
    end Continuous;

    package Interfaces
        partial block SISO
        "Single Input Single Output continuous control block"
          extends CombinedCycle.Blocks.Interfaces.BlockIcon;
          CombinedCycle.Blocks.Interfaces.RealInput u
          "Connector of Real input signal"
            annotation (Placement(transformation(extent={{-140,-20},{-100,20}},
                rotation=0)));
          CombinedCycle.Blocks.Interfaces.RealOutput y
          "Connector of Real output signal"
            annotation (Placement(transformation(extent={{100,-10},{120,10}},
                rotation=0)));
          annotation (             Window(
              x=0.32,
              y=0.07,
              width=0.6,
              height=0.6),
          Documentation(info="<html>
<p>
Block has one continuous Real input and one continuous Real output signal.
</p>
</html>"));
        end SISO;

    connector RealInput = input CombinedCycle.Blocks.Interfaces.RealSignal
        "'input Real' as connector"
      annotation (defaultComponentName="u",
      Icon(graphics={Polygon(
              points={{-100,100},{100,0},{-100,-100},{-100,100}},
              lineColor={0,0,127},
              fillColor={0,0,127},
              fillPattern=FillPattern.Solid)},
           coordinateSystem(extent={{-100,-100},{100,100}},
            preserveAspectRatio=false,
            grid={1,1},
            initialScale=0.2)),
      Diagram(coordinateSystem(
            preserveAspectRatio=false,
            extent={{-100,-100},{100,100}},
            grid={1,1},
            initialScale=0.2), graphics={Polygon(
              points={{0,50},{100,0},{0,-50},{0,50}},
              lineColor={0,0,127},
              fillColor={0,0,127},
              fillPattern=FillPattern.Solid), Text(
              extent={{-120,105},{100,60}},
              lineColor={0,0,127},
              textString=
                 "%name")}),
        Documentation(info="<html>
<p>
Connector with one input signal of type Real.
</p>
</html>"));
    connector RealOutput = output CombinedCycle.Blocks.Interfaces.RealSignal
        "'output Real' as connector"
      annotation (defaultComponentName="y",
      Icon(coordinateSystem(
            preserveAspectRatio=false,
            extent={{-100,-100},{100,100}},
            grid={1,1}), graphics={Polygon(
              points={{-100,100},{100,0},{-100,-100},{-100,100}},
              lineColor={0,0,127},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid)}),
      Diagram(coordinateSystem(
            preserveAspectRatio=false,
            extent={{-100,-100},{100,100}},
            grid={1,1}), graphics={Polygon(
              points={{-100,50},{0,0},{-100,-50},{-100,50}},
              lineColor={0,0,127},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid), Text(
              extent={{-100,140},{130,60}},
              lineColor={0,0,127},
              textString=
                 "%name")}),
        Documentation(info="<html>
<p>
Connector with one output signal of type Real.
</p>
</html>"));
        partial block BlockIcon "Basic graphical layout of input/output block"
          annotation (
            Window(
              x=0,
              y=0,
              width=0.6,
              height=0.6),
            Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
                  {100,100}}), graphics={Rectangle(
                extent={{-100,-100},{100,100}},
                lineColor={0,0,127},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid), Text(extent={{-150,150},{150,
                    110}}, textString=
                    "%name")}),
          Documentation(info="<html>
<p>
Block that has only the basic icon for an input/output
block (no declarations, no equations). Most blocks
of package Modelica.Blocks inherit directly or indirectly
from this block.
</p>
</html>"));
        end BlockIcon;

    connector RealSignal "Real port (both input/output possible)"
      extends Real;
    end RealSignal;

        partial block SO "Single Output continuous control block"
          extends CombinedCycle.Blocks.Interfaces.BlockIcon;
          CombinedCycle.Blocks.Interfaces.RealOutput y
          "Connector of Real output signal"
            annotation (Placement(transformation(extent={{100,-10},{120,10}},
                rotation=0)));
          annotation (
            Window(
              x=0.25,
              y=0.02,
              width=0.6,
              height=0.6),
            Diagram(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={2,2}), graphics),
          Documentation(info="<html>
<p>
Block has one continuous Real output signal.
</p>
</html>"));
        end SO;

        partial block SignalSource "Base class for continuous signal source"
          extends CombinedCycle.Blocks.Interfaces.SO;
          parameter Real offset=0 "offset of output signal";
          parameter Modelica.SIunits.Time startTime=0
          "output = offset for time < startTime";
        annotation (Documentation(info="<html>
<p>
Basic block for Real sources of package Blocks.Sources.
This component has one continuous Real output signal y
and two parameters (offset, startTime) to shift the
generated signal.
</p>
</html>"));
        end SignalSource;
    end Interfaces;

    package Sources
          block Constant "Generate constant signal of type Real"
            parameter Real k=1 "Constant output value";
            extends CombinedCycle.Blocks.Interfaces.SO;
          equation
            y = k;
            annotation (defaultComponentName="const",
              Window(
                x=0.29,
                y=0.19,
                width=0.6,
                height=0.6),
              Icon(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={2,2}), graphics={
              Line(points={{-80,68},{-80,-80}}, color={192,192,192}),
              Polygon(
                points={{-80,90},{-88,68},{-72,68},{-80,90}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-90,-70},{82,-70}}, color={192,192,192}),
              Polygon(
                points={{90,-70},{68,-62},{68,-78},{90,-70}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-80,0},{80,0}}, color={0,0,0}),
              Text(
                extent={{-150,-150},{150,-110}},
                lineColor={0,0,0},
                textString=
                         "k=%k")}),
              Diagram(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={2,2}), graphics={
              Polygon(
                points={{-80,90},{-88,68},{-72,68},{-80,90}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-80,68},{-80,-80}}, color={192,192,192}),
              Line(
                points={{-80,0},{80,0}},
                color={0,0,0},
                thickness=0.5),
              Line(points={{-90,-70},{82,-70}}, color={192,192,192}),
              Polygon(
                points={{90,-70},{68,-62},{68,-78},{90,-70}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Text(
                extent={{-75,94},{-22,76}},
                lineColor={160,160,164},
                textString=
                         "y"),
              Text(
                extent={{70,-80},{94,-100}},
                lineColor={160,160,164},
                textString=
                         "time"),
              Text(
                extent={{-101,8},{-81,-12}},
                lineColor={160,160,164},
                textString=
                         "k")}),
          Documentation(info="<html>

</html>"));
          end Constant;

          block Step "Generate step signal of type Real"
            parameter Real height=1 "Height of step";
            extends CombinedCycle.Blocks.Interfaces.SignalSource;
            parameter Real k=1e5;
            constant Real pi = Modelica.Constants.pi;
      protected
            Real activation;
          equation
            activation = (atan(k*(time-startTime))+pi/2)/pi;
            y = offset + height*activation;
            annotation (
              Window(
                x=0.38,
                y=0.11,
                width=0.6,
                height=0.6),
              Icon(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={1,1}), graphics={
              Line(points={{-80,68},{-80,-80}}, color={192,192,192}),
              Polygon(
                points={{-80,90},{-88,68},{-72,68},{-80,90}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-90,-70},{82,-70}}, color={192,192,192}),
              Polygon(
                points={{90,-70},{68,-62},{68,-78},{90,-70}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-80,-70},{0,-70},{0,50},{80,50}}, color={0,0,0}),
              Text(
                extent={{-150,-150},{150,-110}},
                lineColor={0,0,0},
                textString=
                         "startTime=%startTime")}),
              Diagram(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={1,1}), graphics={
              Polygon(
                points={{-80,90},{-88,68},{-72,68},{-80,90}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-80,68},{-80,-80}}, color={192,192,192}),
              Line(
                points={{-80,-18},{0,-18},{0,50},{80,50}},
                color={0,0,0},
                thickness=0.5),
              Line(points={{-90,-70},{82,-70}}, color={192,192,192}),
              Polygon(
                points={{90,-70},{68,-62},{68,-78},{90,-70}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Text(
                extent={{70,-80},{94,-100}},
                lineColor={160,160,164},
                textString=
                         "time"),
              Text(
                extent={{-21,-72},{25,-90}},
                lineColor={160,160,164},
                textString=
                         "startTime"),
              Line(
                points={{0,-17},{0,-71}},
                color={192,192,192},
                pattern=LinePattern.Dash),
              Text(
                extent={{-68,-36},{-22,-54}},
                lineColor={160,160,164},
                textString=
                         "offset"),
              Line(
                points={{-13,50},{-13,-17}},
                color={192,192,192},
                pattern=LinePattern.Solid,
                thickness=0.25,
                arrow={Arrow.None,Arrow.None}),
              Polygon(
                points={{2,50},{-19,50},{2,50}},
                lineColor={192,192,192},
                pattern=LinePattern.Dash),
              Polygon(
                points={{-13,-17},{-16,-4},{-10,-4},{-13,-17},{-13,-17}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{-13,50},{-16,37},{-9,37},{-13,50}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Text(
                extent={{-68,26},{-22,8}},
                lineColor={160,160,164},
                textString=
                         "height"),
              Polygon(
                points={{-13,-69},{-16,-56},{-10,-56},{-13,-69},{-13,-69}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(
                points={{-13,-18},{-13,-70}},
                color={192,192,192},
                pattern=LinePattern.Solid,
                thickness=0.25,
                arrow={Arrow.None,Arrow.None}),
              Polygon(
                points={{-13,-18},{-16,-31},{-9,-31},{-13,-18}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Text(
                extent={{-72,100},{-31,80}},
                lineColor={160,160,164},
                textString=
                         "y")}),
          Documentation(info="<html>

</html>"));
          end Step;

          block Ramp "Generate ramp signal"
            parameter Real height=1 "Height of ramps";
            parameter Real duration(min=Modelica.Constants.small) = 2
          "Durations of ramp";
            parameter Real offset=0 "Offset of output signal";
            parameter Modelica.SIunits.Time startTime=0
          "Output = offset for time < startTime";
            extends CombinedCycle.Blocks.Interfaces.SO;
            parameter Real k_1=1e5;
            parameter Real k_2=1e5;
      protected
            Real activation_1;
            Real activation_2;
            constant Real pi = Modelica.Constants.pi;
          equation
            activation_1 = (atan(k_1*(time-startTime))+pi/2)/pi;
            activation_2 = (atan(k_2*(time-(startTime+duration)))+pi/2)/pi;
            y = offset + ( (activation_1*(time - startTime)*height/duration*(1-activation_2)) + height*activation_2);
            annotation (
              Window(
                x=0.19,
                y=0.02,
                width=0.59,
                height=0.77),
              Icon(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={1,1}), graphics={
              Line(points={{-80,68},{-80,-80}}, color={192,192,192}),
              Polygon(
                points={{-80,90},{-88,68},{-72,68},{-80,90}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-90,-70},{82,-70}}, color={192,192,192}),
              Polygon(
                points={{90,-70},{68,-62},{68,-78},{90,-70}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-80,-70},{-40,-70},{31,38}}, color={0,0,0}),
              Text(
                extent={{-150,-150},{150,-110}},
                lineColor={0,0,0},
                textString=
                         "duration=%duration"),
              Line(points={{31,38},{86,38}}, color={0,0,0})}),
              Diagram(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={1,1}), graphics={
              Polygon(
                points={{-80,90},{-88,68},{-72,68},{-80,90}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(points={{-80,68},{-80,-80}}, color={192,192,192}),
              Line(
                points={{-80,-20},{-20,-20},{50,50}},
                color={0,0,0},
                thickness=0.5),
              Line(points={{-90,-70},{82,-70}}, color={192,192,192}),
              Polygon(
                points={{90,-70},{68,-62},{68,-78},{90,-70}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{-40,-20},{-42,-30},{-37,-30},{-40,-20}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Line(
                points={{-40,-20},{-40,-70}},
                color={192,192,192},
                pattern=LinePattern.Solid,
                thickness=0.25,
                arrow={Arrow.None,Arrow.None}),
              Polygon(
                points={{-40,-70},{-43,-60},{-38,-60},{-40,-70},{-40,-70}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Text(
                extent={{-80,-33},{-41,-49}},
                lineColor={160,160,164},
                textString=
                         "offset"),
              Text(
                extent={{-40,-70},{6,-88}},
                lineColor={160,160,164},
                textString=
                         "startTime"),
              Text(
                extent={{-66,92},{-25,72}},
                lineColor={160,160,164},
                textString=
                         "y"),
              Text(
                extent={{70,-80},{94,-100}},
                lineColor={160,160,164},
                textString=
                         "time"),
              Line(
                points={{-20,-20},{-20,-70}},
                color={192,192,192},
                pattern=LinePattern.Dash),
              Line(
                points={{-19,-20},{50,-20}},
                color={192,192,192},
                pattern=LinePattern.Solid,
                thickness=0.25,
                arrow={Arrow.None,Arrow.None}),
              Line(
                points={{50,50},{101,50}},
                color={0,0,0},
                thickness=0.5),
              Line(
                points={{50,50},{50,-20}},
                color={192,192,192},
                pattern=LinePattern.Solid,
                thickness=0.25,
                arrow={Arrow.None,Arrow.None}),
              Polygon(
                points={{50,-20},{42,-18},{42,-22},{50,-20}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{-20,-20},{-11,-18},{-11,-22},{-20,-20}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{50,50},{48,40},{53,40},{50,50}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Polygon(
                points={{50,-20},{47,-10},{52,-10},{50,-20},{50,-20}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
              Text(
                extent={{53,25},{82,7}},
                lineColor={160,160,164},
                textString=
                         "height"),
              Text(
                extent={{0,-17},{35,-37}},
                lineColor={160,160,164},
                textString=
                         "duration")}),
          Documentation(info="<html>

</html>"));
          end Ramp;
    end Sources;

    package Math
          block Feedback
        "Output difference between commanded and feedback input"
            input Modelica.Blocks.Interfaces.RealInput u1
                                          annotation (Placement(transformation(
                extent={{-100,-20},{-60,20}}, rotation=0)));
            input Modelica.Blocks.Interfaces.RealInput u2
              annotation (Placement(transformation(
              origin={0,-80},
              extent={{-20,-20},{20,20}},
              rotation=90)));
            output Modelica.Blocks.Interfaces.RealOutput y
                                           annotation (Placement(transformation(
                extent={{80,-10},{100,10}}, rotation=0)));
          equation
            y = u1 - u2;
            annotation (
              Window(
                x=0.35,
                y=0.02,
                width=0.52,
                height=0.68),
              Documentation(info="
<HTML>
<p>
This blocks computes output <b>y</b> as <i>difference</i> of the
commanded input <b>u1</b> and the feedback
input <b>u2</b>:
</p>
<pre>
    <b>y</b> = <b>u1</b> - <b>u2</b>;
</pre>
<p>
Example:
</p>
<pre>
     parameter:   n = 2
  results in the following equations:
     y = u1 - u2
</pre>

</HTML>
"),           Icon(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={2,2}), graphics={
              Ellipse(
                extent={{-20,20},{20,-20}},
                lineColor={0,0,127},
                fillColor={235,235,235},
                fillPattern=FillPattern.Solid),
              Line(points={{-60,0},{-20,0}}, color={0,0,127}),
              Line(points={{20,0},{80,0}}, color={0,0,127}),
              Line(points={{0,-20},{0,-60}}, color={0,0,127}),
              Text(
                extent={{-14,0},{82,-94}},
                lineColor={0,0,0},
                textString=
                         "-"),
              Text(extent={{-100,110},{100,60}}, textString=
                                                         "%name")}),
              Diagram(coordinateSystem(
              preserveAspectRatio=false,
              extent={{-100,-100},{100,100}},
              grid={2,2}), graphics={
              Ellipse(
                extent={{-20,20},{20,-20}},
                lineColor={0,0,255},
                pattern=LinePattern.Solid,
                lineThickness=0.25,
                fillColor={235,235,235},
                fillPattern=FillPattern.Solid),
              Line(points={{-60,0},{-20,0}}),
              Line(points={{20,0},{80,0}}),
              Line(points={{0,-20},{0,-60}}),
              Text(
                extent={{-12,10},{84,-84}},
                lineColor={0,0,0},
                textString=
                         "-")}));
          end Feedback;
    end Math;
  end Blocks;

  package Circuits_Tests
    model CombinedCycle_ThermalStress
      Components.Gas.BraytonJoule_exhaustGases braytonJoule_exhaustGases(
        T_min=548,
        T_max=843,
        w_min=454,
        w_max=585)   annotation (Placement(transformation(extent={{-60,62},{-40,
                82}}, rotation=0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst_1(
        Tstart=600 + 273.15,
        Tmstart=600 + 273.15,
        V=10,
        Cm=100)
        annotation (Placement(transformation(extent={{-30,82},{-10,62}},
              rotation=0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst_2(
        V=10,
        Tstart=500 + 273.15,
        Tmstart=500 + 273.15,
        Cm=100)
        annotation (Placement(transformation(extent={{6,82},{26,62}}, rotation=
                0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst_3(
        V=10,
        Tstart=400 + 273.15,
        Tmstart=400 + 273.15,
        Cm=100)
        annotation (Placement(transformation(extent={{40,82},{60,62}}, rotation=
               0)));
      Components.Gas.SinkP environment
                                 annotation (Placement(transformation(extent={{
                76,62},{96,82}}, rotation=0)));
      Components.Water.Flow1DLiquidPConstWall Economizer(
        pstart=90e5,
        Tstart=400,
        Tmstart=400,
        wnom=70,
        V=30,
        Cm=200*Economizer.wnom/4186/50)
        annotation (Placement(transformation(extent={{58,-52},{38,-32}},
              rotation=0)));
      Components.Water.Drum Evaporator(
        V=15,
        pstart=60e5,
        alphastart=0.5,
        Cm=200*70/4186/5,
        Tstart=600,
        Tmstart=600)
        annotation (Placement(transformation(extent={{26,-50},{6,-30}},
              rotation=0)));
      Components.Water.TurbineThermalPort turbine(
        pstart=70e5,
        h_iso=20e5,
        Gamma=100,
        k=70/90e5)
        annotation (Placement(transformation(extent={{-70,-52},{-50,-32}},
              rotation=0)));
      Components.Thermal.ThermalConductor thermalConductor_3(G=350000)
        annotation (Placement(transformation(
            origin={50,42},
            extent={{-10,-10},{10,10}},
            rotation=90)));
      Components.Thermal.ThermalConductor thermalConductor_1(G=500000)
        annotation (Placement(transformation(
            origin={-20,42},
            extent={{-10,-10},{10,10}},
            rotation=90)));
      Blocks.Sources.Ramp load(
        offset=0.5,
        height=-0.3,
        startTime=1000,
        duration=2000)
                      annotation (Placement(transformation(extent={{-92,62},{
                -72,82}}, rotation=0)));
      Components.Water.Flow1DVapourPConstWall SuperHeater(
        pstart=90e5,
        Tstart=800,
        Tmstart=800,
        V=5,
        Cm=200*70/4186/5)
        annotation (Placement(transformation(extent={{-10,-52},{-30,-32}},
              rotation=0)));
      Components.Thermal.ThermalConductor thermalConductor_2(G=1300000)
        annotation (Placement(transformation(
            origin={16,42},
            extent={{-10,-10},{10,10}},
            rotation=90)));
      Components.Thermal.CylinderThermalStress_radial_noVector
        cylinderThermalStress(                                       rint=0.4,
          rext=0.6,
        Tstartint=800,
        Tstartext=800)
                    annotation (Placement(transformation(extent={{-70,-70},{-50,
                -50}}, rotation=0)));
      Blocks.Continuous.PI PI(
        y_start=70,
        k=-1000,
        T=0.01)
              annotation (Placement(transformation(extent={{-42,-6},{-24,10}},
              rotation=0)));
      Blocks.Math.Feedback feedback          annotation (Placement(
            transformation(extent={{-68,-8},{-48,12}}, rotation=0)));
      Blocks.Sources.Step alpha_SP(
        height=0,
        startTime=10,
        offset=0.5)   annotation (Placement(transformation(extent={{-94,-8},{
                -74,12}}, rotation=0)));
      Components.Water.SourceW_waterLiquid_Input WaterLiquidSource(wstart=70, Tnom=
            273.15 + 35)
        annotation (Placement(transformation(extent={{90,-52},{70,-32}},
              rotation=0)));
      Components.Thermal.FixedHeatFlow_DHT_N1 fixedHeatFlow_DHT_N1_1(Q_flow=0) annotation (Placement(
            transformation(
            origin={-60,-82},
            extent={{-10,-10},{10,10}},
            rotation=90)));
    equation
      connect(flow1DGasPConst_3.outlet, environment.flange)
                                                     annotation (Line(points={{
              60,72},{76,72}}, color={159,159,223}));
      connect(flow1DGasPConst_2.outlet, flow1DGasPConst_3.inlet)
                                                               annotation (Line(
            points={{26,72},{40,72}}, color={159,159,223}));
      connect(flow1DGasPConst_1.outlet, flow1DGasPConst_2.inlet)
                                                              annotation (Line(
            points={{-10,72},{6,72}}, color={159,159,223}));
      connect(braytonJoule_exhaustGases.flange, flow1DGasPConst_1.inlet)
        annotation (Line(points={{-40,72},{-30,72}}, color={159,159,223}));
      connect(thermalConductor_3.port_b, flow1DGasPConst_3.wall)
                                                              annotation (Line(
            points={{50,52},{50,67}}, color={191,0,0}));
      connect(thermalConductor_3.port_a, Economizer.wall)
                                                        annotation (Line(points=
             {{50,32},{50,-37},{48,-37}}, color={191,0,0}));
      connect(thermalConductor_1.port_b, flow1DGasPConst_1.wall)
                                                              annotation (Line(
            points={{-20,52},{-20,67}}, color={191,0,0}));
      connect(flow1DGasPConst_2.wall, thermalConductor_2.port_b)
                                                               annotation (Line(
            points={{16,67},{16,52}}, color={191,0,0}));
      connect(cylinderThermalStress.internalBoundary, turbine.dHT) annotation (Line(
            points={{-60,-57},{-60,-46.2}}, color={255,127,0}));
      connect(load.y, braytonJoule_exhaustGases.load) annotation (Line(points={
              {-71,72},{-60,72}}, color={0,0,127}));
      connect(Evaporator.inlet, Economizer.outlet) annotation (Line(points={{24,
              -45.8},{30.7,-45.8},{30.7,-42},{38,-42}},      color={159,159,223}));
      connect(Evaporator.outlet, SuperHeater.inlet) annotation (Line(points={{10,-34},
              {0.4,-34},{0.4,-42},{-10,-42}},              color={159,159,223}));
      connect(SuperHeater.wall, thermalConductor_1.port_a)
                                                          annotation (Line(
            points={{-20,-37},{-20,32}}, color={191,0,0}));
      connect(Evaporator.wall, thermalConductor_2.port_a)
                                                         annotation (Line(
            points={{16,-48.9},{16,32}},
                                       color={191,0,0}));
      connect(turbine.inlet, SuperHeater.outlet) annotation (Line(points={{-51,
              -42},{-30,-42}}, color={159,159,223}));
      connect(feedback.y, PI.u) annotation (Line(points={{-49,2},{-46.4,2},{
              -43.8,2}}, color={0,0,127}));
      connect(alpha_SP.y, feedback.u1) annotation (Line(points={{-73,2},{-71.25,
              2},{-71.25,2},{-69.5,2},{-69.5,2},{-66,2}}, color={0,0,127}));
      connect(Evaporator.voidFraction, feedback.u2) annotation (Line(points={{8.4,-46},
              {-6,-46},{-6,-20},{-58,-20},{-58,-6}},          color={0,0,127}));
      connect(PI.y, WaterLiquidSource.w) annotation (Line(points={{-23.1,2},{
              86.2,2},{86.2,-36}}, color={0,0,127}));
      connect(Economizer.inlet, WaterLiquidSource.flange) annotation (Line(
            points={{58,-42},{70,-42}}, color={159,159,223}));
      connect(fixedHeatFlow_DHT_N1_1.port, cylinderThermalStress.
        externalBoundary) annotation (Line(points={{-60,-72},{-60,-63}}, color=
              {255,127,0}));
      annotation (Diagram(graphics),
        experiment(StopTime=1000),
        experimentSetupOutput);
    end CombinedCycle_ThermalStress;

    model CombinedCycle_ThermalStress_startUp
      Components.Gas.BraytonJoule_exhaustGases braytonJoule_exhaustGases(
        T_min=548,
        T_max=843,
        w_min=454,
        w_max=585,
        wstart=460,
        Tstart=550)  annotation (Placement(transformation(extent={{-60,68},{-40,
                88}}, rotation=0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst_1(
        V=10,
        Cm=100,
        Tstart=625,
        Tmstart=625)
        annotation (Placement(transformation(extent={{-30,88},{-10,68}},
              rotation=0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst_2(
        V=10,
        Cm=100,
        Tstart=500,
        Tmstart=500)
        annotation (Placement(transformation(extent={{6,88},{26,68}}, rotation=
                0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst_3(
        V=10,
        Cm=100,
        Tstart=450,
        Tmstart=450)
        annotation (Placement(transformation(extent={{40,88},{60,68}}, rotation=
               0)));
      Components.Gas.SinkP environment
                                 annotation (Placement(transformation(extent={{
                76,68},{96,88}}, rotation=0)));
      Components.Water.Flow1DLiquidPConstWall Economizer(
        V=30,
        Cm=200*70/4186/50,
        pstart=3e6,
        Tstart=400,
        Tmstart=400,
        wnom=30)
        annotation (Placement(transformation(extent={{58,-48},{38,-28}},
              rotation=0)));
      Components.Water.Drum Evaporator(
        V=15,
        alphastart=0.5,
        Cm=200*70/4186/5,
        pstart=3e6,
        Tstart=450,
        Tmstart=450)
        annotation (Placement(transformation(extent={{26,-46},{6,-26}},
              rotation=0)));
      Components.Water.TurbineThermalPort turbine(
        h_iso=20e5,
        Gamma=100,
        k=70/90e5,
        pstart=3e6)
        annotation (Placement(transformation(extent={{-70,-46},{-50,-26}},
              rotation=0)));
      Components.Thermal.ThermalConductor thermalConductor_3(G=270000)
        annotation (Placement(transformation(
            origin={50,48},
            extent={{-10,-10},{10,10}},
            rotation=90)));
      Components.Thermal.ThermalConductor thermalConductor_1(G=500000)
        annotation (Placement(transformation(
            origin={-20,48},
            extent={{-10,-10},{10,10}},
            rotation=90)));
      Blocks.Sources.Ramp load(
        offset=0.11,
        height=0.88,
        startTime=1,
        duration=10000)
                      annotation (Placement(transformation(extent={{-92,68},{
                -72,88}}, rotation=0)));
      Components.Water.Flow1DVapourPConstWall SuperHeater(
        V=5,
        Cm=200*70/4186/5,
        pstart=3e6,
        Tstart=550,
        Tmstart=550)
        annotation (Placement(transformation(extent={{-10,-46},{-30,-26}},
              rotation=0)));
      Components.Thermal.ThermalConductor thermalConductor_2(G=1300000)
        annotation (Placement(transformation(
            origin={16,48},
            extent={{-10,-10},{10,10}},
            rotation=90)));
      Components.Thermal.CylinderThermalStress_radial_noVector
        cylinderThermalStress(
        Tstartint=550,
        Tstartext=550,
        rint=0.04,
        rext=0.3)   annotation (Placement(transformation(extent={{-70,-68},{-50,
                -48}}, rotation=0)));
      Blocks.Continuous.PI PI(
        k=-1000,
        T=0.01,
        y_start=30)
              annotation (Placement(transformation(extent={{-42,0},{-24,16}},
              rotation=0)));
      Blocks.Math.Feedback feedback          annotation (Placement(
            transformation(extent={{-68,-2},{-48,18}}, rotation=0)));
      Blocks.Sources.Step alpha_SP(
        height=0,
        offset=0.5,
        startTime=0)  annotation (Placement(transformation(extent={{-94,-2},{
                -74,18}}, rotation=0)));
      Components.Water.SourceW_waterLiquid_Input WaterLiquidSource(           Tnom=
            273.15 + 35,
        pstart=3e6,
        wstart=30)
        annotation (Placement(transformation(extent={{90,-48},{70,-28}},
              rotation=0)));
      Components.Thermal.FixedHeatFlow_DHT_N1 fixedHeatFlow_DHT_N1_1(Q_flow=0)
        annotation (Placement(transformation(
            origin={-60,-86},
            extent={{-10,-10},{10,10}},
            rotation=90)));
    initial equation
      der(cylinderThermalStress.T__2)=0;
      der(Economizer.wat_liq_out.T)=0;
      der(flow1DGasPConst_1.gas_out.T)=0;
      der(flow1DGasPConst_2.gas_out.T)=0;
      der(flow1DGasPConst_3.gas_out.T)=0;
      der(SuperHeater.wat_vap_out.T)=0;
    equation
      connect(flow1DGasPConst_3.outlet, environment.flange)
                                                     annotation (Line(points={{
              60,78},{76,78}}, color={159,159,223}));
      connect(flow1DGasPConst_2.outlet, flow1DGasPConst_3.inlet)
                                                               annotation (Line(
            points={{26,78},{40,78}}, color={159,159,223}));
      connect(flow1DGasPConst_1.outlet, flow1DGasPConst_2.inlet)
                                                              annotation (Line(
            points={{-10,78},{6,78}}, color={159,159,223}));
      connect(braytonJoule_exhaustGases.flange, flow1DGasPConst_1.inlet)
        annotation (Line(points={{-40,78},{-30,78}}, color={159,159,223}));
      connect(thermalConductor_3.port_b, flow1DGasPConst_3.wall)
                                                              annotation (Line(
            points={{50,58},{50,73}}, color={191,0,0}));
      connect(thermalConductor_3.port_a, Economizer.wall)
                                                        annotation (Line(points=
             {{50,38},{50,-33},{48,-33}}, color={191,0,0}));
      connect(thermalConductor_1.port_b, flow1DGasPConst_1.wall)
                                                              annotation (Line(
            points={{-20,58},{-20,73}}, color={191,0,0}));
      connect(flow1DGasPConst_2.wall, thermalConductor_2.port_b)
                                                               annotation (Line(
            points={{16,73},{16,58}}, color={191,0,0}));
      connect(cylinderThermalStress.internalBoundary, turbine.dHT) annotation (Line(
            points={{-60,-55},{-60,-40.2}}, color={255,127,0}));
      connect(load.y, braytonJoule_exhaustGases.load) annotation (Line(points={
              {-71,78},{-60,78}}, color={0,0,127}));
      connect(Evaporator.inlet, Economizer.outlet) annotation (Line(points={{24,
              -41.8},{30.7,-41.8},{30.7,-38},{38,-38}},      color={159,159,223}));
      connect(Evaporator.outlet, SuperHeater.inlet) annotation (Line(points={{10,-30},
              {0.4,-30},{0.4,-36},{-10,-36}},              color={159,159,223}));
      connect(SuperHeater.wall, thermalConductor_1.port_a)
                                                          annotation (Line(
            points={{-20,-31},{-20,38}}, color={191,0,0}));
      connect(Evaporator.wall, thermalConductor_2.port_a)
                                                         annotation (Line(
            points={{16,-44.9},{16,38}},
                                       color={191,0,0}));
      connect(turbine.inlet, SuperHeater.outlet) annotation (Line(points={{-51,
              -36},{-30,-36}}, color={159,159,223}));
      connect(feedback.y, PI.u) annotation (Line(points={{-49,8},{-43.8,8}},
            color={0,0,127}));
      connect(alpha_SP.y, feedback.u1) annotation (Line(points={{-73,8},{-66,8}},
            color={0,0,127}));
      connect(Evaporator.voidFraction, feedback.u2) annotation (Line(points={{8.4,-42},
              {-6,-42},{-6,-14},{-58,-14},{-58,0}},                     color={
              0,0,127}));
      connect(PI.y, WaterLiquidSource.w) annotation (Line(points={{-23.1,8},{
              86.2,8},{86.2,-32}}, color={0,0,127}));
      connect(Economizer.inlet, WaterLiquidSource.flange) annotation (Line(
            points={{58,-38},{70,-38}}, color={159,159,223}));
      connect(fixedHeatFlow_DHT_N1_1.port, cylinderThermalStress.
        externalBoundary) annotation (Line(points={{-60,-76},{-60,-61}}, color=
              {255,127,0}));
      annotation (Diagram(graphics),
        experiment(StopTime=1000),
        experimentSetupOutput);
    end CombinedCycle_ThermalStress_startUp;

    model CombinedCycle_sub1
      Components.Gas.BraytonJoule_exhaustGases braytonJoule_exhaustGases(
        T_min=600,
        T_max=800,
        w_min=300,
        w_max=500)
                annotation (Placement(transformation(extent={{-64,24},{-44,44}},
              rotation=0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst(V=5)
        annotation (Placement(transformation(extent={{-36,44},{-16,24}},
              rotation=0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst1(V=5)
        annotation (Placement(transformation(extent={{-2,44},{18,24}}, rotation=
               0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst2(V=5)
        annotation (Placement(transformation(extent={{34,44},{54,24}}, rotation=
               0)));
      Components.Gas.SinkP sinkP annotation (Placement(transformation(extent={{
                74,24},{94,44}}, rotation=0)));
      Modelica.Blocks.Sources.Constant ramp(k=0.5)
                      annotation (Placement(transformation(extent={{-96,24},{
                -76,44}}, rotation=0)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow(Q_flow=0)
        annotation (Placement(transformation(
            origin={-26,-2},
            extent={{-10,-10},{10,10}},
            rotation=90)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow1(Q_flow=0)
        annotation (Placement(transformation(
            origin={8,-4},
            extent={{-10,-10},{10,10}},
            rotation=90)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow2(Q_flow=0)
        annotation (Placement(transformation(
            origin={44,-4},
            extent={{-10,-10},{10,10}},
            rotation=90)));
    equation
      connect(flow1DGasPConst2.outlet, sinkP.flange) annotation (Line(points={{
              54,34},{74,34}}, color={159,159,223}));
      connect(flow1DGasPConst1.outlet, flow1DGasPConst2.inlet) annotation (Line(
            points={{18,34},{34,34}}, color={159,159,223}));
      connect(flow1DGasPConst.outlet, flow1DGasPConst1.inlet) annotation (Line(
            points={{-16,34},{-2,34}}, color={159,159,223}));
      connect(braytonJoule_exhaustGases.flange, flow1DGasPConst.inlet)
        annotation (Line(points={{-44,34},{-36,34}}, color={159,159,223}));
      connect(ramp.y, braytonJoule_exhaustGases.load) annotation (Line(points={
              {-75,34},{-64,34}}, color={0,0,127}));
      connect(fixedHeatFlow2.port, flow1DGasPConst2.wall) annotation (Line(
            points={{44,6},{44,29}}, color={191,0,0}));
      connect(flow1DGasPConst.wall, fixedHeatFlow.port) annotation (Line(points=
             {{-26,29},{-26,8},{-26,8}}, color={191,0,0}));
      connect(fixedHeatFlow1.port, flow1DGasPConst1.wall) annotation (Line(
            points={{8,6},{8,17.5},{8,17.5},{8,29}}, color={191,0,0}));
      annotation (Diagram(graphics));
    end CombinedCycle_sub1;

    model CombinedCycle_sub2
      Components.Water.Flow1DLiquidPConstWall Economizer(
        pstart=90e5,
        Tstart=400,
        Tmstart=400,
        wnom=70,
        V=30,
        Cm=200*Economizer.wnom/4186/50)
        annotation (Placement(transformation(extent={{50,-50},{30,-30}},
              rotation=0)));
      Components.Water.Flow1DVapourPConstWall SuperHeater(    pstart=90e5,
        Tstart=800,
        Tmstart=800,
        V=5,
        Cm=200*70/4186/5)
        annotation (Placement(transformation(extent={{-32,-50},{-52,-30}},
              rotation=0)));
      Components.Water.Turbine turbine(k=10, h_iso=2.3e5)
        annotation (Placement(transformation(extent={{-86,-50},{-66,-30}},
              rotation=0)));
      Components.Water.SourceW_waterLiquid_Input sourceW(Tnom=273.15 + 35, wstart=
            70)
        annotation (Placement(transformation(extent={{88,-50},{68,-30}},
              rotation=0)));
      Components.Water.Drum Evaporator(
        V=15,
        pstart=60e5,
        alphastart=0.5,
        Cm=200*70/4186/5,
        Tstart=600,
        Tmstart=600)
        annotation (Placement(transformation(extent={{6,-50},{-14,-30}},
              rotation=0)));
      Blocks.Continuous.PI PI(
        k=-1000,
        T=0.01,
        y_start=30)
              annotation (Placement(transformation(extent={{-44,30},{-26,46}},
              rotation=0)));
      Blocks.Math.Feedback feedback          annotation (Placement(
            transformation(extent={{-70,28},{-50,48}}, rotation=0)));
      Blocks.Sources.Step alpha_SP(
        height=0,
        offset=0.5,
        startTime=0)  annotation (Placement(transformation(extent={{-96,28},{
                -76,48}}, rotation=0)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow(Q_flow=3e7)
        annotation (Placement(transformation(
            origin={40,-14},
            extent={{-10,-10},{10,10}},
            rotation=270)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow1(Q_flow=9e7)
        annotation (Placement(transformation(
            origin={-4,-12},
            extent={{-10,-10},{10,10}},
            rotation=270)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow2(Q_flow=4e7)
        annotation (Placement(transformation(
            origin={-42,-10},
            extent={{-10,-10},{10,10}},
            rotation=270)));
    equation
      connect(turbine.inlet, SuperHeater.outlet) annotation (Line(points={{-67,
              -40},{-52,-40}}, color={159,159,223}));
      connect(Economizer.inlet, sourceW.flange) annotation (Line(points={{50,
              -40},{68,-40}}, color={159,159,223}));
      connect(SuperHeater.inlet, Evaporator.outlet) annotation (Line(points={{
              -32,-40},{-22,-40},{-22,-34.2},{-11.2,-34.2}}, color={159,159,223}));
      connect(Evaporator.inlet, Economizer.outlet) annotation (Line(points={{
              3.4,-45.4},{15.7,-45.4},{15.7,-40},{30,-40}}, color={159,159,223}));
      connect(Evaporator.voidFraction,feedback. u2) annotation (Line(points={{
              -11.6,-46},{-24,-46},{-24,-16},{-60,-16},{-60,30}}, color={0,0,
              127}));
      connect(PI.y, sourceW.w) annotation (Line(points={{-25.1,38},{84.2,38},{
              84.2,-34}}, color={0,0,127}));
      connect(fixedHeatFlow.port, Economizer.wall) annotation (Line(points={{40,
              -24},{40,-35}}, color={191,0,0}));
      connect(Evaporator.wall, fixedHeatFlow1.port) annotation (Line(points={{
              -4,-31},{-4,-28.75},{-4,-28.75},{-4,-26.5},{-4,-22},{-4,-22}},
            color={191,0,0}));
      connect(alpha_SP.y, feedback.u1) annotation (Line(points={{-75,38},{-68,
              38}}, color={0,0,127}));
      connect(feedback.y, PI.u) annotation (Line(points={{-51,38},{-45.8,38}},
            color={0,0,127}));
      connect(SuperHeater.wall, fixedHeatFlow2.port) annotation (Line(points={{
              -42,-35},{-42,-20}}, color={191,0,0}));
      annotation (Diagram(graphics));
    end CombinedCycle_sub2;

    model CombinedCycle_sub3
      Components.Water.Flow1DLiquidPConstWall Economizer(
        pstart=90e5,
        Tstart=400,
        Tmstart=400,
        wnom=70,
        V=30,
        Cm=200*Economizer.wnom/4186/50)
        annotation (Placement(transformation(extent={{50,-50},{30,-30}},
              rotation=0)));
      Components.Water.Flow1DVapourPConstWall SuperHeater(    pstart=90e5,
        Tstart=800,
        Tmstart=800,
        V=5,
        Cm=200*70/4186/5)
        annotation (Placement(transformation(extent={{-32,-50},{-52,-30}},
              rotation=0)));
      Components.Water.SourceW_waterLiquid_Input sourceW(Tnom=273.15 + 35, wstart=
            70)
        annotation (Placement(transformation(extent={{88,-50},{68,-30}},
              rotation=0)));
      Components.Water.Drum Evaporator(
        V=15,
        pstart=60e5,
        alphastart=0.5,
        Cm=200*70/4186/5,
        Tstart=600,
        Tmstart=600)
        annotation (Placement(transformation(extent={{6,-50},{-14,-30}},
              rotation=0)));
      Blocks.Continuous.PI PI(
        k=-1000,
        T=0.01,
        y_start=30)
              annotation (Placement(transformation(extent={{-44,30},{-26,46}},
              rotation=0)));
      Blocks.Math.Feedback feedback          annotation (Placement(
            transformation(extent={{-70,28},{-50,48}}, rotation=0)));
      Blocks.Sources.Step alpha_SP(
        height=0,
        offset=0.5,
        startTime=0)  annotation (Placement(transformation(extent={{-96,28},{
                -76,48}}, rotation=0)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow(Q_flow=3e7)
        annotation (Placement(transformation(
            origin={40,-14},
            extent={{-10,-10},{10,10}},
            rotation=270)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow1(Q_flow=9e7)
        annotation (Placement(transformation(
            origin={-4,-12},
            extent={{-10,-10},{10,10}},
            rotation=270)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow2(Q_flow=4e7)
        annotation (Placement(transformation(
            origin={-42,-10},
            extent={{-10,-10},{10,10}},
            rotation=270)));
      Components.Water.TurbineThermalPort turbine1(
        h_iso=20e5,
        Gamma=100,
        k=70/90e5,
        pstart=3e6)
        annotation (Placement(transformation(extent={{-86,-50},{-66,-30}},
              rotation=0)));
      Components.Thermal.CylinderThermalStress_radial_noVector
        cylinderThermalStress(
        Tstartint=550,
        Tstartext=550,
        rint=0.04,
        rext=0.3)   annotation (Placement(transformation(extent={{-86,-74},{-66,
                -54}}, rotation=0)));
      Components.Thermal.FixedHeatFlow_DHT_N1 fixedHeatFlow_DHT_N1_1(Q_flow=0)
        annotation (Placement(transformation(
            origin={-76,-88},
            extent={{-10,-10},{10,10}},
            rotation=90)));
    equation
      connect(Economizer.inlet, sourceW.flange) annotation (Line(points={{50,
              -40},{68,-40}}, color={159,159,223}));
      connect(SuperHeater.inlet, Evaporator.outlet) annotation (Line(points={{
              -32,-40},{-22,-40},{-22,-34.2},{-11.2,-34.2}}, color={159,159,223}));
      connect(Evaporator.inlet, Economizer.outlet) annotation (Line(points={{
              3.4,-45.4},{15.7,-45.4},{15.7,-40},{30,-40}}, color={159,159,223}));
      connect(Evaporator.voidFraction,feedback. u2) annotation (Line(points={{
              -11.6,-46},{-24,-46},{-24,-16},{-60,-16},{-60,30}}, color={0,0,
              127}));
      connect(PI.y, sourceW.w) annotation (Line(points={{-25.1,38},{84.2,38},{
              84.2,-34}}, color={0,0,127}));
      connect(fixedHeatFlow.port, Economizer.wall) annotation (Line(points={{40,
              -24},{40,-35}}, color={191,0,0}));
      connect(Evaporator.wall, fixedHeatFlow1.port) annotation (Line(points={{
              -4,-31},{-4,-28.75},{-4,-28.75},{-4,-26.5},{-4,-22},{-4,-22}},
            color={191,0,0}));
      connect(alpha_SP.y, feedback.u1) annotation (Line(points={{-75,38},{-68,
              38}}, color={0,0,127}));
      connect(feedback.y, PI.u) annotation (Line(points={{-51,38},{-45.8,38}},
            color={0,0,127}));
      connect(SuperHeater.wall, fixedHeatFlow2.port) annotation (Line(points={{
              -42,-35},{-42,-20}}, color={191,0,0}));
      connect(cylinderThermalStress.internalBoundary, turbine1.dHT)
                                                                   annotation (Line(
            points={{-76,-61},{-76,-44.2}}, color={255,127,0}));
      connect(turbine1.inlet, SuperHeater.outlet) annotation (Line(points={{-67,
              -40},{-52,-40}}, color={159,159,223}));
      connect(fixedHeatFlow_DHT_N1_1.port, cylinderThermalStress.
        externalBoundary) annotation (Line(points={{-76,-78},{-76,-67}}, color=
              {255,127,0}));
      annotation (Diagram(graphics));
    end CombinedCycle_sub3;

    model GasFlow1d_test
      Components.Gas.SourceP sourceP(pnom=120000)
        annotation (Placement(transformation(extent={{-80,16},{-60,36}},
              rotation=0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst(V=1)
        annotation (Placement(transformation(extent={{-34,36},{-14,16}},
              rotation=0)));
      Components.Gas.SinkP sinkP annotation (Placement(transformation(extent={{
                80,16},{100,36}}, rotation=0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst1(V=1)
        annotation (Placement(transformation(extent={{6,36},{26,16}}, rotation=
                0)));
      Components.Gas.Flow1DGasPConst flow1DGasPConst2(V=1)
        annotation (Placement(transformation(extent={{42,36},{62,16}}, rotation=
               0)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow(Q_flow=0)
        annotation (Placement(transformation(
            origin={-24,-10},
            extent={{-10,-10},{10,10}},
            rotation=90)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow1(Q_flow=0)
        annotation (Placement(transformation(
            origin={16,-10},
            extent={{-10,-10},{10,10}},
            rotation=90)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow2(Q_flow=0)
        annotation (Placement(transformation(
            origin={52,-10},
            extent={{-10,-10},{10,10}},
            rotation=90)));
    equation
      connect(sourceP.flange, flow1DGasPConst.inlet) annotation (Line(points={{
              -60,26},{-34,26}}, color={159,159,223}));
      connect(flow1DGasPConst.outlet, flow1DGasPConst1.inlet) annotation (Line(
            points={{-14,26},{6,26}}, color={159,159,223}));
      connect(flow1DGasPConst1.outlet, flow1DGasPConst2.inlet) annotation (Line(
            points={{26,26},{42,26}}, color={159,159,223}));
      connect(flow1DGasPConst2.outlet, sinkP.flange) annotation (Line(points={{
              62,26},{80,26}}, color={159,159,223}));
      connect(fixedHeatFlow.port, flow1DGasPConst.wall) annotation (Line(points=
             {{-24,5.55112e-16},{-24,21}}, color={191,0,0}));
      connect(fixedHeatFlow1.port, flow1DGasPConst1.wall) annotation (Line(
            points={{16,5.55112e-16},{16,21}}, color={191,0,0}));
      connect(fixedHeatFlow2.port, flow1DGasPConst2.wall) annotation (Line(
            points={{52,5.55112e-16},{52,21}}, color={191,0,0}));
      annotation (Diagram(graphics));
    end GasFlow1d_test;

    model WaterLiquidFlow1d_test
      Components.Gas.SinkP sinkP
        annotation (Placement(transformation(
            origin={-56,-10},
            extent={{-10,-10},{10,10}},
            rotation=180)));
      Components.Water.Flow1DLiquidPConstWall Economizer(V=1)
        annotation (Placement(transformation(extent={{6,-20},{-14,0}}, rotation=
               0)));
      Components.Water.SourceW_waterLiquid sourceW(
                                       wnom=1)
        annotation (Placement(transformation(extent={{56,-20},{36,0}}, rotation=
               0)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow(Q_flow=0)
        annotation (Placement(transformation(
            origin={-4,22},
            extent={{-10,-10},{10,10}},
            rotation=270)));
    equation
      connect(Economizer.inlet,sourceW. flange) annotation (Line(points={{6,-10},
              {36,-10}}, color={159,159,223}));
      connect(sinkP.flange, Economizer.outlet) annotation (Line(points={{-46,-10},
              {-30,-10},{-30,-10},{-14,-10}},      color={159,159,223}));
      connect(fixedHeatFlow.port, Economizer.wall) annotation (Line(points={{-4,12},
              {-4,7.75},{-4,7.75},{-4,3.5},{-4,-5},{-4,-5}},     color={191,0,0}));
      annotation (Diagram(graphics));
    end WaterLiquidFlow1d_test;

    model WaterDrum_test
      Components.Water.Drum Evaporator(
        pstart=70e5,
        Tstart=800,
        Tmstart=800,
        alphastart=0.3,
        V=30,
        Cm=2000*4186)
        annotation (Placement(transformation(extent={{18,-38},{-2,-18}},
              rotation=0)));
      Components.Water.SourceW_waterVapour_Input sourceW(
        wstart=70, Tnom=700)
        annotation (Placement(transformation(extent={{70,-40},{50,-20}},
              rotation=0)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow(           Q_flow=1.2e7)
        annotation (Placement(transformation(
            origin={8,2},
            extent={{-10,-10},{10,10}},
            rotation=270)));
      Components.Water.SinkP_waterVapour sinkP_waterVapour(
        pnom=80e5,
        Tnom=600,
        Res=1)
        annotation (Placement(transformation(
            origin={-46,-22},
            extent={{-10,-10},{10,10}},
            rotation=180)));
      Blocks.Continuous.PI PI(
        k=3,
        T=100)
        annotation (Placement(transformation(extent={{26,24},{44,40}}, rotation=
               0)));
      Modelica.Blocks.Math.Feedback feedback annotation (Placement(
            transformation(extent={{-22,22},{-2,42}}, rotation=0)));
      Modelica.Blocks.Sources.Constant step(k=0.3)
        annotation (Placement(transformation(extent={{-58,22},{-38,42}},
              rotation=0)));
    equation
      connect(Evaporator.inlet,sourceW. flange) annotation (Line(points={{16,
              -33.8},{32,-33.8},{32,-30},{50,-30}}, color={159,159,223}));
      connect(fixedHeatFlow.port, Evaporator.wall) annotation (Line(points={{8,-8},{
              8,-10.75},{8,-10.75},{8,-13.5},{8,-36.9},{8,-36.9}},    color={
              191,0,0}));
      connect(sinkP_waterVapour.flange, Evaporator.outlet) annotation (Line(
            points={{-36,-22},{-20,-22},{-20,-22},{2,-22}},       color={159,
              159,223}));
      connect(PI.y, sourceW.w) annotation (Line(points={{44.9,32},{66.2,32},{
              66.2,-24}}, color={0,0,127}));
      connect(feedback.y, PI.u)
        annotation (Line(points={{-3,32},{24.2,32}}, color={0,0,127}));
      connect(Evaporator.voidFraction, feedback.u2) annotation (Line(points={{0.4,-34},
              {-12,-34},{-12,24}},          color={0,0,127}));
      connect(step.y, feedback.u1)
        annotation (Line(points={{-37,32},{-20,32}}, color={0,0,127}));
      annotation (Diagram(graphics));
    end WaterDrum_test;

    model WaterVapourFlow1d_test
      Components.Gas.SinkP sinkP(pnom=80e5, Tnom=100)
        annotation (Placement(transformation(
            origin={-56,-10},
            extent={{-10,-10},{10,10}},
            rotation=180)));
      Components.Water.Flow1DVapourPConstWall SuperHeater(
        V=1,
        pstart=90e5,
        Tstart=1000,
        Tmstart=1000)
        annotation (Placement(transformation(extent={{6,-20},{-14,0}}, rotation=
               0)));
      Components.Water.SourceW_waterVapour sourceW(
                                       wnom=1,
        pnom=90e5,
        Tnom=800)
        annotation (Placement(transformation(extent={{56,-20},{36,0}}, rotation=
               0)));
      Components.Thermal.FixedHeatFlow fixedHeatFlow(Q_flow=0)
        annotation (Placement(transformation(
            origin={-4,20},
            extent={{-10,-10},{10,10}},
            rotation=270)));
    equation
      connect(SuperHeater.inlet, sourceW.flange)
                                                annotation (Line(points={{6,-10},
              {36,-10}}, color={159,159,223}));
      connect(sinkP.flange, SuperHeater.outlet)
                                               annotation (Line(points={{-46,-10},
              {-30,-10},{-30,-10},{-14,-10}},      color={159,159,223}));
      connect(fixedHeatFlow.port, SuperHeater.wall) annotation (Line(points={{-4,10},
              {-4,6.25},{-4,6.25},{-4,2.5},{-4,-5},{-4,-5}},        color={191,
              0,0}));
      annotation (Diagram(graphics));
    end WaterVapourFlow1d_test;

    model Turbine_test
      parameter Real fictitius_K = sourceW_waterVapour.wnom/sourceW_waterVapour.pnom;
      Components.Water.SourceW_waterVapour sourceW_waterVapour(
        pnom=90e5,
        Tnom=1000,
        wnom=60) annotation (Placement(transformation(extent={{-16,-38},{4,-18}},
              rotation=0)));
      Components.Water.TurbineThermalPort turbineThermalPort(
        h_iso=30e5,
        Gamma=1,
        pstart=90e5,
        k=fictitius_K)
                annotation (Placement(transformation(
            origin={40,-28},
            extent={{-10,-10},{10,10}},
            rotation=180)));
      Components.Thermal.FixedHeatFlow_DHT_N1 fixedHeatFlow_DHT_N1_1(Q_flow=0)
        annotation (Placement(transformation(
            origin={40,-4},
            extent={{-10,-10},{10,10}},
            rotation=270)));
    equation
      connect(fixedHeatFlow_DHT_N1_1.port, turbineThermalPort.dHT) annotation (Line(
            points={{40,-14},{40,-23.8}}, color={255,127,0}));
      connect(sourceW_waterVapour.flange, turbineThermalPort.inlet) annotation (Line(
            points={{4,-28},{31,-28}}, color={159,159,223}));
      annotation (Diagram(graphics));
    end Turbine_test;

    model Turbine_test_withThermalStress
      Components.Water.SourceW_waterVapour sourceW_waterVapour(
        pnom=90e5,
        Tnom=900,
        wnom=70) annotation (Placement(transformation(extent={{-60,-38},{-40,
                -18}}, rotation=0)));
      Components.Water.TurbineThermalPort turbineThermalPort(
        h_iso=30e5,
        Gamma=1,
        k=1e-6) annotation (Placement(transformation(
            origin={-8,-28},
            extent={{-10,-10},{10,10}},
            rotation=180)));
      Components.Thermal.CylinderThermalStress_radial_noVector
        cylinderThermalStress(                                       rint=0.4,
          rext=0.6,
        Tstartint=800,
        Tstartext=800)
                    annotation (Placement(transformation(
            origin={-8,-8},
            extent={{-10,-10},{10,10}},
            rotation=180)));
      Components.Thermal.FixedHeatFlow_DHT_N1 fixedHeatFlow_DHT_N1_1(Q_flow=0)
        annotation (Placement(transformation(
            origin={-8,14},
            extent={{-10,-10},{10,10}},
            rotation=270)));
    equation
      connect(sourceW_waterVapour.flange, turbineThermalPort.inlet) annotation (Line(
            points={{-40,-28},{-17,-28}}, color={159,159,223}));
      connect(turbineThermalPort.dHT, cylinderThermalStress.internalBoundary)
        annotation (Line(points={{-8,-23.8},{-8,-16.9},{-8,-11},{-8,-11}},
            color={255,127,0}));
      connect(fixedHeatFlow_DHT_N1_1.port, cylinderThermalStress.
        externalBoundary) annotation (Line(points={{-8,4},{-8,1.75},{-8,1.75},{
              -8,-0.5},{-8,-5},{-8,-5}}, color={255,127,0}));
      annotation (Diagram(graphics));
    end Turbine_test_withThermalStress;

    model braytonJoule_exhaustGases_test
      Components.Gas.BraytonJoule_exhaustGases braytonJoule_exhaustGases(
        T_min=548,
        T_max=843,
        w_min=454,
        w_max=585) annotation (Placement(transformation(extent={{-26,-4},{-6,16}},
              rotation=0)));
      Components.Gas.SinkP sinkP annotation (Placement(transformation(extent={{
                12,-4},{32,16}}, rotation=0)));
      Modelica.Blocks.Sources.Ramp ramp(
        duration=1,
        height=-1,
        offset=1)
        annotation (Placement(transformation(extent={{-70,-4},{-50,16}},
              rotation=0)));
    equation
      connect(braytonJoule_exhaustGases.flange, sinkP.flange) annotation (Line(
            points={{-6,6},{-1.5,6},{-1.5,6},{3,6},{3,6},{12,6}}, color={159,
              159,223}));
      connect(ramp.y, braytonJoule_exhaustGases.load) annotation (Line(points={
              {-49,6},{-43.25,6},{-43.25,6},{-37.5,6},{-37.5,6},{-26,6}}, color=
             {0,0,127}));
      annotation (Diagram(graphics));
    end braytonJoule_exhaustGases_test;

    model SourceW_water_vapour_test
      Components.Water.SourceW_waterVapour sourceW_waterVapour(
        pnom=90e5,
        Tnom=1000,
        wnom=60*10e4)
                 annotation (Placement(transformation(extent={{-60,-38},{-40,
                -18}}, rotation=0)));
      Components.Water.SinkP_waterVapour sinkP_waterVapour(
        pnom=90e5,
        Tnom=1000,
        Res=0) annotation (Placement(transformation(extent={{-14,-38},{6,-18}},
              rotation=0)));
    equation
      connect(sourceW_waterVapour.flange, sinkP_waterVapour.flange) annotation (Line(
            points={{-40,-28},{-14,-28}}, color={159,159,223}));
      annotation (Diagram(graphics));
    end SourceW_water_vapour_test;
  end Circuits_Tests;

  package Optimization
    package Simulators
      model CC0D_FindInitialStateFullLoad
        "Simulate to print out the full load steady state"
        CombinedCycle.Optimization.Plants.CC0D_FindInitialState plant
          annotation (Placement(transformation(extent={{0,0},{20,20}}, rotation=
                 0)));
        Blocks.Sources.Ramp load_S(
          offset=1,
          height=0,
          startTime=1,
          duration=10000)
                        annotation (Placement(transformation(extent={{-80,0},{
                  -60,20}}, rotation=0)));
        Blocks.Continuous.FirstOrder firstOrder
          annotation (Placement(transformation(extent={{-40,0},{-20,20}},
                rotation=0)));
      equation
        connect(load_S.y, firstOrder.u) annotation (Line(points={{-59,10},{-42,
                10}}, color={0,0,127}));
        connect(firstOrder.y, plant.load)                       annotation (Line(
              points={{-19,10},{-10,10},{0,10}},                         color=
                {0,0,127}));
        annotation (Diagram(graphics),
          experiment(StopTime=100000),
          experimentSetupOutput(equdistant=false));
      end CC0D_FindInitialStateFullLoad;

      model CC0D_FindInitialStateWarmStartUp
        "Simulate to print out the start up initial steady state"

        CombinedCycle.Optimization.Plants.CC0D_FindInitialState plant
          annotation (Placement(transformation(extent={{0,0},{20,20}}, rotation=
                 0)));
        Blocks.Sources.Ramp load_S(
          offset=1,
          startTime=1,
          duration=2000,
          height=-0.85)  annotation (Placement(transformation(extent={{-80,0},{
                  -60,20}}, rotation=0)));
        Blocks.Continuous.FirstOrder firstOrder
          annotation (Placement(transformation(extent={{-40,0},{-20,20}},
                rotation=0)));
      equation
        connect(load_S.y, firstOrder.u) annotation (Line(points={{-59,10},{-42,
                10}}, color={0,0,127}));
        connect(firstOrder.y, plant.load)                       annotation (Line(
              points={{-19,10},{0,10},{0,10}},                           color=
                {0,0,127}));
        annotation (Diagram(graphics),
          experiment(StopTime=100000),
          experimentSetupOutput(equdistant=false));
      end CC0D_FindInitialStateWarmStartUp;

      model CC0D_FullLoadSteadyState
        "Simulate to check that full load initial state is correct"
        CombinedCycle.Optimization.Plants.CC0D_FullLoad plant
          annotation (Placement(transformation(extent={{0,0},{20,20}}, rotation=
                 0)));
        Blocks.Sources.Ramp load_S(
          offset=1,
          height=0,
          startTime=1,
          duration=10000)
                        annotation (Placement(transformation(extent={{-80,0},{
                  -60,20}}, rotation=0)));
        Blocks.Continuous.FirstOrder firstOrder
          annotation (Placement(transformation(extent={{-40,0},{-20,20}},
                rotation=0)));
      equation
        connect(load_S.y, firstOrder.u) annotation (Line(points={{-59,10},{-42,
                10}}, color={0,0,127}));
        connect(firstOrder.y, plant.load)                       annotation (Line(
              points={{-19,10},{0,10},{0,10}},                           color=
                {0,0,127}));
        annotation (Diagram(graphics),
          experiment(StopTime=10000),
          experimentSetupOutput);
      end CC0D_FullLoadSteadyState;

      model CC0D_WarmStartUpSteadyState
        "Simulate to check that the warm start-up initial state is correct"

        Plants.CC0D_WarmStartUp plant
          annotation (Placement(transformation(extent={{0,0},{20,20}}, rotation=
                 0)));
        Blocks.Sources.Ramp load_S(
          offset=0.15,
          height=0,
          startTime=1,
          duration=10000)
                        annotation (Placement(transformation(extent={{-80,0},{
                  -60,20}}, rotation=0)));
        Blocks.Continuous.FirstOrder firstOrder(y_start=0.15)
          annotation (Placement(transformation(extent={{-40,0},{-20,20}},
                rotation=0)));
      equation
        connect(load_S.y, firstOrder.u) annotation (Line(points={{-59,10},{-42,
                10}}, color={0,0,127}));
        connect(firstOrder.y, plant.load)                       annotation (Line(
              points={{-19,10},{0,10}},                                  color=
                {0,0,127}));
        annotation (Diagram(graphics),
          experiment(StopTime=10000),
          experimentSetupOutput);
      end CC0D_WarmStartUpSteadyState;

      model CC0D_WarmStartUpTransient
        "Simulates the entire warm start-up transient"
      //Real u = plant.load;
      //Real cost(start=0,fixed=true);
        Plants.CC0D_WarmStartUp plant
          annotation (Placement(transformation(extent={{0,0},{20,20}}, rotation=
                 0)));
        Blocks.Continuous.FirstOrder firstOrder
          annotation (Placement(transformation(extent={{-40,0},{-20,20}},
                rotation=0)));
        Modelica.Blocks.Sources.TimeTable timeTable(table=[0,0.15; 6000,1;
              10000,1])
          annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
      equation
      // der(cost) = 1*((plant.p-7.57e6)/1e6)^2 + (plant.load-1)^2;
        connect(firstOrder.y, plant.load)                       annotation (Line(
              points={{-19,10},{0,10}},                                  color=
                {0,0,127}));
        connect(timeTable.y, firstOrder.u) annotation (Line(
            points={{-59,10},{-42,10}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          experiment(StopTime=10000, Tolerance=1e-006),
          experimentSetupOutput);
      end CC0D_WarmStartUpTransient;

      model CC1D_FindInitialStateFullLoad
        "Simulate to print out the full load steady state"
        CombinedCycle.Optimization.Plants.CC1D_FindInitialState plant
          annotation (Placement(transformation(extent={{0,0},{20,20}}, rotation=
                 0)));
        Blocks.Sources.Ramp load_S(
          offset=1,
          height=0,
          startTime=1,
          duration=10000)
                        annotation (Placement(transformation(extent={{-80,0},{
                  -60,20}}, rotation=0)));
        Blocks.Continuous.FirstOrder firstOrder
          annotation (Placement(transformation(extent={{-40,0},{-20,20}},
                rotation=0)));
      equation
        connect(load_S.y, firstOrder.u) annotation (Line(points={{-59,10},{-42,
                10}}, color={0,0,127}));
        connect(firstOrder.y, plant.load)                       annotation (Line(
              points={{-19,10},{-10,10},{0,10}},                         color=
                {0,0,127}));
        annotation (Diagram(graphics),
          experiment(StopTime=100000),
          experimentSetupOutput(equdistant=false));
      end CC1D_FindInitialStateFullLoad;

      model CC1D_FindInitialStateWarmStartUp
        "Simulate to print out the start up initial steady state"
        CombinedCycle.Optimization.Plants.CC1D_FindInitialState plant
          annotation (Placement(transformation(extent={{0,0},{20,20}}, rotation=
                 0)));
        Blocks.Sources.Ramp load_S(
          offset=1,
          startTime=1,
          duration=1000,
          height=-0.85) annotation (Placement(transformation(extent={{-80,0},{
                  -60,20}}, rotation=0)));
        Blocks.Continuous.FirstOrder firstOrder
          annotation (Placement(transformation(extent={{-40,0},{-20,20}},
                rotation=0)));
      equation
        connect(load_S.y, firstOrder.u) annotation (Line(points={{-59,10},{-42,
                10}}, color={0,0,127}));
        connect(firstOrder.y, plant.load)                       annotation (Line(
              points={{-19,10},{0,10},{0,10}},                           color=
                {0,0,127}));
        annotation (Diagram(graphics),
          experiment(StopTime=100000),
          experimentSetupOutput(equdistant=false));
      end CC1D_FindInitialStateWarmStartUp;

      model CC1D_FullLoadSteadyState
        "Simulate to check that full load initial state is correct"
        CombinedCycle.Optimization.Plants.CC1D_FullLoad plant
          annotation (Placement(transformation(extent={{0,0},{20,20}}, rotation=
                 0)));
        Blocks.Sources.Ramp load_S(
          height=0,
          startTime=1,
          duration=10000,
          offset=1)     annotation (Placement(transformation(extent={{-80,0},{
                  -60,20}}, rotation=0)));
        Blocks.Continuous.FirstOrder firstOrder
          annotation (Placement(transformation(extent={{-40,0},{-20,20}},
                rotation=0)));
      equation
        connect(load_S.y, firstOrder.u) annotation (Line(points={{-59,10},{-42,
                10}}, color={0,0,127}));
        connect(firstOrder.y, plant.load)                       annotation (Line(
              points={{-19,10},{0,10},{0,10}},                           color=
                {0,0,127}));
        annotation (Diagram(graphics),
          experiment(StopTime=10000),
          experimentSetupOutput);
      end CC1D_FullLoadSteadyState;

      model CC1D_WarmStartUpSteadyState
        "Simulate to check that the warm start-up initial state is correct"
        CombinedCycle.Optimization.Plants.CC1D_WarmStartUp plant
          annotation (Placement(transformation(extent={{0,0},{20,20}}, rotation=
                 0)));
        Blocks.Sources.Ramp load_S(
          height=0,
          startTime=1,
          duration=10000,
          offset=0.15)  annotation (Placement(transformation(extent={{-80,0},{
                  -60,20}}, rotation=0)));
        Blocks.Continuous.FirstOrder firstOrder
          annotation (Placement(transformation(extent={{-40,0},{-20,20}},
                rotation=0)));
      equation
        connect(load_S.y, firstOrder.u) annotation (Line(points={{-59,10},{-42,
                10}}, color={0,0,127}));
        connect(firstOrder.y, plant.load)                       annotation (Line(
              points={{-19,10},{0,10}},                                  color=
                {0,0,127}));
        annotation (Diagram(graphics),
          experiment(StopTime=10000),
          experimentSetupOutput);
      end CC1D_WarmStartUpSteadyState;

      model CC1D_WarmStartUpTransient
        "Simulates the entire warm start-up transient"
      //Real u = plant.load;
      //Real cost(start=0,fixed=true);
        Plants.CC1D_WarmStartUp plant
          annotation (Placement(transformation(extent={{0,0},{20,20}}, rotation=
                 0)));
        Blocks.Continuous.FirstOrder firstOrder
          annotation (Placement(transformation(extent={{-40,0},{-20,20}},
                rotation=0)));
        Modelica.Blocks.Sources.TimeTable timeTable(table=[0,0.15; 6000,1;
              10000,1])
          annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
      equation
      // der(cost) = 1*((plant.p-7.57e6)/1e6)^2 + (plant.load-1)^2;
        connect(firstOrder.y, plant.load)                       annotation (Line(
              points={{-19,10},{0,10}},                                  color=
                {0,0,127}));
        connect(timeTable.y, firstOrder.u) annotation (Line(
            points={{-59,10},{-42,10}},
            color={0,0,127},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          experiment(StopTime=10000, Tolerance=1e-006),
          experimentSetupOutput);
      end CC1D_WarmStartUpTransient;
    end Simulators;

    package Plants
      model CC0D "Simple 0D model of CC plant with turbine stress"

        Components.Gas.BraytonJoule_exhaustGases gasTurbine(
          w_min=454,
          wstart=460,
          T_min=548,
          T_max=843,
          w_max=580,
          load_min_w=0.5,
          Tstart=550)  annotation (Placement(transformation(extent={{-60,-50},{
                  -40,-30}},rotation=0)));
        Components.Gas.Flow1DGasPConst superheater_gas_side(
          Tstart=625,
          Tmstart=625,
          V=4000)
          annotation (Placement(transformation(extent={{-30,-50},{-10,-30}},
                rotation=0)));
        Components.Gas.Flow1DGasPConst evaporator_gas_side(
          Tstart=500,
          Tmstart=500,
          V=4000)
          annotation (Placement(transformation(extent={{6,-50},{26,-30}},
                rotation=0)));
        Components.Gas.Flow1DGasPConst economizer_gas_side(
          Tstart=450,
          Tmstart=450,
          V=4000)
          annotation (Placement(transformation(extent={{40,-50},{60,-30}},
                rotation=0)));
        Components.Gas.SinkP environment
                                   annotation (Placement(transformation(extent={{76,-50},
                  {96,-30}},         rotation=0)));
        Components.Water.Flow1DLiquidPConstWall economizer(
          V=30,
          Cm=200*70/4186/50,
          wnom=30,
          pstart=3000000,
          Tstart=400,
          Tmstart=400)
          annotation (Placement(transformation(extent={{58,28},{38,8}},
                rotation=0)));
        Components.Water.Drum evaporator(
          V=15,
          alphastart=0.5,
          Cm=200*70/4186/5,
          pstart=3000000,
          Tstart=450,
          Tmstart=450)
          annotation (Placement(transformation(extent={{28,12},{4,36}},
                rotation=0)));
        Components.Water.TurbineThermalPort turbine(
          h_iso=20e5,
          Gamma=2000,
          k=67.5/90e5,
          pstart=8000000)
          annotation (Placement(transformation(extent={{-70,20},{-50,40}},
                rotation=0)));
        Components.Thermal.ThermalConductor economizer_ht(G=300000)
          annotation (Placement(transformation(
              origin={50,-14},
              extent={{10,-10},{-10,10}},
              rotation=90)));
        Components.Thermal.ThermalConductor superheater_ht(G=500000)
          annotation (Placement(transformation(
              origin={-20,-14},
              extent={{10,-10},{-10,10}},
              rotation=90)));
        Components.Water.Flow1DVapourPConstWall superheater(
          V=5,
          Cm=200*70/4186/5,
          pstart=3000000,
          Tstart=550,
          Tmstart=550)
          annotation (Placement(transformation(extent={{-10,40},{-30,20}},
                rotation=0)));
        Components.Thermal.ThermalConductor evaporator_ht(G=920000)
          annotation (Placement(transformation(
              origin={16,-14},
              extent={{10,-10},{-10,10}},
              rotation=90)));
        Components.Thermal.CylinderThermalStress_radial_noVector turbineShaft(
          rint(displayUnit="mm") = 0.04,
          rext(displayUnit="mm") = 0.327,
          rho=7750,
          c=577,
          lambda=43,
          linearExpansionCoefficient=1.2e-5,
          Tstartint=550,
          Tstartext=550,
          youngModulus(displayUnit="Pa") = 1.96e11,
          poissonRatio=0.3)
                      annotation (Placement(transformation(extent={{-70,24},{-50,4}},
                             rotation=0)));
        Blocks.Continuous.PI PI(
          k=-1000,
          T=0.01,
          y_start=30)
                annotation (Placement(transformation(extent={{-42,60},{-24,76}},
                rotation=0)));
        Blocks.Math.Feedback feedback          annotation (Placement(
              transformation(extent={{-68,58},{-48,78}}, rotation=0)));
        Blocks.Sources.Constant alpha_SP(k=0.5)
                        annotation (Placement(transformation(extent={{-94,58},{
                  -74,78}}, rotation=0)));
        Components.Water.SourceW_waterLiquid_Input WaterLiquidSource(
          Tnom=273.15 + 117,
          wstart=70,
          pstart=3000000)
          annotation (Placement(transformation(extent={{90,8},{70,28}},
                rotation=0)));
        CombinedCycle.Blocks.Interfaces.RealInput load
          annotation (Placement(transformation(extent={{-110,-60},{-70,-20}},
                rotation=0), iconTransformation(extent={{-120,-20},{-80,20}})));
        Components.Thermal.FixedHeatFlow_DHT_N1 fixedHeatFlow_DHT_N1_1(Q_flow=0)
          annotation (Placement(transformation(extent={{-88,-12},{-68,8}})));
        Modelica.Blocks.Interfaces.RealOutput sigma(nominal = 1e8)
          "External surface stress on rotor"
          annotation (Placement(transformation(extent={{96,50},{116,70}})));
        Modelica.Blocks.Interfaces.RealOutput p(nominal = 50e5)
          "External surface stress on rotor"
          annotation (Placement(transformation(extent={{96,-70},{116,-50}})));
      equation
        // the minus sign is used to obtain a positive value
        // the factor 2 is the geometric factor for thermal
        // stresses as in Casella, Pretolani 2006.
        sigma = -2*turbineShaft.extThermalStress;
        p = evaporator.p;
        connect(economizer_gas_side.outlet, environment.flange)
                                                       annotation (Line(points={{60,-40},
                {76,-40}},         color={159,159,223}));
        connect(evaporator_gas_side.outlet, economizer_gas_side.inlet)
                                                                 annotation (Line(
              points={{26,-40},{40,-40}},
                                        color={159,159,223}));
        connect(superheater_gas_side.outlet, evaporator_gas_side.inlet)
                                                                annotation (Line(
              points={{-10,-40},{6,-40}},
                                        color={159,159,223}));
        connect(gasTurbine.flange, superheater_gas_side.inlet)
          annotation (Line(points={{-40,-40},{-30,-40}},
                                                       color={159,159,223}));
        connect(economizer_ht.port_b, economizer_gas_side.wall) annotation (Line(
              points={{50,-24},{50,-35}},
                                        color={191,0,0}));
        connect(economizer_ht.port_a, economizer.wall)    annotation (Line(
              points={{50,-4},{50,13},{48,13}},   color={191,0,0}));
        connect(superheater_ht.port_b, superheater_gas_side.wall)
                                                                annotation (Line(
              points={{-20,-24},{-20,-35}},
                                          color={191,0,0}));
        connect(evaporator_gas_side.wall, evaporator_ht.port_b)  annotation (Line(
              points={{16,-35},{16,-24}},
                                        color={191,0,0}));
        connect(evaporator.inlet,economizer. outlet) annotation (Line(points={{25.6,
                17.04},{30.7,17.04},{30.7,18},{38,18}},        color={159,159,
                223}));
        connect(evaporator.outlet, superheater.inlet) annotation (Line(points={{8.8,
                31.2},{0.4,31.2},{0.4,30},{-10,30}},          color={159,159,
                223}));
        connect(superheater.wall, superheater_ht.port_a)    annotation (Line(
              points={{-20,25},{-20,-4}},  color={191,0,0}));
        connect(evaporator.wall, evaporator_ht.port_a)     annotation (Line(
              points={{16,13.32},{16,-4}},
                                         color={191,0,0}));
        connect(turbine.inlet, superheater.outlet) annotation (Line(points={{-51,30},
                {-30,30}},           color={159,159,223}));
        connect(feedback.y, PI.u) annotation (Line(points={{-49,68},{-46.4,68},
                {-43.8,68}},         color={0,0,127}));
        connect(alpha_SP.y, feedback.u1) annotation (Line(points={{-73,68},{-66,
                68}},                                              color={0,0,
                127}));
        connect(evaporator.voidFraction, feedback.u2) annotation (Line(points={{6.88,
                16.8},{-6,16.8},{-6,46},{-58,46},{-58,60}},      color={0,0,127}));
        connect(PI.y, WaterLiquidSource.w) annotation (Line(points={{-23.1,68},
                {86.2,68},{86.2,24}},color={0,0,127}));
        connect(economizer.inlet, WaterLiquidSource.flange) annotation (Line(
              points={{58,18},{58,18},{70,18}},
                                          color={159,159,223}));
        connect(gasTurbine.load, load)                annotation (Line(points={{-60,-40},
                {-90,-40}},          color={0,0,127}));
        connect(turbine.dHT, turbineShaft.externalBoundary) annotation (Line(
            points={{-60,25.8},{-60,17}},
            color={255,127,0},
            smooth=Smooth.None));
        connect(turbineShaft.internalBoundary, fixedHeatFlow_DHT_N1_1.port)
          annotation (Line(
            points={{-60,11},{-60,-2},{-68,-2}},
            color={255,127,0},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          experiment(StopTime=1000),
          experimentSetupOutput,
          Icon(graphics={Rectangle(extent={{-100,100},{100,-100}},
                                                                 lineColor={0,0,
                    255}), Text(
                extent={{-136,78},{138,-74}},
                lineColor={0,0,255},
                textString=
                     "P")}));
      end CC0D;

      model CC0D_FindInitialState
        extends CC0D;
        import Modelica.Utilities.Streams.*;
      initial equation
              economizer.wat_liq_out.T = 459;
              economizer_gas_side.gas_out.T= 490;
              evaporator.p= 7.5e6;
              evaporator_gas_side.gas_out.T=454;
              superheater.wat_vap_out.T = 797;
              superheater_gas_side.gas_out.T = 746;
              turbineShaft.T__2 = 791;
      /*  
  economizer.wat_liq_out.T = 400;
  economizer_gas_side.gas_out.T= 400;
  evaporator.p= 60e5;
  evaporator_gas_side.gas_out.T=600;
  superheater.wat_vap_out.T = 800;
  superheater_gas_side.gas_out.T = 850;
  turbineShaft.T__2 = 450;
  */
        der(PI.x) = 0;
        der(evaporator.alpha)=0;
      equation
              when terminal() then
                print("");
                print("initial equation");
                print("  economizer.wat_liq_out.T = "+String(economizer.wat_liq_out.T)+";");
                print("  economizer_gas_side.gas_out.T = "+String(economizer_gas_side.gas_out.T)+";");
                print("  evaporator.alpha = "+String(evaporator.alpha)+";");
                print("  evaporator.p = "+String(evaporator.p)+";");
                print("  evaporator_gas_side.gas_out.T = "+String(evaporator_gas_side.gas_out.T)+";");
                print("  PI.x = "+String(PI.x)+";");
                print("  superheater.wat_vap_out.T = "+String(superheater.wat_vap_out.T)+";");
                print("  superheater_gas_side.gas_out.T = "+String(superheater_gas_side.gas_out.T)+";");
                print("  turbineShaft.T__2 ="+String(turbineShaft.T__2)+";");
                print("");
              end when;
        annotation (Diagram(graphics),
          experiment(StopTime=1000),
          experimentSetupOutput,
          Icon(graphics={Rectangle(extent={{-100,100},{100,-100}},
                                                                 lineColor={0,0,
                    255}), Text(
                extent={{-136,78},{138,-74}},
                lineColor={0,0,255},
                textString=
                     "P")}));
      end CC0D_FindInitialState;

      model CC0D_FullLoad "Includes initial equations with given states"
        extends CombinedCycle.Optimization.Plants.CC0D;
        import Modelica.Utilities.Streams.*;
      initial equation
        economizer.wat_liq_out.T = 521.48;
        economizer_gas_side.gas_out.T = 536.548;
        evaporator.alpha = 0.5;
        evaporator.p = 8.29575e+006;
        evaporator_gas_side.gas_out.T = 592.978;
        PI.x = -0.0622182;
        superheater.wat_vap_out.T = 860.732;
        superheater_gas_side.gas_out.T = 766.947;
        turbineShaft.T__2 =860.731;
        annotation (Diagram(graphics),
          experiment(StopTime=1000),
          experimentSetupOutput,
          Icon(graphics={Rectangle(extent={{-100,100},{100,-100}},
                                                                 lineColor={0,0,
                    255}), Text(
                extent={{-136,78},{138,-74}},
                lineColor={0,0,255},
                textString=
                     "P")}));
      end CC0D_FullLoad;

      model CC0D_WarmStartUp "Includes initial equations with given states"
        extends CombinedCycle.Optimization.Plants.CC0D;
        import Modelica.Utilities.Streams.*;
      initial equation
        economizer.wat_liq_out.T = 519.032;
        economizer_gas_side.gas_out.T = 484.54;
        evaporator.alpha = 0.5;
        evaporator.p = 3.47342e+006;
        evaporator_gas_side.gas_out.T = 514.173;
        PI.x = -0.0260506;
        superheater.wat_vap_out.T = 688.909;
        superheater_gas_side.gas_out.T = 614.001;
        turbineShaft.T__2 =688.909;
          annotation (Diagram(graphics),
          experiment(StopTime=1000),
          experimentSetupOutput,
          Icon(graphics={Rectangle(extent={{-100,100},{100,-100}},
                                                                 lineColor={0,0,
                    255}), Text(
                extent={{-136,78},{138,-74}},
                lineColor={0,0,255},
                textString=
                     "P")}));
      end CC0D_WarmStartUp;

      model CC1D "Simple 0D model of CC plant with 1D turbine stress model"

        Components.Gas.BraytonJoule_exhaustGases gasTurbine(
          w_min=454,
          wstart=460,
          T_min=548,
          T_max=843,
          w_max=580,
          load_min_w=0.5,
          Tstart=550)  annotation (Placement(transformation(extent={{-60,-50},{
                  -40,-30}},rotation=0)));
        Components.Gas.Flow1DGasPConst superheater_gas_side(
          Tstart=625,
          Tmstart=625,
          V=4000)
          annotation (Placement(transformation(extent={{-30,-50},{-10,-30}},
                rotation=0)));
        Components.Gas.Flow1DGasPConst evaporator_gas_side(
          Tstart=500,
          Tmstart=500,
          V=4000)
          annotation (Placement(transformation(extent={{6,-50},{26,-30}},
                rotation=0)));
        Components.Gas.Flow1DGasPConst economizer_gas_side(
          Tstart=450,
          Tmstart=450,
          V=4000)
          annotation (Placement(transformation(extent={{40,-50},{60,-30}},
                rotation=0)));
        Components.Gas.SinkP environment
                                   annotation (Placement(transformation(extent={{76,-50},
                  {96,-30}},         rotation=0)));
        Components.Water.Flow1DLiquidPConstWall economizer(
          V=30,
          Cm=200*70/4186/50,
          wnom=30,
          pstart=3000000,
          Tstart=400,
          Tmstart=400)
          annotation (Placement(transformation(extent={{58,28},{38,8}},
                rotation=0)));
        Components.Water.Drum evaporator(
          V=15,
          alphastart=0.5,
          Cm=200*70/4186/5,
          pstart=3000000,
          Tstart=450,
          Tmstart=450)
          annotation (Placement(transformation(extent={{28,12},{4,36}},
                rotation=0)));
        Components.Water.TurbineThermalPort turbine(
          h_iso=20e5,
          Gamma=2000,
          k=67.5/90e5,
          pstart=8000000)
          annotation (Placement(transformation(extent={{-70,20},{-50,40}},
                rotation=0)));
        Components.Thermal.ThermalConductor economizer_ht(G=300000)
          annotation (Placement(transformation(
              origin={50,-14},
              extent={{10,-10},{-10,10}},
              rotation=90)));
        Components.Thermal.ThermalConductor superheater_ht(G=500000)
          annotation (Placement(transformation(
              origin={-20,-14},
              extent={{10,-10},{-10,10}},
              rotation=90)));
        Components.Water.Flow1DVapourPConstWall superheater(
          V=5,
          Cm=200*70/4186/5,
          pstart=3000000,
          Tstart=550,
          Tmstart=550)
          annotation (Placement(transformation(extent={{-10,40},{-30,20}},
                rotation=0)));
        Components.Thermal.ThermalConductor evaporator_ht(G=920000)
          annotation (Placement(transformation(
              origin={16,-14},
              extent={{10,-10},{-10,10}},
              rotation=90)));
        Components.Thermal.CylinderThermalStressConstant turbineShaft(
          rint(displayUnit="mm") = 0.04,
          rext(displayUnit="mm") = 0.327,
          rho=7750,
          c=577,
          lambda=43,
          linearExpansionCoefficient=1.2e-5,
          youngModulus(displayUnit="Pa") = 1.96e11,
          poissonRatio=0.3,
          Nr=8,
          Tstartint=550,
          Tstartext=550)
                      annotation (Placement(transformation(extent={{-70,24},{-50,4}},
                             rotation=0)));
        Blocks.Continuous.PI PI(
          k=-1000,
          T=0.01,
          y_start=30)
                annotation (Placement(transformation(extent={{-42,60},{-24,76}},
                rotation=0)));
        Blocks.Math.Feedback feedback          annotation (Placement(
              transformation(extent={{-68,58},{-48,78}}, rotation=0)));
        Blocks.Sources.Constant alpha_SP(k=0.5)
                        annotation (Placement(transformation(extent={{-94,58},{
                  -74,78}}, rotation=0)));
        Components.Water.SourceW_waterLiquid_Input WaterLiquidSource(
          Tnom=273.15 + 117,
          wstart=70,
          pstart=3000000)
          annotation (Placement(transformation(extent={{90,8},{70,28}},
                rotation=0)));
        CombinedCycle.Blocks.Interfaces.RealInput load
          annotation (Placement(transformation(extent={{-110,-60},{-70,-20}},
                rotation=0), iconTransformation(extent={{-120,-20},{-80,20}})));
        Components.Thermal.FixedHeatFlow_DHT_N1 fixedHeatFlow_DHT_N1_1(Q_flow=0)
          annotation (Placement(transformation(extent={{-88,-12},{-68,8}})));
        Modelica.Blocks.Interfaces.RealOutput sigma(nominal = 1e8)
          "External surface stress on rotor"
          annotation (Placement(transformation(extent={{96,50},{116,70}})));
        Modelica.Blocks.Interfaces.RealOutput p(nominal = 50e5)
          "External surface stress on rotor"
          annotation (Placement(transformation(extent={{96,-70},{116,-50}})));
      equation
        // the minus sign is used to obtain a positive value
        // the factor 2 is the geometric factor for thermal
        // stresses as in Casella, Pretolani 2006.
        sigma = -2*turbineShaft.extThermalStress;
        p = evaporator.p;
        connect(economizer_gas_side.outlet, environment.flange)
                                                       annotation (Line(points={{60,-40},
                {76,-40}},         color={159,159,223}));
        connect(evaporator_gas_side.outlet, economizer_gas_side.inlet)
                                                                 annotation (Line(
              points={{26,-40},{40,-40}},
                                        color={159,159,223}));
        connect(superheater_gas_side.outlet, evaporator_gas_side.inlet)
                                                                annotation (Line(
              points={{-10,-40},{6,-40}},
                                        color={159,159,223}));
        connect(gasTurbine.flange, superheater_gas_side.inlet)
          annotation (Line(points={{-40,-40},{-30,-40}},
                                                       color={159,159,223}));
        connect(economizer_ht.port_b, economizer_gas_side.wall) annotation (Line(
              points={{50,-24},{50,-35}},
                                        color={191,0,0}));
        connect(economizer_ht.port_a, economizer.wall)    annotation (Line(
              points={{50,-4},{50,13},{48,13}},   color={191,0,0}));
        connect(superheater_ht.port_b, superheater_gas_side.wall)
                                                                annotation (Line(
              points={{-20,-24},{-20,-35}},
                                          color={191,0,0}));
        connect(evaporator_gas_side.wall, evaporator_ht.port_b)  annotation (Line(
              points={{16,-35},{16,-24}},
                                        color={191,0,0}));
        connect(evaporator.inlet,economizer. outlet) annotation (Line(points={{25.6,
                17.04},{30.7,17.04},{30.7,18},{38,18}},        color={159,159,
                223}));
        connect(evaporator.outlet, superheater.inlet) annotation (Line(points={{8.8,
                31.2},{0.4,31.2},{0.4,30},{-10,30}},          color={159,159,
                223}));
        connect(superheater.wall, superheater_ht.port_a)    annotation (Line(
              points={{-20,25},{-20,-4}},  color={191,0,0}));
        connect(evaporator.wall, evaporator_ht.port_a)     annotation (Line(
              points={{16,13.32},{16,-4}},
                                         color={191,0,0}));
        connect(turbine.inlet, superheater.outlet) annotation (Line(points={{-51,30},
                {-30,30}},           color={159,159,223}));
        connect(feedback.y, PI.u) annotation (Line(points={{-49,68},{-46.4,68},
                {-43.8,68}},         color={0,0,127}));
        connect(alpha_SP.y, feedback.u1) annotation (Line(points={{-73,68},{-66,
                68}},                                              color={0,0,
                127}));
        connect(evaporator.voidFraction, feedback.u2) annotation (Line(points={{6.88,
                16.8},{-6,16.8},{-6,46},{-58,46},{-58,60}},      color={0,0,127}));
        connect(PI.y, WaterLiquidSource.w) annotation (Line(points={{-23.1,68},
                {86.2,68},{86.2,24}},color={0,0,127}));
        connect(economizer.inlet, WaterLiquidSource.flange) annotation (Line(
              points={{58,18},{58,18},{70,18}},
                                          color={159,159,223}));
        connect(gasTurbine.load, load)                annotation (Line(points={{-60,-40},
                {-90,-40}},          color={0,0,127}));
        connect(turbine.dHT, turbineShaft.externalBoundary) annotation (Line(
            points={{-60,25.8},{-60,17}},
            color={255,127,0},
            smooth=Smooth.None));
        connect(turbineShaft.internalBoundary, fixedHeatFlow_DHT_N1_1.port)
          annotation (Line(
            points={{-60,11},{-60,-2},{-68,-2}},
            color={255,127,0},
            smooth=Smooth.None));
        annotation (Diagram(graphics),
          experiment(StopTime=1000),
          experimentSetupOutput,
          Icon(graphics={Rectangle(extent={{-100,100},{100,-100}},
                                                                 lineColor={0,0,
                    255}), Text(
                extent={{-136,78},{138,-74}},
                lineColor={0,0,255},
                textString=
                     "P")}));
      end CC1D;

      model CC1D_FindInitialState
        extends CC1D;
        import Modelica.Utilities.Streams.*;
      initial equation
              economizer.wat_liq_out.T = 459;
              economizer_gas_side.gas_out.T= 490;
              evaporator.p= 7.5e6;
              evaporator_gas_side.gas_out.T=454;
              superheater.wat_vap_out.T = 797;
              superheater_gas_side.gas_out.T = 746;
              for i in 2:turbineShaft.Nr-1 loop
                turbineShaft.T[i] = 791;
              end for;
        der(PI.x) = 0;
        der(evaporator.alpha)=0;
      equation
              when terminal() then
                print("");
                print("initial equation");
                print("  economizer.wat_liq_out.T = "+String(economizer.wat_liq_out.T)+";");
                print("  economizer_gas_side.gas_out.T = "+String(economizer_gas_side.gas_out.T)+";");
                print("  evaporator.alpha = "+String(evaporator.alpha)+";");
                print("  evaporator.p = "+String(evaporator.p)+";");
                print("  evaporator_gas_side.gas_out.T = "+String(evaporator_gas_side.gas_out.T)+";");
                print("  PI.x = "+String(PI.x)+";");
                print("  superheater.wat_vap_out.T = "+String(superheater.wat_vap_out.T)+";");
                print("  superheater_gas_side.gas_out.T = "+String(superheater_gas_side.gas_out.T)+";");
                print("  turbineShaft.T[2:(turbineShaft.Nr-1)] = ones(turbineShaft.Nr-2)*"+String(turbineShaft.T[2])+";");
                print("");
              end when;
        annotation (Diagram(graphics),
          experiment(StopTime=1000),
          experimentSetupOutput,
          Icon(graphics={Rectangle(extent={{-100,100},{100,-100}},
                                                                 lineColor={0,0,
                    255}), Text(
                extent={{-136,78},{138,-74}},
                lineColor={0,0,255},
                textString=
                     "P")}));
      end CC1D_FindInitialState;

      model CC1D_FullLoad "Includes initial equations with given states"
        extends CombinedCycle.Optimization.Plants.CC1D;
        import Modelica.Utilities.Streams.*;
      initial equation
        economizer.wat_liq_out.T = 521.48;
        economizer_gas_side.gas_out.T = 536.548;
        evaporator.alpha = 0.5;
        evaporator.p = 8.29575e+006;
        evaporator_gas_side.gas_out.T = 592.978;
        PI.x = -0.0622182;
        superheater.wat_vap_out.T = 860.732;
        superheater_gas_side.gas_out.T = 766.947;
        turbineShaft.T[2:(turbineShaft.Nr-1)] = ones(turbineShaft.Nr-2)*860.731;
        annotation (Diagram(graphics),
          experiment(StopTime=1000),
          experimentSetupOutput,
          Icon(graphics={Rectangle(extent={{-100,100},{100,-100}},
                                                                 lineColor={0,0,
                    255}), Text(
                extent={{-136,78},{138,-74}},
                lineColor={0,0,255},
                textString=
                     "P")}));
      end CC1D_FullLoad;

      model CC1D_WarmStartUp "Includes initial equations with given states"
        extends CombinedCycle.Optimization.Plants.CC1D;
        import Modelica.Utilities.Streams.*;
      initial equation
        economizer.wat_liq_out.T = 519.032;
        economizer_gas_side.gas_out.T = 484.54;
        evaporator.alpha = 0.5;
        evaporator.p = 3.47342e+006;
        evaporator_gas_side.gas_out.T = 514.173;
        PI.x = -0.0260506;
        superheater.wat_vap_out.T = 688.909;
        superheater_gas_side.gas_out.T = 614.001;
        turbineShaft.T[2:(turbineShaft.Nr-1)] = ones(turbineShaft.Nr-2)*688.909;
          annotation (Diagram(graphics),
          experiment(StopTime=1000),
          experimentSetupOutput,
          Icon(graphics={Rectangle(extent={{-100,100},{100,-100}},
                                                                 lineColor={0,0,
                    255}), Text(
                extent={{-136,78},{138,-74}},
                lineColor={0,0,255},
                textString=
                     "P")}));
      end CC1D_WarmStartUp;
    end Plants;
  end Optimization;

  package Types
    type Temperature = Modelica.SIunits.Temperature(nominal = 500);
    type Pressure = Modelica.SIunits.Pressure(nominal = 1e6);
    type GasDensity = Modelica.SIunits.Density(nominal = 30);
    type LiquidDensity = Modelica.SIunits.Density(nominal = 1000);
    type MassFlowRate = Modelica.SIunits.MassFlowRate(nominal = 10);
    type HeatFlowRate = Modelica.SIunits.HeatFlowRate(nominal = 1e6);
    type SpecificEnthalpy = Modelica.SIunits.SpecificEnthalpy(nominal = 1e6);
    type SpecificEnergy = Modelica.SIunits.SpecificEnergy(nominal = 1e6);
    type SpecificHeatCapacity = Modelica.SIunits.SpecificHeatCapacity(nominal = 1000);
    type HeatFlux = Real (final quantity="HeatFlux", final unit="W/m2", nominal = 1e4);
    type Stress = Modelica.SIunits.NormalStress(nominal = 1e7);
  end Types;
  annotation (Modelica(version="2.2.1"), uses(Modelica(version="3.1")),
    version="2",
    conversion(from(version="", script="ConvertFromCombinedCycle_.mos"),
        noneFromVersion="1"));
end CombinedCycle;
