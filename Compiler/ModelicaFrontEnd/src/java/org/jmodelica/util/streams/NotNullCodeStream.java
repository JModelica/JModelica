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

import java.io.OutputStream;
import java.io.PrintStream;

public class NotNullCodeStream extends CodeStream {

    public NotNullCodeStream(PrintStream out) {
        super(out);
    }

    public NotNullCodeStream(OutputStream out) {
        super(out);
    }

    public NotNullCodeStream(CodeStream parent) {
        super(parent);
    }

    @Override
    public void print(String s) {
        if (s == null)
            throw new NullPointerException();
        super.print(s);
    }

    @Override
    public void print(Object o) {
        if (o == null)
            throw new NullPointerException();
        super.print(o);
    }

    @Override
    public void format(String format, Object... args) {
        for (Object obj : args)
            if (obj == null)
                throw new NullPointerException();
        super.format(format, args);
    }

}
