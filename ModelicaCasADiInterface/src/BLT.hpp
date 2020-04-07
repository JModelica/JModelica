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

#ifndef _MODELICACASADI_BLT
#define _MODELICACASADI_BLT

#include <iostream>
#include "casadi/casadi.hpp"
#include "Equation.hpp"
#include "RefCountedNode.hpp"
#include "Block.hpp"
#include "Ref.hpp"
#include "Equations.hpp"
#include <vector>
#include <map>
#include <string>

namespace ModelicaCasADi
{
    class BLT: public Equations
    {
        public:
          //~BLT(){std::cout<<"\nDELETE_BLT\n";}
            /**
             * Check if equations object has a BLT
             * @return A boolean
             */
            virtual bool hasBLT() const;
            /**
             * Give the DAE residual of all equations from BLT.
             * @return An MX
             */
            virtual const casadi::MX getDaeResidual() const;
            /**
             * Give the list of equations from BLT.
             * @return A std::vector of Equation
             */
            std::vector< Ref< Equation> > getDaeEquations() const;

            /** @param A pointer to an equation */
            virtual void addDaeEquation(Ref<Equation> eq);

            /**************BlockMethods*************/
            /**
             * Add a block to BLT
             * @param A pointer to a Block.
             */
            void addBlock(Ref<Block> block);
            /**
             * Gives the number of blocks of BLT
             * @return An Integer.
             */
            int getNumberOfBlocks() const;
            /**
             * Gives the ith block of BLT
             * @param An Integer
             * @return A pointer to a Block.
             */
            Ref<Block> getBlock(int i) const;
            /***************************************/

            /**************AuxiliaryMethods*************/
            /**
             * Print the BLT
             * @param A std::ostream
             * @param A Boolean
             */
            void printBLT(std::ostream& out, bool with_details=false) const;
            /**
             * Give the list of variables that are eliminable according to BLT information.
             * Eliminable variables are those that have solution in the BLT.
             * @return A std::set of Variable
             */
            std::set<const Variable*> eliminableVariables() const;
            /**
             * Fills a map with variable -> solution from BLT information
             * Should not be use for variable elimination because it does not consider order!!
             * @param A std::set of Variable
             * @param A reference to a std::map<Variable,MX> if not empty must have absolut substitution not relative! 
             */
            void getSubstitues(const Variable* eliminable, std::map<const Variable*,casadi::MX>& storageMap) const;
            /**
             * Fills a map with variable -> solution from BLT information
             * Considers order for substitution of variables in expressions. 
             * @param A std::list of pairs <id_block, Variable*>
             * @param A reference to a std::map<Variable,MX> 
             */
            void getSubstitues(const std::list< std::pair<int, const Variable*> >& eliminables, std::map<const Variable*,casadi::MX>& storageMap) const;

            /**
             * Delete the symbolic solution of a variable in the BLT.
             * @param A pointer to a Variable
             */
            void removeSolutionOfVariable(const Variable* var);
            /**
             * Substitute variables to the corresponding mapped expression into equations.
             * @param A std::map<Variable,MX>
             */
            void substitute(const std::map<const Variable*,casadi::MX>& substituteMap);

            /** @param A CasadiInterface variable pointer */
            bool isBLTEliminable(Ref<Variable> var) const;
            /**
             * Substitute variable to the corresponding solution gotten from BLT.
             * After the substitution the solution equation z=f(z) is removed from BLT.
             * @param A std::map of Variable to solution
             */
            void eliminateVariables(const std::map<const Variable*,casadi::MX>& substituteMap);


            ///Return -1 if the variable does not have a solution
            int getBlockIDWithSolutionOf(Ref<Variable> var);
            
            void solveBlocksWithLinearSystems();
            /*******************************************/

            MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
            private:
            std::vector< Ref<Block> > blt;

    };

    inline int BLT::getNumberOfBlocks() const {return blt.size();}

}; // End namespace
#endif
