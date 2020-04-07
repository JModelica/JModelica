/*
 * Copyright (c) 2001-2004 Ant-Contrib project.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package net.sf.antcontrib.property;

import java.io.File;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;
import org.apache.tools.ant.util.FileUtils;

public class PathToFileSet
    extends Task
{
    private File dir;
    private String name;
    private String pathRefId;
    private boolean ignoreNonRelative = false;

    private static FileUtils fileUtils = FileUtils.newFileUtils();

    public void setDir(File dir) {
        this.dir = dir;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setPathRefId(String pathRefId) {
        this.pathRefId = pathRefId;
    }

    public void setIgnoreNonRelative(boolean ignoreNonRelative) {
        this.ignoreNonRelative = ignoreNonRelative;
    }

    public void execute() {
        if (dir == null)
            throw new BuildException("missing dir");
        if (name == null)
            throw new BuildException("missing name");
        if (pathRefId == null)
            throw new BuildException("missing pathrefid");

        if (! dir.isDirectory())
            throw new BuildException(
                dir.toString() + " is not a directory");

        Object path =  getProject().getReference(pathRefId);
        if (path == null)
            throw new BuildException("Unknown reference " + pathRefId);
        if (! (path instanceof Path))
            throw new BuildException(pathRefId + " is not a path");
        

        String[] sources = ((Path) path).list();

        FileSet fileSet = new FileSet();
        fileSet.setProject(getProject());
        fileSet.setDir(dir);
        String dirNormal =
            fileUtils.normalize(dir.getAbsolutePath()).getAbsolutePath();
        if (! dirNormal.endsWith(File.separator)) {
            dirNormal += File.separator;
        }


        boolean atLeastOne = false;
        for (int i = 0; i < sources.length; ++i) {
            File sourceFile = new File(sources[i]);
            if (! sourceFile.exists())
                continue;
            String relativeName = getRelativeName(dirNormal, sourceFile);
            if (relativeName == null && !ignoreNonRelative) {
                throw new BuildException(
                    sources[i] + " is not relative to " + dir.getAbsolutePath());
            }
            if (relativeName == null)
                continue;
            fileSet.createInclude().setName(relativeName);
            atLeastOne = true;
        }

        if (! atLeastOne) {
            // need to make an empty fileset
            fileSet.createInclude().setName("a:b:c:d//THis si &&& not a file  !!! ");
        }
        getProject().addReference(name, fileSet);
    }

    private String getRelativeName(String dirNormal, File file) {
        String fileNormal =
            fileUtils.normalize(file.getAbsolutePath()).getAbsolutePath();
        if (! fileNormal.startsWith(dirNormal))
            return null;
        return fileNormal.substring(dirNormal.length());
    }
}

