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

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;

public class NullStream {
	
	public static final OutputStream OUTPUT = new OutputStream() {
		@Override
        public void write(int b) throws IOException {
		    // ignore - NullStream
		}

		@Override
        public void write(byte[] b) throws IOException {
            // ignore - NullStream
		}

		@Override
        public void write(byte[] b, int off, int len) throws IOException {
            // ignore - NullStream
		}
	};

	public static final PrintStream PRINT = new PrintStream(OUTPUT);
	
	public static final InputStream INPUT = new InputStream() {
		@Override
        public int read() throws IOException {
			return -1;
		}
	};

}
