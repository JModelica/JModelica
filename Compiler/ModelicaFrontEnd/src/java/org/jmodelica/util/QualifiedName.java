/*
    Copyright (C) 2018 Modelon AB

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

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.lang.reflect.Constructor;
import java.util.ArrayList;
import java.util.Iterator;

import org.jmodelica.util.exceptions.NameFormatException;

import beaver.Scanner;
import beaver.Scanner.Exception;
import beaver.Symbol;

/**
 * Handle splitting strings into different parts of a qualified name.
 */
public class QualifiedName implements Iterator<String> {
    private static Constructor<? extends Scanner> scannerConstructor;
    private static int ID_TOKEN_VALUE;
    private static int EOF_TOKEN_VALUE;
    private static int DOT_TOKEN_VALUE;
    
    @SuppressWarnings("unchecked")
    private static void initInternal() {
        try {
            scannerConstructor = ((Class<? extends Scanner>)Class.forName("org.jmodelica.modelica.parser.ModelicaScanner")).getConstructor(Reader.class);
            Class<?> clazz = Class.forName("org.jmodelica.modelica.parser.ModelicaParser$Terminals");
            ID_TOKEN_VALUE = clazz.getField("ID").getInt(null);
            EOF_TOKEN_VALUE = clazz.getField("EOF").getInt(null);
            DOT_TOKEN_VALUE = clazz.getField("DOT").getInt(null);
        } catch (Throwable e) {
            try {
                scannerConstructor = ((Class<? extends Scanner>)Class.forName("org.jmodelica.optimica.parser.ModelicaScanner")).getConstructor(Reader.class);
                Class<?> clazz = Class.forName("org.jmodelica.optimica.parser.ModelicaParser$Terminals");
                ID_TOKEN_VALUE = clazz.getField("ID").getInt(null);
                EOF_TOKEN_VALUE = clazz.getField("EOF").getInt(null);
                DOT_TOKEN_VALUE = clazz.getField("DOT").getInt(null);
            } catch (Throwable e2) {
                // This should never happen; simply throw a RuntimeException.
                throw new RuntimeException("Scanner class not found");
            }
        }
    }
    static {
        initInternal();
    }
    
    private final boolean isGlobal;
    private final ArrayList<String> names;
    private final boolean isUnQualifiedImport;
    private final Iterator<String> iterator;

    public QualifiedName(String name) {
        isUnQualifiedImport = name.endsWith(".*");
        isGlobal = name.startsWith(".");
        names = new ArrayList<>();
        splitQualifiedClassName(name);
        iterator = names.iterator();
    }
    
    private QualifiedName(QualifiedName orginal) {
        isUnQualifiedImport = orginal.isUnQualifiedImport;
        isGlobal = orginal.isGlobal;
        names = orginal.names;
        iterator = names.iterator();
    }
    
    /**
     * Copy this QualifiedName with the iterator reseted.
     * This method does not reparse the name. 
     * @return A copy of this QualifiedName with a new iterator
     */
    public QualifiedName resetedCopy() {
        return new QualifiedName(this);
    }

    // Interpret name as global or not regardless of dot form or not.
    public QualifiedName(String name, boolean isGlobal) {
        isUnQualifiedImport = name.endsWith(".*");
        names = new ArrayList<>();
        splitQualifiedClassName(name); 
        this.isGlobal = isGlobal; // Note: must be set after splitting
        iterator = names.iterator();
    }

    public int numberOfParts() {
        return names.size();
    }
    
    @Override
    public boolean hasNext() {
        return iterator.hasNext();
    }
    
    @Override
    public String next() {
        return iterator.next();
    }
    
    @Override
    public void remove() {
        throw new UnsupportedOperationException("remove");
    }
    
    public String getName(int i) {
        return names.get(i);
    }

    private static Scanner newScanner(String name) {
        try {
            return scannerConstructor.newInstance(new StringReader(name));
        } catch (Throwable e) {
            throw new RuntimeException("Unhandled internal error", e);
        }
    }
    
    /**
     * Checks if the name is a valid and simple (unqualified) identifier.
     * @param name The name.
     * @param allowGlobal If <code>true</code>, then takes 'global' notation with a leading dot into account by 
     * ignoring such a character. 
     * @return Whether or not <code>name</code> is a valid identifier. 
     */
    public static boolean isValidSimpleIdentifier(String name, boolean allowGlobal) {
        if (allowGlobal && name.startsWith(".")) {
            name = name.substring(1, name.length());
        }
        Scanner ms = newScanner(name);

        try {
           if (ms.nextToken().getId() != ID_TOKEN_VALUE) {
               return false;
           }
           if (ms.nextToken().getId() != EOF_TOKEN_VALUE) {
               return false;
           }
           return true;
        } catch (IOException e) {
            // This shouldn't happen when using a StringReader.
            throw nameFormatException(name);
        } catch (Exception e) {
            // Scanner cannot handle this, so this is not a valid identifier.
            return false;
        }
    }

    @Override
    public String toString() {
        return (isGlobal ? "(global) " : "") + (isUnQualifiedImport ? ".* " : "") + names.toString();
    }

    public boolean isGlobal() {
        return isGlobal;
    }
    
    private static NameFormatException nameFormatException(String name) {
        return new NameFormatException(name + " is not a valid qualified name");
    }

    /**
     * Splits a composite class name into all its partial accesses
     */
    private final void splitQualifiedClassName(String name) {
        if (name.length() == 0) {
            throw new NameFormatException("A name must have at least one caracter");
        }
        if (isGlobal || isUnQualifiedImport) {
            int start = isGlobal ? 1 : 0;
            int end = isUnQualifiedImport ? name.length() -2 : name.length(); 
            name = name.substring(start, end);
        }
        Scanner ms = newScanner(name);
        try {
            Symbol sym;
            do {
                sym = ms.nextToken();
                if (sym.getId() != ID_TOKEN_VALUE) {
                    throw nameFormatException(name);
                }
                names.add((String)sym.value);
            } while ((sym = ms.nextToken()).getId() == DOT_TOKEN_VALUE);
            if (sym.getId() != EOF_TOKEN_VALUE) {
                throw nameFormatException(name);
            }
        } catch (Exception | IOException e) {
            // beaver.Scanner.Exception means invalid name, whereas IOException should never happen with a StringReader.
            throw nameFormatException(name);
        }
    }
}
