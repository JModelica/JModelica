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

#include "FlatEquations.hpp"

namespace ModelicaCasADi
{
    const casadi::MX FlatEquations::getDaeResidual() const
    {
        casadi::MX daeRes;
        for (std::vector< Ref<Equation> >::const_iterator it = daeEquations.begin(); it != daeEquations.end(); ++it) {
            daeRes.append((*it)->getResidual());
        }
        return daeRes;
    }

    void FlatEquations::addDaeEquation(Ref<Equation>eq) { daeEquations.push_back(eq); }

    std::vector< Ref< Equation> > FlatEquations::getDaeEquations() const { return daeEquations; }
}; //End namespace
