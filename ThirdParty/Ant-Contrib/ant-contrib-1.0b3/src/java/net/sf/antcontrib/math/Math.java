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

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;


/**
 * Utility class for executing calculations.
 *
 * @author		inger
 */


public class Math
{
    public static final Number evaluate(String operation,
                                        String datatype,
                                        boolean strict,
                                        Evaluateable operands[])
    {
        if (datatype == null)
            datatype = "double";

        try
        {
            operation = operation.toLowerCase();

            Method m = Math.class.getDeclaredMethod(operation,
                                                    new Class[]{
                                                        String.class,
                                                        Boolean.TYPE,
                                                        operands.getClass()
                                                    });
            Number n = (Number) m.invoke(null,
                                         new Object[]{
                                             datatype,
                                             strict ? Boolean.TRUE : Boolean.FALSE,
                                             operands
                                         });

            return n;
        }
        catch (NoSuchMethodException e)
        {
            e.printStackTrace();
        }
        catch (IllegalAccessException e)
        {
            e.printStackTrace();
        }
        catch (InvocationTargetException e)
        {
            e.getTargetException().printStackTrace();
        }
        return null;
    }

    public static final Number add(String datatype,
                                   boolean strict,
                                   Evaluateable operands[])
    {
        Number result = null;

        Number numbers[] = new Number[operands.length];
        for (int i = 0; i < operands.length; i++)
            numbers[i] = operands[i].evaluate();

        if (datatype.equalsIgnoreCase("int"))
        {
            int sum = 0;
            for (int i = 0; i < numbers.length; i++)
                sum += numbers[i].intValue();
            result = new Integer(sum);
        }
        else if (datatype.equalsIgnoreCase("long"))
        {
            long sum = 0;
            for (int i = 0; i < numbers.length; i++)
                sum += numbers[i].longValue();
            result = new Long(sum);
        }
        else if (datatype.equalsIgnoreCase("float"))
        {
            float sum = 0;
            for (int i = 0; i < numbers.length; i++)
                sum += numbers[i].floatValue();
            result = new Float(sum);
        }
        else if (datatype.equalsIgnoreCase("double"))
        {
            double sum = 0;
            for (int i = 0; i < numbers.length; i++)
                sum += numbers[i].doubleValue();
            result = new Double(sum);
        }
        return result;
    }

    public static final Number subtract(String datatype,
                                        boolean strict,
                                        Evaluateable operands[])
    {
        Number result = null;

        Number numbers[] = new Number[operands.length];
        for (int i = 0; i < operands.length; i++)
            numbers[i] = operands[i].evaluate();

        if (datatype.equalsIgnoreCase("int"))
        {
            int sum = numbers[0].intValue();
            for (int i = 1; i < numbers.length; i++)
                sum -= numbers[i].intValue();
            result = new Integer(sum);
        }
        else if (datatype.equalsIgnoreCase("long"))
        {
            long sum = numbers[0].longValue();
            for (int i = 1; i < numbers.length; i++)
                sum -= numbers[i].longValue();
            result = new Long(sum);
        }
        else if (datatype.equalsIgnoreCase("float"))
        {
            float sum = numbers[0].floatValue();
            for (int i = 1; i < numbers.length; i++)
                sum -= numbers[i].floatValue();
            result = new Float(sum);
        }
        else if (datatype.equalsIgnoreCase("double"))
        {
            double sum = numbers[0].doubleValue();
            for (int i = 1; i < numbers.length; i++)
                sum -= numbers[i].doubleValue();
            result = new Double(sum);
        }
        return result;
    }

    public static final Number multiply(String datatype,
                                        boolean strict,
                                        Evaluateable operands[])
    {
        Number result = null;

        Number numbers[] = new Number[operands.length];
        for (int i = 0; i < operands.length; i++)
            numbers[i] = operands[i].evaluate();

        if (datatype.equalsIgnoreCase("int"))
        {
            int sum = 1;
            for (int i = 0; i < numbers.length; i++)
                sum *= numbers[i].intValue();
            result = new Integer(sum);
        }
        else if (datatype.equalsIgnoreCase("long"))
        {
            long sum = 1;
            for (int i = 0; i < numbers.length; i++)
                sum *= numbers[i].longValue();
            result = new Long(sum);
        }
        else if (datatype.equalsIgnoreCase("float"))
        {
            float sum = 1;
            for (int i = 0; i < numbers.length; i++)
                sum *= numbers[i].floatValue();
            result = new Float(sum);
        }
        else if (datatype.equalsIgnoreCase("double"))
        {
            double sum = 1;
            for (int i = 0; i < numbers.length; i++)
                sum *= numbers[i].doubleValue();
            result = new Double(sum);
        }
        return result;
    }

    public static final Number divide(String datatype,
                                      boolean strict,
                                      Evaluateable operands[])
    {
        Number result = null;

        Number numbers[] = new Number[operands.length];
        for (int i = 0; i < operands.length; i++)
            numbers[i] = operands[i].evaluate();

        if (datatype.equalsIgnoreCase("int"))
        {
            int sum = numbers[0].intValue();
            for (int i = 1; i < numbers.length; i++)
                sum /= numbers[i].intValue();
            result = new Integer(sum);
        }
        else if (datatype.equalsIgnoreCase("long"))
        {
            long sum = numbers[0].longValue();
            for (int i = 1; i < numbers.length; i++)
                sum /= numbers[i].longValue();
            result = new Long(sum);
        }
        else if (datatype.equalsIgnoreCase("float"))
        {
            float sum = numbers[0].floatValue();
            for (int i = 1; i < numbers.length; i++)
                sum /= numbers[i].floatValue();
            result = new Float(sum);
        }
        else if (datatype.equalsIgnoreCase("double"))
        {
            double sum = numbers[0].doubleValue();
            for (int i = 1; i < numbers.length; i++)
                sum /= numbers[i].doubleValue();
            result = new Double(sum);
        }
        return result;
    }

    public static final Number mod(String datatype,
                                   boolean strict,
                                   Evaluateable operands[])
    {
        Number result = null;

        Number numbers[] = new Number[operands.length];
        for (int i = 0; i < operands.length; i++)
            numbers[i] = operands[i].evaluate();

        if (datatype.equalsIgnoreCase("int"))
        {
            int sum = numbers[0].intValue();
            for (int i = 1; i < numbers.length; i++)
                sum %= numbers[i].intValue();
            result = new Integer(sum);
        }
        else if (datatype.equalsIgnoreCase("long"))
        {
            long sum = numbers[0].longValue();
            for (int i = 1; i < numbers.length; i++)
                sum %= numbers[i].longValue();
            result = new Long(sum);
        }
        else if (datatype.equalsIgnoreCase("float"))
        {
            float sum = numbers[0].floatValue();
            for (int i = 1; i < numbers.length; i++)
                sum %= numbers[i].floatValue();
            result = new Float(sum);
        }
        else if (datatype.equalsIgnoreCase("double"))
        {
            double sum = numbers[0].doubleValue();
            for (int i = 1; i < numbers.length; i++)
                sum %= numbers[i].doubleValue();
            result = new Double(sum);
        }
        return result;
    }

    public static final Number convert(Number n, String datatype)
    {
        if (datatype == null)
            datatype = "double";
        if (datatype.equals("int"))
            return new Integer(n.intValue());
        if (datatype.equals("long"))
            return new Long(n.longValue());
        if (datatype.equals("float"))
            return new Float(n.floatValue());
        if (datatype.equals("double"))
            return new Double(n.doubleValue());
        throw new BuildException("Invalid datatype.");
    }

    public static final Number execute(String method,
                                       String datatype,
                                       boolean strict,
                                       Class paramTypes[],
                                       Object params[])
    {
        try
        {
            Class c = null;
            if (strict)
            {
                c = Thread.currentThread().getContextClassLoader().loadClass("java.lang.StrictMath");
            }
            else
            {
                c = Thread.currentThread().getContextClassLoader().loadClass("java.lang.Math");
            }

            Method m = c.getDeclaredMethod(method, paramTypes);
            Number n = (Number) m.invoke(null, params);
            return convert(n, datatype);
        }
        catch (ClassNotFoundException e)
        {
            throw new BuildException(e);
        }
        catch (NoSuchMethodException e)
        {
            throw new BuildException(e);
        }
        catch (IllegalAccessException e)
        {
            throw new BuildException(e);
        }
        catch (InvocationTargetException e)
        {
            throw new BuildException(e);
        }
    }

    public static final Number random(String datatype,
                                      boolean strict,
                                      Evaluateable operands[])
    {
        return execute("random",
                       datatype,
                       strict,
                       new Class[0],
                       new Object[0]);
    }

    public static Class getPrimitiveClass(String datatype)
    {
        if (datatype == null)
            return Double.TYPE;
        if (datatype.equals("int"))
            return Integer.TYPE;
        if (datatype.equals("long"))
            return Long.TYPE;
        if (datatype.equals("float"))
            return Float.TYPE;
        if (datatype.equals("double"))
            return Double.TYPE;
        throw new BuildException("Invalid datatype.");

    }

    public static final Number abs(String datatype,
                                   boolean strict,
                                   Evaluateable operands[])
    {
        Object ops[] = new Object[]{convert(operands[0].evaluate(), datatype)};
        Class params[] = new Class[]{getPrimitiveClass(datatype)};

        return execute("abs",
                       datatype,
                       strict,
                       params,
                       ops);
    }

    private static final Number doOneDoubleArg(String operation,
                                               String datatype,
                                               boolean strict,
                                               Evaluateable operands[])
    {
        Object ops[] = new Object[]{convert(operands[0].evaluate(),
                                            "double")};
        Class params[] = new Class[]{Double.TYPE};

        return execute(operation,
                       datatype,
                       strict,
                       params,
                       ops);
    }

    public static final Number acos(String datatype,
                                    boolean strict,
                                    Evaluateable operands[])
    {
        return doOneDoubleArg("acos", datatype, strict, operands);
    }

    public static final Number asin(String datatype,
                                    boolean strict,
                                    Evaluateable operands[])
    {
        return doOneDoubleArg("asin", datatype, strict, operands);
    }

    public static final Number atan(String datatype,
                                    boolean strict,
                                    Evaluateable operands[])
    {
        return doOneDoubleArg("atan", datatype, strict, operands);
    }

    public static final Number atan2(String datatype,
                                     boolean strict,
                                     Evaluateable operands[])
    {
        Object ops[] = new Object[]{convert(operands[0].evaluate(),
                                            "double"),
                                    convert(operands[1].evaluate(),
                                            "double")};
        Class params[] = new Class[]{Double.TYPE,
                                     Double.TYPE};

        return execute("atan2",
                       datatype,
                       strict,
                       params,
                       ops);
    }

    public static final Number sin(String datatype,
                                   boolean strict,
                                   Evaluateable operands[])
    {
        return doOneDoubleArg("sin", datatype, strict, operands);
    }

    public static final Number tan(String datatype,
                                   boolean strict,
                                   Evaluateable operands[])
    {
        return doOneDoubleArg("sin", datatype, strict, operands);
    }

    public static final Number cos(String datatype,
                                   boolean strict,
                                   Evaluateable operands[])
    {
        return doOneDoubleArg("cos", datatype, strict, operands);
    }

    public static final Number ceil(String datatype,
                                    boolean strict,
                                    Evaluateable operands[])
    {
        return doOneDoubleArg("ceil", datatype, strict, operands);
    }

    public static final Number floor(String datatype,
                                     boolean strict,
                                     Evaluateable operands[])
    {
        return doOneDoubleArg("floor", datatype, strict, operands);
    }

    public static final Number exp(String datatype,
                                   boolean strict,
                                   Evaluateable operands[])
    {
        return doOneDoubleArg("exp", datatype, strict, operands);
    }

    public static final Number rint(String datatype,
                                    boolean strict,
                                    Evaluateable operands[])
    {
        return doOneDoubleArg("rint", datatype, strict, operands);
    }

    public static final Number round(String datatype,
                                     boolean strict,
                                     Evaluateable operands[])
    {
        Object ops[] = new Object[]{convert(operands[0].evaluate(),
                                            datatype)};
        Class params[] = new Class[]{getPrimitiveClass(datatype)};

        return execute("round",
                       datatype,
                       strict,
                       params,
                       ops);
    }

    public static final Number sqrt(String datatype,
                                    boolean strict,
                                    Evaluateable operands[])
    {
        return doOneDoubleArg("sqrt", datatype, strict, operands);
    }

    public static final Number degrees(String datatype,
                                       boolean strict,
                                       Evaluateable operands[])
    {
        return todegrees(datatype, strict, operands);
    }

    public static final Number todegrees(String datatype,
                                       boolean strict,
                                       Evaluateable operands[])
    {
        return doOneDoubleArg("toDegrees", datatype, strict, operands);
    }

    public static final Number radians(String datatype,
                                       boolean strict,
                                       Evaluateable operands[])
    {
        return toradians(datatype, strict, operands);
    }

    public static final Number toradians(String datatype,
                                       boolean strict,
                                       Evaluateable operands[])
    {
        return doOneDoubleArg("toRadians", datatype, strict, operands);
    }

    public static final Number ieeeremainder(String datatype,
                                             boolean strict,
                                             Evaluateable operands[])
    {
        Object ops[] = new Object[]{convert(operands[0].evaluate(),
                                            "double"),
                                    convert(operands[1].evaluate(),
                                            "double")};
        Class params[] = new Class[]{Double.TYPE,
                                     Double.TYPE};

        return execute("IEEERemainder",
                       datatype,
                       strict,
                       params,
                       ops);
    }

    public static final Number min(String datatype,
                                   boolean strict,
                                   Evaluateable operands[])
    {
        Object ops[] = new Object[]{convert(operands[0].evaluate(),
                                            datatype),
                                    convert(operands[1].evaluate(),
                                            datatype)};
        Class params[] = new Class[]{getPrimitiveClass(datatype),
                                     getPrimitiveClass(datatype)};

        return execute("min",
                       datatype,
                       strict,
                       params,
                       ops);
    }

    public static final Number max(String datatype,
                                   boolean strict,
                                   Evaluateable operands[])
    {
        Object ops[] = new Object[]{convert(operands[0].evaluate(),
                                            datatype),
                                    convert(operands[1].evaluate(),
                                            datatype)};
        Class params[] = new Class[]{getPrimitiveClass(datatype),
                                     getPrimitiveClass(datatype)};

        return execute("max",
                       datatype,
                       strict,
                       params,
                       ops);
    }

}
