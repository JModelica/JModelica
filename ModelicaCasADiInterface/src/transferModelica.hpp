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

#ifndef TRANSFER_MODELICA
#define TRANSFER_MODELICA

#include <vector>
#include <string>

// Most of the transfer functionality lies here, shared with transferOptimica
// and implemented with templates.
#include "sharedTransferFunctionality.hpp"

// The ModelicaCasADiModel
#include "Ref.hpp"
#include "Model.hpp"
#include "CompilerOptionsWrapper.hpp"

#include "OptimizationProblem.hpp"
namespace ModelicaCasADi {

void transferModelFromModelicaCompiler(Ref<Model> m, 
                           std::string modelName, 
                           const std::vector<std::string> &modelFiles,
                           Ref<ModelicaOptionsWrapper> options, 
                           std::string log_level);
                           
void transferModelFromOptimicaCompiler(Ref<Model> m,
                           std::string modelName, 
                           const std::vector<std::string> &modelFiles, 
                           Ref<OptimicaOptionsWrapper> options, 
                           std::string log_level);
                           
                           

}; // End namespace

#endif
