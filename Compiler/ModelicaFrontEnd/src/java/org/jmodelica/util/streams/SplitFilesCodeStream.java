/*
    Copyright (C) 2016 Modelon AB

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

import java.io.File;
import java.util.ArrayList;

public class SplitFilesCodeStream extends CodeStream {
    private File file;
    private boolean debugGen;
    private int i = 0;
    private String header;
    private ArrayList<File> files;
    
    public SplitFilesCodeStream(File file, boolean debugGen, String header) {
        super((CodeStream) null);
        this.file = file;
        this.debugGen = debugGen;
        this.header = header;
        files = new ArrayList<>();
        switchParent(nextFileStream());
    }
    
    @Override
    public void splitFile() {
        switchParent(nextFileStream());
        print(header);
    }
    
    protected CodeStream nextFileStream() {
        File nextFile = nextFile();
        files.add(nextFile);
        return createCodeStream(nextFile);
    }

    protected File nextFile() {
        String path = file.getPath();
        if (i > 0) {
            path = path.replaceAll(".[^.]+$", "_" + i + "$0");
        }
        i++;
        return new File(path);
    }

    protected NotNullCodeStream createCodeStream(File nextFile) {
        return new NotNullCodeStream(createPrintStream(nextFile, debugGen));
    }

    /**
     * All files from this used by this code stream including the original file.
     */
    public Iterable<File> files() {
        return files;
    }

}
