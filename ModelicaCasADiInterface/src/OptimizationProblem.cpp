/*
Copyright (C) 2013 Modelon AB

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

#include "OptimizationProblem.hpp"
#include <string>
#include <math.h>
#include <stdio.h>
using std::ostream; using casadi::MX;

namespace ModelicaCasADi
{

    OptimizationProblem::~OptimizationProblem() {
        // Delete all the OptimizationProblem's variables, since they are OwnedNodes with the OptimizationProblem as owner.
        for (std::vector< TimedVariable * >::iterator it = timedVariables.begin(); it != timedVariables.end(); ++it) {
            delete *it;
            *it = NULL;
        }
    }

    void OptimizationProblem::initializeProblem(std::string identifier /* = "" */, bool normalizedTime /* = true */ ) {
        Model::initializeModel(identifier);
        this->normalizedTime = normalizedTime;
    }


    std::vector< Ref<TimedVariable> > OptimizationProblem::getTimedVariables() const
    {
        std::vector< Ref<TimedVariable> > result;
        for (std::vector< TimedVariable * >::const_iterator it = timedVariables.begin(); it != timedVariables.end(); ++it) {
            result.push_back(*it);
        }
        return result;
    }


    void OptimizationProblem::print(ostream& os) const
    {
        //    os << "OptimizationProblem<" << this << ">"; return;
    
        using namespace std;
        os << "Model contained in OptimizationProblem:\n" << endl;
        Model::print(os);
        os << "----------------------- Optimization information ------------------------\n\n";
        os << "Start time = ";
        if (startTime.isEmpty()) {
            os << "not set";
        }
        else {
            os << ModelicaCasADi::normalizeMXRespresentation(startTime);
        }
    
        os << "\nFinal time = ";
        if (finalTime.isEmpty()) {
            os << "not set";
        }
        else {
            os << ModelicaCasADi::normalizeMXRespresentation(finalTime);
        }
    
        os << "\n\n";
        for (vector< Ref<Constraint> >::const_iterator it = pathConstraints.begin(); it != pathConstraints.end(); ++it) {
            if (it == pathConstraints.begin()) {
                os << "-- Path constraints --" << endl;
            }
            os << *it << endl;
        }
        for (vector< Ref<Constraint> >::const_iterator it = pointConstraints.begin(); it != pointConstraints.end(); ++it) {
            if (it == pointConstraints.begin()) {
                os << "-- Point constraints --" << endl;
            }
            os << *it << endl;
        }
        for (vector< TimedVariable * >::const_iterator it = timedVariables.begin(); it != timedVariables.end(); ++it) {
            if (it == timedVariables.begin()) {
                os << "\n-- Timed variables --\n";
            }
            os << **it << endl;
        }
    
        os << "\n-- Objective integrand term --\n";
        if (objectiveIntegrand.isEmpty()) {
            os << "not set";
        }
        else {
            os << ModelicaCasADi::normalizeMXRespresentation(objectiveIntegrand);
        }
    
        os << "\n-- Objective term --\n";
        if (objective.isEmpty()) {
            os << "not set";
        }
        else {
            os << ModelicaCasADi::normalizeMXRespresentation(objective);
        }
    }
    
    void OptimizationProblem::setEliminableVariables(){
        if(equations_->hasBLT()) {
            std::vector< Ref<TimedVariable> > timedVars = getTimedVariables();
            std::vector< Ref<Variable> > alias_vars = getAliases();
            for(std::vector<Variable*>::iterator it=z.begin();it!=z.end();++it) {
    
                bool hasAlias=false;
                for(std::vector< Ref<Variable> >::iterator it_alias = alias_vars.begin();
                it_alias!=alias_vars.end() && !hasAlias;++it_alias) {
                    if((*it)==(*it_alias)->getModelVariable()) {
                        hasAlias=true;
                    }
                }                
                
                bool isTimed=false;
                for(std::vector< Ref<TimedVariable> >::iterator tit=timedVars.begin();tit!=timedVars.end() && !isTimed;++tit) {
                    if(*it==(*tit)->getBaseVariable()) {
                        isTimed=true;
                    }
                }                
                if(equations_->isBLTEliminable((*it)) && classifyVariable(*it) != DERIVATIVE && !isTimed && !hasAlias /*&& !(*it)->hasAttributeSet("min") && !(*it)->hasAttributeSet("max")*/) {
                    (*it)->setAsEliminable();
                }
            }
        }    
    }
    
    void OptimizationProblem::setEquations(Ref<Equations> eqCont) {
        equations_ = eqCont;
        setEliminableVariables();
    }


    void OptimizationProblem::eliminateAlgebraics() {
        if(!hasBLT()) {
            throw std::runtime_error("Only Models with BLT can eliminate variables. Please enable the equation_sorting compiler option.\n");        
        }
        std::vector< Ref<Variable> > algebraics = getVariables(REAL_ALGEBRAIC);
        std::vector< Ref<Variable> > eliminable_algebraics;
        for(std::vector< Ref<Variable> >::iterator it = algebraics.begin(); it!=algebraics.end(); ++it){
            if((*it)->isEliminable() && !(*it)->hasAttributeSet("min") && !(*it)->hasAttributeSet("max")){
                eliminable_algebraics.push_back(*it);        
            }
        }
        markVariablesForElimination(eliminable_algebraics);
        eliminateVariables();
    }

    bool compareFunction2(const std::pair<int, const Variable*>& a, const std::pair<int, const Variable*>& b) {
        return a.first < b.first;
    }

    void OptimizationProblem::substituteAllEliminables() {
        if(hasBLT()) {
            
            std::vector< Ref<Variable> > eliminateables = getEliminableVariables();
            std::list< std::pair<int, const Variable*> > toSubstituteList;
            for(std::vector<Ref<Variable> >::iterator it=eliminateables.begin();it!=eliminateables.end();++it) {
                int id_block = equations_->getBlockIDWithSolutionOf(*it);
                if(id_block>=0) {
                    toSubstituteList.push_back(std::pair<int, const Variable*>(id_block,const_cast<const Variable*>((*it).getNode())));
                }    
            }                   
            toSubstituteList.sort(compareFunction2);
            std::map<const Variable*,casadi::MX> tmpMap;
            equations_->getSubstitues(toSubstituteList, tmpMap);
            std::vector<casadi::MX> eliminatedMXs;
            std::vector<casadi::MX> subtitutes;
            for(std::map<const Variable*,casadi::MX>::const_iterator it=tmpMap.begin();
            it!=tmpMap.end();++it) {
                eliminatedMXs.push_back(it->first->getVar());
                subtitutes.push_back(it->second);
            }
    
            //Substitutes in the optimization expressions
            std::vector<casadi::MX> expressions;
            expressions.push_back(startTime);
            expressions.push_back(finalTime);
            expressions.push_back(objectiveIntegrand);
            expressions.push_back(objective);
    
            if(pathConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::const_iterator path_it = pathConstraints.begin();
                path_it!=pathConstraints.end();++path_it) {
                    expressions.push_back((*path_it)->getLhs());
                    expressions.push_back((*path_it)->getRhs());
                }
            }
            if(pointConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::const_iterator point_it = pointConstraints.begin();
                point_it!=pointConstraints.end();++point_it) {
                    expressions.push_back((*point_it)->getLhs());
                    expressions.push_back((*point_it)->getRhs());
                }
            }
    
            std::vector<casadi::MX> subtitutedExpressions = casadi::substitute(expressions,eliminatedMXs,subtitutes);
    
            int counter=0;
            startTime = subtitutedExpressions[counter++];
            finalTime = subtitutedExpressions[counter++];
            objectiveIntegrand = subtitutedExpressions[counter++];
            objective = subtitutedExpressions[counter++];
    
            if(pathConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::iterator path_it = pathConstraints.begin();
                path_it!=pathConstraints.end();++path_it) {
                    (*path_it)->setLhs(subtitutedExpressions[counter++]);
                    (*path_it)->setRhs(subtitutedExpressions[counter++]);
                }
            }
            if(pointConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::iterator point_it = pointConstraints.begin();
                point_it!=pointConstraints.end();++point_it) {
                    (*point_it)->setLhs(subtitutedExpressions[counter++]);
                    (*point_it)->setRhs(subtitutedExpressions[counter++]);
                }
            }
    
            //Substitutes in DAE
            equations_->substitute(tmpMap);
        }
        else {
            std::cout<<"The Model does not have symbolic manipulation capabilities. Try with BLT\n.";
        }
    }


    void OptimizationProblem::markVariablesForElimination(const std::vector< Ref<Variable> >& vars) {
        if(hasBLT()) {
            for(std::vector< Ref<Variable> >::const_iterator it=vars.begin();it!=vars.end();++it) {
                if((*it)->isEliminable()) {
                    int id_block = equations_->getBlockIDWithSolutionOf(*it);
                    if(id_block>=0) {
                        listToEliminate.push_back(std::pair<int, const Variable*>(id_block,(*it).getNode()));
                    }
                }
                else {
                    std::cout<<"Variable <<< "<<(*it)->getName()<<" >>> is not Eliminable.\n";
                }
            }
        }
        else {
            std::cout<<"Only Models with BLT can eliminate variables.\n";
        }
    }


    void OptimizationProblem::markVariablesForElimination(Ref<Variable> var) {
        if(hasBLT()) {
            if(var->isEliminable()) {
                int id_block = equations_->getBlockIDWithSolutionOf(var);
                if(id_block>=0) {
                    listToEliminate.push_back(std::pair<int, const Variable*>(id_block,var.getNode()));
                }
            }
            else {
                std::cout<<"Variable <<< "<<var->getName()<<" >>> is not Eliminable.\n";
            }
        }
        else {
            std::cout<<"Only Models with BLT can eliminate variables.\n";
        }
    }


    void OptimizationProblem::eliminateVariables() {
        if(!hasBLT()) {
            throw std::runtime_error("Only Models with BLT can eliminate variables. Please enable the equation_sorting compiler option.\n");        
        }
        if(call_count_eliminations<1){
            //Sort the list first
            listToEliminate.sort(compareFunction2);
        
            equations_->getSubstitues(listToEliminate,eliminatedVariableToSolution);
            equations_->eliminateVariables(eliminatedVariableToSolution);
        
            //Mark variables as Eliminated
            std::vector< Variable* >::iterator fit;
            for(std::list< std::pair<int, const Variable*> >::iterator it_var=listToEliminate.begin();
            it_var!=listToEliminate.end();++it_var) {
                //it_var->second->setAsEliminated();
                //Removes variables from variables vector. Makes sure duplicates in the list are not twice eliminated
                if(!it_var->second->wasEliminated()){
                    //eliminated_z.push_back(const_cast<Variable*>(it_var->second));
                    fit = std::find(z.begin(), z.end(),it_var->second);
                    (*fit)->setAsEliminated();
                    //z.erase(fit);
                }
            }
        
            std::vector<casadi::MX> eliminatedMXs;
            std::vector<casadi::MX> subtitutes;
            for(std::map<const Variable*,casadi::MX>::const_iterator it=eliminatedVariableToSolution.begin();
            it!=eliminatedVariableToSolution.end();++it) {
                if(!it->second.isEmpty()) {
                    eliminatedMXs.push_back(it->first->getVar());
                    subtitutes.push_back(it->second);
                    
                    //This does not work for problems with scaling 
                    /*if(it->first->hasAttributeSet("min")){
                        casadi::MX min = *(const_cast<Variable*>(it->first)->getMin());
                        std::cout<<it->first->getName()<<" min "<< min <<"\n";
                        pathConstraints.push_back(new Constraint(min,it->second,Constraint::GEQ));                    
                    }
                    if(it->first->hasAttributeSet("max")){
                        casadi::MX max = *(const_cast<Variable*>(it->first)->getMax());
                        std::cout<<it->first->getName()<<" max "<< max <<"\n";
                        pathConstraints.push_back(new Constraint(it->second,max,Constraint::LEQ));                    
                    }*/
                }
            }
    
            for(std::vector< Ref<Constraint> >::iterator it_path=pathConstraints.begin();it_path!=pathConstraints.end();++it_path){
                std::cout<<*it_path<<"\n";            
            }
            
            std::vector<casadi::MX> expressions;
            expressions.push_back(startTime);
            expressions.push_back(finalTime);
            expressions.push_back(objectiveIntegrand);
            expressions.push_back(objective);
        
            if(pathConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::const_iterator path_it = pathConstraints.begin();
                path_it!=pathConstraints.end();++path_it) {
                    expressions.push_back((*path_it)->getLhs());
                    expressions.push_back((*path_it)->getRhs());
                }
            }
            if(pointConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::const_iterator point_it = pointConstraints.begin();
                point_it!=pointConstraints.end();++point_it) {
                    expressions.push_back((*point_it)->getLhs());
                    expressions.push_back((*point_it)->getRhs());
                }
            }
        
            std::vector<casadi::MX> subtitutedExpressions = casadi::substitute(expressions,eliminatedMXs,subtitutes);
        
            int counter=0;
            startTime = subtitutedExpressions[counter++];
            finalTime = subtitutedExpressions[counter++];
            objectiveIntegrand = subtitutedExpressions[counter++];
            objective = subtitutedExpressions[counter++];
        
            if(pathConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::iterator path_it = pathConstraints.begin();
                path_it!=pathConstraints.end();++path_it) {
                    (*path_it)->setLhs(subtitutedExpressions[counter++]);
                    (*path_it)->setRhs(subtitutedExpressions[counter++]);
                }
            }
            if(pointConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::iterator point_it = pointConstraints.begin();
                point_it!=pointConstraints.end();++point_it) {
                    (*point_it)->setLhs(subtitutedExpressions[counter++]);
                    (*point_it)->setRhs(subtitutedExpressions[counter++]);
                }
            }
        }
        else{
            std::cout<<"WARNING: Variables have been already eliminated once. Further eliminations are ignored.\n";
        }
        ++call_count_eliminations;
    }

    std::string removesMXprint(std::string s)
    {
        std::string strnomx = s.substr(3,s.length()-4);
        return strnomx;
        /*if(strnomx[0] == "(" && strnomx[strnomx.length()-1] == ")"){
            return strnomx.substr(1,strnomx.length()-2);
        }
        else{
            return strnomx;
        }*/
    } 

    void OptimizationProblem::printPyomoModel(const std::string& modelName /*="model"*/)
    {
        std::vector<casadi::MX> pyomoStates;
        std::vector<casadi::MX> pyomoDerivatives;
        std::vector<casadi::MX> pyomoInputs;
        std::vector<casadi::MX> pyomoAlgebraics;
        std::vector<casadi::MX> pyomoIndParams;
        std::vector<casadi::MX> pyomoDepParams;
        std::vector<casadi::MX> pyomoTimedVars;

        std::vector<casadi::MX> JMStates;
        std::vector<casadi::MX> JMDerivatives;
        std::vector<casadi::MX> JMInputs;
        std::vector<casadi::MX> JMAlgebraics;
        std::vector<casadi::MX> JMIndParams;
        std::vector<casadi::MX> JMDepParams;
        std::vector<casadi::MX> JMTimedVars;

        std::ofstream modelFile;
        std::string name;
        std::string fileName = identifier;
        fileName = "JMPyomoModel.py";
        double min;
        double max;
        double initialGuess;
        modelFile.open(fileName.c_str());
        modelFile << "from pyomo.environ import *\n";
        modelFile << "from pyomo.dae import *\n";
        modelFile << "from pyomo import *\n\n";
        modelFile << "import pyomo.core.base.expr as pyomo_ope\n";

        modelFile << "\nsq = lambda x : x**2\n";
        modelFile << "exp = lambda x : pyomo_ope.exp(x)\n";
        modelFile << "log = lambda x : pyomo_ope.log10(x)\n";
        modelFile << "sin = lambda x : pyomo_ope.sin(x)\n";
        modelFile << "cos = lambda x : pyomo_ope.cos(x)\n";
        modelFile << "tan = lambda x : pyomo_ope.tan(x)\n";
        modelFile << "inf = float('inf')\n\n";


        modelFile << modelName << " = ConcreteModel()\n";

        std::vector< Ref<Variable> > ind_parameters = getVariables(REAL_PARAMETER_INDEPENDENT);
        if(!ind_parameters.empty()){modelFile << "\n# Independent Params ....Could be written in a data file instead\n";}
        for(std::vector<Ref<Variable> >::iterator it=ind_parameters.begin();it!=ind_parameters.end();++it)
        {
            name = (*it)->getName();
            std::replace(name.begin(), name.end(), '.', '_');
            std::replace(name.begin(), name.end(), '(','_');
            std::replace(name.begin(), name.end(), ')','_');  
            modelFile << name <<" = "<< evaluateExpression((*it)->getVar())<<"\n";
            JMIndParams.push_back((*it)->getVar());
            pyomoIndParams.push_back(casadi::MX::sym(name));
        }

        modelFile << "\n# Sets\n";
        modelFile << modelName << ".t = ContinuousSet(bounds = (startTime, finalTime))\n"; 

        std::vector< Ref<Variable> > states = getVariables(DIFFERENTIATED);

        modelFile << "\n# State and Derivative Variables \n";
        for(std::vector<Ref<Variable> >::iterator it=states.begin();it!=states.end();++it)
        {
            name = (*it)->getName();
            min = evaluateExpression(*(*it)->getMin());
            max = evaluateExpression(*(*it)->getMax());
            initialGuess = evaluateExpression(*(*it)->getStart());
            if(casadi::casadi_limits<double>::isInf(initialGuess) || casadi::casadi_limits<double>::isMinusInf(initialGuess) || initialGuess==0.0)
            {
                initialGuess = 1.0;
            }
            std::replace(name.begin(), name.end(), '.', '_');
            std::replace(name.begin(), name.end(), '(','_');
            std::replace(name.begin(), name.end(), ')','_');  
            Ref<RealVariable> casted = dynamic_cast<RealVariable*>((*it).getNode());
            Ref<Variable> derivative = casted->getMyDerivativeVariable();
            std::string name_der = derivative->getName();
            std::replace(name_der.begin(), name_der.end(), '.', '_');
            std::replace(name_der.begin(), name_der.end(), '(', '_');
            std::replace(name_der.begin(), name_der.end(), ')', '_');
            if(casadi::casadi_limits<double>::isInf(max) && casadi::casadi_limits<double>::isMinusInf(min)){   
                modelFile << modelName << "." << name <<" = Var("<< modelName <<".t, initialize = "<<initialGuess<<")\n";
            }
            else{
                modelFile << modelName << "." << name <<" = Var("<< modelName <<".t, bounds = ("<< min << "," << max <<"), initialize = "<<initialGuess<<")\n";
            }
            modelFile << modelName << "." << name_der <<" = DerivativeVar("<< modelName <<"."<< name <<")\n";
            
            JMStates.push_back((*it)->getVar());
            JMDerivatives.push_back(derivative->getVar());
            pyomoStates.push_back(casadi::MX::sym(modelName+"."+name+"[i]"));
            pyomoDerivatives.push_back(casadi::MX::sym(modelName+"."+name_der+"[i]"));
        }

        std::vector< Ref<Variable> > inputs = getVariables(REAL_INPUT);
        if(!inputs.empty()){modelFile << "\n# Inputs\n";}
        for(std::vector<Ref<Variable> >::iterator it=inputs.begin();it!=inputs.end();++it)
        {
            name = (*it)->getName();
            min = evaluateExpression(*(*it)->getMin());
            max = evaluateExpression(*(*it)->getMax());
            initialGuess = evaluateExpression(*(*it)->getStart());
            if(casadi::casadi_limits<double>::isInf(initialGuess) || casadi::casadi_limits<double>::isMinusInf(initialGuess) || initialGuess==0.0)
            {
                initialGuess = 1.0;
            }
            std::replace(name.begin(), name.end(), '.', '_');
            std::replace(name.begin(), name.end(), '(','_');
            std::replace(name.begin(), name.end(), ')','_');  
            if(casadi::casadi_limits<double>::isInf(max) && casadi::casadi_limits<double>::isMinusInf(min)){   
                modelFile << modelName << "." << name <<" = Var("<< modelName <<".t, initialize = "<<initialGuess<<")\n";
            }
            else{
                modelFile << modelName << "." << name <<" = Var("<< modelName <<".t, bounds = ("<< min << "," << max <<"), initialize = "<<initialGuess<<")\n";
            }
            JMInputs.push_back((*it)->getVar());
            pyomoInputs.push_back(casadi::MX::sym(modelName+"."+name+"[i]"));
        }
        
        std::vector< Ref<Variable> > algebraics = getVariables(REAL_ALGEBRAIC);
        if(!algebraics.empty()){modelFile << "\n# Algebraics\n";}
        for(std::vector<Ref<Variable> >::iterator it=algebraics.begin();it!=algebraics.end();++it)
        {
            name = (*it)->getName();
            min = evaluateExpression(*(*it)->getMin());
            max = evaluateExpression(*(*it)->getMax());
            initialGuess = evaluateExpression(*(*it)->getStart());
            if(casadi::casadi_limits<double>::isInf(initialGuess) || casadi::casadi_limits<double>::isMinusInf(initialGuess) || initialGuess==0.0)
            {
                initialGuess = 1.0;
            }
            std::replace(name.begin(), name.end(), '.', '_');
            std::replace(name.begin(), name.end(), '(','_');
            std::replace(name.begin(), name.end(), ')','_');  
            if(casadi::casadi_limits<double>::isInf(max) && casadi::casadi_limits<double>::isMinusInf(min)){   
                modelFile << modelName << "." << name <<" = Var("<< modelName <<".t, initialize = "<<initialGuess<<")\n";
            }
            else{
                modelFile << modelName << "." << name <<" = Var("<< modelName <<".t, bounds = ("<< min << "," << max <<"), initialize = "<<initialGuess<<")\n";
            }
            JMAlgebraics.push_back((*it)->getVar());
            pyomoAlgebraics.push_back(casadi::MX::sym(modelName+"."+name+"[i]"));
        }

        std::vector< Ref<Variable> > dep_parameters = getVariables(REAL_PARAMETER_DEPENDENT);
        if(!dep_parameters.empty()){modelFile << "\n# Dependent Parameters\n";}
        for(std::vector<Ref<Variable> >::iterator it=dep_parameters.begin();it!=dep_parameters.end();++it)
        {
            name = (*it)->getName();
            std::replace(name.begin(), name.end(), '.', '_');
            std::replace(name.begin(), name.end(), '(','_');
            std::replace(name.begin(), name.end(), ')','_');  
            modelFile << modelName << "." << name <<" = Var()\n";
            JMDepParams.push_back((*it)->getVar());
            pyomoDepParams.push_back(casadi::MX::sym(modelName+"."+name));
        }

        std::vector< Ref<TimedVariable> >  timed_vars = getTimedVariables();
        std::string timed_string;
        for(std::vector< Ref<TimedVariable> >::iterator it=timed_vars.begin();it!=timed_vars.end();++it)
        {
            Ref<Variable> base = (*it)->getBaseVariable();
            name = base->getName();
            std::replace(name.begin(), name.end(), '.', '_');
            std::replace(name.begin(), name.end(), '(','_');
            std::replace(name.begin(), name.end(), ')','_');
            std::ostringstream sstream;
            sstream << evaluateExpression((*it)->getTimePoint());
            //timed_string = sstream.str();
            timed_string = removesMXprint((*it)->getTimePoint().getRepresentation());
            JMTimedVars.push_back((*it)->getVar());
            pyomoTimedVars.push_back(casadi::MX::sym(modelName+"."+name+"["+timed_string+"]"));
        }


        std::vector< Ref< Equation> > dae = getDaeEquations();
        std::vector<casadi::MX> daeLHS;
        std::vector<casadi::MX> daeRHS;
        for(std::vector< Ref< Equation> >::iterator it=dae.begin();it!=dae.end();++it)
        {
            daeLHS.push_back(casadi::MX((*it)->getLhs()));
            daeRHS.push_back(casadi::MX((*it)->getRhs()));
        }

        // All of this can be avoided if the loop is done over all variables .... to be improved later 
        std::vector<casadi::MX> allVarsJM;
        allVarsJM.insert(allVarsJM.end(), JMStates.begin(), JMStates.end());
        allVarsJM.insert(allVarsJM.end(), JMDerivatives.begin(), JMDerivatives.end());
        allVarsJM.insert(allVarsJM.end(), JMInputs.begin(), JMInputs.end());
        allVarsJM.insert(allVarsJM.end(), JMAlgebraics.begin(), JMAlgebraics.end());
        allVarsJM.insert(allVarsJM.end(), JMDepParams.begin(), JMDepParams.end());
        allVarsJM.insert(allVarsJM.end(), JMIndParams.begin(), JMIndParams.end());
        allVarsJM.insert(allVarsJM.end(), JMTimedVars.begin(), JMTimedVars.end());
        

        std::vector<casadi::MX> allVarsPY;
        allVarsPY.insert(allVarsPY.end(), pyomoStates.begin(), pyomoStates.end());
        allVarsPY.insert(allVarsPY.end(), pyomoDerivatives.begin(), pyomoDerivatives.end());
        allVarsPY.insert(allVarsPY.end(), pyomoInputs.begin(), pyomoInputs.end());
        allVarsPY.insert(allVarsPY.end(), pyomoAlgebraics.begin(), pyomoAlgebraics.end());
        allVarsPY.insert(allVarsPY.end(), pyomoDepParams.begin(), pyomoDepParams.end());
        allVarsPY.insert(allVarsPY.end(), pyomoIndParams.begin(), pyomoIndParams.end());
        allVarsPY.insert(allVarsPY.end(), pyomoTimedVars.begin(), pyomoTimedVars.end());

        std::vector<casadi::MX> pyLHS = casadi::substitute(daeLHS,
        allVarsJM,
        allVarsPY);

        std::vector<casadi::MX> pyRHS = casadi::substitute(daeRHS,
        allVarsJM,
        allVarsPY);
        modelFile << "\n################## Constraints ##################\n\n";
        for(int i=0;i<pyRHS.size();++i)
        {
            modelFile << "def dae_constraint_rule_" << i << "("<<modelName<<",i):\n";
            modelFile << "\tif i == 0:\n\t\treturn Constraint.Skip\n";
            modelFile << "\treturn " << removesMXprint(pyLHS[i].getRepresentation()) << " == " << removesMXprint(pyRHS[i].getRepresentation()) <<"\n";
            modelFile << modelName << ".dae_constraint_" << i << " = " 
            << "Constraint(" << modelName << ".t, rule = "<< "dae_constraint_rule_" << i << ")\n\n";
        }

        modelFile << "# Initial Conditions\n";
        std::vector< Ref< Equation> > dae_init = getInitialEquations();
        std::vector<casadi::MX> dae_initLHS;
        std::vector<casadi::MX> dae_initRHS;
        for(std::vector< Ref< Equation> >::iterator it=dae_init.begin();it!=dae_init.end();++it)
        {
            dae_initLHS.push_back(casadi::MX((*it)->getLhs()));
            dae_initRHS.push_back(casadi::MX((*it)->getRhs()));
        }

        std::vector<casadi::MX> pyinitLHS = casadi::substitute(dae_initLHS,
        allVarsJM,
        allVarsPY);

        std::vector<casadi::MX> pyinitRHS = casadi::substitute(dae_initRHS,
        allVarsJM,
        allVarsPY);

        modelFile << "def _init_rule("<<modelName<<"):\n\ti=0\n";
        for(int i=0;i<dae_initRHS.size();++i)
        {
            modelFile << "\tyield " << removesMXprint(pyinitLHS[i].getRepresentation()) << " == " 
            << removesMXprint(pyinitRHS[i].getRepresentation())<<"\n";
        }
        modelFile << "\tyield ConstraintList.End\n";
        modelFile << modelName << ".init_conditions = ConstraintList( rule = _init_rule)\n\n";

        std::vector< Ref<Constraint> >  pathConst = getPathConstraints();
        if(!pathConst.empty()){modelFile << "# Path constraints\n";}
        std::vector<casadi::MX> path_LHS;
        std::vector<casadi::MX> path_RHS;
        for(std::vector< Ref< Constraint> >::iterator it=pathConst.begin();it!=pathConst.end();++it)
        {
            path_LHS.push_back(casadi::MX((*it)->getLhs()));
            path_RHS.push_back(casadi::MX((*it)->getRhs()));
        }

        std::vector<casadi::MX> pypathLHS = casadi::substitute(path_LHS,
        allVarsJM,
        allVarsPY);

        std::vector<casadi::MX> pypathRHS = casadi::substitute(path_RHS,
        allVarsJM,
        allVarsPY);

        for(int i=0;i<pypathLHS.size();++i)
        {
            modelFile << "def path_constraint_rule_" << i << "("<<modelName<<",i):\n";
            if(pathConst[i]->getType() == Constraint::EQ){
                modelFile << "\treturn " << removesMXprint(pypathLHS[i].getRepresentation()) << " == " << removesMXprint(pypathRHS[i].getRepresentation()) <<"\n";
            }
            else if(pathConst[i]->getType() == Constraint::LEQ){
                modelFile << "\treturn " << removesMXprint(pypathLHS[i].getRepresentation()) << " <= " << removesMXprint(pypathRHS[i].getRepresentation()) <<"\n";
            }
            else{
                modelFile << "\treturn " << removesMXprint(pypathLHS[i].getRepresentation()) << " >= " << removesMXprint(pypathRHS[i].getRepresentation()) <<"\n";
            }
            modelFile << modelName << ".path_constraint_" << i << " = " 
            << "Constraint(" << modelName << ".t, rule = "<< "path_constraint_rule_" << i << ")\n\n";
        }

        std::vector< Ref<Constraint> >  pointConst = getPointConstraints();
        if(!pointConst.empty()){modelFile << "# Point constraints\n";}
        std::vector<casadi::MX> point_LHS;
        std::vector<casadi::MX> point_RHS;
        for(std::vector< Ref< Constraint> >::iterator it=pointConst.begin();it!=pointConst.end();++it)
        {
            point_LHS.push_back(casadi::MX((*it)->getLhs()));
            point_RHS.push_back(casadi::MX((*it)->getRhs()));
        }

        std::vector<casadi::MX> pypointLHS = casadi::substitute(point_LHS,
        allVarsJM,
        allVarsPY);

        std::vector<casadi::MX> pypointRHS = casadi::substitute(point_RHS,
        allVarsJM,
        allVarsPY);

        for(int i=0;i<pypointLHS.size();++i)
        {
            modelFile << "def point_constraint_rule_" << i << "("<<modelName<<"):\n";
            if(pointConst[i]->getType() == Constraint::EQ){
                modelFile << "\treturn " << removesMXprint(pypointLHS[i].getRepresentation()) << " == " << removesMXprint(pypointLHS[i].getRepresentation()) <<"\n";
            }
            else if(pointConst[i]->getType() == Constraint::LEQ){
                modelFile << "\treturn " << removesMXprint(pypointLHS[i].getRepresentation()) << " <= " << removesMXprint(pypointLHS[i].getRepresentation()) <<"\n";
            }
            else{
                modelFile << "\treturn " << removesMXprint(pypointLHS[i].getRepresentation()) << " >= " << removesMXprint(pypointLHS[i].getRepresentation()) <<"\n";
            }
            modelFile << modelName << ".point_constraint_" << i << " = " 
            << "Constraint(" << modelName << ".t, rule = "<< "point_constraint_rule_" << i << ")\n\n";
        }

        modelFile << "################## Objective function ##################\n\n";
        std::vector<casadi::MX> Boltza;
        Boltza.push_back(casadi::MX(objectiveIntegrand));
        Boltza.push_back(casadi::MX(objective));
        
        std::vector<casadi::MX> pyObjective = casadi::substitute(Boltza,
        allVarsJM,
        allVarsPY);

        if(!pyObjective.front().isZero()){
            modelFile << "def _integralExp("<<modelName<<",i):\n";
            modelFile << "\treturn " << removesMXprint(pyObjective.front().getRepresentation()) << "\n";
            modelFile << modelName << ".initExp = Integral(" << modelName << ".t, rule = _integralExp, wrt = "<<modelName <<".t)\n";
        }
        modelFile << "\ndef _obj_rule("<<modelName<<"):\n";
        modelFile << "\treturn " << removesMXprint(pyObjective.back().getRepresentation());
        if(!pyObjective.front().isZero()){ 
        modelFile << " + " << modelName <<".initExp\n"; 
        }
        else{
            modelFile << "\n";
        }
        modelFile << modelName<< ".obj = Objective(rule = _obj_rule)\n";

        modelFile.close();
        std::cout << "Pyomo model written in file "<<fileName<<"\n";
    }

}; // End namespace
