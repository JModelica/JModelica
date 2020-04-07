package org.jmodelica.test.common;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.assertFalse;

import org.jmodelica.common.GUIDManager;
import org.junit.Before;
import org.junit.Test;

public class GUIDManagerTest {
    
    private GUIDManager guidManager;
    
    @Before
    public void setup() {
        guidManager = new GUIDManager("GUID_Tester", "1.0");
    }
    
    private void test(String source, String[] dependent, String[] expected) {
        guidManager.setSourceString(source);
        StringBuilder[] output = new StringBuilder[dependent.length];
        for (int i = 0; i < dependent.length; i++) {
            output[i] = new StringBuilder();
            guidManager.addDependentString(dependent[i], output[i]);
        }
        guidManager.processDependentFiles();
        for (int i = 0; i < expected.length; i++) {
            assertEquals(ignoreWhitespace(expected[i]), ignoreWhitespace(output[i].toString()));
        }
    }
    
    private String ignoreWhitespace(String string) {
        return string.trim();
    }
    
    @Test
    public void testGuid() {
        String[] dependent = {"guid=" + guidManager.getGuidToken()};
        String[] expected = {"guid=fd3dbec9730101bff92acc820befc34"};
        test("Test string", dependent, expected);
    }
    
    @Test
    public void testDate() {
        String input = "guid=" + guidManager.getGuidToken() + ", date=" + guidManager.getDateToken();
        String expected = "guid=277efff8e9f33c422aa6e3fecb8b592";
        guidManager.setSourceString(input);
        StringBuilder output = new StringBuilder();
        guidManager.addDependentString(input, output);
        guidManager.processDependentFiles();
        String actual = output.toString();
        assertEquals(expected, actual.substring(0, expected.length()));
        assertFalse(input.equals(actual));
        actual = actual.substring(expected.length() + 2);
        assertTrue(actual + " does not match date pattern", actual.trim().matches("date=[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}"));
    }
    
    @Test
    public void testCompilerVersion() {
        String[] dependent = {"guid=" + guidManager.getGuidToken() + ", cv=" + guidManager.getCompilerVersionToken()};
        String[] expected = {"guid=529d037245bb851e67db9a7df5a048e1, cv=1.0"};
        test(guidManager.getGuidToken() + " " + guidManager.getCompilerVersionToken(),
                dependent, expected);
    }
    
    @Test
    public void testTwoToolTokens() {
        String[] dependent = {"generationTool=" + guidManager.getGenerationToolToken()
                + "\nTool name=" + guidManager.getToolNameToken()};
        String[] expected = {"generationTool=GUID_Tester\nTool name=GUID_Tester"};
        test("", dependent, expected);
    }
    
    @Test
    public void twoGuidSameLine() {
        String source = guidManager.getGuidToken() + " " + guidManager.getGuidToken();
        String expected = "2b84c9f19d607e5ecae42d8ac40f5c48" + " " + guidManager.getGuidToken();
        test(source, new String[]{source}, new String[]{expected});
    }
    
    @Test
    public void twoGuidDifferentLines() {
        String source = guidManager.getGuidToken() + "\n" + guidManager.getGuidToken();
        String expected = "a68b2a2d03d772bafedb0fa15febaf08" + "\n" + guidManager.getGuidToken();
        test(source, new String[]{source}, new String[]{expected});
    }
    
    @Test
    public void guidTwoDependentFiles() {
        test("Test string",
                new String[]{guidManager.getGuidToken(), "guid: " + guidManager.getGuidToken()},
                new String[]{"fd3dbec9730101bff92acc820befc34", "guid: fd3dbec9730101bff92acc820befc34"});
    }
    
    @Test
    public void guidLineBreaks() {
        String[] dependent = {guidManager.getGuidToken()};
        String[] expected = {"de471a9016ad61d89970490da698ac3"};
        test("Teststring", dependent, expected);
        test("Test\nstring", dependent, expected);
        test("Test\r\nstring", dependent, expected);
    }

}
