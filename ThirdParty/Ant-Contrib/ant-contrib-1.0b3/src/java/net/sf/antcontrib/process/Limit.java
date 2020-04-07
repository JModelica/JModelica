
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
package net.sf.antcontrib.process;


import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;


import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.TaskContainer;
import org.apache.tools.ant.types.EnumeratedAttribute;


/**
 * Limits the amount of time that a task or set of tasks can run. This is useful
 * for tasks that may "hang" or otherwise not complete in a timely fashion. This
 * task is done when either the maxwait time has expired or all nested tasks are
 * complete, whichever is first.
 *
 * <p>Developed for use with Antelope, migrated to ant-contrib Oct 2003.
 *
 * @author    Dale Anson
 * @author    Robert D. Rice
 * @version   $Revision: 1.6 $
 * @since Ant 1.5
 */
public class Limit extends Task implements TaskContainer {


   // storage for nested tasks
   private Vector tasks = new Vector();


   // time units, default value is 3 minutes.
   private long maxwait = 180;
   protected TimeUnit unit = TimeUnit.SECOND_UNIT;

   // property to set if time limit is reached
   private String timeoutProperty = null;
   private String timeoutValue = "true";


   // storage for task currently executing
   private Task currentTask = null;


   // used to control thread stoppage
   private Thread taskRunner = null;


   // should the build fail if the time limit has expired? Default is no.
   private boolean failOnError = false;


   private Exception exception = null;




   /**
    * Add a task to wait on.
    *
    * @param task                A task to execute
    * @exception BuildException  won't happen
    */
   public void addTask( Task task ) throws BuildException {
      tasks.addElement( task );
   }




   /**
    * How long to wait for all nested tasks to complete, in units. 
    * Default is to wait 3 minutes.
    *
    * @param wait  time to wait, set to 0 to wait forever.
    */
   public void setMaxwait( int wait ) {
      maxwait = wait;
   }

   /**
    * Sets the unit for the max wait. Default is minutes.

    * @param unit valid values are "millisecond", "second", "minute", "hour", "day", and "week".

    */
   public void setUnit( String unit ) {
      if ( unit == null )
         return ;
      if ( unit.equals( TimeUnit.SECOND ) ) {
         setMaxWaitUnit( TimeUnit.SECOND_UNIT );
         return ;
      }
      if ( unit.equals( TimeUnit.MILLISECOND ) ) {
         setMaxWaitUnit( TimeUnit.MILLISECOND_UNIT );
         return ;
      }
      if ( unit.equals( TimeUnit.MINUTE ) ) {
         setMaxWaitUnit( TimeUnit.MINUTE_UNIT );
         return ;
      }
      if ( unit.equals( TimeUnit.HOUR ) ) {
         setMaxWaitUnit( TimeUnit.HOUR_UNIT );
         return ;
      }
      if ( unit.equals( TimeUnit.DAY ) ) {
         setMaxWaitUnit( TimeUnit.DAY_UNIT );
         return ;
      }
      if ( unit.equals( TimeUnit.WEEK ) ) {
         setMaxWaitUnit( TimeUnit.WEEK_UNIT );
         return ;
      }

   }

   /**
    * Set a millisecond wait value.
    * @param value the number of milliseconds to wait.
    */
   public void setMilliseconds( int value ) {
      setMaxwait( value );
      setMaxWaitUnit( TimeUnit.MILLISECOND_UNIT );
   }

   /**
    * Set a second wait value.
    * @param value the number of seconds to wait.
    */
   public void setSeconds( int value ) {
      setMaxwait( value );
      setMaxWaitUnit( TimeUnit.SECOND_UNIT );
   }

   /**
    * Set a minute wait value.
    * @param value the number of milliseconds to wait.
    */
   public void setMinutes( int value ) {
      setMaxwait( value );
      setMaxWaitUnit( TimeUnit.MINUTE_UNIT );
   }

   /**
    * Set an hours wait value.
    * @param value the number of hours to wait.
    */
   public void setHours( int value ) {
      setMaxwait( value );
      setMaxWaitUnit( TimeUnit.HOUR_UNIT );
   }

   /**
    * Set a day wait value.
    * @param value the number of days to wait.
    */
   public void setDays( int value ) {
      setMaxwait( value );
      setMaxWaitUnit( TimeUnit.DAY_UNIT );
   }

   /**
    * Set a week wait value.
    * @param value the number of weeks to wait.
    */
   public void setWeeks( int value ) {
      setMaxwait( value );
      setMaxWaitUnit( TimeUnit.WEEK_UNIT );
   }

   /**
    * Set the max wait time unit, default is minutes.
    */
   public void setMaxWaitUnit( TimeUnit unit ) {
      this.unit = unit;
   }


   /**
    * Determines whether the build should fail if the time limit has
    * expired on this task.
    * Default is no.
    *
    * @param fail  if true, fail the build if the time limit has been reached.
    */
   public void setFailonerror( boolean fail ) {
      failOnError = fail;
   }


   /**
    * Name the property to set after a timeout.
    *
    * @param p of property to set if the time limit has been reached.
    */
   public void setProperty( String p ) {
      timeoutProperty = p;
   }


   /**
    * The value for the property to set after a timeout, defaults to true.
    *
    * @param v for the property to set if the time limit has been reached.
    */
   public void setValue( String v ) {
      timeoutValue = v;
   }


   /**
    * Execute all nested tasks, but stopping execution of nested tasks after
    * maxwait or when all tasks are done, whichever is first.
    *
    * @exception BuildException  Description of the Exception
    */
   public void execute() throws BuildException {
      try {
         // start executing nested tasks
         final Thread runner =
            new Thread() {
               public void run() {
                  Enumeration e = tasks.elements();
                  while ( e.hasMoreElements() ) {
                     if ( taskRunner != this ) {
                        break;
                     }
                     currentTask = ( Task ) e.nextElement();
                     try {
                        currentTask.perform();
                     }
                     catch ( Exception ex ) {
                        if ( failOnError ) {
                           exception = ex;
                           return ;
                        }
                        else {
                           exception = ex;
                        }
                     }
                  }
               }
            };
         taskRunner = runner;
         runner.start();
         runner.join( unit.toMillis( maxwait ) );


         // stop executing the nested tasks
         if ( runner.isAlive() ) {
            taskRunner = null;
            runner.interrupt();
            int index = tasks.indexOf( currentTask );
            StringBuffer not_ran = new StringBuffer();
            for ( int i = index + 1; i < tasks.size(); i++ ) {
               not_ran.append( '<' ).append( ( ( Task ) tasks.get( i ) ).getTaskName() ).append( '>' );
               if ( i < tasks.size() - 1 ) {
                  not_ran.append( ", " );
               }
            }


            // maybe set timeout property
            if ( timeoutProperty != null ) {
               getProject().setNewProperty( timeoutProperty, timeoutValue );
            }


            // create output message
            StringBuffer msg = new StringBuffer();
            msg.append( "Interrupted task <" )
            .append( currentTask.getTaskName() )
            .append( ">. Waited " )
            .append( ( maxwait ) ).append( " " ).append( unit.getValue() )
            .append( ", but this task did not complete." )
            .append( ( not_ran.length() > 0 ?
                  " The following tasks did not execute: " + not_ran.toString() + "." :
                  "" ) );


            // deal with it
            if ( failOnError ) {
               throw new BuildException( msg.toString() );
            }
            else {
               log( msg.toString() );
            }
         }
         else if ( failOnError && exception != null ) {
            throw new BuildException( exception );
         }
      }
      catch ( Exception e ) {
         throw new BuildException( e );
      }
   }


   /**
    * The enumeration of units:
    * millisecond, second, minute, hour, day, week
    * Todo: we use timestamps in many places, why not factor this out
    */
   public static class TimeUnit extends EnumeratedAttribute {

      public static final String MILLISECOND = "millisecond";
      public static final String SECOND = "second";
      public static final String MINUTE = "minute";
      public static final String HOUR = "hour";
      public static final String DAY = "day";
      public static final String WEEK = "week";

      /** static unit objects, for use as sensible defaults */
      public static final TimeUnit MILLISECOND_UNIT =
         new TimeUnit( MILLISECOND );
      public static final TimeUnit SECOND_UNIT =
         new TimeUnit( SECOND );
      public static final TimeUnit MINUTE_UNIT =
         new TimeUnit( MINUTE );
      public static final TimeUnit HOUR_UNIT =
         new TimeUnit( HOUR );
      public static final TimeUnit DAY_UNIT =
         new TimeUnit( DAY );
      public static final TimeUnit WEEK_UNIT =
         new TimeUnit( WEEK );


      private static final String[] units = {
               MILLISECOND, SECOND, MINUTE, HOUR, DAY, WEEK
            };

      private Hashtable timeTable = new Hashtable();

      public TimeUnit() {
         timeTable.put( MILLISECOND, new Long( 1L ) );
         timeTable.put( SECOND, new Long( 1000L ) );
         timeTable.put( MINUTE, new Long( 1000L * 60L ) );
         timeTable.put( HOUR, new Long( 1000L * 60L * 60L ) );
         timeTable.put( DAY, new Long( 1000L * 60L * 60L * 24L ) );
         timeTable.put( WEEK, new Long( 1000L * 60L * 60L * 24L * 7L ) );
      }

      /**
       * private constructor
       * used for static construction of TimeUnit objects.
       * @param value String representing the value.
       */
      private TimeUnit( String value ) {
         this( );
         setValueProgrammatically( value );
      }

      /**
       * set the inner value programmatically.
       * @param value to set
       */
      protected void setValueProgrammatically( String value ) {
         this.value = value;
      }

      public long getMultiplier() {
         String key = getValue().toLowerCase();
         Long l = ( Long ) timeTable.get( key );
         return l.longValue();
      }

      public String[] getValues() {
         return units;
      }

      /**
       * convert the time in the current unit, to millis
       * @param numberOfUnits long expressed in the current objects units
       * @return long representing the value in millis
       */
      public long toMillis( long numberOfUnits ) {
         return numberOfUnits * getMultiplier( );
      }
   }
}



