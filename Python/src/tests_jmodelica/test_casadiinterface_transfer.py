#Copyright (C) 2013 Modelon AB

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, version 3 of the License.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
from tests_jmodelica import testattr, get_files_path
try:
    from modelicacasadi_transfer import *
    # Common variables used in the tests
    x1 = MX.sym("x1")
    x2 = MX.sym("x2")
    x3 = MX.sym("x3")
    der_x1 = MX.sym("der(x1)")
except (NameError, ImportError):
    pass

modelFile = os.path.join(get_files_path(), 'Modelica', 'TestModelicaModels.mo')
optproblemsFile = os.path.join(get_files_path(), 'Modelica', 'TestOptimizationProblems.mop')
import platform

## In this file there are tests for transferModelica, transferOptimica and tests for
## the correct transfer of the MX representation of expressions and various Modelica constructs
## from JModelica.org.

def load_optimization_problem(*args, **kwargs):
    ocp = OptimizationProblem()
    transfer_optimization_problem(ocp, *args, **kwargs)
    return ocp

def strnorm(StringnotNorm):
    caracters = ['\n','\t',' ']
    StringnotNorm = str(StringnotNorm)
    for c in caracters:
        StringnotNorm = StringnotNorm.replace(c, '')
    return StringnotNorm
    
def assertNear(val1, val2, tol):
    assert abs(val1 - val2) < tol
    
##############################################
#                                            # 
#          MODELICA TRANSFER TESTS           #
#                                            #
##############################################

class ModelicaTransfer(object):
    """Base class for Modelica transfer tests. Subclasses define load_model"""

    @testattr(casadi_base = True)
    def test_ModelicaAliasVariables(self):
        model = self.load_model("atomicModelAlias", modelFile)
        assert not model.getVariable("x").isNegated()
        assert model.getVariable("z").isNegated()
        assert strnorm(model.getVariable("x")) ==\
               strnorm("Real x(alias: y);")
        assert strnorm(model.getModelVariable("x")) ==\
               strnorm("Real y;")
        assert strnorm(model.getVariable("y")) ==\
               strnorm("Real y;")
        assert strnorm(model.getModelVariable("y")) ==\
               strnorm("Real y;")
        assert strnorm(model.getVariable("z")) ==\
               strnorm("Real z(alias: y);")
        assert strnorm(model.getModelVariable("z")) ==\
               strnorm("Real y;")
    

    @testattr(casadi_base = True)
    def test_ModelicaSimpleEquation(self):
        assert strnorm(self.load_model("AtomicModelSimpleEquation", modelFile).getDaeResidual()) ==\
               strnorm(der_x1 - x1) 

    @testattr(casadi_base = True)
    def test_ModelicaSimpleInitialEquation(self):
        assert strnorm(self.load_model("AtomicModelSimpleInitialEquation", modelFile).getInitialResidual()) == strnorm(x1 - MX(1))

    @testattr(casadi_base = True)
    def test_ModelicaFunctionCallEquations(self):
        assert( strnorm(repr(self.load_model("AtomicModelFunctionCallEquation", modelFile, compiler_options={"inline_functions":"none"}).getDaeResidual())) == 
                    strnorm("MX(vertcat((der(x1)-x1), (vertcat(x2, x3)-vertcat(function(\"AtomicModelFunctionCallEquation.f\")" + 
                    ".call([der(x1)]){0}, function(\"AtomicModelFunctionCallEquation.f\").call([der(x1)]){1}))))") )  

    @testattr(casadi_base = True)
    def test_ModelicaBindingExpression(self):
        model =  self.load_model("AtomicModelAttributeBindingExpression", modelFile)
        dependent =  model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
        independent =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
        actual =  str(independent[0].getAttribute("bindingExpression")) + str(dependent[0].getAttribute("bindingExpression"))
        expected = str(MX(2)) + str(MX.sym("p1"))
        assert strnorm(actual) == strnorm(expected)

    @testattr(casadi_base = True)
    def test_ModelicaUnit(self):
        model =  self.load_model("AtomicModelAttributeUnit", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        assert strnorm(diffs[0].getAttribute("unit")) ==\
               strnorm(MX.sym("kg"))

    @testattr(casadi_base = True)
    def test_ModelicaQuantity(self):
        model =  self.load_model("AtomicModelAttributeQuantity", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        assert strnorm(diffs[0].getAttribute("quantity")) ==\
               strnorm(MX.sym("kg")) 

    @testattr(casadi_base = True)
    def test_ModelicaDisplayUnit(self):
        model =  self.load_model("AtomicModelAttributeDisplayUnit", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        assert strnorm(diffs[0].getAttribute("displayUnit")) ==\
               strnorm(MX.sym("kg")) 

    @testattr(casadi_base = True)
    def test_ModelicaMin(self):
        model =  self.load_model("AtomicModelAttributeMin", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        assert strnorm((diffs[0].getAttribute("min"))) ==\
               strnorm(MX(0)) 

    @testattr(casadi_base = True)
    def test_ModelicaMax(self):
        model =  self.load_model("AtomicModelAttributeMax", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        assert strnorm(diffs[0].getAttribute("max")) == strnorm(MX(100))

    @testattr(casadi_base = True)
    def test_ModelicaStart(self):
        model =  self.load_model("AtomicModelAttributeStart", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        assert strnorm(diffs[0].getAttribute("start"))  ==\
               strnorm(MX(0.0005))

    @testattr(casadi_base = True)
    def test_ModelicaFixed(self):
        model =  self.load_model("AtomicModelAttributeFixed", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        assert strnorm(diffs[0].getAttribute("fixed")) ==\
               strnorm(MX(True))

    @testattr(casadi_base = True)
    def test_ModelicaNominal(self):
        model =  self.load_model("AtomicModelAttributeNominal", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        assert strnorm(diffs[0].getAttribute("nominal")) ==\
               strnorm(MX(0.1))

    @testattr(casadi_base = True)
    def test_ModelicaComment(self):
        model =  self.load_model("AtomicModelComment", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        assert strnorm(diffs[0].getAttribute("comment")) ==\
               strnorm(MX.sym("I am x1's comment"))

    @testattr(casadi_base = True)
    def test_ModelicaRealDeclaredType(self):
        model =  self.load_model("AtomicModelDerivedRealTypeVoltage", modelFile)
        assert strnorm(model.getVariableType("Voltage")) ==\
               strnorm("Voltage type = Real (quantity = ElectricalPotential, unit = V);")

    @testattr(casadi_base = True)
    def test_ModelicaDerivedTypeDefaultType(self):
        model =  self.load_model("AtomicModelDerivedTypeAndDefaultType", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        assert int(diffs[0].getDeclaredType().this) == int(model.getVariableType("Voltage").this)
        assert int(diffs[1].getDeclaredType().this) == int(model.getVariableType("Real").this)

    @testattr(casadi_base = True)
    def test_ModelicaIntegerDeclaredType(self):
        model =  self.load_model("AtomicModelDerivedIntegerTypeSteps", modelFile)
        assert strnorm(model.getVariableType("Steps")) ==\
               strnorm("Steps type = Integer (quantity = steps);")

    @testattr(casadi_base = True)
    def test_ModelicaBooleanDeclaredType(self):
        model =  self.load_model("AtomicModelDerivedBooleanTypeIsDone", modelFile)
        assert strnorm(model.getVariableType("IsDone")) ==\
               strnorm("IsDone type = Boolean (quantity = Done);")

    @testattr(casadi_base = True)
    def test_ModelicaRealConstant(self):
        model =  self.load_model("atomicModelRealConstant", modelFile)
        constVars =  model.getVariables(Model.REAL_CONSTANT)
        assert strnorm(constVars[0].getVar()) ==\
               strnorm(MX.sym("pi"))
        assertNear(constVars[0].getAttribute("bindingExpression").getValue(), 3.14, 0.0000001)

    @testattr(casadi_base = True)
    def test_ModelicaRealIndependentParameter(self):
        model =  self.load_model("atomicModelRealIndependentParameter", modelFile)
        indepParam =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
        assert strnorm(indepParam[0].getVar()) ==\
               strnorm(MX.sym("pi"))
        assertNear(indepParam[0].getAttribute("bindingExpression").getValue(), 3.14, 0.0000001)

    @testattr(casadi_base = True)
    def test_ModelicaRealDependentParameter(self):
        model =  self.load_model("atomicModelRealDependentParameter", modelFile)
        depParam =  model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
        indepParam =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
        assert strnorm(2*(indepParam[0].getVar())) ==\
               strnorm(depParam[0].getAttribute("bindingExpression"))

    @testattr(casadi_base = True)
    def test_ModelicaDerivative(self):
        model =  self.load_model("atomicModelRealDerivative", modelFile)
        assert strnorm(model.getVariables(Model.DERIVATIVE)[0].getVar()) ==\
               strnorm(der_x1)

    @testattr(casadi_base = True)
    def test_ModelicaDifferentiated(self):
        model = self.load_model("atomicModelRealDifferentiated", modelFile)
        diff = model.getVariables(Model.DIFFERENTIATED)
        assert strnorm(diff[0].getVar()) ==\
               strnorm(x1)

    @testattr(casadi_base = True)
    def test_ModelicaRealInput(self):
        model =  self.load_model("atomicModelRealInput", modelFile)
        ins =  model.getVariables(Model.REAL_INPUT)
        assert strnorm(ins[0].getVar()) ==\
               strnorm(x1)

    @testattr(casadi_base = True)
    def test_ModelicaAlgebraic(self):
        model =  self.load_model("atomicModelRealAlgebraic", modelFile)
        alg =  model.getVariables(Model.REAL_ALGEBRAIC)
        assert strnorm(alg[0].getVar()) ==\
               strnorm(x1)

    @testattr(casadi_base = True)
    def test_ModelicaRealDisrete(self):
        model =  self.load_model("atomicModelRealDiscrete", modelFile)
        realDisc =  model.getVariables(Model.REAL_DISCRETE)
        assert strnorm(realDisc[0].getVar()) ==\
               strnorm(x1)

    @testattr(casadi_base = True)
    def test_ModelicaIntegerConstant(self):
        model =  self.load_model("atomicModelIntegerConstant", modelFile)
        constVars =  model.getVariables(Model.INTEGER_CONSTANT)
        assert strnorm(constVars[0].getVar()) ==\
               strnorm(MX.sym("pi"))
        assertNear( constVars[0].getAttribute("bindingExpression").getValue(), 3, 0.0000001)

    @testattr(casadi_base = True)
    def test_ModelicaIntegerIndependentParameter(self):
        model =  self.load_model("atomicModelIntegerIndependentParameter", modelFile)
        indepParam =  model.getVariables(Model.INTEGER_PARAMETER_INDEPENDENT)
        assert strnorm(indepParam[0].getVar()) ==\
               strnorm(MX.sym("pi"))
        assertNear( indepParam[0].getAttribute("bindingExpression").getValue(), 3, 0.0000001 )

    @testattr(casadi_base = True)
    def test_ModelicaIntegerDependentConstants(self):
        model =  self.load_model("atomicModelIntegerDependentParameter", modelFile)    
        depParam =  model.getVariables(Model.INTEGER_PARAMETER_DEPENDENT)
        indepParam =  model.getVariables(Model.INTEGER_PARAMETER_INDEPENDENT)
        assert strnorm(2*(indepParam[0].getVar())) ==\
               strnorm(depParam[0].getAttribute("bindingExpression"))

    @testattr(casadi_base = True)
    def test_ModelicaIntegerDiscrete(self):
        model =  self.load_model("atomicModelIntegerDiscrete", modelFile)
        intDisc =  model.getVariables(Model.INTEGER_DISCRETE)
        assert strnorm(intDisc[0].getVar()) ==\
               strnorm(x1)

    @testattr(casadi_base = True)
    def test_ModelicaIntegerInput(self):
        model =  self.load_model("atomicModelIntegerInput", modelFile)    
        intIns =  model.getVariables(Model.INTEGER_INPUT)
        assert strnorm(intIns[0].getVar()) ==\
               strnorm(x1)

    @testattr(casadi_base = True)
    def test_ModelicaBooleanConstant(self):
        model =  self.load_model("atomicModelBooleanConstant", modelFile)
        constVars =  model.getVariables(Model.BOOLEAN_CONSTANT)
        assert strnorm(constVars[0].getVar()) ==\
               strnorm(MX.sym("pi"))
        assertNear( constVars[0].getAttribute("bindingExpression").getValue(), MX(True).getValue(), 0.0000001 )

    @testattr(casadi_base = True)
    def test_ModelicaBooleanIndependentParameter(self):
        model =  self.load_model("atomicModelBooleanIndependentParameter", modelFile)
        indepParam =  model.getVariables(Model.BOOLEAN_PARAMETER_INDEPENDENT)
        assert strnorm(indepParam[0].getVar()) ==\
               strnorm(MX.sym("pi"))
        assertNear( indepParam[0].getAttribute("bindingExpression").getValue(), MX(True).getValue(), 0.0000001 )

    @testattr(casadi_base = True)
    def test_ModelicaBooleanDependentParameter(self):
        model =  self.load_model("atomicModelBooleanDependentParameter", modelFile)    
        depParam =  model.getVariables(Model.BOOLEAN_PARAMETER_DEPENDENT)  
        indepParam =  model.getVariables(Model.BOOLEAN_PARAMETER_INDEPENDENT)
        assert strnorm( indepParam[0].getVar().logic_and(MX(True)) ) ==\
               strnorm(depParam[0].getAttribute("bindingExpression"))

    @testattr(casadi_base = True)
    def test_ModelicaBooleanDiscrete(self):
        model =  self.load_model("atomicModelBooleanDiscrete", modelFile)        
        boolDisc =  model.getVariables(Model.BOOLEAN_DISCRETE)
        assert strnorm(boolDisc[0].getVar()) ==\
               strnorm(x1)

    @testattr(casadi_base = True)
    def test_ModelicaBooleanInput(self):
        model =  self.load_model("atomicModelBooleanInput", modelFile)
        boolIns =  model.getVariables(Model.BOOLEAN_INPUT)
        assert strnorm(boolIns[0].getVar()) ==\
               strnorm(x1)

    @testattr(casadi_base = True)
    def test_ModelicaModelFunction(self):
        model =  self.load_model("simpleModelWithFunctions", modelFile)
        expectedPrint = ("ModelFunction : function(\"simpleModelWithFunctions.f\")\n Inputs (2):\n"
                                "  0. 1-by-1 (dense)\n"
                                "  1. 1-by-1 (dense)\n"
                                " Outputs (2):\n"
                                "  0. 1-by-1 (dense)\n"
                                "  1. 1-by-1 (dense)\n"
                                "@0 = input[0]\n"
                                "@1 = input[1]\n"
                                "{@2, @3} = function(\"simpleModelWithFunctions.f2\").call([@0, @1])\n"
                                "output[0] = @2\n"
                                "output[1] = @3\n"
                                "ModelFunction : function(\"simpleModelWithFunctions.f2\")\n Inputs (2):\n"
                                "  0. 1-by-1 (dense)\n"
                                "  1. 1-by-1 (dense)\n"
                                " Outputs (2):\n"
                                "  0. 1-by-1 (dense)\n"
                                "  1. 1-by-1 (dense)\n" 
                                "@0 = 0.5\n"
                                "@1 = input[0]\n"
                                "@0 = (@0*@1)\n"
                                "output[0] = @0\n"
                                "@1 = input[1]\n"
                                "@1 = (@1+@0)\n"
                                "output[1] = @1\n")
        mf_1 = model.getModelFunction("simpleModelWithFunctions.f")
        mf_2 = model.getModelFunction("simpleModelWithFunctions.f2")
        actual = str(mf_1) + str(mf_2)
        assert strnorm(expectedPrint) == strnorm(actual)

    @testattr(casadi_base = True)
    def test_ModelicaDependentParametersCalculated(self):
        model =  self.load_model("atomicModelDependentParameter", modelFile)
        model.calculateValuesForDependentParameters()
        depVars = model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
        assert depVars[0].getAttribute("evaluatedBindingExpression").getValue() == 20
        assert depVars[1].getAttribute("evaluatedBindingExpression").getValue() == 20
        assert depVars[2].getAttribute("evaluatedBindingExpression").getValue() == 200

    @testattr(casadi_base = True)
    def test_ModelicaFunctionCallEquationForParameterBinding(self):
        model =  self.load_model("atomicModelPolyOutFunctionCallForDependentParameter", modelFile, compiler_options={"inline_functions":"none"})
        model.calculateValuesForDependentParameters()
        expected = ("parameter Real p2[1](bindingExpression = function(\"atomicModelPolyOutFunctionCallForDependentParameter.f\").call([p1]){0}, evaluatedBindingExpression = 2) = function(\"atomicModelPolyOutFunctionCallForDependentParameter.f\").call([p1]){0}/* 2 */;\n"
                    "parameter Real p2[2](bindingExpression = function(\"atomicModelPolyOutFunctionCallForDependentParameter.f\").call([p1]){1}, evaluatedBindingExpression = 4) = function(\"atomicModelPolyOutFunctionCallForDependentParameter.f\").call([p1]){1}/* 4 */;\n")
        actual = ""
        for var in model.getVariables(Model.REAL_PARAMETER_DEPENDENT):
            actual += str(var) + "\n"
        print expected, "\n", actual
        assert strnorm(actual) == strnorm(expected)


    @testattr(casadi_base = True)
    def test_ModelicaTimeVariable(self):
        model = self.load_model("atomicModelTime", modelFile)
        t = model.getTimeVariable()
        eq = model.getDaeResidual()
        assert eq[1].getDep(1).getDep(1).isEqual(t) and eq[0].getDep(1).isEqual(t)

    ##############################################
    #                                            # 
    #         CONSTRUCTS TRANSFER TESTS          #
    #                                            #
    ##############################################
    
    @testattr(casadi_base = True)
    def test_ConstructElementaryDivision(self):
        model = self.load_model("AtomicModelElementaryDivision", modelFile)
        params = model.getVariables(model.REAL_PARAMETER_DEPENDENT)
        expected =""" array([parameter Real p3[1](bindingExpression = (p1[1]/p2[1])) = (p1[1]/p2[1]);,
       parameter Real p3[2](bindingExpression = (p1[2]/p2[2])) = (p1[2]/p2[2]);,
       parameter Real p3[3](bindingExpression = (p1[3]/p2[3])) = (p1[3]/p2[3]);,
       parameter Real p4(bindingExpression = (p1[1]/p2[1])) = (p1[1]/p2[1]);,
       parameter Real p5[1](bindingExpression = (p1[1]/p2[1])) = (p1[1]/p2[1]);,
       parameter Real p5[2](bindingExpression = (p1[2]/p2[1])) = (p1[2]/p2[1]);,
       parameter Real p5[3](bindingExpression = (p1[3]/p2[1])) = (p1[3]/p2[1]);], dtype=object)"""
        assert strnorm(repr(params)) == strnorm(expected)
        
    @testattr(casadi_base = True)
    def test_ConstructElementaryMultiplication(self):
        model = self.load_model("AtomicModelElementaryMultiplication", modelFile)
        params = model.getVariables(model.REAL_PARAMETER_DEPENDENT)
        expected ="""array([parameter Real p3[1](bindingExpression = (p1[1]*p2[1])) = (p1[1]*p2[1]);,
       parameter Real p3[2](bindingExpression = (p1[2]*p2[2])) = (p1[2]*p2[2]);,
       parameter Real p3[3](bindingExpression = (p1[3]*p2[3])) = (p1[3]*p2[3]);,
       parameter Real p4(bindingExpression = (p1[1]*p2[1])) = (p1[1]*p2[1]);,
       parameter Real p5[1](bindingExpression = (p1[1]*p2[1])) = (p1[1]*p2[1]);,
       parameter Real p5[2](bindingExpression = (p1[2]*p2[1])) = (p1[2]*p2[1]);,
       parameter Real p5[3](bindingExpression = (p1[3]*p2[1])) = (p1[3]*p2[1]);], dtype=object)"""
        assert strnorm(repr(params)) == strnorm(expected)
        
    @testattr(casadi_base = True)
    def test_ConstructElementaryAddition(self):
        model = self.load_model("AtomicModelElementaryAddition", modelFile)
        params = model.getVariables(model.REAL_PARAMETER_DEPENDENT)
        expected ="""array([parameter Real p3[1](bindingExpression = (p1[1]+p2[1])) = (p1[1]+p2[1]);,
       parameter Real p3[2](bindingExpression = (p1[2]+p2[2])) = (p1[2]+p2[2]);,
       parameter Real p3[3](bindingExpression = (p1[3]+p2[3])) = (p1[3]+p2[3]);], dtype=object)"""
        assert strnorm(repr(params)) == strnorm(expected)
        
    @testattr(casadi_base = True)
    def test_ConstructElementarySubtraction(self):
        model = self.load_model("AtomicModelElementarySubtraction", modelFile)
        params = model.getVariables(model.REAL_PARAMETER_DEPENDENT)
        expected ="""array([parameter Real p3[1](bindingExpression = (p1[1]-p2[1])) = (p1[1]-p2[1]);,
       parameter Real p3[2](bindingExpression = (p1[2]-p2[2])) = (p1[2]-p2[2]);,
       parameter Real p3[3](bindingExpression = (p1[3]-p2[3])) = (p1[3]-p2[3]);], dtype=object)"""
        assert strnorm(repr(params)) == strnorm(expected)
        
    @testattr(casadi_base = True)
    def test_ConstructElementaryExponentiation(self):
        model = self.load_model("AtomicModelElementaryExponentiation", modelFile)
        params = model.getVariables(model.REAL_PARAMETER_DEPENDENT)
        expected ="""array([ parameter Real p3[1](bindingExpression = pow(p1[1],p2[1])) = pow(p1[1],p2[1]);,
       parameter Real p3[2](bindingExpression = pow(p1[2],p2[2])) = pow(p1[2],p2[2]);,
       parameter Real p3[3](bindingExpression = pow(p1[3],p2[3])) = pow(p1[3],p2[3]);,
       parameter Real p4[1](bindingExpression = pow(p1[1],p2[2])) = pow(p1[1],p2[2]);,
       parameter Real p4[2](bindingExpression = pow(p1[2],p2[2])) = pow(p1[2],p2[2]);,
       parameter Real p4[3](bindingExpression = pow(p1[3],p2[2])) = pow(p1[3],p2[2]);,
       parameter Real p5[1](bindingExpression = pow(p1[1],p2[1])) = pow(p1[1],p2[1]);,
       parameter Real p5[2](bindingExpression = pow(p1[1],p2[2])) = pow(p1[1],p2[2]);,
       parameter Real p5[3](bindingExpression = pow(p1[1],p2[3])) = pow(p1[1],p2[3]);,
       parameter Real p6(bindingExpression = pow(p1[1],p2[1])) = pow(p1[1],p2[1]);,
       parameter Real p9[1,1](bindingExpression = pow(p7[1,1],p8[1,1])) = pow(p7[1,1],p8[1,1]);,
       parameter Real p9[1,2](bindingExpression = pow(p7[1,2],p8[1,2])) = pow(p7[1,2],p8[1,2]);,
       parameter Real p9[2,1](bindingExpression = pow(p7[2,1],p8[2,1])) = pow(p7[2,1],p8[2,1]);,
       parameter Real p9[2,2](bindingExpression = pow(p7[2,2],p8[2,2])) = pow(p7[2,2],p8[2,2]);,
       parameter Real p10[1,1](bindingExpression = pow(p7[1,1],p8[1,1])) = pow(p7[1,1],p8[1,1]);,
       parameter Real p10[1,2](bindingExpression = pow(p7[1,1],p8[1,2])) = pow(p7[1,1],p8[1,2]);,
       parameter Real p10[2,1](bindingExpression = pow(p7[1,1],p8[2,1])) = pow(p7[1,1],p8[2,1]);,
       parameter Real p10[2,2](bindingExpression = pow(p7[1,1],p8[2,2])) = pow(p7[1,1],p8[2,2]);], dtype=object)"""
        assert strnorm(repr(params)) == strnorm(expected) 
    
    @testattr(casadi_base = True)
    def test_ConstructElementaryExpression(self):
        dae = self.load_model("AtomicModelElementaryExpressions", modelFile).getDaeResidual()
        expected ="MX(vertcat((der(x1)-(2+x1)), (der(x2)-(x2-x1)), (der(x3)-(x3*x2)), (der(x4)-(x4/x3))))"
        assert strnorm(repr(dae)) == strnorm(expected) 

    @testattr(casadi_base = True)
    def test_ConstructElementaryFunctions(self):
        dae = self.load_model("AtomicModelElementaryFunctions", modelFile).getDaeResidual()
        expected = ("MX(vertcat((der(x1)-pow(x1,5)), (der(x2)-fabs(x2)), (der(x3)-fmin(x3,x2)), (der(x4)-fmax(x4,x3)), (der(x5)-sqrt(x5)), (der(x6)-sin(x6)), (der(x7)-cos(x7)), (der(x8)-tan(x8)), (der(x9)-asin(x9)), (der(x10)-acos(x10)), (der(x11)-atan(x11)), (der(x12)-atan2(x12,x11)), (der(x13)-sinh(x13)), (der(x14)-cosh(x14)), (der(x15)-tanh(x15)), (der(x16)-exp(x16)), (der(x17)-log(x17)), (der(x18)-(0.434294*log(x18))), (der(x19)+x18)))")# CasADi converts log10 to log with constant.
        assert strnorm(repr(dae)) == strnorm(expected)

    @testattr(casadi_base = True)
    def test_ConstructBooleanExpressions(self):
        dae = self.load_model("AtomicModelBooleanExpressions", modelFile).getDaeResidual()
        expected = ("MX(vertcat((der(x1)-((x2?1:0)+((!x2)?2:0))), " + 
                    "(x2-(0<x1)), (x3-(0<=x1)), (x4-(x1<0)), " + 
                    "(x5-(x1<=0)), (x6-(x5==x4)), (x7-(x6!=x5)), (x8-(x6&&x5)), (x9-(x6||x5))))")
        assert strnorm(repr(dae)) == strnorm(expected)

    @testattr(casadi_base = True)
    def test_ConstructMisc(self):
        model = self.load_model("AtomicModelMisc", modelFile)
        expected = (
        "MX(vertcat((der(x1)-1.11), (x2-(((1<x1)?3:0)+((!(1<x1))?4:0))), (x3-(1||(1<x2))), (x4-(0||x3))))"     
         "MX(vertcat(x1, pre(x2), pre(x3), pre(x4)))")
        assert strnorm(repr(model.getDaeResidual()) + repr(model.getInitialResidual()))  ==\
               strnorm(expected)



    @testattr(casadi_base = True)
    def test_ConstructVariableLaziness(self):
        model = self.load_model("AtomicModelVariableLaziness", modelFile)
        x2_eq = model.getDaeResidual()[0].getDep(1)
        x1_eq = model.getDaeResidual()[1].getDep(1)
        x1_var = model.getVariables(Model.DIFFERENTIATED)[0].getVar()
        x2_var = model.getVariables(Model.DIFFERENTIATED)[1].getVar()
        assert x1_var.isEqual(x1_eq) and x2_var.isEqual(x2_eq)

    @testattr(casadi_base = True)
    def test_ConstructArrayInOutFunction1(self):
        model = self.load_model("AtomicModelVector1", modelFile, compiler_options={"inline_functions":"none"})
        expected = ("ModelFunction : function(\"AtomicModelVector1.f\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@0 = (-@0)\n"
                    "output[0] = @0\n"
                    "@0 = input[1]\n"
                    "@0 = (-@0)\n"
                    "output[1] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelVector1.f")) == strnorm(expected)
        expected = ("MX(vertcat((vertcat(temp_1[1], temp_1[2])-vertcat(function(\"AtomicModelVector1.f\").call([A[1], A[2]]){0}, function(\"AtomicModelVector1.f\").call([A[1], A[2]]){1})), (der(A[1])-temp_1[1]), (der(A[2])-temp_1[2])))")
        assert strnorm(model.getDaeResidual()) == strnorm(expected)

    @testattr(casadi_base = True)
    def test_ConstructArrayInOutFunction2(self):
        model = self.load_model("AtomicModelVector2", modelFile, compiler_options={"inline_functions":"none"})
        expected = ("ModelFunction : function(\"AtomicModelVector2.f\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = input[1]\n"
                    "{@2, @3} = function(\"AtomicModelVector2.f2\").call([@0, @1])\n"
                    "output[0] = @2\n"
                    "output[1] = @3\n")
        assert strnorm(model.getModelFunction("AtomicModelVector2.f")) == strnorm(expected)
        expected = "MX(vertcat((vertcat(temp_1[1], temp_1[2])-vertcat(function(\"AtomicModelVector2.f\").call([A[1], A[2]]){0}, function(\"AtomicModelVector2.f\").call([A[1], A[2]]){1})), (der(A[1])-temp_1[1]), (der(A[2])-temp_1[2])))"
        assert strnorm(model.getDaeResidual()) == strnorm(expected)



    @testattr(casadi_base = True)
    def test_ConstructArrayInOutFunctionCallEquation(self):
        model = self.load_model("AtomicModelVector3", modelFile, compiler_options={"inline_functions":"none", "variability_propagation":False})
        expected = ("ModelFunction : function(\"AtomicModelVector3.f\")\n"
                    " Inputs (4):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "  2. 1-by-1 (dense)\n"
                    "  3. 1-by-1 (dense)\n"
                    " Outputs (4):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "  2. 1-by-1 (dense)\n"
                    "  3. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@0 = (-@0)\n"
                    "output[0] = @0\n"
                    "@0 = input[1]\n"
                    "@0 = (-@0)\n"
                    "output[1] = @0\n"
                    "@0 = input[2]\n"
                    "@0 = (2.*@0)\n"
                    "output[2] = @0\n"
                    "@0 = input[3]\n"
                    "@0 = (2.*@0)\n"
                    "output[3] = @0\n")
        assert str(model.getModelFunction("AtomicModelVector3.f")).replace('\n','') == expected.replace('\n','')
        expected = "MX((vertcat(A[1], A[2], B[1], B[2])-vertcat(function(\"AtomicModelVector3.f\").call([A[1], A[2], 1, 2]){0}, function(\"AtomicModelVector3.f\").call([A[1], A[2], 1, 2]){1}, function(\"AtomicModelVector3.f\").call([A[1], A[2], 1, 2]){2}, function(\"AtomicModelVector3.f\").call([A[1], A[2], 1, 2]){3})))"
        assert str(model.getDaeResidual()).replace('\n','') == expected.replace('\n','')


    @testattr(casadi_base = True)
    def test_FunctionCallEquationOmittedOuts(self):
        model = self.load_model("atomicModelFunctionCallEquationIgnoredOuts", modelFile, compiler_options={"inline_functions":"none", "variability_propagation":False})
        expected = "MX(vertcat((der(x2)-(x1+x2)), (vertcat(x1, x2)-vertcat(function(\"atomicModelFunctionCallEquationIgnoredOuts.f\").call([1, x3]){0}, function(\"atomicModelFunctionCallEquationIgnoredOuts.f\").call([1, x3]){2}))))"
        assert strnorm(model.getDaeResidual()) == strnorm(expected)  

    @testattr(casadi_base = True)
    def test_FunctionCallStatementOmittedOuts(self):
        model = self.load_model("atomicModelFunctionCallStatementIgnoredOuts", modelFile, compiler_options={"inline_functions":"none"})
        expected = ("ModelFunction : function(\"atomicModelFunctionCallStatementIgnoredOuts.f2\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = 10\n"
                    "@1 = input[0]\n"
                    "{NULL, NULL, @2} = function(\"atomicModelFunctionCallStatementIgnoredOuts.f\").call([@0, @1])\n"
                    "output[0] = @2\n")
        assert strnorm(model.getModelFunction("atomicModelFunctionCallStatementIgnoredOuts.f2")) == strnorm(expected)
    
    @testattr(casadi_base = True)
    def test_ParameterIndexing(self):
        model = self.load_model("ParameterIndexing1", modelFile)
        expected = "[x[1] = 0 x[2] = 2]"
        assert strnorm(model.getDaeEquations()) == strnorm(expected)
    
    @testattr(casadi_base = True)
    def test_OmittedArrayRecordOuts(self):
        model = self.load_model("atomicModelFunctionCallStatementIgnoredArrayRecordOuts", modelFile, compiler_options={"inline_functions":"none"})
        expectedFunctionPrint = ("ModelFunction : function(\"atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f2\")\n"
                                " Input: 1-by-1 (dense)\n"
                                " Outputs (6):\n"
                                "  0. 1-by-1 (dense)\n"
                                "  1. 1-by-1 (dense)\n"
                                "  2. 1-by-1 (dense)\n"
                                "  3. 1-by-1 (dense)\n"
                                "  4. 1-by-1 (dense)\n"
                                "  5. 1-by-1 (dense)\n"
                                "@0 = 10\n"
                                "@1 = input[0]\n"
                                "{@2, @3, @4, NULL, NULL, @5, @6, @7} = function(\"atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f\").call([@0, @1])\n"
                                "output[0] = @2\n"
                                "output[1] = @3\n"
                                "output[2] = @4\n"
                                "output[3] = @5\n"
                                "output[4] = @6\n"
                                "output[5] = @7\n")
        expectedResidualPrint = "MX((vertcat(x1, x2)-vertcat(function(\"atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f2\").call([x1]){2}, function(\"atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f2\").call([x1]){5})))"
        assert strnorm(model.getModelFunction("atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f2")) ==\
               strnorm(expectedFunctionPrint)
        assert strnorm(model.getDaeResidual()) ==\
               strnorm(expectedResidualPrint)

    @testattr(casadi_base = True)
    def test_ConstructFunctionMatrix(self):
        model = self.load_model("AtomicModelMatrix", modelFile, compiler_options={"inline_functions":"none","variability_propagation":False})
        expected = ("ModelFunction : function(\"AtomicModelMatrix.f\")\n"
                    " Inputs (4):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "  2. 1-by-1 (dense)\n"
                    "  3. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[2]\n"
                    "output[0] = @0\n"
                    "@0 = input[3]\n"
                    "output[1] = @0\n"
                    "@0 = input[0]\n"
                    "@1 = input[1]\n")

        assert strnorm(model.getModelFunction("AtomicModelMatrix.f")) ==\
               strnorm(expected)
        expected = "MX(vertcat((vertcat(temp_1[1,1],temp_1[1,2])-vertcat(function(\"AtomicModelMatrix.f\").call([A[1,1],A[1,2],X[1,1],X[2,1]]){0},function(\"AtomicModelMatrix.f\").call([A[1,1],A[1,2],X[1,1],X[2,1]]){1})),(der(A[1,1])+temp_1[1,1]),(der(A[1,2])+temp_1[1,2]),(vertcat(temp_2[1,1],temp_2[1,2],temp_2[2,1],temp_2[2,2])-vertcat(function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){0},function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){1},function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){2},function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){3})),(der(dx[1,1])+temp_2[1,1]),(der(dx[1,2])+temp_2[1,2]),(der(dx[2,1])+temp_2[2,1]),(der(dx[2,2])+temp_2[2,2]),(X[1,1]-0.1),(X[2,1]-0.3)))"
        assert strnorm(model.getDaeResidual()) ==\
               strnorm(expected)

    @testattr(casadi_base = True)
    def test_ConstructFunctionMatrixDimsGreaterThanTwo(self):
        model = self.load_model("AtomicModelLargerThanTwoDimensionArray", modelFile, compiler_options={"inline_functions":"none"})
        expected = ("ModelFunction : function(\"AtomicModelLargerThanTwoDimensionArray.f\")\n"
                    " Inputs (6):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "  2. 1-by-1 (dense)\n"
                    "  3. 1-by-1 (dense)\n"
                    "  4. 1-by-1 (dense)\n"
                    "  5. 1-by-1 (dense)\n"
                    " Outputs (6):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "  2. 1-by-1 (dense)\n"
                    "  3. 1-by-1 (dense)\n"
                    "  4. 1-by-1 (dense)\n"
                    "  5. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@0 = (-@0)\n"
                    "output[0] = @0\n"
                    "@0 = input[1]\n"
                    "@0 = (-@0)\n"
                    "output[1] = @0\n"
                    "@0 = input[2]\n"
                    "@0 = (-@0)\n"
                    "output[2] = @0\n"
                    "@0 = input[3]\n"
                    "@0 = (-@0)\n"
                    "output[3] = @0\n"
                    "@0 = input[4]\n"
                    "@0 = (-@0)\n"
                    "output[4] = @0\n"
                    "@0 = 10\n"
                    "output[5] = @0\n"
                    "@0 = input[5]\n")
        assert strnorm(model.getModelFunction("AtomicModelLargerThanTwoDimensionArray.f")) ==\
               strnorm(expected)
        expected = "MX(vertcat((vertcat(temp_1[1,1,1], temp_1[1,1,2], temp_1[1,1,3], temp_1[1,2,1], temp_1[1,2,2], temp_1[1,2,3])-vertcat(function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1], A[1,1,2], A[1,1,3], A[1,2,1], A[1,2,2], A[1,2,3]]){0}, function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1], A[1,1,2], A[1,1,3], A[1,2,1], A[1,2,2], A[1,2,3]]){1}, function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1], A[1,1,2], A[1,1,3], A[1,2,1], A[1,2,2], A[1,2,3]]){2}, function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1], A[1,1,2], A[1,1,3], A[1,2,1], A[1,2,2], A[1,2,3]]){3}, function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1], A[1,1,2], A[1,1,3], A[1,2,1], A[1,2,2], A[1,2,3]]){4}, function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1], A[1,1,2], A[1,1,3], A[1,2,1], A[1,2,2], A[1,2,3]]){5})), (der(A[1,1,1])-temp_1[1,1,1]), (der(A[1,1,2])-temp_1[1,1,2]), (der(A[1,1,3])-temp_1[1,1,3]), (der(A[1,2,1])-temp_1[1,2,1]), (der(A[1,2,2])-temp_1[1,2,2]), (der(A[1,2,3])-temp_1[1,2,3])))"
        assert strnorm(model.getDaeResidual()).replace('\n','') ==\
               strnorm(expected)

    @testattr(casadi_base = True)
    def test_ConstructNestedRecordFunctions(self):
        model = self.load_model("AtomicModelRecordNestedArray",  modelFile, compiler_options={"inline_functions":"none"})
        expected = ("ModelFunction : function(\"AtomicModelRecordNestedArray.generateCurves\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Outputs (8):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "  2. 1-by-1 (dense)\n"
                    "  3. 1-by-1 (dense)\n"
                    "  4. 1-by-1 (dense)\n"
                    "  5. 1-by-1 (dense)\n"
                    "  6. 1-by-1 (dense)\n"
                    "  7. 1-by-1 (dense)\n"
                    "@0 = 0\n"
                    "output[0] = @0\n"
                    "@0 = input[0]\n"
                    "output[1] = @0\n"
                    "@0 = 2\n"
                    "output[2] = @0\n"
                    "@1 = 3\n"
                    "output[3] = @1\n"
                    "@2 = 6\n"
                    "output[4] = @2\n"
                    "@2 = 7\n"
                    "output[5] = @2\n"
                    "output[6] = @0\n"
                    "output[7] = @1\n")
        assert strnorm(model.getModelFunction("AtomicModelRecordNestedArray.generateCurves")) ==\
               strnorm(expected)
        expected ="MX(vertcat((vertcat(compCurve.curves[1].path[1].point[1], compCurve.curves[1].path[1].point[2], compCurve.curves[1].path[2].point[1], compCurve.curves[1].path[2].point[2], compCurve.curves[2].path[1].point[1], compCurve.curves[2].path[1].point[2], compCurve.curves[2].path[2].point[1], compCurve.curves[2].path[2].point[2])-vertcat(function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){0}, function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){1}, function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){2}, function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){3}, function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){4}, function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){5}, function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){6}, function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){7})), (der(a)-compCurve.curves[1].path[1].point[2])))"
        assert strnorm(model.getDaeResidual()) ==\
               strnorm(expected)


    @testattr(casadi_base = True)
    def test_ConstructRecordInFunctionInFunction(self):
        model = self.load_model("AtomicModelRecordInOutFunctionCallStatement", modelFile, compiler_options={"inline_functions":"none"})
        expected = ("ModelFunction : function(\"AtomicModelRecordInOutFunctionCallStatement.f1\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = 2\n"
                    "@1 = input[0]\n"
                    "@0 = (@0+@1)\n"
                    "{@2, @3} = function(\"AtomicModelRecordInOutFunctionCallStatement.f2\").call([@1, @0])\n"
                    "@2 = (@2*@3)\n"
                    "output[0] = @2\n"
                    "ModelFunction : function(\"AtomicModelRecordInOutFunctionCallStatement.f2\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@0 = 10\n"
                    "@1 = input[1]\n"
                    "@0 = (@0*@1)\n" 
                    "output[1] = @0\n")
        funcStr = str(model.getModelFunction("AtomicModelRecordInOutFunctionCallStatement.f1")) + str(model.getModelFunction("AtomicModelRecordInOutFunctionCallStatement.f2"))
        assert strnorm(funcStr) == strnorm(expected)
        assert strnorm(model.getDaeResidual()) ==\
               strnorm("MX((der(a)+function(\"AtomicModelRecordInOutFunctionCallStatement.f1\").call([a]){0}))")



    @testattr(casadi_base = True)
    def test_ConstructRecordArbitraryDimension(self):
        model = self.load_model("AtomicModelRecordArbitraryDimension", modelFile, compiler_options={"inline_functions":"none"})
        expected = ("ModelFunction : function(\"AtomicModelRecordArbitraryDimension.f\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Outputs (8):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "  2. 1-by-1 (dense)\n"
                    "  3. 1-by-1 (dense)\n"
                    "  4. 1-by-1 (dense)\n"
                    "  5. 1-by-1 (dense)\n"
                    "  6. 1-by-1 (dense)\n"
                    "  7. 1-by-1 (dense)\n"
                    "@0 = 1\n"
                    "output[0] = @0\n"
                    "@0 = 2\n"
                    "output[1] = @0\n"
                    "@0 = 3\n"
                    "output[2] = @0\n"
                    "@0 = 4\n"
                    "output[3] = @0\n"
                    "@0 = 5\n"
                    "output[4] = @0\n"
                    "@0 = 6\n"
                    "output[5] = @0\n"
                    "@0 = input[0]\n"
                    "output[6] = @0\n"
                    "@0 = (2.*@0)\n"
                    "output[7] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelRecordArbitraryDimension.f")) ==\
               strnorm(expected)
        expected = "MX(vertcat((der(a)+a), (vertcat(r.A[1,1,1], r.A[1,1,2], r.A[1,2,1], r.A[1,2,2], r.A[2,1,1], r.A[2,1,2], r.A[2,2,1], r.A[2,2,2])-vertcat(function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){0}, function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){1}, function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){2}, function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){3}, function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){4}, function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){5}, function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){6}, function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){7}))))"
        assert strnorm(model.getDaeResidual()) ==\
               strnorm(expected)



    @testattr(casadi_base = True)
    def test_ConstructArrayFlattening(self):
        model =  self.load_model("atomicModelSimpleArrayIndexing", modelFile, compiler_options={"inline_functions":"none"})
        expected = ("ModelFunction : function(\"atomicModelSimpleArrayIndexing.f\")\n"
                    " Inputs (0):\n"
                    " Outputs (4):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "  2. 1-by-1 (dense)\n"
                    "  3. 1-by-1 (dense)\n"
                    "@0 = 1\n"
                    "output[0] = @0\n"
                    "@0 = 2\n"
                    "output[1] = @0\n"
                    "@0 = 3\n"
                    "output[2] = @0\n"
                    "@0 = 4\n"
                    "output[3] = @0\n")
        assert strnorm(model.getModelFunction("atomicModelSimpleArrayIndexing.f")) ==\
               strnorm(expected)

    @testattr(casadi_base = True)
    def test_ConstructRecordNestedSeveralVars(self):
        model = self.load_model("AtomicModelRecordSeveralVars", modelFile, compiler_options={"inline_functions":"none"})
        expected = ("ModelFunction : function(\"AtomicModelRecordSeveralVars.f\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Outputs (10):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "  2. 1-by-1 (dense)\n"
                    "  3. 1-by-1 (dense)\n"
                    "  4. 1-by-1 (dense)\n"
                    "  5. 1-by-1 (dense)\n"
                    "  6. 1-by-1 (dense)\n"
                    "  7. 1-by-1 (dense)\n"
                    "  8. 1-by-1 (dense)\n"
                    "  9. 1-by-1 (dense)\n"
                    "@0 = 1\n"
                    "output[0] = @0\n"
                    "@0 = 2\n"
                    "output[1] = @0\n"
                    "@0 = 3\n"
                    "output[2] = @0\n"
                    "@0 = 4\n"
                    "output[3] = @0\n"
                    "@0 = 5\n"
                    "output[4] = @0\n"
                    "@0 = 6\n"
                    "output[5] = @0\n"
                    "@0 = 7\n"
                    "output[6] = @0\n"
                    "@0 = 8\n"
                    "output[7] = @0\n"
                    "@0 = 9\n"
                    "output[8] = @0\n"
                    "@0 = input[0]\n"
                    "output[9] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelRecordSeveralVars.f")).replace('\n','') ==\
               strnorm(expected)
        expected = "MX(vertcat((der(a)+a), (vertcat(r.r1.A, r.r1.B, r.rArr[1].A, r.rArr[1].B, r.rArr[2].A, r.rArr[2].B, r.matrix[1,1], r.matrix[1,2], r.matrix[2,1], r.matrix[2,2])-vertcat(function(\"AtomicModelRecordSeveralVars.f\").call([a]){0}, function(\"AtomicModelRecordSeveralVars.f\").call([a]){1}, function(\"AtomicModelRecordSeveralVars.f\").call([a]){2}, function(\"AtomicModelRecordSeveralVars.f\").call([a]){3}, function(\"AtomicModelRecordSeveralVars.f\").call([a]){4}, function(\"AtomicModelRecordSeveralVars.f\").call([a]){5}, function(\"AtomicModelRecordSeveralVars.f\").call([a]){6}, function(\"AtomicModelRecordSeveralVars.f\").call([a]){7}, function(\"AtomicModelRecordSeveralVars.f\").call([a]){8}, function(\"AtomicModelRecordSeveralVars.f\").call([a]){9}))))"
        assert strnorm(model.getDaeResidual()) ==\
               strnorm(expected)



    @testattr(casadi_base = True)
    def test_ConstructFunctionsInRhs(self):
        model = self.load_model("AtomicModelAtomicRealFunctions", modelFile, compiler_options={"inline_functions":"none"})
        expected = "MX(vertcat((der(x1)-sin(function(\"AtomicModelAtomicRealFunctions.monoInMonoOut\").call([x1]){0})), (der(x2)-function(\"AtomicModelAtomicRealFunctions.polyInMonoOut\").call([x1, x2]){0}), (vertcat(x3, x4)-vertcat(function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\").call([x2]){0}, function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\").call([x2]){1})), (vertcat(x5, x6)-vertcat(function(\"AtomicModelAtomicRealFunctions.polyInPolyOut\").call([x1, x2]){0}, function(\"AtomicModelAtomicRealFunctions.polyInPolyOut\").call([x1, x2]){1})), (der(x7)-function(\"AtomicModelAtomicRealFunctions.monoInMonoOutReturn\").call([x7]){0}), (der(x8)-function(\"AtomicModelAtomicRealFunctions.functionCallInFunction\").call([x8]){0}), (der(x9)-function(\"AtomicModelAtomicRealFunctions.functionCallEquationInFunction\").call([x9]){0}), (der(x10)-function(\"AtomicModelAtomicRealFunctions.monoInMonoOutInternal\").call([x10]){0}), (vertcat(x11, x12)-vertcat(function(\"AtomicModelAtomicRealFunctions.polyInPolyOutInternal\").call([x9, x10]){0}, function(\"AtomicModelAtomicRealFunctions.polyInPolyOutInternal\").call([x9, x10]){1}))))"
        assert strnorm(model.getDaeResidual()) ==\
               strnorm(expected)


        model = self.load_model("AtomicModelAtomicIntegerFunctions", modelFile, compiler_options={"inline_functions":"none"})
        expected = "MX(vertcat((x1-function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOut\").call([u1]){0}), (x2-function(\"AtomicModelAtomicIntegerFunctions.polyInMonoOut\").call([u1, u2]){0}), (vertcat(x3, x4)-vertcat(function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\").call([u2]){0}, function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\").call([u2]){1})), (vertcat(x5, x6)-vertcat(function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOut\").call([u1, u2]){0}, function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOut\").call([u1, u2]){1})), (x7-function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutReturn\").call([u1]){0}), (x8-function(\"AtomicModelAtomicIntegerFunctions.functionCallInFunction\").call([u2]){0}), (x9-function(\"AtomicModelAtomicIntegerFunctions.functionCallEquationInFunction\").call([u1]){0}), (x10-function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutInternal\").call([u2]){0}), (vertcat(x11, x12)-vertcat(function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal\").call([u1, u2]){0}, function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal\").call([u1, u2]){1}))))"
        assert strnorm(model.getDaeResidual()) ==\
               strnorm(expected) 


        model = self.load_model("AtomicModelAtomicBooleanFunctions", modelFile, compiler_options={"inline_functions":"none"})
        expected = "MX(vertcat((x1-function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOut\").call([u1]){0}), (x2-function(\"AtomicModelAtomicBooleanFunctions.polyInMonoOut\").call([u1, u2]){0}), (vertcat(x3, x4)-vertcat(function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\").call([u2]){0}, function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\").call([u2]){1})), (vertcat(x5, x6)-vertcat(function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOut\").call([u1, u2]){0}, function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOut\").call([u1, u2]){1})), (x7-function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutReturn\").call([u1]){0}), (x8-function(\"AtomicModelAtomicBooleanFunctions.functionCallInFunction\").call([u2]){0}), (x9-function(\"AtomicModelAtomicBooleanFunctions.functionCallEquationInFunction\").call([u1]){0}), (x10-function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutInternal\").call([u2]){0}), (vertcat(x11, x12)-vertcat(function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal\").call([u1, u2]){0}, function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal\").call([u1, u2]){1}))))"
        assert strnorm(model.getDaeResidual()) ==\
               strnorm(expected) 



    @testattr(casadi_base = True)
    def test_ConstructVariousRealValuedFunctions(self):
        model = self.load_model("AtomicModelAtomicRealFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
        #function monoInMonoOut
            #input Real x
            #output Real y
        #algorithm
            #y := x
        #end monoInMonoOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.monoInMonoOut\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInMonoOut"))==\
               strnorm(expected) 

        #function polyInMonoOut
            #input Real x1
            #input Real x2
            #output Real y
        #algorithm
            #y := x1+x2
        #end polyInMonoOut
        #end monoInMonoOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.polyInMonoOut\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = input[1]\n"
                    "@0 = (@0+@1)\n"
                    "output[0] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.polyInMonoOut")) ==\
               strnorm(expected) 

        #function monoInPolyOut
            #input Real x
            #output Real y1
            #output Real y2
        #algorithm
            #y1 := if(x > 2) then 1 else 5
            #y2 := x
        #end monoInPolyOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = 2\n"
                    "@1 = input[0]\n"
                    "@0 = (@0<@1)\n"
                    "@2 = 1\n"
                    "@2 = (@0?@2:0)\n"
                    "@0 = (!@0)\n"
                    "@3 = 5\n"
                    "@0 = (@0?@3:0)\n"
                    "@2 = (@2+@0)\n"
                    "output[0] = @2\n"
                    "output[1] = @1\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInPolyOut")) ==\
               strnorm(expected)

        #function polyInPolyOut
            #input Real x1
            #input Real x2
            #output Real y1
            #output Real y2
        #algorithm
            #y1 := x1
            #y2 := x2
        #end polyInPolyOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.polyInPolyOut\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@0 = input[1]\n"
                    "output[1] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.polyInPolyOut")) ==\
               strnorm(expected)

        #function monoInMonoOutReturn
            #input Real x
            #output Real y
        #algorithm
            #y := x
            #return
            #y := 2*x
        #end monoInMonoOutReturn
        expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.monoInMonoOutReturn\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInMonoOutReturn")) ==\
               strnorm(expected)

        #function functionCallInFunction
            #input Real x
            #output Real y
        #algorithm
            #y := monoInMonoOut(x)
        #end functionCallInFunction
        expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.functionCallInFunction\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = function(\"AtomicModelAtomicRealFunctions.monoInMonoOut\").call([@0])\n"
                    "output[0] = @1\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.functionCallInFunction")) ==\
               strnorm(expected)

        #function functionCallEquationInFunction
            #input Real x
            #Real internal
            #output Real y
        #algorithm
            #(y,internal) := monoInPolyOut(x)
        #end functionCallEquationInFunction
        expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.functionCallEquationInFunction\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "{@1, NULL} = function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\").call([@0])\n"
                    "output[0] = @1\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.functionCallEquationInFunction")) ==\
               strnorm(expected)

        #function monoInMonoOutInternal
            #input Real x
            #Real internal
            #output Real y
        #algorithm
            #internal := sin(x)
            #y := x*internal
            #internal := sin(y)
            #y := x + internal
        #end monoInMonoOutInternal
        expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.monoInMonoOutInternal\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = sin(@0)\n"
                    "@1 = (@0*@1)\n"
                    "@1 = sin(@1)\n"
                    "@0 = (@0+@1)\n"
                    "output[0] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInMonoOutInternal")) ==\
               strnorm(expected)

        #function polyInPolyOutInternal
            #input Real x1
            #input Real x2
            #Real internal1
            #Real internal2
            #output Real y1
            #output Real y2
        #algorithm
            #internal1 := x1
            #internal2 := x2 + internal1
            #y1 := internal1
            #y2 := internal2 + x1
            #y2 := 1
        #end polyInPolyOutInternal
        expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.polyInPolyOutInternal\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@0 = 1\n"
                    "output[1] = @0\n"
                    "@0 = input[1]\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.polyInPolyOutInternal")) ==\
               strnorm(expected)


    @testattr(casadi_base = True)
    def test_ConstructVariousIntegerValuedFunctions(self):
        model = self.load_model("AtomicModelAtomicIntegerFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
        #function monoInMonoOut
            #input Integer x
            #output Integer y
        #algorithm
            #y := x
        #end monoInMonoOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOut\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInMonoOut")) ==\
               strnorm(expected) 

        #function polyInMonoOut
            #input Integer x1
            #input Integer x2
            #output Integer y
        #algorithm
            #y := x1+x2
        #end polyInMonoOut
        #end monoInMonoOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.polyInMonoOut\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = input[1]\n"
                    "@0 = (@0+@1)\n"
                    "output[0] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.polyInMonoOut"))==\
               strnorm(expected) 

        #function monoInPolyOut
            #input Integer x
            #output Integer y1
            #output Integer y2
        #algorithm
            #y1 := if(x > 2) then 1 else 5
            #y2 := x
        #end monoInPolyOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = 2\n"
                    "@1 = input[0]\n"
                    "@0 = (@0<@1)\n"
                    "@2 = 1\n"
                    "@2 = (@0?@2:0)\n"
                    "@0 = (!@0)\n"
                    "@3 = 5\n"
                    "@0 = (@0?@3:0)\n"
                    "@2 = (@2+@0)\n"
                    "output[0] = @2\n"
                    "output[1] = @1\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInPolyOut")) ==\
               strnorm(expected)

        #function polyInPolyOut
            #input Integer x1
            #input Integer x2
            #output Integer y1
            #output Integer y2
        #algorithm
            #y1 := x1
            #y2 := x2
        #end polyInPolyOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOut\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@0 = input[1]\n"
                    "output[1] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.polyInPolyOut")) ==\
               strnorm(expected)

        #function monoInMonoOutReturn
            #input Integer x
            #output Integer y
        #algorithm
            #y := x
            #return
            #y := 2*x
        #end monoInMonoOutReturn
        expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutReturn\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInMonoOutReturn")) ==\
               strnorm(expected)

        #function functionCallInFunction
            #input Integer x
            #output Integer y
        #algorithm
            #y := monoInMonoOut(x)
        #end functionCallInFunction
        expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.functionCallInFunction\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOut\").call([@0])\n"
                    "output[0] = @1\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.functionCallInFunction")) ==\
               strnorm(expected)

        #function functionCallEquationInFunction
            #input Integer x
            #Integer internal
            #output Integer y
        #algorithm
            #(y,internal) := monoInPolyOut(x)
        #end functionCallEquationInFunction
        expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.functionCallEquationInFunction\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "{@1, NULL} = function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\").call([@0])\n"
                    "output[0] = @1\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.functionCallEquationInFunction")) ==\
               strnorm(expected)

        #function monoInMonoOutInternal
            #input Integer x
            #Integer internal
            #output Integer y
        #algorithm
            #internal := 3*x
            #y := x*internal
            #internal := 1+y
            #y := x + internal
        #end monoInMonoOutInternal
        expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutInternal\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = 3\n"
                    "@1 = input[0]\n"
                    "@0 = (@0*@1)\n"
                    "@0 = (@1*@0)\n"
                    "@2 = 1\n"
                    "@2 = (@2+@0)\n"
                    "@1 = (@1+@2)\n"
                    "output[0] = @1\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInMonoOutInternal")) ==\
               strnorm(expected)

        #function polyInPolyOutInternal
            #input Integer x1
            #input Integer x2
            #Integer internal1
            #Integer internal2
            #output Integer y1
            #output Integer y2
        #algorithm
            #internal1 := x1
            #internal2 := x2 + internal1
            #y1 := internal1
            #y2 := internal2 + x1
            #y2 := 1
        #end polyInPolyOutInternal
        expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@0 = 1\n"
                    "output[1] = @0\n"
                    "@0 = input[1]\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal")) ==\
               strnorm(expected)


    @testattr(casadi_base = True)
    def test_ConstructVariousBooleanValuedFunctions(self):
        model = self.load_model("AtomicModelAtomicBooleanFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
        #function monoInMonoOut
            #input Boolean x
            #output Boolean y
        #algorithm
            #y := x
        #end monoInMonoOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOut\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInMonoOut")) ==\
               strnorm(expected) 

        #function polyInMonoOut
            #input Boolean x1
            #input Boolean x2
            #output Boolean y
        #algorithm
            #y := x1 and x2
        #end polyInMonoOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.polyInMonoOut\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = input[1]\n"
                    "@0 = (@0&&@1)\n"
                    "output[0] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.polyInMonoOut")) ==\
               strnorm(expected) 

        #function monoInPolyOut
            #input Boolean x
            #output Boolean y1
            #output Boolean y2
        #algorithm
            #y1 := if(x) then false else (x or false)
            #y2 := x
        #end monoInPolyOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = 0\n"
                    "@1 = input[0]\n"
                    "@0 = (@0||@1)\n"
                    "@2 = (!@1)\n"
                    "@2 = (@2?@0:0)\n"
                    "output[0] = @2\n"
                    "output[1] = @1\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInPolyOut")) ==\
               strnorm(expected)

        #function polyInPolyOut
            #input Boolean x1
            #input Boolean x2
            #output Boolean y1
            #output Boolean y2
        #algorithm
            #y1 := x1
            #y2 := x2
        #end polyInPolyOut
        expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOut\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@0 = input[1]\n"
                    "output[1] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.polyInPolyOut")) ==\
               strnorm(expected)

        #function monoInMonoOutReturn
            #input Boolean x
            #output Boolean y
        #algorithm
            #y := x
            #return
            #y := x or false
        #end monoInMonoOutReturn
        expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutReturn\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInMonoOutReturn")) ==\
               strnorm(expected)

        #function functionCallInFunction
            #input Boolean x
            #output Boolean y
        #algorithm
            #y := monoInMonoOut(x)
        #end functionCallInFunction
        expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.functionCallInFunction\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOut\").call([@0])\n"
                    "output[0] = @1\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.functionCallInFunction")) ==\
               strnorm(expected)

        #function functionCallEquationInFunction
            #input Boolean x
            #Boolean internal
            #output Boolean y
        #algorithm
            #(y,internal) := monoInPolyOut(x)
        #end functionCallEquationInFunction
        expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.functionCallEquationInFunction\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "{@1, NULL} = function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\").call([@0])\n"
                    "output[0] = @1\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.functionCallEquationInFunction"))==\
               strnorm(expected)

        #function monoInMonoOutInternal
            #input Boolean x
            #Boolean internal
            #output Boolean y
        #algorithm
            #internal := x
            #y := x and internal
            #internal := false or y
            #y := false or internal
        #end monoInMonoOutInternal
        expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutInternal\")\n"
                    " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@0 = (@0&&@0)\n"
                    "@1 = 0\n"
                    "@1 = (@1||@0)\n"
                    "@0 = 0\n"
                    "@0 = (@0||@1)\n"
                    "output[0] = @0\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInMonoOutInternal")) ==\
               strnorm(expected)

        #function polyInPolyOutInternal
            #input Boolean x1
            #input Boolean x2
            #Boolean internal1
            #Boolean internal2
            #output Boolean y1
            #output Boolean y2
        #algorithm
            #internal1 := x1
            #internal2 := x2  or internal1
            #y1 := internal1
            #y2 := internal2 or x1
            #y2 := true
        #end polyInPolyOutInternal
        expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal\")\n"
                    " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@0 = 1\n"
                    "output[1] = @0\n"
                    "@0 = input[1]\n")
        assert strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal"))==\
               strnorm(expected)

    @testattr(casadi_base = True)
    def test_TransferVariableType(self):
        model = self.load_model("AtomicModelMisc", modelFile)
        x1 = model.getVariable('x1')
        assert isinstance(x1, RealVariable)
        assert isinstance(x1.getMyDerivativeVariable(), DerivativeVariable)
        assert isinstance(model.getVariable('x2'), IntegerVariable)
        assert isinstance(model.getVariable('x3'), BooleanVariable)
        assert isinstance(model.getVariable('x4'), BooleanVariable)

    @testattr(casadi_base = True)
    def test_ModelIdentifier(self):
        model = self.load_model("identifierTest.identfierTestModel", modelFile)
        assert model.getIdentifier().replace('\n','') ==\
               "identifierTest_identfierTestModel".replace('\n','')


class TestModelicaTransfer(ModelicaTransfer):
    """Modelica transfer tests that use transfer_model to load the model"""
    def load_model(self, *args, **kwargs):
        model = Model()
        transfer_model(model, *args, **kwargs)
        return model

class TestModelicaTransferOpt(ModelicaTransfer):
    """Modelica transfer tests that use transfer_model to load the model"""
    def load_model(self, *args, **kwargs):
        model = OptimizationProblem()
        transfer_model(model, *args, **kwargs)
        return model


##############################################
#                                            # 
#          OPTIMICA TRANSFER TESTS           #
#                                            #
##############################################

def computeStringRepresentationForContainer(myContainer):
    stringRepr = ""
    for index in range(len(myContainer)):
        stringRepr += str(myContainer[index])
    return stringRepr
    
    
@testattr(casadi_base = True)    
def test_OptimicaLessThanPathConstraint():
    optProblem =  load_optimization_problem("atomicOptimizationLEQ", optproblemsFile)
    expected = str(x1.getName()) + " <= " + str(1)
    assert( strnorm(computeStringRepresentationForContainer(optProblem.getPathConstraints())) ==\
            strnorm(expected))

@testattr(casadi_base = True)
def test_OptimicaGreaterThanPathConstraint():
    optProblem =  load_optimization_problem("atomicOptimizationGEQ", optproblemsFile)
    expected = str(x1.getName()) + " >= " + str(1)
    assert( strnorm(computeStringRepresentationForContainer(optProblem.getPathConstraints())) ==\
            strnorm(expected))
    
@testattr(casadi_base = True)    
def test_OptimicaSevaralPathConstraints():
    optProblem =  load_optimization_problem("atomicOptimizationGEQandLEQ", optproblemsFile)
    expected = str(x2.getName()) + " <= " + str(1) +  str(x1.getName()) + " >= " + str(1) 
    assert( strnorm(computeStringRepresentationForContainer(optProblem.getPathConstraints())) ==\
            strnorm(expected))    

@testattr(casadi_base = True)
def test_OptimicaEqualityPointConstraint():
    optProblem =  load_optimization_problem("atomicOptimizationEQpoint", optproblemsFile)
    expected = str(MX.sym("x1(finalTime)").getName()) + " = " + str(1)
    assert( strnorm(computeStringRepresentationForContainer(optProblem.getPointConstraints())) ==\
            strnorm(expected))
    
@testattr(casadi_base = True)    
def test_OptimicaLessThanPointConstraint():
    optProblem =  load_optimization_problem("atomicOptimizationLEQpoint", optproblemsFile)
    expected = str(MX.sym("x1(finalTime)").getName()) + " <= " + str(1)
    assert( strnorm(computeStringRepresentationForContainer(optProblem.getPointConstraints())) ==\
            strnorm(expected))

@testattr(casadi_base = True)
def test_OptimicaGreaterThanPointConstraint():
    optProblem =  load_optimization_problem("atomicOptimizationGEQpoint", optproblemsFile)
    expected = str(MX.sym("x1(finalTime)").getName()) + " >= " + str(1)
    assert( strnorm(computeStringRepresentationForContainer(optProblem.getPointConstraints())) ==\
            strnorm(expected))
    
@testattr(casadi_base = True)    
def test_OptimicaSevaralPointConstraints():
    optProblem =  load_optimization_problem("atomicOptimizationGEQandLEQandEQpoint", optproblemsFile)
    expected = str(MX.sym("x2(startTime + 1)").getName()) + " <= " + str(1) +  str(MX.sym("x1(startTime + 1)").getName()) + " >= " + str(1) + str(MX.sym("x2(finalTime + 1)").getName()) + " = " + str(1)
    assert( strnorm(computeStringRepresentationForContainer(optProblem.getPointConstraints())) ==\
            strnorm(expected))
    
@testattr(casadi_base = True)    
def test_OptimicaMixedConstraints():
    optProblem =  load_optimization_problem("atomicOptimizationMixedConstraints", optproblemsFile)
    expectedPath = str(MX.sym("x3(startTime + 1)").getName()) + " <= " + str(x1.getName())
    expectedPoint =  str(MX.sym("x2(startTime + 1)").getName()) + " <= " + str(1) +  str(MX.sym("x1(startTime + 1)").getName()) + " >= " + str(1) 
    assert( strnorm(computeStringRepresentationForContainer(optProblem.getPathConstraints())) ==\
            strnorm(expectedPath))
    assert( strnorm(computeStringRepresentationForContainer(optProblem.getPointConstraints())) ==\
            strnorm(expectedPoint))
    
@testattr(casadi_base = True)    
def test_OptimicaTimedVariables():
    optProblem =  load_optimization_problem("atomicOptimizationTimedVariables", optproblemsFile)
    # test there are 3 timed
    timedVars = optProblem.getTimedVariables()
    assert len(timedVars) == 4

    # test they contain model vars
    x1 = optProblem.getVariable("x1")
    x2 = optProblem.getVariable("x2")
    x3 = optProblem.getVariable("x3")

    assert x1 == timedVars[0].getBaseVariable()
    assert x2 == timedVars[1].getBaseVariable()
    assert x3 == timedVars[2].getBaseVariable()
    assert x1 == timedVars[3].getBaseVariable()
        
        
    # Test their time expression has start/final parameter MX in them and
    # that timed variables are lazy.
    startTime = optProblem.getVariable("startTime")
    finalTime = optProblem.getVariable("finalTime")
    path_constraints = optProblem.getPathConstraints()
    point_constraints = optProblem.getPointConstraints()

    tp1 = timedVars[0].getTimePoint()
    tp2 = timedVars[1].getTimePoint()
    tp3 = timedVars[2].getTimePoint()
    tp4 = timedVars[3].getTimePoint()

    tv1 = timedVars[0].getVar()
    tv2 = timedVars[1].getVar()
    tv3 = timedVars[2].getVar()
    tv4 = timedVars[3].getVar()

    assert tp1.getDep(1).isEqual(startTime.getVar())
    assert tp2.getDep(1).isEqual(startTime.getVar())
    assert tp3.getDep(0).isEqual(finalTime.getVar())
    assert tp4.isEqual(finalTime.getVar())

    assert tv1.isEqual(point_constraints[0].getLhs())
    assert tv2.isEqual(path_constraints[0].getLhs())
    assert tv3.isEqual(path_constraints[1].getLhs())
    assert tv4.isEqual(optProblem.getObjective())

@testattr(casadi_base = True)
def test_OptimicaStartTime():
    optProblem =  load_optimization_problem("atomicOptimizationStart5", optproblemsFile)
    assert( optProblem.getStartTime().getValue() == 5)
    
@testattr(casadi_base = True)    
def test_OptimicaFinalTime():
    optProblem =  load_optimization_problem("atomicOptimizationFinal10", optproblemsFile)
    assert( optProblem.getFinalTime().getValue() == 10)

@testattr(casadi_base = True)
def test_OptimicaObjectiveIntegrand():
    optProblem =  load_optimization_problem("atomicLagrangeX1", optproblemsFile)
    assert str(optProblem.getObjectiveIntegrand()) == str(x1) 
    optProblem =  load_optimization_problem("atomicLagrangeNull", optproblemsFile)
    assert str(optProblem.getObjectiveIntegrand()) == str(MX(0))  

@testattr(casadi_base = True)
def test_OptimicaObjective():
    optProblem =  load_optimization_problem("atomicMayerFinalTime", optproblemsFile)
    assert str(optProblem.getObjective()) == str(MX.sym("finalTime")) 
    optProblem =  load_optimization_problem("atomicMayerNull", optproblemsFile)
    assert str(optProblem.getObjective()) == str(MX(0))

@testattr(casadi_base = True)
def test_OptimicaFree():
    model =  load_optimization_problem("atomicWithFree", optproblemsFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str((diffs[0].getAttribute("free"))) == str(MX(False))

@testattr(casadi_base = True)
def test_OptimicaInitialGuess():
    model =  load_optimization_problem("atomicWithInitialGuess", optproblemsFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("initialGuess")) == str(MX(5))

@testattr(casadi_base = True)
def test_OptimicaNormalizedTimeFlag():
    optProblem = load_optimization_problem("atomicWithInitialGuess", optproblemsFile)
    assert optProblem.getNormalizedTimeFlag()
    optProblem = load_optimization_problem("atomicWithInitialGuess", optproblemsFile, compiler_options={"normalize_minimum_time_problems":True})
    assert optProblem.getNormalizedTimeFlag()
    optProblem = load_optimization_problem("atomicWithInitialGuess", optproblemsFile, compiler_options={"normalize_minimum_time_problems":False})
    assert not optProblem.getNormalizedTimeFlag()
    

@testattr(casadi_base = True)    
def test_ModelIdentifier():
    optProblem = load_optimization_problem("identifierTest.identfierTestModel", optproblemsFile)
    assert strnorm(optProblem.getIdentifier()) ==\
           strnorm("identifierTest_identfierTestModel")
