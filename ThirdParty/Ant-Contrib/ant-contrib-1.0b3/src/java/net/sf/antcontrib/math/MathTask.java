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
package net.sf.antcontrib.math;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.DynamicConfigurator;

/**
 * Task for mathematical operations.
 *
 * @author		inger
 */


public class MathTask
        extends Task
        implements DynamicConfigurator
{
    // storage for result
    private String result = null;
    private Operation operation = null;
    private Operation locOperation = null;
    private String datatype = null;
    private boolean strict = false;

    public MathTask()
    {
        super();
    }

    public void execute()
            throws BuildException
    {
        Operation op = locOperation;
        if (op == null)
            op = operation;

        Number res = op.evaluate();

        if (datatype != null)
            res = Math.convert(res, datatype);
        getProject().setUserProperty(result, res.toString());
    }

    public void setDynamicAttribute(String s, String s1)
            throws BuildException {
        throw new BuildException("No dynamic attributes for this task");
    }

    public Object createDynamicElement(String name)
            throws BuildException {
        Operation op = new Operation();
        op.setOperation(name);
        operation = op;
        return op;
    }

    public void setResult(String result)
    {
        this.result = result;
    }

    public void setDatatype(String datatype)
    {
        this.datatype = datatype;
    }

    public void setStrict(boolean strict)
    {
        this.strict = strict;
    }

    private Operation getLocalOperation()
    {
        if (locOperation == null)
        {
            locOperation = new Operation();
            locOperation.setDatatype(datatype);
            locOperation.setStrict(strict);
        }
        return locOperation;
    }

    public void setOperation(String operation)
    {
        getLocalOperation().setOperation(operation);
    }

    public void setDataType(String dataType)
    {
        getLocalOperation().setDatatype(dataType);
    }

    public void setOperand1(String operand1)
    {
        getLocalOperation().setArg1(operand1);
    }

    public void setOperand2(String operand2)
    {
        getLocalOperation().setArg2(operand2);
    }

    public Operation createOperation()
    {
        if (locOperation != null || operation != null)
            throw new BuildException("Only 1 operation can be specified");
        this.operation = new Operation();
        this.operation.setStrict(strict);
        this.operation.setDatatype(datatype);
        return this.operation;
    }

    // conform to old task
    public Operation createOp()
    {
        return createOperation();
    }
}
