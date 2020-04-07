package org.jmodelica.util.annotations;

import org.jmodelica.test.common.AssertMethods;
import org.jmodelica.util.annotations.mock.DummyAnnotProvider;
import org.jmodelica.util.annotations.mock.DummyAnnotationNode;

import static org.jmodelica.util.annotations.mock.DummyAnnotProvider.newProvider;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class GenericAnnotationNodeTest extends AssertMethods {

    /**
     * Create a standard construction top(a(ab=4,ab=5)=1, b(ba=1,bb=2)=2, c=3)
     * 
     */
    public static DummyAnnotationNode createDefault() {
        DummyAnnotProvider n = newProvider("top").addNodes(
                newProvider("a", 1).addNodes(
                        newProvider("ab", 4),
                        newProvider("ab", 5)),
                newProvider("b", 2).addNodes(
                        newProvider("ba", 1),
                        newProvider("bb", 2)),
                newProvider("c", 3)
        );
        return n.createAnnotationNode();
    }

    /*
     * Test GenericAnnotationNode
     */
    @Test
    public void testValueAsAnnotationForAmbiguous() {
        DummyAnnotationNode n = createDefault();
        assertTrue(n.forPath("a", "ab").valueAsAnnotation().isAmbiguous());
    }

    @Test
    public void testToStringExisting() {
        DummyAnnotProvider n = newProvider("top");
        n.addNodes(newProvider("a").addNodes(newProvider("n", 3)));
        DummyAnnotationNode testNode = n.createAnnotationNode();

        assertEquals("top(a(n=3))", testNode.toString());
    }

    @Test
    public void testExistsForExistingNode() {
        DummyAnnotProvider n = newProvider("top");
        n.addNodes(newProvider("a").addNodes(newProvider("n", 3)));
        DummyAnnotationNode testNode = n.createAnnotationNode();

        assertTrue(testNode.forPath("a").nodeExists());
    }

    @Test
    public void testExistingForNonexistingNode() {
        DummyAnnotProvider n = newProvider("top");
        n.addNodes(newProvider("a").addNodes(newProvider("n", 3)));

        DummyAnnotationNode testNode = n.createAnnotationNode();
        assertFalse(testNode.forPath("n").nodeExists());
    }

    @Test
    public void testNotExistAfterReplaced() {
        DummyAnnotationNode top = newProvider("top").addNodes(
                newProvider("test")).createAnnotationNode();
        DummyAnnotationNode replaced = top.forPath("test");
        top.disconnectFromNode();
        top.testSrcRemoveAll();
        top.updateNode("top", newProvider("p"));
        assertFalse(replaced.nodeExists());
    }

    @Test
    public void testNoSyncAfterSet() {
        DummyAnnotProvider n1 = newProvider("top").addNodes(newProvider("test"));
        DummyAnnotProvider n2 = newProvider("top").addNodes(newProvider("test"));
        DummyAnnotationNode top = n1.createAnnotationNode(); 
        top.updateNode("top", n2);
        assertFalse(top.hasSubNodesCache());
    }

    @Test
    public void testConstructionOfComplexNode () {
        DummyAnnotProvider n = newProvider("top").addNodes(
                newProvider("a").addNodes(
                        newProvider("n", "3").addNodes(
                                newProvider("u").addNodes(
                                        newProvider("v", "4")),
                                newProvider("k", "3")),
                        newProvider("v", "4"),
                        newProvider("q", "5")
                )
        );
        assertEquals("top(a(n(u(v=4), k=3)=3, v=4, q=5))", n.createAnnotationNode().toString());
    }

    @Test
    public void updateTopNode() {
        DummyAnnotationNode n = createDefault();
        n.updateNode("newTop", n.node());
        assertEquals("newTop(a(ab=4, ab=5)=1, b(ba=1, bb=2)=2, c=3)", n.toString());
    }
    
    @Test
    public void updateSubNode() {
        DummyAnnotationNode n = createDefault();
        DummyAnnotationNode subNode = n.subNodes().iterator().next();
        subNode.node().name = "newa";
        subNode.updateNode("newa", subNode.node());
        assertEquals("top(newa(ab=4, ab=5)=1, b(ba=1, bb=2)=2, c=3)", n.toString());
    }

    @Test
    public void testNode() {
        DummyAnnotationNode n = createDefault();
        DummyAnnotationNode newNode = n.forPath("newNode");
        assertFalse(newNode.nodeExists());
        newNode.node();
        assertTrue(newNode.nodeExists()); 
    }

    @Test
    public void existingFilteredIterator() {
        DummyAnnotationNode n = createDefault();
        n.testSrcRemoveAll();
        n.disconnectFromNode();
        assertEmpty(n.forPath("a").subNodes().iterator());
        assertEquals("n", n.forPath("n").toString());
    }

    @Test
    public void existingFilteredIterator2() {
        DummyAnnotationNode n = createDefault();
        n.forPath("a").testSrcRemoveAll();
        n.forPath("a").disconnectFromNode();
        assertEmpty(n.forPath("a").subNodes().iterator());
        assertEquals("top(a=1, b(ba=1, bb=2)=2, c=3)", n.toString());
    }

    @Test
    public void recalculatedFromSource() {
        DummyAnnotationNode n = createDefault();
        n.forPath("b").disconnectFromNode(); // Source untouched.
        assertEquals("top(a(ab=4, ab=5)=1, b(ba=1, bb=2)=2, c=3)", n.toString());
    }

    @Test
    public void testForPathNoneCreating() {
        DummyAnnotationNode testNode = newProvider("top").createAnnotationNode();
        testNode.forPath("a");
        testNode.forPath("else");
        assertEmpty(testNode.subNodes());
    }

    @Test
    public void disconnectNonExistentNode() {
        DummyAnnotationNode n = createDefault();
        String orginal = n.toString();
        n.forPath("n").disconnectFromNode();
        assertEquals(orginal, n.toString());
    }

    @Test
    public void testReplaceWithSubNodes() {
        DummyAnnotProvider n = newProvider("top");
        n.addNodes(
                newProvider("a").addNodes(
                        newProvider("n", 3)
                )
        );
        DummyAnnotProvider replacement = new DummyAnnotProvider("newNode");
        replacement.addAnnotationSubNode("a").addNodes(new DummyAnnotProvider("aa", 1));
        DummyAnnotationNode testNode = n.createAnnotationNode();

        DummyAnnotationNode replacementNode = testNode.forPath("a", "n");
        replacementNode.updateNode("newNode", replacement);

        testNode.forPath("a").node().subNodes.clear();
        testNode.forPath("a").node().addNodes(replacement);

        assertEquals("top(a(newNode(a(aa=1))))", testNode.toString());
    }
}
