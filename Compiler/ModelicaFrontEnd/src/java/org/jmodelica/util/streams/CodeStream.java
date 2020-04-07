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
package org.jmodelica.util.streams;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.Collection;

public class CodeStream {

    protected PrintStream out;
    protected CodeStream parent;
    protected String lineEnder = "\n";

    public CodeStream(PrintStream ps) {
        this.out = ps;
    }

    public CodeStream(CodeStream parent) {
        this.parent = parent;
    }

    public CodeStream(OutputStream os) {
        this(new PrintStream(os));
    }

    public CodeStream(String file) {
        this(new File(file));
    }

    public CodeStream(File file) {
        this(createPrintStream(file, false));
    }

    public static PrintStream createPrintStream(File file, boolean cloneToSysOut) {
        try {
            return createPrintStream(new BufferedOutputStream(new FileOutputStream(file)),
                    cloneToSysOut ? System.out : null);
        } catch (IOException e) {
            throw new RuntimeException("File I/O problem during code generation", e);
        }
    }

    public static PrintStream createPrintStream(OutputStream os, boolean cloneToSysOut) {
        return createPrintStream(os, cloneToSysOut ? System.out : null);
    }

    public static PrintStream createPrintStream(OutputStream os, PrintStream clone) {
        if (clone != null) {
            os = new CloneOutputStream(os, clone).setClose(true, false);
        }
        try {
            return new PrintStream(os, clone != null, "UTF-8");
        } catch (IOException e) {
            throw new RuntimeException("File I/O problem during code generation", e);
        }
    }

    public void switchParent(CodeStream par) {
        if (parent != null) {
            parent.close();
        }
        parent = par;
    }

    public void close() {
        if (parent != null) {
            parent.close();
            parent = null;
        } else {
            out.close();
            out = null;
        }
    }

    public void print(String s) {
        if (parent != null) {
            parent.print(s);
        } else {
            out.print(s);
        }
    }

    public void format(String format, Object... args) {
        if (parent != null) {
            parent.format(format, args);
        } else {
            out.format(format, args);
        }
    }

    public void splitFile() {
        // No default action
    }

    public void println() {
        print(lineEnder);
    }

    public void print(Object o) {
        print(o.toString());
    }

    public void print(Object... os) {
        for (Object s : os) {
            print(s);
        }
    }

    public void println(String s) {
        print(s);
        println();
    }

    public void println(Object o) {
        print(o);
        println();
    }

    public void println(Object... o) {
        print(o);
        println();
    }


    public void formatln(String format, Object... args) {
        format(format, args);
        println();
    }

    public void print(Collection<? extends Object> collection, String separator) {
        boolean first = true;
        for (Object o : collection) {
            if (!first) {
                print(separator);
            }
            first = false;
            print(o);
        }
    }

    public void setLineEnder(String lineEnder) {
        this.lineEnder = lineEnder;
    }

    public String getLineEnder() {
        return lineEnder;
    }

}