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
package net.sf.antcontrib.net;

/**
 * Simple bean to represent a name/value pair.
 * <p>Developed for use with Antelope, migrated to ant-contrib Oct 2003.
 *
 * @author    Dale Anson, danson@germane-software.com
 * @version   $Revision: 1.3 $
 */
public class Prop {
    private String name = null;
    private String value = null;
    public void setName( String name ) {
        this.name = name;
    }
    public String getName() {
        return name;
    }
    public void setValue( String value ) {
        this.value = value;
    }
    public String getValue() {
        return value;
    }
}

