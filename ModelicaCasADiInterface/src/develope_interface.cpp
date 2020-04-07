#include <iostream>
#include <string>
#include <vector>
#include <stdlib.h>

#include "Ref.hpp"
#include "CompilerOptionsWrapper.hpp"
#include "sharedTransferFunctionality.hpp"
#include "casadi/casadi.hpp"

#include "transferModelica.hpp"
#include "transferOptimica.hpp"

#include "OptimizationProblem.hpp"
#include "Model.hpp"

#include "Block.hpp"
#include "Equation.hpp"
#include <algorithm>

#include "Equations.hpp"
#include "FlatEquations.hpp"
#include "BLT.hpp"

namespace mc = org::jmodelica::modelica::compiler;
namespace jl = java::lang;
using org::jmodelica::util::OptionRegistry;


int main(int argc, char ** argv)
{
  int with_blt=0;
  if(argc>1){
    with_blt=atoi(argv[1]);
  }
   //Class
   //std::string modelName("BLTExample");
   //std::string modelName("CombinedCycle.Substances.Gas");
   //std::string modelName("Modelica.Mechanics.Rotational.Examples.CoupledClutches");
   std::string modelName("VDP_pack.VDP_Opt");
   //Files
   std::vector<std::string> modelFiles;
   modelFiles.push_back("VDP.mop");
   //modelFiles.push_back("./example_blt.mo");
   //modelFiles.push_back("./CombinedCycle.mo");   
   //modelFiles.push_back("./MSL/Modelica");
   //modelFiles.push_back("./MSL/ModelicaServices");
   
   std::string log_level = "warning";

   // Start java vitual machine  
   setUpJVM();
   {
      //OptionWrapper
      ModelicaCasADi::Ref<ModelicaCasADi::ModelicaOptionsWrapper> options = new ModelicaCasADi::ModelicaOptionsWrapper();
      options->setStringOption("inline_functions", "none");
      options->setBooleanOption("automatic_tearing", false); //disable tearing
      options->setBooleanOption("equation_sorting", true); //Enables blt
      options->setBooleanOption("generate_runtime_option_parameters", false); // avoid compiler variables generation      
      
      
      //Model
      ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> model = new ModelicaCasADi::OptimizationProblem();
      ModelicaCasADi::transferOptimizationProblem(model, 
        modelName, 
        modelFiles,
        options, 
        log_level);
      
      //casadi::MX x = casadi::MX::sym("x");
      //casadi::MX y = x+1;
      //std::cout<<"Not normalized "<<y<<"\n";
      //std::cout<<"Normalized "<<ModelicaCasADi::normalizeMXRespresentation(y)<<"\n";
      //model->print(std::cout);
      model->printPyomoModel("model");
      //model->printBLT(std::cout,true);
      //ModelicaCasADi::Ref<ModelicaCasADi::Block> b = model->getBlock(0);
      //b->printBlock(std::cout,true);
      //b->solveLinearSystem();
      //model->printBLT(std::cout,true);
      //b->printBlock(std::cout,true);
      
      /*std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Variable> > eliminables = model->getEliminableVariables();
      
      for(std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Variable> >::const_iterator it=eliminables.begin();
            it!=eliminables.end();++it){
            std::cout<<(*it)->getName()<<" ";      
      }
      
      
      
      //model->eliminateAlgebraics();
      std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Variable> > algebraics = model->getVariables(ModelicaCasADi::Model::REAL_ALGEBRAIC);
      model->markVariablesForElimination(algebraics);
      
      model->print(std::cout);
      
      model->eliminateVariables();
      
      model->print(std::cout);*/
      
      /*std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Variable> > eliminated = model->getEliminatedVariables();
      std::cout<<std::endl;
      model->print(std::cout);      
      model->substituteAllEliminateables();
      model->print(std::cout);*/  
      

   }
   tearDownJVM();
   std::cout<<"DONE\n";  
   return 0;
}
