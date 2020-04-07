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
package net.sf.antcontrib.logic;

import net.sf.antcontrib.BuildFileTestBase;

/**
 * Since AntCallBack is basically a copy and paste of antcall, the only testing
 * done here is on the extra features provided by antcallback. It is assumed
 * that changes to antcall will be propagated to antcallback and that antcall
 * has it's own unit tests (which turns out to have been a bad assumption,
 * I can't find any unit tests for antcall).
 *
 * @author   danson
 */
public class AssertTest extends BuildFileTestBase {

   /**
    * Constructor for the AntCallBackTest object
    *
    * @param name  Description of the Parameter
    */
   public AssertTest( String name ) {
      super( name );
   }


   /** The JUnit setup method */
   public void setUp() {
      configureProject( "test/resources/logic/asserttest.xml" );
   }


   /** A unit test for JUnit */
   public void test1() {
      executeTarget( "test1" );
   }

   public void test2() {
      expectBuildExceptionStackTraceContaining( "test2", "testing assert failure", "Property 'testprop' doesn't exist in this project." );
   }

   public void test3() {
      expectBuildExceptionStackTraceContaining( "test3", "testing assert failure", "Expected 'false', but was 'true'." );
   }
   
   public void test4() {
      executeTarget("test4");  
   }

   public void test5() {
      executeTarget("test5");  
   }
   
   public void test6() {
      executeTarget("test6"); 
   }
   
   public void test7(){
      expectBuildExceptionStackTraceContaining( "test7", "testing conditions", "Assertion failed boolean test." );
   }
   
   public void test8() {
      executeTarget("test8"); 
   }
   
   public void test9() {
      expectBuildExceptionStackTraceContaining( "test9", "testing conditions", "Assertion failed boolean test." );
   }
}

