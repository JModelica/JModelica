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
import org.apache.tools.ant.DynamicConfigurator;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Vector;

/**
 * Class to represent a mathematical operation.
 *
 * @author		inger
 */


public class Operation
        implements Evaluateable, DynamicConfigurator {
    private String operation = "add";
    private Vector operands = new Vector();
    private String datatype = "double";
    private boolean strict = false;

    private boolean hasLocalOperands = false;
    private Numeric localOperands[] = new Numeric[5];

    public void setDynamicAttribute(String s, String s1)
            throws BuildException {
        throw new BuildException("no dynamic attributes for this element");
    }

    public Object createDynamicElement(String name)
            throws BuildException {
        Operation op = new Operation();
        op.setOperation(name);
        operands.add(op);
        return op;
    }

    private void setLocalOperand(String value, int index) {
        hasLocalOperands = true;
        localOperands[index - 1] = new Numeric();
        localOperands[index - 1].setValue(value);
    }

    public void setArg1(String value) {
        setLocalOperand(value, 1);
    }

    public void setArg2(String value) {
        setLocalOperand(value, 2);
    }

    public void setArg3(String value) {
        setLocalOperand(value, 3);
    }

    public void setArg4(String value) {
        setLocalOperand(value, 4);
    }

    public void setArg5(String value) {
        setLocalOperand(value, 5);
    }

    public void addConfiguredNumeric(Numeric numeric) {
        if (hasLocalOperands)
            throw new BuildException("Cannot combine operand attributes with subelements");

        operands.add(numeric);
    }

    public void addConfiguredOperation(Operation operation) {
        if (hasLocalOperands)
            throw new BuildException("Cannot combine operand attributes with subelements");

        operands.add(operation);
    }

    public void addConfiguredNum(Numeric numeric) {
        if (hasLocalOperands)
            throw new BuildException("Cannot combine operand attributes with subelements");

        operands.add(numeric);
    }

    public void addConfiguredOp(Operation operation) {
        if (hasLocalOperands)
            throw new BuildException("Cannot combine operand attributes with subelements");

        operands.add(operation);
    }

    public void setOp(String operation) {
        setOperation(operation);
    }

    public void setOperation(String operation) {
        if (operation.equals("+"))
            this.operation = "add";
        else if (operation.equals("-"))
            this.operation = "subtract";
        else if (operation.equals("*"))
            this.operation = "multiply";
        else if (operation.equals("/"))
            this.operation = "divide";
        else if (operation.equals("%"))
            this.operation = "mod";
        else
            this.operation = operation;
    }

    public void setDatatype(String datatype) {
        this.datatype = datatype;
    }

    public void setStrict(boolean strict) {
        this.strict = strict;
    }

    public Number evaluate() {
        Evaluateable ops[] = null;

        if (hasLocalOperands) {
            List localOps = new ArrayList();
            for (int i = 0; i < localOperands.length; i++) {
                if (localOperands[i] != null)
                    localOps.add(localOperands[i]);
            }

            ops = (Evaluateable[]) localOps.toArray(new Evaluateable[localOps.size()]);
        }
        else {
            ops = (Evaluateable[]) operands.toArray(new Evaluateable[operands.size()]);
        }

        return Math.evaluate(operation,
                             datatype,
                             strict,
                             ops);
    }

    public String toString() {
        return "Operation[operation=" + operation
                + ";datatype=" + datatype
                + ";strict=" + strict
                + ";localoperands=" + Arrays.asList(localOperands)
                + ";operands=" + operands
                + "]";
    }
}
