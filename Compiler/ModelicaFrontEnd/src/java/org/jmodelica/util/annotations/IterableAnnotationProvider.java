package org.jmodelica.util.annotations;

import org.jmodelica.util.annotations.AnnotationProvider.SubAnnotationPair;
import org.jmodelica.util.values.Evaluable;

public interface IterableAnnotationProvider<N extends AnnotationProvider<N, V>, V extends Evaluable>
        extends AnnotationProvider<N, V>, Iterable<SubAnnotationPair<N>> {
    // No new methods
}
