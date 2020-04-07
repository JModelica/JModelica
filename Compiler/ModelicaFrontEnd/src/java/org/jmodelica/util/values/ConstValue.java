package org.jmodelica.util.values;

public abstract class ConstValue {
    
    /**
     * Get a string describing this CValue for use in 
     *        ConstantEvaluationExceptions.
     */
    public String errorDesc() {
        return getClass().getSimpleName() + " (" + toString() + ")";
    }

    /**
     * Convert to int, default implementation.
     * 
     * @return Value converted to int.
     */
    public int intValue() { 
        throw new ConstantEvaluationException(this, "get int value of "); 
    }

    /**
     * Convert to a vector of int, default implementation.
     * 
     * @return Value converted to int vector.
     */
    public int[] intVector() {
        throw new ConstantEvaluationException(this, "get int vector of "); 
    }

    /**
     * Convert to double, default implementation.
     * 
     * @return Value converted to double.
     */
    public double realValue() { 
        throw new ConstantEvaluationException(this, "get real value of "); 
    }
    
    /**
     * Convert to a vector of double, default implementation.
     * 
     * @return Value converted to double vector.
     */
    public double[] realVector() { 
        throw new ConstantEvaluationException(this, "get real vector of "); 
    }
    
    /**
     * Convert to a matrix of doubles, default implementation.
     * 
     * @return Value converted to double matrix.
     */
    public double[][] realMatrix() { 
        throw new ConstantEvaluationException(this, "get real matrix of "); 
    }
    
    /**
     * Convert to boolean, default implementation.
     * 
     * @return Value converted to boolean.
     */
    public boolean booleanValue() { 
        throw new ConstantEvaluationException(this, "get boolean value of "); 
    }
    
    /**
     * Convert to string, default implementation.
     * 
     * @return Value converted to string.
     */
    public String stringValue() { 
        throw new ConstantEvaluationException(this, "get string value of "); 
    }
    
    /**
     * Convert to a vector of strings, default implementation.
     * 
     * @return Value converted to string vector.
     */
    public String[] stringVector() { 
        throw new ConstantEvaluationException(this, "get string vector of "); 
    }

    /**
     * Convert to Object, default implementation.
     * 
     * @return Value as an Object.
     */
    public Object objectValue() { 
        throw new ConstantEvaluationException(this, "get value of "); 
    }

    /**
     * Calculate the min value of this constant value.
     * Works for integer, real and array CValues.
     * 
     * @return The smallest value that this CValue represent
     */
    public double minValue() {
        throw new ConstantEvaluationException(this, "get min value of "); 
    }

    /**
     * Calculate the max value of this constant value.
     * Works for integer, real and array CValues.
     * 
     * @return The largest value that this CValue represent
     */
    public double maxValue() {
        throw new ConstantEvaluationException(this, "get max value of "); 
    }
    
    /**
     * Returns true if the constant value is of integer type or array that
     * only contain integer types.
     * 
     * @return True if the constant is an integer value.
     */
    public boolean isInteger() {
        return false;
    }

    /**
     * Returns true if the constant value is of real type or array that
     * only contain real types.
     * 
     * @return True if the constant is a real value.
     */
    public boolean isReal() {
        return false;
    }

    /**
     * Returns true if the constant value is of boolean type or array that
     * only contain boolean types.
     * 
     * @return True if the constant is a boolean value.
     */
    public boolean isBoolean() {
        return false;
    }

    /**
     * Returns true if the constant value is of string type or array that
     * only contain string types.
     * 
     * @return True if the constant is a string value.
     */
    public boolean isString() {
        return false;
    }

    /**
     * Returns true if the constant value is of enum type or array that
     * only contain enum types.
     * 
     * @return True if the constant is a enum value.
     */
    public boolean isEnum() {
        return false;
    }

    /**
     * Returns true if the constant value is of numeric type.
     * 
     * @return True if the constant is a numerical value.
     */
    public boolean isNumeric() {
        return false;
    }
    
    /**
     * Check if there was an error in the evaluation.
     *
     * @return true if there was an error, otherwise false. 
     */
    public boolean isUnknown() {
        return false;
    }
    
    /**
     * Check if there was an error in any part of the evaluation.
     *
     * @return true if there was an error, otherwise false. 
     */
    public boolean isPartlyUnknown() {
        return isUnknown();
    }
    
    /**
     * Check if there was a compliance error in the evaluation.
     *
     * @return true if there was a compliance error, otherwise false. 
     */
    public boolean isUnsupported() {
        return false;
    }

    /**
     * Returns true if the constant value is of scalar numeric type and has a negative value.
     */
    public boolean isNegative() {
        return false;
    }

    /**
     * Returns false if the constant value is NaN, infinity or unknown.
     */
    public boolean isValid() {
        return true;
    }

    /**
     * Overloading of the toString() method.
     * 
     * @return The string.
     */
    @Override
    public String toString() { 
        return stringValue(); 
    }
   
    /**
     * 
     * Returns true if the constant value represents a scalar value.
     * @return True if constant is a scalar
     */
    public final boolean isScalar() {
        return !isArray();
    }

    /**
     * Returns true if the constant value represents an array.
     * ,
     * @return True if constant is an array.
     */
    public boolean isArray() {
        return false;
    }
    
    /**
     * Returns true if the constant value is a vector.
     * 
     * @return True if the constant is a vector
     */
    public final boolean isVector() {
        return ndims() == 1;
    }

    /**
     * Returns true if the constant value is a matrix.
     * 
     * @return True if the constant is a matrix
     */
    public final boolean isMatrix() {
        return ndims() == 2;
    }

    /**
     * Returns the number of dimensions of the value. 
     * A scalar value will return 0.
     */
    public int ndims() {
        return 0;
    }

    /**
     * Check if this is a record.
     */
    public boolean isRecord() {
        return false;
    }
    
    /**
     * Checks if this value can be used as an integer value.
     * 
     * @return
     *          {@code true} if this value can be used as an integer, {@code false} otherwise.
     */
    public boolean hasIntValue() {
        return false;
    }
    
    /**
     * Checks if this value can be used as a boolean value.
     * 
     * @return
     *          {@code true} if this value can be used as a boolean, {@code false} otherwise.
     */
    public boolean hasBooleanValue() {
        return false;
    }
    
    /**
     * Checks if this value can be used as a double value.
     * 
     * @return
     *          {@code true} if this value can be used as a double, {@code false} otherwise.
     */
    public boolean hasRealValue() {
        return false;
    }
    
    /**
     * Checks if this value can be used as a string value.
     * 
     * @return
     *          {@code true} if this value can be used as a string, {@code false} otherwise.
     */
    public boolean hasStringValue() {
        return false;
    }
    
    /**
     * Checks if this value is an unknown caused by an unresolvable access.
     */
    public boolean isUnknownAccess() {
        return false;
    }
    
    /**
     * If this value is an unknown access returns the access as a string, otherwise null.
     */
    public String access() {
        throw new ConstantEvaluationException(this, "get access from");
    }
    
    /**
     * If this value is an unknown access returns the access as a string, otherwise null.
     */
    public String[] accessVector() {
        throw new ConstantEvaluationException(this, "get access vector from");
    }
}
