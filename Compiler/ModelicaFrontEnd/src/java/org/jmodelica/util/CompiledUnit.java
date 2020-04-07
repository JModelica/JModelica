/*
    Copyright (C) 2015-2017 Modelon AB

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

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;

import org.jmodelica.api.problemHandling.Problem;
import org.jmodelica.util.logging.Level;
import org.jmodelica.util.logging.XMLLogger;
import org.jmodelica.util.logging.units.LoggingUnit;

/**
 * Contains information about the generated result of the compilation.
 */
public class CompiledUnit implements LoggingUnit {

    /**
     * Serial version UID.
     */
    private static final long serialVersionUID = 2L;

    private Collection<Problem> warnings = Collections.<Problem> emptyList();
    private final File fmu;
    private final int numberOfComponents;

    /**
     * Construct a compiled unit representing the artifacts produced by a compilation process.
     * 
     * @param fmu                   the file object pointing to the produced FMU.
     * @param numberOfComponents    the number of components in the compiled unit.
     * @deprecated                  use {@link #CompiledUnit(File, Collection, int)} instead.
     */
    @Deprecated
    public CompiledUnit(File fmu, int numberOfComponents) {
        this(fmu, Collections.<Problem> emptyList(), numberOfComponents);
    }

    /**
     * Construct a compiled unit representing the artifacts produced by a compilation process.
     * 
     * @param fmu                   the file object pointing to the produced FMU.
     * @param warnings              the warnings generated during the compilation.
     * @param numberOfComponents    the number of components in the compiled unit.
     */
    public CompiledUnit(File fmu, Collection<Problem> warnings, int numberOfComponents) {
        this.fmu = fmu;
        this.warnings = new ArrayList<Problem>(warnings);
        this.numberOfComponents = numberOfComponents;
    }

    /**
     * Get the file object pointing to the generated file.
     * 
     * @return  the path to the FMU.
     */
    public File fmu() {
        return fmu;
    }

    /**
     * Retrieve the number of components produced by the compilation.
     * 
     * @return  the number of components produced by the compilation.
     */
    public int getNumberOfComponents() {
        return numberOfComponents;
    }

    /**
     * Retrieve the warnings generated during the compilation.
     * 
     * @return  the warnings generated during the compilation.
     */
    public Iterable<Problem> warnings() {
        return new Iterable<Problem>() {

            @SuppressWarnings("synthetic-access")
            @Override
            public Iterator<Problem> iterator() {
                return warnings.iterator();
            }
        };
    }

    @Override
    public String toString() {
        return fmu.toString();
    }

    @Override
    public String print(Level level) {
        return "";
    }

    @Override
    public String printXML(Level level) {
        return XMLLogger.write_node("CompilationUnit", "file", toString());
    }
}
