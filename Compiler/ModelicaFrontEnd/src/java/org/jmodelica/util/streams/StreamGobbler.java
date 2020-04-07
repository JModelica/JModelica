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

public class StreamGobbler extends Thread {
	private InputStream is;
    private OutputStream os;
    
    public StreamGobbler(InputStream is) {
        this(is, NullStream.OUTPUT);
    }
    
    public StreamGobbler(InputStream is, OutputStream redirect) {
        this.is = is;
        this.os = redirect;
    }
    
    @Override
    public void run() {
        try {
        	try {
        		// Write to output as soon as data is available.
				byte[] b = new byte[128];
				int n;
				while ((n = is.read(b, 0, 1)) > 0) {
					int m = is.available();
					if (m > b.length - 1)
						m = b.length - 1;
					n += is.read(b, 1, m);
					os.write(b, 0, n);
				}
				os.flush();
	        } finally {
	        	is.close();
	        }
        } catch (IOException ioe) {
            // TODO need to take action here?
        }
    }
}
