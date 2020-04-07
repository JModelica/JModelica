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
package net.sf.antcontrib.logic.condition;

import org.apache.tools.ant.taskdefs.condition.ConditionBase;

/**
 * Extends ConditionBase so I can get access to the condition count and the
 * first condition. This is the class that the BooleanConditionTask is proxy
 * for.
 * <p>Developed for use with Antelope, migrated to ant-contrib Oct 2003.
 *
 * @author     Dale Anson, danson@germane-software.com
 */
public class BooleanConditionBase extends ConditionBase {
   /**
    * Adds a feature to the IsPropertyTrue attribute of the BooleanConditionBase
    * object
    *
    * @param i  The feature to be added to the IsPropertyTrue attribute
    */
   public void addIsPropertyTrue( IsPropertyTrue i ) {
      super.add( i );
   }

   /**
    * Adds a feature to the IsPropertyFalse attribute of the
    * BooleanConditionBase object
    *
    * @param i  The feature to be added to the IsPropertyFalse attribute
    */
   public void addIsPropertyFalse( IsPropertyFalse i ) {
      super.add( i );
   }
   
   public void addIsGreaterThan( IsGreaterThan i) {
      super.add(i);  
   }
   
   public void addIsLessThan( IsLessThan i) {
      super.add(i);  
   }
}

