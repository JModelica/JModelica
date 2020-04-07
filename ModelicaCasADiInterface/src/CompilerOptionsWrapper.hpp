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

#ifndef _MODELICACASADI_COMPILER_OPTIONS_WRAPPER
#define _MODELICACASADI_COMPILER_OPTIONS_WRAPPER
#include <string>
#include <iostream>

#include "jni.h"
#include "RefCountedNode.hpp"
#include "org/jmodelica/modelica/compiler/ModelicaCompiler.h"
#include "org/jmodelica/modelica/compiler/generated/OptionRegistry.h"
#include "org/jmodelica/optimica/compiler/ModelicaCompiler.h"
#include "org/jmodelica/optimica/compiler/generated/OptionRegistry.h"

namespace ModelicaCasADi
{
// One wrapper class for each compiler.
// Templating these classes to reduce code duplication does not work well with SWIG.

class ModelicaOptionsWrapper : public RefCountedNode {
    protected:
        org::jmodelica::modelica::compiler::generated::OptionRegistry optr;

    public:
        ModelicaOptionsWrapper() : optr(org::jmodelica::modelica::compiler::ModelicaCompiler::createOptions()) {}
        void setStringOption(std::string opt, std::string val);
        void setBooleanOption(std::string opt, bool val);
        void setIntegerOption(std::string opt, int val);
        void setRealOption(std::string opt, double val);

        bool getBooleanOption(std::string opt);

        void printCompilerOptions(std::ostream& out);
        void printOpts() {printCompilerOptions(std::cout);}

        org::jmodelica::modelica::compiler::generated::OptionRegistry getOptionRegistry() { return optr; }

        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
};

class OptimicaOptionsWrapper : public RefCountedNode {
    protected:
        org::jmodelica::optimica::compiler::generated::OptionRegistry optr;

    public:
        OptimicaOptionsWrapper() : optr(org::jmodelica::optimica::compiler::ModelicaCompiler::createOptions()) {}
        void setStringOption(std::string opt, std::string val);
        void setBooleanOption(std::string opt, bool val);
        void setIntegerOption(std::string opt, int val);
        void setRealOption(std::string opt, double val);

        bool getBooleanOption(std::string opt);

        void printCompilerOptions(std::ostream& out);
        void printOpts() {printCompilerOptions(std::cout);}

        org::jmodelica::optimica::compiler::generated::OptionRegistry getOptionRegistry() { return optr; }

        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
};

}; // End namespace
#endif
