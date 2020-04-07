package org.jmodelica.util.tarjan;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * A simple implementation of Tarjan where visited, index and lowLink is
 * handled internally by hashmaps and hashsets.
 */
public abstract class SimpleTarjan<N> extends Tarjan<N, TarjanComponent<N>> {
    
    private final Set<N> visited = new HashSet<N>();
    private final Map<N, Integer> index = new HashMap<N, Integer>();
    private final Map<N, Integer> lowLink = new HashMap<N, Integer>();


    @Override
    protected final boolean visited(N n) {
        return visited.contains(n);
    }

    @Override
    protected final void setVisited(N n, boolean val) {
        if (val) {
            visited.add(n);
        } else {
            visited.remove(n);
        }
    }

    @Override
    protected final int getIndex(N n) {
        return index.get(n);
    }

    @Override
    protected final void setIndex(N n, int val) {
        index.put(n, val);
    }

    @Override
    protected final int getLowLink(N n) {
        return lowLink.get(n);
    }

    @Override
    protected final void setLowLink(N n, int val) {
        lowLink.put(n, val);
    }

    @Override
    protected final TarjanComponent<N> createComponent() {
        return new TarjanComponent<N>();
    }

    /**
     * Default implementation, override if needed!
     */
    @Override
    protected boolean shouldVisit(N n) {
        return true;
    }

}
