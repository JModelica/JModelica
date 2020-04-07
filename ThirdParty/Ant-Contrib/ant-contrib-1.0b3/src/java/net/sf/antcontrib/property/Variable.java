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
import java.io.FileInputStream;
import java.io.IOException;
import java.lang.reflect.Field;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Properties;
import java.util.Vector;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;
import org.apache.tools.ant.Task;

/**
 * Similar to Property, but this property is mutable. In fact, much of the code
 * in this class is copy and paste from Property. In general, the standard Ant
 * property should be used, but occasionally it is useful to use a mutable
 * property.
 * <p>
 * This used to be a nice little task that took advantage of what is probably
 * a flaw in the Ant Project API -- setting a "user" property programatically
 * causes the project to overwrite a previously set property. Now this task
 * has become more violent and employs a technique known as "object rape" to
 * directly access the Project's private property hashtable.
 * <p>Developed for use with Antelope, migrated to ant-contrib Oct 2003.
 *
 * @author   Dale Anson, danson@germane-software.com
 * @since    Ant 1.5
 * @version  $Revision: 1.6 $
 */
public class Variable extends Task {

   // attribute storage
   private String value = "";
   private String name = null;
   private File file = null;
   private boolean remove = false;


   /**
    * Set the name of the property. Required unless 'file' is used.
    *
    * @param name  the name of the property.
    */
   public void setName( String name ) {
      this.name = name;
   }


   /**
    * Set the value of the property. Optional, defaults to "".
    *
    * @param value  the value of the property.
    */
   public void setValue( String value ) {
      this.value = value;
   }


   /**
    * Set the name of a file to read properties from. Optional.
    *
    * @param file  the file to read properties from.
    */
   public void setFile( File file ) {
      this.file = file;
   }

   /**
    * Determines whether the property should be removed from the project.
    * Default is false. Once  removed, conditions that check for property
    * existence will find this property does not exist.
    *
    * @param b set to true to remove the property from the project. 
    */
   public void setUnset( boolean b ) {
      remove = b;
   }


   /**
    * Execute this task.
    *
    * @exception BuildException  Description of the Exception
    */
   public void execute() throws BuildException {
      if ( remove ) {
         if ( name == null || name.equals( "" ) ) {
            throw new BuildException( "The 'name' attribute is required with 'unset'." );
         }
         removeProperty( name );
         return ;
      }
      if ( file == null ) {
         // check for the required name attribute
         if ( name == null || name.equals( "" ) ) {
            throw new BuildException( "The 'name' attribute is required." );
         }

         // check for the required value attribute
         if ( value == null ) {
            value = "";
         }

         // adjust the property value if necessary -- is this necessary?
         // Doesn't Ant do this automatically?
         value = getProject().replaceProperties( value );

         // set the property
         forceProperty( name, value );
      }
      else {
         if ( !file.exists() ) {
            throw new BuildException( file.getAbsolutePath() + " does not exists." );
         }
         loadFile( file );
      }
   }

   /**
    * Remove a property from the project's property table and the userProperty table.
    * Note that Ant 1.6 uses a helper for this.
    */
   private void removeProperty( String name ) {
      Hashtable properties = null;
      // Ant 1.5 stores properties in Project
      try {
         properties = ( Hashtable ) getValue( getProject(), "properties" );
         if ( properties != null ) {
            properties.remove( name );
         }
      }
      catch ( Exception e ) {
         // ignore, could be Ant 1.6
      }
      try {
         properties = ( Hashtable ) getValue( getProject(), "userProperties" );
         if ( properties != null ) {
            properties.remove( name );
         }
      }
      catch ( Exception e ) {
         // ignore, could be Ant 1.6
      }

      // Ant 1.6 uses a PropertyHelper, can check for it by checking for a
      // reference to "ant.PropertyHelper"
      try {
         Object property_helper = getProject().getReference( "ant.PropertyHelper" );
         if ( property_helper != null ) {
            try {
               properties = ( Hashtable ) getValue( property_helper, "properties" );
               if ( properties != null ) {
                  properties.remove( name );
               }
            }
            catch ( Exception e ) {
               // ignore
            }
            try {
               properties = ( Hashtable ) getValue( property_helper, "userProperties" );
               if ( properties != null ) {
                  properties.remove( name );
               }
            }
            catch ( Exception e ) {
               // ignore
            }
         }
      }
      catch ( Exception e ) {
         // ignore, could be Ant 1.5
      }
   }

   private void forceProperty( String name, String value ) {
      try {
         Hashtable properties = ( Hashtable ) getValue( getProject(), "properties" );
         if ( properties == null ) {
            getProject().setUserProperty( name, value );
         }
         else {
            properties.put( name, value );
         }
      }
      catch ( Exception e ) {
         getProject().setUserProperty( name, value );
      }
   }


   /**
    * Object rape: fondle the private parts of an object without it's
    * permission.
    *
    * @param thisClass                 The class to rape.
    * @param fieldName                 The field to fondle
    * @return                          The field value
    * @exception NoSuchFieldException  Darn, nothing to fondle.
    */
   private Field getField( Class thisClass, String fieldName ) throws NoSuchFieldException {
      if ( thisClass == null ) {
         throw new NoSuchFieldException( "Invalid field : " + fieldName );
      }
      try {
         return thisClass.getDeclaredField( fieldName );
      }
      catch ( NoSuchFieldException e ) {
         return getField( thisClass.getSuperclass(), fieldName );
      }
   }


   /**
    * Object rape: fondle the private parts of an object without it's
    * permission.
    *
    * @param instance                    the object instance
    * @param fieldName                   the name of the field
    * @return                            an object representing the value of the
    *      field
    * @exception IllegalAccessException  foiled by the security manager
    * @exception NoSuchFieldException    Darn, nothing to fondle
    */
   private Object getValue( Object instance, String fieldName )
   throws IllegalAccessException, NoSuchFieldException {
      Field field = getField( instance.getClass(), fieldName );
      field.setAccessible( true );
      return field.get( instance );
   }


   /**
    * load variables from a file
    *
    * @param file                file to load
    * @exception BuildException  Description of the Exception
    */
   private void loadFile( File file ) throws BuildException {
      Properties props = new Properties();
      try {
         if ( file.exists() ) {
            FileInputStream fis = new FileInputStream( file );
            try {
               props.load( fis );
            }
            finally {
               if ( fis != null ) {
                  fis.close();
               }
            }
            addProperties( props );
         }
         else {
            log( "Unable to find property file: " + file.getAbsolutePath(),
                 Project.MSG_VERBOSE );
         }
      }
      catch ( IOException ex ) {
         throw new BuildException( ex, location );
      }
   }


   /**
    * iterate through a set of properties, resolve them, then assign them
    *
    * @param props  The feature to be added to the Properties attribute
    */
   protected void addProperties( Properties props ) {
      resolveAllProperties( props );
      Enumeration e = props.keys();
      while ( e.hasMoreElements() ) {
         String name = ( String ) e.nextElement();
         String value = props.getProperty( name );
         forceProperty( name, value );
      }
   }


   /**
    * resolve properties inside a properties hashtable
    *
    * @param props               properties object to resolve
    * @exception BuildException  Description of the Exception
    */
   private void resolveAllProperties( Properties props ) throws BuildException {
      for ( Enumeration e = props.keys(); e.hasMoreElements(); ) {
         String name = ( String ) e.nextElement();
         String value = props.getProperty( name );

         boolean resolved = false;
         while ( !resolved ) {
            Vector fragments = new Vector();
            Vector propertyRefs = new Vector();
            ProjectHelper.parsePropertyString( value, fragments,
                  propertyRefs );

            resolved = true;
            if ( propertyRefs.size() != 0 ) {
               StringBuffer sb = new StringBuffer();
               Enumeration i = fragments.elements();
               Enumeration j = propertyRefs.elements();
               while ( i.hasMoreElements() ) {
                  String fragment = ( String ) i.nextElement();
                  if ( fragment == null ) {
                     String propertyName = ( String ) j.nextElement();
                     if ( propertyName.equals( name ) ) {
                        throw new BuildException( "Property " + name
                              + " was circularly "
                              + "defined." );
                     }
                     fragment = getProject().getProperty( propertyName );
                     if ( fragment == null ) {
                        if ( props.containsKey( propertyName ) ) {
                           fragment = props.getProperty( propertyName );
                           resolved = false;
                        }
                        else {
                           fragment = "${" + propertyName + "}";
                        }
                     }
                  }
                  sb.append( fragment );
               }
               value = sb.toString();
               props.put( name, value );
            }
         }
      }
   }

}

