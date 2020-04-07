/*
    Copyright (C) 2017 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.util.annotations;

import org.jmodelica.common.URIResolver.URIException;
import org.jmodelica.util.values.Evaluable;

/**
 * Generic interface which all nodes that are supposed to be navigable by
 * {@code GenericAnnotationNode}. This includes modifications and annotations.
 * Provides methods for traversing the tree structure and manipulating the data.
 * 
 * <p><strong>Overview</strong>:
 * <p>FlatAnnotationProvider: <br>
 *     AnnotationProvider for the Flat tree used for navigating and working with FAttributes & FAttributeList.
 *     Implemented in FlatAnnotation as private class (ListAnnotationProvider)) 
 *     in order to work with FAttributeLists.
 *
 * <p>SrcAnnotationProvider:<br>
 *     AnnotationProvider for modifications and annotations in the SourceTree.
 *     Implemented by SrcModification and SrcAnnotation directly. SrcComponent and SrcClassDecl provide 
 *     providers which obtain their annotations and modifiers.
 *
 * <p>SrcIterableAnnotationProvider:<br>
 *     Immutable AnnotationProvider type used by, among others, SrcComponentDecl, SrcShortClassDecl and SrcExtendClause
 *     to obtain their annotations. 
 *
 * <p>RootAnnotationProvider:<br>
 *     Bridge provider for elements (classes & components and extendsClauses)
 *     which aren't modifications themselves but can have modifications.
 *     Methods are delegated to the actual annotation. Implemented typically as an anonymous inner class.
 *
 * <p>ASTAnnotationAnnotationProvider:<br>
 *     Bridge provider for elements (classes & components and extendsClauses)
 *     which aren't annotations themselves but can have annotations.
 *
 * <p>SrcAnnotationIteratorProvider:<br>
 *     Represents a fixed array of annotations which can be iterated.
 *     The array is not mutable.
 *
 * <p>ExpValueProvider:<br>     
 *     For navigating expressions (SrcExp). 
 *     Avoiding having expressions being providers themselves which is generally inconvenient.
 *     The only expressions that are providers themselves are SrcFunctionCall and SrcArrayConstructor,
 *     as they are special in the case that they are the only expressions that can have sub-annotations.
 *     
 * @param <N> The base node type which we deal with
 * @param <V> The value that is returned by the nodes
 * 
 */
public interface AnnotationProvider<N extends AnnotationProvider<N, V>, V extends Evaluable> {
    public Iterable<SubAnnotationPair<N>> annotationSubNodes();
    
    /**
     * Returns either the binding expression, if available, otherwise the annotation interpreted as a value,
     * if possible. Otherwise, returns <code>null</code>.
     */
    public V annotationValue();

    /**
     * Checks whether this AnnotationProvider supports setting new annotation values.
     * @return <code>true</code> if a subsequent call to {@link #setAnnotationValue} will succeed; <code>false</code> if
     *         a subsequent call to {@link #setAnnotationValue} will throw an exception.
     */
    public boolean canChangeAnnotationValue();
    
    /**
     * Change the value of this Annotation/modification if possible.
     * @param newValue The new value
     * @throws FailedToSetAnnotationValueException If the value cannot be changed.
     */
    public void setAnnotationValue(V newValue) throws FailedToSetAnnotationValueException;
    
    /**
     * Create a new subannotation for the given name
     * @param name The name to create a subannotation for.
     * @return The annotationProvider for the new subannotation.
     * @throws AnnotationEditException If the subannotation cannot be created.
     */
    public N addAnnotationSubNode(String name) throws AnnotationEditException;
    
    public boolean isEach();
    public boolean isFinal();
    public String resolveURI(String str) throws URIException;

    /**
     * A (name, value) pair representing a sub-annotation.
     * The name can be <code>null</code>.
     * @param <N> The base node type which we deal with
     */
    public interface SubAnnotationPair<N> {
        public String getAnnotationName();
        public N getAnnotationValue();
    }

    public static class SubAnnotationPairImpl<N> implements SubAnnotationPair<N> {
        private final String name;
        private final N node;
        public SubAnnotationPairImpl(String name, N node) {
            this.name = name;
            this.node = node;
        }
        @Override
        public String getAnnotationName() {
            return name;
        }
        @Override
        public N getAnnotationValue() {
            return node;
        }
    }
}
