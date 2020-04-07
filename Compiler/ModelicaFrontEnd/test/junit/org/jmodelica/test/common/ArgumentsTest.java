package org.jmodelica.test.common;

import static org.junit.Assert.assertEquals;

import org.jmodelica.util.Arguments;
import org.jmodelica.util.Arguments.InvalidArgumentException;
import org.junit.Test;

public class ArgumentsTest {

    private static Arguments construct(String... args) throws InvalidArgumentException {
        return new Arguments("ModelicaCompiler", args);
    }

    @Test(expected = InvalidArgumentException.class)
    public void manyInputs() throws InvalidArgumentException {
        construct("a", "b", "c", "d");
    }

    @Test(expected = InvalidArgumentException.class)
    public void unknownOption() throws InvalidArgumentException {
        construct("-target=cs", "-log=w|os|stderr", "test", "libPath", "-unknownOption=value");
    }

    @Test(expected = InvalidArgumentException.class)
    public void noInput() throws InvalidArgumentException {
        construct();
    }

    @Test(expected = InvalidArgumentException.class)
    public void onlyOptionArguments() throws InvalidArgumentException {
        construct("-target=cs", "-modelicapath=X", "-log=w|os|stderr");
    }

    @Test
    public void parseOneNoOptionArgument() throws InvalidArgumentException {
        Arguments args = construct("-target=parse", "-modelicapath=X", "-log=w|os|stderr", "libraryPath");
        assertEquals("libraryPath", args.libraryPath());
    }

    @Test
    public void classNameOneNoOptionArgument() throws InvalidArgumentException {
        Arguments args = construct("-target=cs", "-modelicapath=X", "-log=w|os|stderr", "test");
        assertEquals("test", args.className());
    }

    @Test
    public void libraryPathOneNoOptionArgument() throws InvalidArgumentException {
        Arguments args = construct("-target=cs", "-modelicapath=X", "-log=w|os|stderr", "test");
        assertEquals("test", args.className());
        assertEquals("", args.libraryPath());
    }

    @Test
    public void twoNonOptionArguments() throws InvalidArgumentException {
        Arguments args = construct("-target=cs", "-modelicapath=X", "-log=w|os|stderr", "libraryPath", "test");
        assertEquals("test", args.className());
        assertEquals("libraryPath", args.libraryPath());
    }

    /*
     * Test the arguments' check.
     */

    @Test
    public void oneArgumentModelicaPathAndParse() throws InvalidArgumentException {
        construct("-target=parse", "-modelicapath=X", "-log=w|os|stderr", "test");
    }

    @Test
    public void oneArgumentModelicaPathNoParse() throws InvalidArgumentException {
        construct("-target=cs", "-modelicapath=X", "-log=w|os|stderr", "test");
    }

    @Test
    public void oneArgumentNoModelicaPathAndParse() throws InvalidArgumentException {
        construct("-target=parse", "-log=w|os|stderr", "test");
    }

    @Test(expected = InvalidArgumentException.class)
    public void oneArgumentNoModelicaPathNoParse() throws InvalidArgumentException {
        construct("-target=cs", "-log=w|os|stderr", "test");
    }

    @Test(expected = InvalidArgumentException.class)
    public void twoArgumentsModelicaPathAndParse() throws InvalidArgumentException {
        construct("-target=parse", "-modelicapath=X", "-log=w|os|stderr", "test", "libPath");
    }

    @Test
    public void twoArgumentsModelicaPathNoParse() throws InvalidArgumentException {
        construct("-target=cs", "-modelicapath=X", "-log=w|os|stderr", "test", "libPath");
    }

    @Test(expected = InvalidArgumentException.class)
    public void twoArgumentsNoModelicaPathAndParse() throws InvalidArgumentException {
        construct("-target=parse", "-log=w|os|stderr", "test", "libPath");
    }

    @Test
    public void twoArgumentsNoModelicaPathNoParse() throws InvalidArgumentException {
        construct("-target=cs", "-log=w|os|stderr", "test", "libPath");
    }

}
