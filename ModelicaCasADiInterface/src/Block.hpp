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

#ifndef _MODELICACASADI_BLOCK
#define _MODELICACASADI_BLOCK

#include <iostream>
#include "casadi/casadi.hpp"
#include "Variable.hpp"
#include "RealVariable.hpp"
#include "Equation.hpp"
#include "RefCountedNode.hpp"
#include <vector>
#include <set>
#include <map>
#include <utility>
#include <string>
#include <assert.h>

namespace ModelicaCasADi
{

    class Block : public RefCountedNode
    {
        public:
            //Default constructor
            Block(): simple_flag(false),linear_flag(false),solve_flag(false){}
            //~Block(){std::cout<<"\nDELETE_BLOCK\n";}

            /***************************TO BE REMOVED******************************/
            //Might be kept
            /**
             * @return A vector with the MX representation of the block variables.
             */
            std::vector< casadi::MX > variablesVector() const;
            /**
             * Mark the chosen tearing residuals.
             */
            void markTearingResiduals();
            /**
             * Set the block as unsolvable. Used when tearing is activated.
             */
            void moveAllEquationsToUnsolvable();
            /**********************************************************************/

            /**************VariablesMethods*************/
            /**
             * The number of block's solved variables.
             * @return An Integer
             */
            int getNumVariables()const {return variables_.size();}
            /**
             * The number of block's unsolved variables.
             * @return An Integer
             */
            int getNumUnsolvedVariables() const {return unSolvedVariables_.size();}
            /**
             * Gives the number of block's external variables.
             * @return  An integer
             */
            int getNumExternalVariables() const {return externalVariables_.size();}
            /**
             * The index of a variable within the block.
             * The index is used for casadi operations like computing the jacobian or solving a linear system.
             * @return An integer
             * @param A pointer to a Variable
             */
            int getVariableIndex(const Variable* var);
            /**
             * Gives block's variables
             * @return A std::set of variable
             */
            const std::set<const Variable*>& variables() const;
            /**
             * Gives block's unsolved variables
             * @return A std::set of variable
             */
            const std::set<const Variable*>& unsolvedVariables() const;
            /**
             * Gives block's external variables
             * @return A std::set of variable
             */
            const std::set<const Variable*>& externalVariables() const;
            /**
             * Check if a variable is external variable of the block
             * @return A boolean
             * @param A pointer to a Variable
             */
            bool isExternal(const Variable* var) const;
            /**
             * Check if a variable belongs to the block
             * @return A boolean
             * @param A pointer to a Variable
             */
            bool isBlockVariable(const Variable* var) const;
            /**
             * Delete a Variable from Block's map of variables solution
             * @return A boolean
             * @param A pointer to a Variable
             */
            bool removeSolutionOfVariable(const Variable* var);
            /**
             * Gives the map of symbolic solutions of Block's variables
             * @return A std::map<Variable*, MX>
             */
            std::map<const Variable*, casadi::MX> getSolutionMap() const;
            /**
             * Gives the symbolic solution of a variable if exists
             * @return A MX
             * @param Pointer to a Variable
             */
            casadi::MX getSolutionOfVariable(const Variable* var) const;
            /**
             * Check if a variable is has a symbolic solution
             * @return A boolean
             * @param A pointer to a Variable
             */
            bool hasSolution(const Variable*) const;
            /**
             * Add a variable to the set of block variables
             * @param A pointer to a Variable.
             * @param A boolean specifying if the variable is solvable or not.
             */
            void addVariable(const Variable* var, bool solvable);
            /**
             * Add a variable to the set of block's external variables
             * @param A pointer to a Variable.
             */
            void addExternalVariable(const Variable* var);
            /**
             * Gives the set of variable that can be eliminated in the block.
             * These are the external variables of the block that have a symbolic solution.
             * @return A std::set of Variable
             */
            std::set<const Variable*> eliminableVariables() const;
            /**
             * Add an entry to the map of solutions of variables
             * This has to be consistent with BLT. For internal use.
             * @param A pointer to Variable
             * @param An MX
             */
            void addSolutionToVariable(const Variable* var, casadi::MX sol);
            /*******************************************/

            /**************EquationMethods*************/
            /**
             * Gives the number of block's equations
             * @return  An integer
             */
            int getNumEquations() const {return equations.size();}
            /**
             * Gives the number of block's unsolvable equations.
             * @return  An integer
             */
            int getNumUnsolvedEquations() const {return unSolvedEquations.size();}
            /**
             * Gives block's equations
             * @return A std::vector of Equation
             */
            std::vector< Ref<Equation> > allEquations() const;
            /**
             * Gives block's unsolved equations
             * @return A std::vector of Equation
             */
            std::vector< Ref<Equation> > notSolvedEquations() const;
            /**
             * Add an equation to the block. Checks O(N*N) if the equation was not already added
             * @param An Equation.
             * @param A boolean specifying if the equation is solvable or not.
             */
            void addEquation(Ref<Equation> eq, bool solvable);
            /**
             * Add an equation to the block. It adds an equation to equations container O(1). No check 
             * Only to be used in transfer block. Not for user
             * @param An Equation.
             */
            void addNotClassifiedEquation(Ref<Equation> eq);
            /**
             * Add an equation to the block. It adds an equation to the unsolvedEquations O(1). No check 
             * Only to be used in transfer block. Not for user
             * @param An Equation.
             */
            void addUnsolvedEquation(Ref<Equation> eq);
            /**
             * Gives equations with symbolic manipulations. (substitutions and eliminations)
             * @return A std::vector of Equation
             */
            std::vector< Ref<Equation> > getEquationsforModel() const;
            /*******************************************/

            /**************AuxiliaryMethods*************/
            /**
             * Compute the jacobian of the block with casadi
             */
            void computeJacobianCasADi();
            /**
             * Print to a stream the information of the block
             * @param A std::ostream
             * @param An optional flag to include details in the output
             */
            void printBlock(std::ostream& out, bool withData=false) const;

            /**
             * Check if the block is simple block. A simple block has only one equation.
             * @return A boolean
             */
            bool isSimple() const;
            /**
             * Check if the block is linear block.
             * @return A boolean
             */
            bool isLinear() const;
            /**
             * Check if the block is Solvable block.
             * @return A boolean
             */
            bool isSolvable() const;
            void setasSimple(bool flag){simple_flag=flag;}
            void setasLinear(bool flag){linear_flag=flag;}
            void setasSolvable(bool flag){solve_flag=flag;}

            //Requires the jacobian to be computed in beforehand
            /**
             * Solve the a linear system symbolically with casadi.
             * The Jacobian must have been set in beforehand
             */
            void solveLinearSystem();
            /**
             * Make substitutions in Block equations.
             * Only external variables of the block are substituted.
             */
            void substitute(const std::map<const Variable*, casadi::MX>& mapVariableToExpression);
            /*******************************************/

            MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
            private:

            /// Vector containing block's equations
            std::vector< Ref<Equation> > equations;
            /// Vector containing block's unsolved equations
            std::vector< Ref<Equation> > unSolvedEquations;

            /// Vector containing pointers to block solved variables
            std::set< const Variable* > variables_;
            /// Vector containing pointers to block unsolved variables
            std::set< const Variable* > unSolvedVariables_;
            ///External variables
            std::set< const Variable* > externalVariables_;

            /// Map with solution of variables
            std::map< const Variable* ,casadi::MX> variableToSolution_;

            /// Map with variable names to index for jacobian computation
            std::map<const Variable*,int> variableToIndex_;
            void addIndexToVariable(const Variable* var);

            ///The jacobian
            casadi::MX jacobian;
            ///For handling casadi operations
            casadi::MX symbolicVariables;
            

            ///Simple flag
            bool simple_flag;
            bool linear_flag;
            bool solve_flag;

    };

    inline bool Block::isSimple() const {return simple_flag;}
    inline bool Block::isLinear() const {return linear_flag;}
    inline bool Block::isSolvable() const {return solve_flag;}

    inline void Block::addVariable(const Variable* var, bool solvable) {
        addIndexToVariable(var);
        variables_.insert(var);
        if(!solvable){unSolvedVariables_.insert(var);}
    }

    inline void Block::addExternalVariable(const Variable* var){externalVariables_.insert(var);}

    inline void Block::addSolutionToVariable(const Variable* var, casadi::MX sol) {
        std::map< const Variable* ,casadi::MX>::iterator it =variableToSolution_.find(var);
        if(it==variableToSolution_.end()) {
            variableToSolution_.insert(std::pair<const Variable*, casadi::MX>(var,sol));
        }
        else {
            std::cout<<"Warning: The variable "<<(it->first)->getVar()<<" has already a solution "<<it->second;
        }
    }

    inline bool Block::removeSolutionOfVariable(const Variable* var) {
        std::map< const Variable* ,casadi::MX>::iterator it =variableToSolution_.find(var);
        if(it!=variableToSolution_.end()) {
            variableToSolution_.erase(it);
            return 1;
        }
        return 0;
    }

    inline std::map<const Variable*, casadi::MX> Block::getSolutionMap() const
    {
        return std::map<const Variable*, casadi::MX>(variableToSolution_);
    }

    inline bool Block::hasSolution(const Variable* var) const
    {
        std::map<const Variable*, casadi::MX>::const_iterator it = variableToSolution_.find(var);
        return ((it!=variableToSolution_.end()) ? 1 : 0);
    }

    inline const std::set< const Variable* >& Block::variables() const
    {
        return variables_;
    }

    inline const std::set< const Variable* >& Block::unsolvedVariables() const
    {
        return unSolvedVariables_;
    }

    inline const std::set< const Variable* >& Block::externalVariables() const
    {
        return externalVariables_;
    }

    inline bool Block::isExternal(const Variable* var) const
    {
        std::set< const Variable* >::iterator it = externalVariables_.find(var);
        if(it!=externalVariables_.end()){return 1;}
        else{return 0;}
    }

    inline bool Block::isBlockVariable(const Variable* var) const
    {
        std::set< const Variable* >::iterator it = variables_.find(var);
        if(it!=variables_.end()){return 1;}
        else{return 0;}
    }

    inline std::vector< casadi::MX > Block::variablesVector() const
    {
        std::vector< casadi::MX > vars;
        for (std::set<const Variable*>::const_iterator it = variables_.begin();
        it != variables_.end(); ++it) {
            vars.push_back((*it)->getVar());
        }
        return vars;
    }

    inline std::vector< Ref<Equation> > Block::allEquations() const
    {
        return std::vector< Ref<Equation> >(equations);
    }

    inline std::vector< Ref<Equation> > Block::notSolvedEquations() const
    {
        return std::vector< Ref<Equation> >(unSolvedEquations);
    }

    inline int Block::getVariableIndex(const Variable* var) {
        std::map<const Variable*,int>::iterator it = variableToIndex_.find(var);
        if(it!=variableToIndex_.end()) {
            return it->second;
        }
        else {
            //To change later
            std::cout<<"The variable was not found returning -1\n";
            return -1;
        }
    }

    inline void Block::addIndexToVariable(const Variable* var) {
        std::set<const Variable*>::iterator it = variables_.find(var);
        if(it==variables_.end()) {
            variableToIndex_.insert(std::pair<const Variable*, int>(var,variables_.size()));
        }
    }

    inline casadi::MX Block::getSolutionOfVariable(const Variable* var) const
    {
        std::map<const Variable*,casadi::MX>::const_iterator it = variableToSolution_.find(var);
        if(it!=variableToSolution_.end()) {
            return it->second;
        }
        else {
            // Returns empty variable (check nonEmpty at substitutions)
            return casadi::MX();
        }
    }

}; // End namespace
#endif
