package org.jmodelica.test.common;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.assertFalse;

import org.jmodelica.util.QualifiedName;
import org.jmodelica.util.exceptions.NameFormatException;
import org.junit.Test;

public class QualifiedNameTest {

    @Test
    public void globalWithQuotedContainingExcapedDot() {
        assertEquals("(global) ['quotedWith.Dot\\'.', secondPart]", 
                new QualifiedName(".'quotedWith.Dot\\'.'.secondPart").toString());
    }

    @Test
    public void globalDotted()  {
        assertEquals("(global) [first, second, third]", 
                new QualifiedName(".first.second.third").toString());
    }

    @Test
    public void global() {
        assertEquals("(global) [global]", 
                new QualifiedName(".global").toString());
    }

    @Test
    public void qoutedDotted() {
        assertEquals("['first', second, 'third']", 
                new QualifiedName("'first'.second.'third'").toString());
    }

    @Test
    public void quotedDot() {
        assertEquals("[first, '.', 'third']",
                new QualifiedName(("first.'.'.'third'")).toString());
    }

    @Test(expected=NameFormatException.class)
    public void quotesWithoutNewPathfails() {
        assertEquals("['quoted''''', second]", 
                new QualifiedName("'quoted'''''.second"));
    }

    @Test
    public void shortNameFirst() {
        assertEquals("[A, 'B', C, D]", new QualifiedName(("A.'B'.C.D")).toString());
    }

    @Test
    public void countNumberOfParts() {
        assertEquals(4, new QualifiedName("A.'B'.C.D").numberOfParts());
    }

    @Test
    public void nonSimpleNameParts() {
        assertEquals(4, new QualifiedName(".A.'B'.C.D").numberOfParts());
    }
    
    @Test
    public void globalSimpleNameParts() {
        assertTrue(QualifiedName.isValidSimpleIdentifier(".'A'", true));
    }

    @Test
    public void globalSimpleNamePartsNegative() {
        assertFalse(QualifiedName.isValidSimpleIdentifier(".'A'", false));
    }

    @Test
    public void nameFromUnqualifiedImport() {
        assertEquals(".* [A, B, C]", new QualifiedName("A.B.C.*").toString());
    }

    @Test(expected=NameFormatException.class)
    public void missplacedQuote() {
        new QualifiedName("first.secon'd.third'");
    }

    @Test(expected=NameFormatException.class)
    public void unmatchedQuotes() {
        new QualifiedName("first.'unclosedPart");
    }

    @Test(expected=NameFormatException.class)
    public void emptyNames() {
        new QualifiedName("first...last");
    }

    @Test(expected=NameFormatException.class)
    public void emptyNamesQuoted()  {
        new QualifiedName("first...'last'");
    }

    @Test(expected=NameFormatException.class)
    public void noName()  {
        new QualifiedName("");
    }
}
