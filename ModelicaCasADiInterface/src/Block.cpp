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

#include "Block.hpp"
#include <iomanip>
#include <iostream>

namespace ModelicaCasADi
{

    void Block::addEquation(Ref<Equation> eq, bool solvable) {
        bool found=false;
        for(std::vector< Ref<Equation> >::iterator it=equations.begin(); it != equations.end() && !found;++it) {
            if((*it)->getLhs().getRepresentation()==eq->getLhs().getRepresentation() &&
            (*it)->getRhs().getRepresentation()==eq->getRhs().getRepresentation()) {
                found=true;
            }
        }
        if(!found) {
            equations.push_back(eq);
        }
        else {
            std::cout<<"Warning: the equation ";
            eq->print(std::cout);
            std::cout<<" was already in equations\n";
        }
        if(!solvable) {
            found=false;
            for(std::vector< Ref<Equation> >::iterator it=unSolvedEquations.begin(); it != unSolvedEquations.end() && !found;++it) {
                if((*it)->getLhs().getRepresentation()==eq->getLhs().getRepresentation() &&
                (*it)->getRhs().getRepresentation()==eq->getRhs().getRepresentation()) {
                    found=true;
                }
            }
            if(!found) {
                unSolvedEquations.push_back(eq);
            }
            else {
                std::cout<<"Warning: the equation ";
                eq->print(std::cout);
                std::cout<<" was already in unSolvedEquations\n";
            }
        }
    }
    
    void Block::addNotClassifiedEquation(Ref<Equation> eq){
        equations.push_back(eq);
    }
    void Block::addUnsolvedEquation(Ref<Equation> eq){
        unSolvedEquations.push_back(eq);
    }

    void Block::printBlock(std::ostream& out,bool withData/*=false*/) const{
    out<<"----------------------------------------\n";
    out << "Number of variables z = (der(x),w): " << std::right << std::setw(10) << getNumVariables() << "\n";
    out << "Number of unsolved variables: " << std::right<< std::setw(16) << getNumUnsolvedVariables() << "\n";
    out << "Number of equations: " << std::right << std::setw(25) << getNumEquations() << "\n";
    out << "Number of unsolved equations: " << std::right << std::setw(16) << getNumUnsolvedEquations() << "\n";
    out << "Number of external variables: " << std::right << std::setw(16) << getNumExternalVariables() << "\n";
    out << "--------Flags---------\n";
    out << "BlockType: " << std::right << std::setw(20) << (isSimple() ? "SimpleBlock\n" : "EquationBlock\n");
    //if(!isSimple()){
    out << "Linearity: " << std::right << std::setw(18) << (isLinear() ? "LinearBlock\n" : "NonlinearBlock\n");
    //}
    if(isSimple()) {
        out << "Solvability: " << std::right << std::setw(15) << (isSolvable() ? "Solvable\n" : "Unsolvable\n");
    }
    if(variableToSolution_.size()>0) {
        out<<"Solutions:\n";
        for(std::map<const Variable*,casadi::MX>::const_iterator it=variableToSolution_.begin();
        it!=variableToSolution_.end();++it) {
            out<< (it->first)->getVar() << " = " <<it->second<<"\n";
        }
    }
    out << "--------Details-------\n";
    if(withData) {
        if(getNumVariables()>0) {
            out<< "Variables:\n";
            for (std::set<const Variable*>::const_iterator it = variables_.begin();
            it != variables_.end(); ++it) {
                out << (*it)->getVar() << "-->v[" << variableToIndex_.find(*it)->second << "]\n";
            }

            out<<"\n";
        }
        if(getNumUnsolvedVariables()>0) {
            out<< "\nUnsolved variables:\n";
            for (std::set<const Variable*>::const_iterator it = unSolvedVariables_.begin();
            it != unSolvedVariables_.end(); ++it) {
                out << (*it)->getVar() << " ";
            }
            out<<"\n";
        }
        if(getNumEquations()>0) {
            out << "\nEquations:\n";
            for(std::vector< Ref<Equation> >::const_iterator it=equations.begin();
            it != equations.end(); ++it) {
                out<<(*it)->getLhs()<<" = "<<(*it)->getRhs()<<"\n";
            }
        }
        if(getNumUnsolvedEquations()>0) {
            out << "Unsolved equations:\n";
            for(std::vector< Ref<Equation> >::const_iterator it=unSolvedEquations.begin();
            it != unSolvedEquations.end(); ++it) {
                out<<(*it)->getLhs()<<" = "<<(*it)->getRhs()<<"\n";
            }
        }
        if(getNumExternalVariables()>0) {
            out<< "\nExternal variables:\n";
            for (std::set<const Variable*>::const_iterator it = externalVariables_.begin();
            it != externalVariables_.end(); ++it) {
                out << (*it)->getVar() << " ";
            }
            out<<"\n";
        }
    }

    out<<"Jacobian\n";
    out<<jacobian<<"\n";
    out<<"---------------------------------------\n";

}

void Block::markTearingResiduals() {
    for(std::vector< Ref<Equation> >::iterator it_eq=equations.begin(); it_eq != equations.end();++it_eq) {
        for(std::vector< Ref<Equation> >::iterator it=unSolvedEquations.begin(); it != unSolvedEquations.end(); ++it) {
            if((*it)->getLhs().getRepresentation()==(*it_eq)->getLhs().getRepresentation() &&
               (*it)->getRhs().getRepresentation()==(*it_eq)->getRhs().getRepresentation()) {
                (*it_eq)->setTearing(true);
                (*it)->setTearing(true);
            }
        }
    }
}

void Block::moveAllEquationsToUnsolvable() {
    unSolvedEquations.clear();
    for(std::vector< Ref<Equation> >::const_iterator it=equations.begin();
    it != equations.end(); ++it) {
        unSolvedEquations.push_back(*it);
    }
    unSolvedVariables_.clear();
    for (std::set<const Variable*>::const_iterator it = variables_.begin();
    it != variables_.end(); ++it) {
        unSolvedVariables_.insert(*it);
    }
}


void Block::computeJacobianCasADi() {
    symbolicVariables = casadi::MX::sym("symVars",variables_.size());
    std::vector<casadi::MX> vars;
    std::vector<casadi::MX> varsSubstitue;
    std::vector<casadi::MX> residuals;
    for(std::vector< Ref<Equation> >::iterator it=equations.begin();
    it != equations.end(); ++it) {
        residuals.push_back((*it)->getLhs()-(*it)->getRhs());
    }
    for (std::map<const Variable*,int>::const_iterator it = variableToIndex_.begin();
    it != variableToIndex_.end(); ++it) {
        vars.push_back(it->first->getVar());
        varsSubstitue.push_back(symbolicVariables(it->second));
    }
    std::vector<casadi::MX> Expressions = casadi::substitute(residuals,
        vars,
        varsSubstitue);
    casadi::MX symbolicResidual;
    for(std::vector< casadi::MX >::iterator it=Expressions.begin();
    it != Expressions.end(); ++it) {
        symbolicResidual.append(*it);
    }
    casadi::MXFunction f = casadi::MXFunction(std::vector<casadi::MX>(1,symbolicVariables),std::vector<casadi::MX>(1,symbolicResidual));
    f.init();
    jacobian=f.jac();
    
    linear_flag = !casadi::dependsOn(jacobian,std::vector< casadi::MX >(1,symbolicVariables));
    
    //This makes printing of the jacobian of linear systems less convoluted. It shows a matrix and not a bunch of symbolics
    /*casadi::MXFunction df(std::vector<casadi::MX>(1,symbolicVariables),std::vector<casadi::MX>(1,jacobian));    
    df.init();
    if(df.getFree().empty() && isLinear()){
        std::vector<double> inputVals;
        //this numbers wont be replaced because the system is linear
        for(int i=0;i<variables_.size();++i){
            inputVals.push_back(1.0);        
        }
        df.setInput(inputVals,0);
        df.evaluate();
        casadi::DMatrix output = df.getOutput();
        jacobian=output;
    }*/
    
    //Make the substitution back to variables.This will only matter if the block is nonlinear
    /*if(!isLinear()){
        Expressions = casadi::substitute(std::vector<casadi::MX>(1,jacobian),
            varsSubstitue,
            vars);
        jacobian = Expressions.front();
    }*/
}


void Block::solveLinearSystem() {
    if(isLinear() && !isSolvable() && !isSimple() /*no simple for now*/) {
        //get the residuals
        std::vector<casadi::MX> residuals;
        //append equations
        for(std::vector< Ref<Equation> >::iterator it=equations.begin();
        it != equations.end(); ++it) {
            residuals.push_back((*it)->getLhs()-(*it)->getRhs());
        }
        std::vector<casadi::MX> zeros(getNumVariables(),casadi::MX(0.0));
        std::vector<casadi::MX> b_ = casadi::substitute(residuals,
            variablesVector(),
            zeros);
        casadi::MX b;
        for(std::vector<casadi::MX>::iterator it=b_.begin();
        it!=b_.end();++it) {
            b.append(*it);
        }
        casadi::MX xsolution = casadi::solve(jacobian,-b);
        /*casadi::MXFunction dummy = casadi::MXFunction(std::vector<casadi::MX>(),std::vector<casadi::MX>(1,xsolution));
        dummy.init();
        casadi::DMatrix output;
        //Dummy function to see the evaluated solution and not the symbolic expression
        if(dummy.getFree().empty()){
            dummy.evaluate();
            output = dummy.getOutput();
        }*/
        
        for(std::set<const Variable*>::const_iterator it = variables_.begin();
        it != variables_.end(); ++it) {
            //if(output.isEmpty()){
                addSolutionToVariable(*it, xsolution[variableToIndex_[*it]]);
            //}
            //else{
            //    addSolutionToVariable(*it, output[variableToIndex_[*it]]);
            //}
        }
        unSolvedEquations.clear();
        unSolvedVariables_.clear();
        solve_flag = true;
        
    }
}


void Block::substitute(const std::map<const Variable*, casadi::MX>& variableToExpression) {
    std::vector<casadi::MX> varstoSubstitute;
    std::vector<casadi::MX> expforsubstitutition;
    std::vector<casadi::MX> Expressions;
    for(std::map<const Variable*, casadi::MX>::const_iterator it = variableToExpression.begin();
    it!=variableToExpression.end();++it) {
        if(isExternal(it->first) && !it->first->getVar().isEmpty() && !it->second.isEmpty()) {
            varstoSubstitute.push_back(it->first->getVar());
            expforsubstitutition.push_back(it->second);
        }
    }
    
    //Get expresions from variableToSolution map
    //Necesary because order is not determined
    std::vector<const Variable*> keys;
    for(std::map<const Variable*,casadi::MX>::iterator it=variableToSolution_.begin();
    it!=variableToSolution_.end();++it) {
        keys.push_back(it->first);
        Expressions.push_back(it->second);
    }

    //Get expresions from equations 
    for(std::vector< Ref<Equation> >::iterator it=equations.begin();
    it != equations.end();++it) {
        Expressions.push_back((*it)->getLhs());
        Expressions.push_back((*it)->getRhs());
    }
    
    //Get expresions from unsolvedEquations
    for(std::vector< Ref<Equation> >::iterator it=unSolvedEquations.begin();
    it != unSolvedEquations.end();++it) {
        Expressions.push_back((*it)->getLhs());
        Expressions.push_back((*it)->getRhs());
    }
    std::vector<casadi::MX> subExpressions = casadi::substitute(Expressions,varstoSubstitute,expforsubstitutition);
    
    //retrive substitutions to constainers
    for(int i=0;i<keys.size();++i) {
        variableToSolution_[keys[i]]=subExpressions[i];
    }
    
    //update equations
    int j=0;
    for(int i=keys.size();i<2*equations.size()+keys.size();i+=2) {
        equations[j]->setLhs(subExpressions[i]);
        equations[j]->setRhs(subExpressions[i+1]);
        ++j;
    }
    
    //update unsolved equations
    j=0;
    for(int i=2*equations.size()+keys.size();i<2*equations.size()+keys.size()+2*unSolvedEquations.size();i+=2) {
        unSolvedEquations[j]->setLhs(subExpressions[i]);
        unSolvedEquations[j]->setRhs(subExpressions[i+1]);
        ++j;
    }
    
    //Recomputes jacobian with the updated expressions
    computeJacobianCasADi();
    
}


std::set<const Variable*> Block::eliminableVariables() const
{
    std::set<const Variable*> keys;
    for(std::map<const Variable*, casadi::MX>::const_iterator it = variableToSolution_.begin();
    it!=variableToSolution_.end();++it) {
        keys.insert(it->first);
    }
    return keys;
}


std::vector< Ref<Equation> > Block::getEquationsforModel() const
{
    // This function (and the surrounding framework) needs to be redesigned.
    // It should not return copies of the solved equations, as this makes it impossible for the user to modifty the
    // actual equations.
    std::vector< Ref<Equation> > modelEqs;
    for(std::map<const Variable*, casadi::MX>::const_iterator it = variableToSolution_.begin();
    it!=variableToSolution_.end();++it) {
        modelEqs.push_back(new Equation(it->first->getVar(),it->second));
    }

    for(std::vector< Ref<Equation> >::const_iterator it=unSolvedEquations.begin();
    it != unSolvedEquations.end();++it) {
        modelEqs.push_back(*it);
    }
    return modelEqs;
}


}; // End namespace
