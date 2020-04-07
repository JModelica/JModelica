package org.jmodelica.build.options;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import java.io.*;

import org.jmodelica.build.options.OptionsAggregator.OptionsAggregationException;
import org.junit.Test;

public class OptionsAggregatorTests {

    private class StringOutputStream extends OutputStream {
        private StringBuilder sb = new StringBuilder();
        @Override
        public void write(int b) throws IOException {
            this.sb.append((char) b );
        }
        @Override
        public String toString() {
            return sb.toString();
        }
    }
    
    OptionsAggregator setup(String s) throws IOException, OptionsAggregationException {
        OptionsAggregator op = new OptionsAggregator();
        try(BufferedReader reader = new BufferedReader(new StringReader(s))) {
            op.parseFile("/file/path", reader);
        }
        return op;
    }
    
    @Test
    public void testLongLine() throws IOException {
        try {
            setup(""
                    + "BOOLEAN opt1 compiler user true"
                    + "BOOLEAN opt2 compiler user true"
                );
            fail();
        } catch (OptionsAggregationException e) {
            String expected = "Too many parts on the line! /file/path\nBOOLEAN opt1 compiler user trueBOOLEAN opt2 compiler user true";
            assertEquals(expected, e.getMessage());
        }
    }
    
    @Test
    public void testSameName() throws IOException {
        try {
            setup(""
                    + "BOOLEAN opt1 compiler user true\n"
                    + "\n"
                    + "\"\"\n"
                    + "\n"
                    + "BOOLEAN opt1 compiler user true\n"
                );
            fail();
        } catch (OptionsAggregationException e) {
            assertEquals("Found duplicated option declaration for opt1. Old declaration from /file/path. New declaration from /file/path.", e.getMessage());
        }
    }
    
    @Test
    public void testModifyNonExistent() throws IOException, OptionsAggregationException {
        OptionsAggregator op = setup("DEFAULT opt1 false\n");
        try {
            op.modify();
            fail();
        } catch (OptionsAggregationException e) {
            assertEquals("Missing option for modification DEFAULT opt1", e.getMessage());
        }
    }
    
    @Test
    public void testDoubleModification() throws IOException, OptionsAggregationException {
        OptionsAggregator op = setup(""
                + "BOOLEAN opt1 compiler user true\n"
                + "\n"
                + "\"\"\n"
                + "\n"
                + "DEFAULT opt1 false\n"
                + "\n"
                + "DEFAULT opt1 false\n"
                );
        try {
            op.modify();
            fail();
        } catch (OptionsAggregationException e) {
            assertEquals("Option already modified opt1", e.getMessage());
        }
    }

    @Test
    public void testFull() throws IOException, OptionsAggregationException {
        OptionsAggregator op = setup(""
                + "BOOLEAN opt1 compiler user true\n"
                + "\n"
                + "\"\"\n"
                + "\n"
                + "BOOLEAN opt2 runtime experimental false\n"
                + "\n"
                + "\"A description\"\n"
                );
        op.modify();
        try (StringOutputStream os = new StringOutputStream()) {
            try(PrintStream out = new PrintStream(os)) {
                op.generate(out, "org.pack");
            }
            String expected = String.format(OptionsAggregator.HEADER
                    + "    public final BooleanOption opt1 = new BooleanOption(\"opt1\", OptionType.compiler, Category.user,%n"
                    + "            \"\",%n"
                    + "            new DefaultValue<>(true));%n"
                    + "    public final BooleanOption opt2 = new BooleanOption(\"opt2\", OptionType.runtime, Category.experimental,%n"
                    + "            \"A description\",%n"
                    + "            new DefaultValue<>(false));%n"
                    + "%n"
                    + "    {%n"
                    + "        optionsMap.put(\"opt1\", opt1);%n"
                    + "        optionsMap.put(\"opt2\", opt2);%n"
                    + "    }%n"
                    + "%n"
                    + "    private void setTestDefaults() {%n"
                    + "    }%n"
                    + OptionsAggregator.FOOTER,
                    "org.pack");
            assertEquals(expected, os.toString());
        }
    }
    
    @Test
    public void testModification() throws IOException, OptionsAggregationException {
        OptionsAggregator op = setup(""
                + "BOOLEAN opt1 compiler user true\n"
                + "\n"
                + "\"\"\n"
                + "\n"
                + "DEFAULT opt1 false\n"
                + "\n"
                );
        op.modify();
        try (StringOutputStream os = new StringOutputStream()) {
            try (PrintStream out = new PrintStream(os)) {
                op.generateTestDefaults(out, "");
            }
            String expected = String.format("opt1.setDefault(new DefaultValue<>(true));%n");
            assertEquals(expected, os.toString());
        }
    }
    
    @Test
    public void testInvert() throws IOException, OptionsAggregationException {
        OptionsAggregator op = setup(""
                + "BOOLEAN opt1 compiler user true\n"
                + "\n"
                + "\"\"\n"
                + "\n"
                + "BOOLEAN opt2 compiler user true\n"
                + "\n"
                + "\"\"\n"
                + "\n"
                + "INVERT opt1 opt2\n"
                + "\n"
            );
        op.modify();
        try (StringOutputStream os = new StringOutputStream()) {
            try (PrintStream out = new PrintStream(os)) {
                op.generateDeclarations(out, "");
            }
            String expected = String.format("public final BooleanOption opt1 = new BooleanOption(\"opt1\", OptionType.compiler, Category.user,%n"
                    + "        \"\",%n"
                    + "        new DefaultInvertBoolean(\"opt2\"));%n"
                    + "public final BooleanOption opt2 = new BooleanOption(\"opt2\", OptionType.compiler, Category.user,%n"
                    + "        \"\",%n"
                    + "        new DefaultValue<>(true));%n");
            assertEquals(expected, os.toString());
        }
    }
}
