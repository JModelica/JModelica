/*
 * Copyright (c) 2004-2005 Ant-Contrib project.  All rights reserved.
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
package net.sf.antcontrib.design;

import java.io.File;
import java.util.Stack;

import org.apache.tools.ant.Location;
import org.apache.tools.ant.Project;
import org.xml.sax.Attributes;
import org.xml.sax.ContentHandler;
import org.xml.sax.InputSource;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;


/**
 * Handler for the root element. Its only child must be the "project" element.
 */
class DesignFileHandler implements ContentHandler {

    private final static String DESIGN = "design";
    private final static String PACKAGE = "package";
    private final static String DEPENDS = "depends";
        
    private Log log = null;
    private File file = null;
    private boolean isCircularDesign;
    private boolean needDeclarationsDefault = true;
    private boolean needDependsDefault = true;

    private Design design = null;
    private Package currentPackage = null;
    private Stack stack = new Stack();
    private Locator locator = null;
    private Location loc;

    /**
     * @param CompileWithWalls
     */
    DesignFileHandler(Log log, File file, boolean isCircularDesign, Location loc) {
        this.log = log;
        this.file = file;
        this.isCircularDesign = isCircularDesign;
        this.loc = loc;
    }
    
	/**
	 * @param needDeclarationsDefault
	 */
	public void setNeedDeclarationsDefault(boolean b) {
		needDeclarationsDefault = b;
	}

	/**
	 * @param needDependsDefault
	 */
	public void setNeedDependsDefault(boolean b) {
		needDependsDefault = b;
	}

    public Design getDesign() {
        return design;
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
        log.log("publicId="+publicId+" systemId="+systemId,
                Project.MSG_VERBOSE);            
        return null;
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

    /**
     * @see org.xml.sax.ContentHandler#startPrefixMapping(java.lang.String, java.lang.String)
     */
    public void startPrefixMapping(String prefix, String uri) throws SAXException {
    }

    /**
     * @see org.xml.sax.ContentHandler#endPrefixMapping(java.lang.String)
     */
    public void endPrefixMapping(String prefix) throws SAXException {
    }

    /**
     * @see org.xml.sax.ContentHandler#startElement(java.lang.String, java.lang.String, java.lang.String, org.xml.sax.Attributes)
     */
    public void startElement(String uri, String name, String qName, Attributes attrs) throws SAXException {
		log.log("Parsing startElement="+name, Project.MSG_DEBUG);
        if (name == null || "".equals(name)) {
            // XMLReader is not-namespace aware
            name = qName;
        }

        try {
            Object o = null;
            if(name.equals(DESIGN)) {
                o = handleDesign(attrs);
            } else if(name.equals(PACKAGE)) {
                currentPackage = handlePackage(attrs);
                o = currentPackage;
            } else if(name.equals(DEPENDS)) {
                o = handleDepends(attrs);
            } else {
                throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                            +", Unexpected element \"" + name + "\"", locator);
            }
            stack.push(o);
        } catch(RuntimeException e) {
            log.log("exception111111111111111111", Project.MSG_INFO);
            throw new SAXParseException("PRoblem parsing", locator, e);
        }
    }
        
    private Design handleDesign(Attributes attrs) throws SAXParseException {
        if(attrs.getLength() > 0)
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +", no attributes allowed for "+DESIGN+" element", locator);
        else if(stack.size() > 0)
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +", "+DESIGN+" cannot be a subelement of "+stack.pop(), locator);
        else if(attrs.getLength() > 0)
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +", "+DESIGN+" element can't have any attributes", locator);
        design = new Design(isCircularDesign, log, loc);
        return design;
    }
        
    private Package handlePackage(Attributes attrs) throws SAXParseException {
        if(stack.size() <= 0 || !(stack.peek() instanceof Design))
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +", "+PACKAGE+" element must be nested in a "+DESIGN+" element", locator);
        
        int len = attrs.getLength();
        String name = null;
        String thePackage = null;
        String depends = null;
        String subpackages = null;
        String needDeclarations = null;
        String needDepends = null;
        for(int i = 0; i < len; i++) {
            String attrName = attrs.getLocalName(i);
					 			
            if ("".equals(attrName)) {
                // XMLReader is not-namespace aware
                attrName = attrs.getQName(i);
            }
            String value = attrs.getValue(i);
			log.log("attr="+attrName+" value="+value, Project.MSG_DEBUG);
            if("name".equals(attrName))
                name = value;
            else if("package".equals(attrName))
                thePackage = value;
            else if("depends".equals(attrName))
                depends = value;
            else if("subpackages".equals(attrName))
                subpackages = value;
            else if("needdeclarations".equals(attrName))
                needDeclarations = value;
            else if("needdepends".equals(attrName))
            	needDepends = value;
            else
                throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                            +"\n'"+attrName+"' attribute is an invalid attribute for the package element", locator);
        }

        //set the defaults
        if(subpackages == null)
            subpackages = "exclude";
        if(needDeclarations == null)
            needDeclarations = Boolean.toString(needDeclarationsDefault);
        if(needDepends == null)
        	needDepends = Boolean.toString(needDependsDefault);
        
        //make sure every attribute had a valid value...
        if(name == null)
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +", package element must contain the 'name' attribute", locator);
        else if(thePackage == null)
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +", package element must contain the 'package' attribute", locator);
        else if(!("include".equals(subpackages) || "exclude".equals(subpackages)))
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +"\nThe subpackages attribute in the package element can only have a"
                                        +"\nvalue of \"include\" or \"exclude\".  value='"+subpackages+"'", locator);
        else if(!("true".equals(needDeclarations) || "false".equals(needDeclarations)))
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +"\nThe needdeclarations attribute in the package element can only have a"
                                        +"\nvalue of \"true\" or \"false\".  value='"+needDeclarations+"'", locator);
        else if(!("true".equals(needDepends) || "false".equals(needDepends)))
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +"\nThe needdepends attribute in the package element can only have a"
                                        +"\nvalue of \"true\" or \"false\".  value='"+needDepends+"'", locator);
                
        Package p = new Package();
        p.setName(name);
        p.setPackage(thePackage);
        if("exclude".equals(subpackages))
            p.setIncludeSubpackages(false);
        else
            p.setIncludeSubpackages(true);
        if("true".equals(needDeclarations))
            p.setNeedDeclarations(true);
        else
            p.setNeedDeclarations(false);
        if("true".equals(needDepends))
        	p.setNeedDepends(true);
        else
        	p.setNeedDepends(false);
        
        if(depends != null)
            p.addDepends(new Depends(depends));
        return p;
    }
    
    private Depends handleDepends(Attributes attrs) throws SAXParseException {
        if(stack.size() <= 0 || !(stack.peek() instanceof Package))
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +", "+DEPENDS+" element must be nested in a "+PACKAGE+" element", locator);
        else if(attrs.getLength() > 0)
            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                                        +", "+DEPENDS+" element can't have any attributes", locator);

        return new Depends();
    }
        
    /**
     * @see org.xml.sax.ContentHandler#endElement(java.lang.String, java.lang.String, java.lang.String)
     */
    public void endElement(String uri, String localName, String qName) throws SAXException {
        try {
            Object o = stack.pop();
            if(o instanceof Package) {
                Package p = (Package)o;
				
				Package tmp = design.getPackage(p.getName());
				if(tmp != null)
		            throw new SAXParseException("Error in file="+file.getAbsolutePath()
                            +"\nname attribute on "+PACKAGE+" element has the same\n"
                            +"name as another package.  name=\""+p.getName()+"\" is used twice or more", locator);

					
                design.addConfiguredPackage(p);
                currentPackage = null;
            } else if(o instanceof Depends) {
                Depends d = (Depends)o;
                currentPackage.addDepends(d);
            }
        } catch(RuntimeException e) {
            throw new SAXParseException("exception", locator, e);
        }
    }

    /**
     * @see org.xml.sax.ContentHandler#skippedEntity(java.lang.String)
     */
    public void skippedEntity(String name) throws SAXException {
    }

    /**
     * @see org.xml.sax.ContentHandler#startDocument()
     */
    public void startDocument() throws SAXException {           
    }

    /**
     * @see org.xml.sax.ContentHandler#endDocument()
     */
    public void endDocument() throws SAXException {
    }

    /**
     * @see org.xml.sax.ContentHandler#characters(char[], int, int)
     */
    public void characters(char[] ch, int start, int length) throws SAXException {
        try {
            Object o = stack.peek();
            if(o instanceof Depends) {
                String s = new String(ch, start, length);
                Depends d = (Depends)o;
                if (d.getName() != null)
                    d.setName(d.getName() + s.trim());
                else
                    d.setName(s.trim());
            }
        } catch(RuntimeException e) {
            log.log("exception3333333333333333333", Project.MSG_INFO);
            throw new SAXParseException("exception", locator, e);
        }
    }

    /**
     * @see org.xml.sax.ContentHandler#ignorableWhitespace(char[], int, int)
     */
    public void ignorableWhitespace(char[] ch, int start, int length) throws SAXException {
    }

    /**
     * @see org.xml.sax.ContentHandler#processingInstruction(java.lang.String, java.lang.String)
     */
    public void processingInstruction(String target, String data) throws SAXException {
    }
}