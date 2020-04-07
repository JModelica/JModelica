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
/*
 * Created on Jan 13, 2005
 */
package mod.nodebugoption;

import mod.dummy.DummyClass;

/** 
 *
 * @author dhiller
 */
public class ClassDependsOnLocalVar {

	public void doSomething() {
		DummyClass c = null;
		//without debug option enabled, the type DummyClass is lost so we
		//must fail with the error saying class wasn't compiled with -g option
		//enabled in javac.
	}
}
