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

#include "Variable.hpp"
#include "Model.hpp"


using std::ostream; using casadi::MX;
namespace ModelicaCasADi 
{
Variable::Variable(Model *owner) : negated(false), eliminable(false), eliminated(false), tearing(false), OwnedNode(owner) {
    var = MX();
    myModelVariable = Ref<Variable>(NULL);
    declaredType = Ref<VariableType>(NULL);
}

Variable::Variable(Model *owner, MX var, Variable::Causality causality, 
                   Variable::Variability variability,
                   Ref<VariableType> declaredType /* Ref<VariableType>() */) : 
  causality(causality), variability(variability), negated(false), eliminable(false), eliminated(false), tearing(false), OwnedNode(owner) {
    if (var.isConstant()) {
        throw std::runtime_error("A variable must have a symbolic MX");
    }
    myModelVariable = Ref<Variable>(NULL);
    this->var = var;
    this->declaredType = declaredType;
}



void Variable::setQuantity(std::string quantity) { setAttribute("quantity", MX::sym(quantity)); }
void Variable::setQuantity(casadi::MX quantity) { setAttribute("quantity", quantity); }
casadi::MX* Variable::getQuantity() { return getAttribute("quantity"); }

void Variable::setNominal(double nominal) { setAttribute("nominal", MX(nominal)); }
void Variable::setNominal(casadi::MX nominal) { setAttribute("nominal", nominal); }
casadi::MX* Variable::getNominal() { return getAttribute("nominal"); }

void Variable::setUnit(std::string unit) { setAttribute("unit", MX::sym(unit)); }
void Variable::setUnit(casadi::MX unit) { setAttribute("unit", unit); }
casadi::MX* Variable::getUnit() { return getAttribute("unit"); }

void Variable::setDisplayUnit(std::string displayUnit) { setAttribute("displayUnit", MX::sym(displayUnit)); }
void Variable::setDisplayUnit(casadi::MX displayUnit) { setAttribute("displayUnit", displayUnit); }
casadi::MX* Variable::getDisplayUnit() { return getAttribute("displayUnit"); }

void Variable::setMin(double min) { setAttribute("min", MX(min)); }
void Variable::setMin(casadi::MX min) { setAttribute("min", min); }
casadi::MX* Variable::getMin() { return getAttribute("min"); }

void Variable::setMax(double max) { setAttribute("max", MX(max)); }
void Variable::setMax(casadi::MX max) { setAttribute("max", max); }
casadi::MX* Variable::getMax() { return getAttribute("max"); }

void Variable::setStart(double start) { setAttribute("start", MX(start)); }
void Variable::setStart(casadi::MX start) { setAttribute("start", start); }
casadi::MX* Variable::getStart() { return getAttribute("start"); }

void Variable::setFixed(bool fixed) { setAttribute("fixed", MX(fixed)); }
void Variable::setFixed(casadi::MX fixed) { setAttribute("fixed", fixed); }
casadi::MX* Variable::getFixed() { return getAttribute("fixed"); }




Variable::AttributeValue* Variable::getAttribute(AttributeKey key) { 
    if (isAlias()) {
        return getAttributeForAlias(key);
    } else {
        return hasAttributeSet(key) ? &attributes.find(AttributeKeyInternal(key))->second :
                                  (declaredType != Ref<VariableType>(NULL) ? declaredType->getAttribute(key) : NULL);
    }
}

bool Variable::hasAttributeSet(AttributeKey key) const { 
    if (isAlias()) {
        return myModelVariable->hasAttributeSet(key);
    } else {
        return attributes.find(AttributeKeyInternal(key)) != attributes.end(); 
    }
}

bool isNegatedAttributeKey(Variable::AttributeKey key) {
    return key == "start" || key == "min" || key == "max" || key == "nominal" ||
           key == "bindingExpression" || key == "evaluatedBindingExpression";
}

/// Assumes that this is an alias, and that the attribute should be retrieved from
/// the alias variable. 
Variable::AttributeValue* Variable::getAttributeForAlias(AttributeKey key) {
    AttributeValue* val = myModelVariable->getAttribute(keyForAlias(key)); // Note that keyForAlias can change key for min/max. 
    if (val == NULL) return val;
    if (isNegated() && isNegatedAttributeKey(key)) {
        val = new MX(val->operator-());
    }
    return val;
}

/// Helper method for handling of alias variables. Assumes that this is an alias.
/// The attributes min and max needs to be interchanged for negated alias variables. 
Variable::AttributeKey Variable::keyForAlias(AttributeKey key)  const{
    if (isNegated()) {
        if (key == "min") {
            key = "max";
        } else if (key == "max") {
            key = "min";
        }
    }
    return key;
}

/// Assumes that this is an alias, and propagates the attribute to its alias variable.
void Variable::setAttributeForAlias(AttributeKey key, AttributeValue val) {
    if (isNegated() && isNegatedAttributeKey(key)) {
        key = keyForAlias(key);
        val = -val;
    }
    myModelVariable->setAttribute(key, val);
}

void Variable::setAttribute(AttributeKey key, AttributeValue val) { 
    if (key == "bindingExpression") {
        myModel().setDirty();
        if (hasAttributeSet("bindingExpression")) {
            MX bindingExpression = *getAttribute(key);
            if (bindingExpression.isConstant() && (!val.isConstant())) {
                throw std::runtime_error("It is not allowed to make independent parameters dependent");
            } else if (!bindingExpression.isConstant()) {
                throw std::runtime_error("It is not allowed to change binding expression of dependent parameters");
            }
        }
    }
    
    if (isAlias()) {
        setAttributeForAlias(key, val);
    } else {
        attributes[AttributeKeyInternal(key)]=val; 
    }
}
void Variable::setAttribute(AttributeKey key, double val) { 
    setAttribute(key, MX(val));
}


void Variable::print(ostream& os) const {
    os << (getCausality() == INPUT ? "input " : (getCausality() == OUTPUT ? "output " : "" ));
    os << (getVariability() == CONTINUOUS ? "" : (getVariability() == DISCRETE ? "discrete " : (getVariability() == PARAMETER ? "parameter " : 
           (getVariability() == CONSTANT ? "constant " : (getVariability() == TIMED ? "constant " : "")))));
    if (declaredType != Ref<VariableType>(NULL)) {
        os << declaredType->getName() << " ";
    } else {
        os << (getType() == REAL ? "Real " : (getType() == INTEGER ? "Integer " : (getType() == BOOLEAN ? "Boolean " : 
              (getType() == STRING ? "String " : ""))));
    }
    os<<ModelicaCasADi::normalizeMXRespresentation(var);
    if (!attributes.empty() || isAlias()) {
        std::string sep = "";
        os <<"(";
        for (attributeMap::const_iterator it = attributes.begin(); it != attributes.end(); ++it) {
            os << sep <<it->first<<" = ";
            //(it->second).print(os);
            os<<ModelicaCasADi::normalizeMXRespresentation(it->second);
            sep = ", ";
        }
        if (isAlias()) {
            os << sep << "alias: " <<  myModelVariable->getName();
        }
        os << ")";
    }
    if (attributes.find(AttributeKeyInternal("bindingExpression")) != attributes.end()) { 
        os << " = ";
        os<<ModelicaCasADi::normalizeMXRespresentation((attributes.find(AttributeKeyInternal("bindingExpression"))->second));
    } 
    if (attributes.find(AttributeKeyInternal("comment")) != attributes.end()) { 
        os << " \"";
        os<<ModelicaCasADi::normalizeMXRespresentation((attributes.find(AttributeKeyInternal("comment"))->second));
        os << "\"";
    }
    if (attributes.find(AttributeKeyInternal("bindingExpression")) != attributes.end()) {
        if (attributes.find(AttributeKeyInternal("bindingExpression"))->second.isConstant()) {
            os << " /* ";
            os<<ModelicaCasADi::normalizeMXRespresentation((attributes.find(AttributeKeyInternal("bindingExpression"))->second));
            os << " */";
        } else if (attributes.find(AttributeKeyInternal("evaluatedBindingExpression")) != attributes.end()) {
            os << "/* ";
            os<<ModelicaCasADi::normalizeMXRespresentation((attributes.find(AttributeKeyInternal("evaluatedBindingExpression"))->second));
            os << " */";
        }
    } 
    os << ";";
}
const Variable::Type Variable::getType() const { throw std::runtime_error("Variable does not have a type"); }
}; // End namespace
