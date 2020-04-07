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

#ifndef _MODELICACASADI_OPTIMIZATIONPROBLEM
#define _MODELICACASADI_OPTIMIZATIONPROBLEM
#include <iostream>
#include <vector>

#include "casadi/casadi.hpp"

#include "Model.hpp"
#include "Constraint.hpp"
#include "SharedNode.hpp"
#include "TimedVariable.hpp"
#include "Ref.hpp"
namespace ModelicaCasADi
{
    class OptimizationProblem : public Model
    {
        public:
            /** Create a blank, uninitialized OptimizationProblem */
            OptimizationProblem() { normalizedTime = false; startTime = finalTime = objective = objectiveIntegrand = casadi::MX(0);call_count_eliminations=0;}
            virtual ~OptimizationProblem();
            /**
             * Initialize the OptimizationProblem, before populating it.
             * @param An optional string identifier, default is empty string.
             * @param An option flag telling whether minumum time normalisation
             * has been performed (by the compiler). Default is false.
             */
            void initializeProblem(std::string identifier = "", bool normalizedTime = false);
            /** @return An MX */
            casadi::MX getStartTime() const;
            /** @return An MX */
            casadi::MX getFinalTime() const;
            /** @return A flag telling whether minumum time normalisation has been performed */
            bool getNormalizedTimeFlag() const;
            /**
             * Returns a vector with the path constraints
             * @return A std::vector of Constraint
             */
            std::vector< Ref<Constraint> >  getPathConstraints() const;
            /**
             * Returns a vector with the point constraints
             * @return A std::vector of Constraint
             */
            std::vector< Ref<Constraint> >  getPointConstraints() const;
            /**
             * Returns a vector with the timed variables
             * @return A std::vector of TimedVariable
             */
            std::vector< Ref<TimedVariable> >  getTimedVariables() const;
            /** @return An MX  */
            casadi::MX getObjectiveIntegrand() const;
            /** @return An MX  */
            casadi::MX getObjective() const;
            /** @param An MX  */
            void setStartTime(casadi::MX startTime);
            /** @param An MX  */
            void setFinalTime(casadi::MX finalTime);
            /**
             * Set path constraints
             * @param A vector with constraints
             */
            void setPathConstraints(const std::vector< Ref<Constraint> > &pathConstraints);
            /**
             * Set point constraints
             * @param A vector with constraints
             */
            void setPointConstraints(const std::vector< Ref<Constraint> > &pointConstraints);
            /** @param An MX */
            void setObjectiveIntegrand(casadi::MX objectiveIntegrand);
            /** @param An MX */
            void setObjective(casadi::MX objective);
            /** @param A Ref<TimedVariable> to be added to the optimization problem during transfer*/
            void addTimedVariable(Ref<TimedVariable> timedVariable);

            /** Allows the use of the operator << to print this class to a stream, through Printable */
            virtual void print(std::ostream& os) const;
            /**
             *Subtitute algebraic variables with corresponding BLT symbolic solution in equations.
             *Equations of the form z=f(z) are removed from DAE and variables are marked as eliminated.
             **/
            void eliminateAlgebraics();
            void eliminateVariables();
            /**
             *Make substitutions off all symbolic solutions of BLT in model equations.
             *Equations of the form z=f(z) are not removed as in the case of variable elimination.
             **/
            void substituteAllEliminables();
            
            /**
             * Transfers the equation container to the model. It can be FlatEquations or BLT
             * @Param Equations
             **/
            virtual void setEquations(Ref<Equations> eqCont);

            /**
             * Append a variable to the list of variables to eliminate
             * @Param Variable
             **/
            void markVariablesForElimination(Ref<Variable> var);
            /**
             * Append a variable to the list of variables to eliminate
             * @Param std::vector of Variable
             **/
            void markVariablesForElimination(const std::vector< Ref<Variable> >& vars);

            void printPyomoModel(const std::string& modelName = "model");


            MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
            private:
            casadi::MX startTime;/// Start time can be an expression
            casadi::MX finalTime;/// Final time can be an expression
            casadi::MX objectiveIntegrand;
            casadi::MX objective;
            bool normalizedTime;
            std::vector< TimedVariable * > timedVariables;
            std::vector< Ref<Constraint> >  pathConstraints;
            std::vector< Ref<Constraint> >  pointConstraints;
            
            /**
            * Mark variables as eliminables after transfering BLT
            **/
            void setEliminableVariables();
    };
    inline casadi::MX OptimizationProblem::getStartTime() const { return startTime; }
    inline casadi::MX OptimizationProblem::getFinalTime() const { return finalTime; }
    inline bool OptimizationProblem::getNormalizedTimeFlag() const { return normalizedTime; }
    inline casadi::MX OptimizationProblem::getObjectiveIntegrand() const { return objectiveIntegrand; }
    inline casadi::MX OptimizationProblem::getObjective() const { return objective; }
    inline std::vector< Ref<Constraint> >  OptimizationProblem::getPathConstraints() const { return pathConstraints; }
    inline std::vector< Ref<Constraint> >  OptimizationProblem::getPointConstraints() const { return pointConstraints; }

    inline void OptimizationProblem::setStartTime(casadi::MX startTime) { this->startTime = startTime; }
    inline void OptimizationProblem::setFinalTime(casadi::MX finalTime) { this->finalTime = finalTime; }
    inline void OptimizationProblem::setPathConstraints(const std::vector< Ref<Constraint> > &pathConstraints) { this->pathConstraints = pathConstraints; }
    inline void OptimizationProblem::setPointConstraints(const std::vector< Ref<Constraint> > &pointConstraints) { this->pointConstraints = pointConstraints; }
    inline void OptimizationProblem::setObjectiveIntegrand(casadi::MX objectiveIntegrand) { this->objectiveIntegrand = objectiveIntegrand; }
    inline void OptimizationProblem::setObjective(casadi::MX objective) { this->objective = objective; }
    inline void OptimizationProblem::addTimedVariable(Ref<TimedVariable> var) { assert(var->isOwnedBy(this)); timedVariables.push_back(var.getNode()); }

}; // End namespace
#endif
