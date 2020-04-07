package org.jmodelica.util.annotations.mock;

import java.util.ArrayList;

import org.jmodelica.common.URIResolver.URIException;
import org.jmodelica.util.annotations.AnnotationEditException;
import org.jmodelica.util.annotations.AnnotationProvider;
import org.jmodelica.util.annotations.FailedToSetAnnotationValueException;
import org.jmodelica.util.collections.TransformerIterable;
import org.jmodelica.util.values.Evaluable;

public class DummyAnnotProvider implements AnnotationProvider<DummyAnnotProvider,Evaluable> {

    public String name;
    public Evaluable value = null;
    public ArrayList<DummyAnnotProvider> subNodes = new ArrayList<>();
    public DummyAnnotProvider() {
        this.name = "";
    }

    public DummyAnnotProvider(String name) {
        this.name=name;
    }

    public DummyAnnotProvider(String name, int value) {
        this.value=new DummyEvaluator(value);
        this.name=name;
    }

    public DummyAnnotProvider(String name, String value) {
        this.value=new DummyEvaluator(value);
        this.name=name;
    }
    
    /**
     * Convenient constructors for DummyAnnotProvider
     */
    
    public static DummyAnnotProvider newProvider(String name) {
        return new DummyAnnotProvider(name);
    }
    
    public static DummyAnnotProvider newProvider(String name, int value) {
        return new DummyAnnotProvider(name, value);
    }
    
    public static DummyAnnotProvider newProvider(String name, String value) {
        return new DummyAnnotProvider(name, value);
    }
    
    @Override
    public Iterable<SubAnnotationPair<DummyAnnotProvider>> annotationSubNodes() {
        return new TransformerIterable<DummyAnnotProvider, SubAnnotationPair<DummyAnnotProvider>>(subNodes) {
            @Override
            protected SubAnnotationPair<DummyAnnotProvider> transform(DummyAnnotProvider a) throws SkipException {
                return new SubAnnotationPairImpl<>(a.name, a);
            }
        };
    }

    @Override
    public String toString() {
        return "MockSrcAnnot:" + name;
    }

    @Override
    public Evaluable annotationValue() {
        return value;
    }

    @Override
    public void setAnnotationValue(Evaluable newValue) throws FailedToSetAnnotationValueException {
        value = newValue;
    }
    
    @Override
    public boolean canChangeAnnotationValue() {
        return true;
    }

    @Override
    public DummyAnnotProvider addAnnotationSubNode(String name) throws AnnotationEditException {
       DummyAnnotProvider newNode = new DummyAnnotProvider(name);
       subNodes.add(newNode);
       return newNode;
    }

    /**
     * Convenience method for adding an existing DummyAnnotProvider directly to this node.
     * Warning creating cycles could cause problems.
     */
    public DummyAnnotProvider addNodes(DummyAnnotProvider... subNodes) {
        for (DummyAnnotProvider subNode: subNodes) {
            this.subNodes.add(subNode);
        }
        return this;
    }

    public DummyAnnotationNode createAnnotationNode() {
        return new DummyAnnotationNode(name, this, null);
    }

    @Override
    public boolean isEach() {
        return false;
    }

    @Override
    public boolean isFinal() {
        return false;
    }

    @Override
    public String resolveURI(String str) throws URIException {
        return null;
    }

}
