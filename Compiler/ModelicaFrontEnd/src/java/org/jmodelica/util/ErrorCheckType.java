/*
    Copyright (C) 2015 Modelon AB

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
package org.jmodelica.util;

public enum ErrorCheckType {
    /** Used when compiling a model. */
    COMPILE,
    /** Used when doing an error check on a model that does not have to be a 
     *  simulation model. */
    CHECK,
    /** Used to invoke the parts of the error check that has side effects 
     *  (e.g. for structural parameters) on generated components. */
    GENERATED;

    public boolean allowBadGeneratedInner() {
        return this == CHECK;
    }

    public boolean allowConstantNoValue() {
        return this == CHECK;
    }

    public boolean allowIncompleteSizes() {
        return this == CHECK;
    }

    public boolean allowIncompleteReplaceableFunc() {
        return this == CHECK;
    }

    public boolean allowExternalObjectMissingBindingExpression() {
        return this == CHECK;
    }

    public boolean checkInactiveComponents() {
        return this == CHECK;
    }

    public boolean allowUnspecifiedEnums() {
        return this == CHECK;
    }

    public boolean checkForRecursiveStructure() {
        return this != GENERATED;
    }

    public boolean checkTypes() {
        return this != GENERATED;
    }
}
