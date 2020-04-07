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
package net.sf.antcontrib.walls;

import java.io.File;

import org.apache.tools.ant.Project;
import org.xml.sax.*;


/**
 * Handler for the root element. Its only child must be the "project" element.
 */
class WallsFileHandler extends HandlerBase {

    private final CompileWithWalls compilewithwalls;
    private File file = null;
    private Walls walls = null;
    private Locator locator = null;

    /**
     * @param CompileWithWalls
     */
    WallsFileHandler(CompileWithWalls walls, File file) {
        this.compilewithwalls = walls;
        this.file = file;
    }
        
    /**
     * Resolves file: URIs relative to the build file.
     *
     * @param publicId The public identifer, or <code>null</code>
     *                 if none is available. Ignored in this
     *                 implementation.
     * @param systemId The system identifier provided in the XML
     *                 document. Will not be <code>null</code>.
     */
    public InputSource resolveEntity(String publicId,
                                     String systemId) {
         compilewithwalls.log("publicId="+publicId+" systemId="+systemId,
             Project.MSG_VERBOSE);            
        return null;
    }

    /**
     * Handles the start of a project element. A project handler is created
     * and initialised with the element name and attributes.
     *
     * @param tag The name of the element being started.
     *            Will not be <code>null</code>.
     * @param attrs Attributes of the element being started.
     *              Will not be <code>null</code>.
     *
     * @exception SAXParseException if the tag given is not
     *                              <code>"project"</code>
     */
    public void startElement(String name, AttributeList attrs) throws SAXParseException {
        if (name.equals("walls")) {
            if(attrs.getLength() > 0)
                throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +", no attributes allowed for walls element", locator);
            walls = this.compilewithwalls.createWalls();
        } else if (name.equals("package")) {
            handlePackage(attrs);
        } else {
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                +", Unexpected element \"" + name + "\"", locator);
        }
    }

    private void handlePackage(AttributeList attrs) throws SAXParseException {
        if(walls == null)
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                +", package element must be nested in a walls element", locator);
        
        String name = attrs.getValue("name");
        String thePackage = attrs.getValue("package");
        String depends = attrs.getValue("depends");
        if(name == null)
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                            +", package element must contain the 'name' attribute", locator);
        else if(thePackage == null)
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                            +", package element must contain the 'package' attribute", locator);

        Package p = new Package();
        p.setName(name);
        p.setPackage(thePackage);
        if(depends != null)
            p.setDepends(depends);
        
        walls.addConfiguredPackage(p);
    }
    /**
     * Sets the locator in the project helper for future reference.
     *
     * @param locator The locator used by the parser.
     *                Will not be <code>null</code>.
     */
    public void setDocumentLocator(Locator locator) {
        this.locator = locator;
    }
}