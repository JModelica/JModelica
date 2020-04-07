package org.jmodelica.util.tarjan;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import org.jmodelica.util.Enumerator;
import org.jmodelica.util.collections.HashStack;

/**
 * Implementation of Tarjan's strongly connected components.
 * 
 * @param <N> Type of nodes which are sorted by Tarjan
 * @param <C> Type of the result object.
 */
public abstract class Tarjan<N, C extends TarjanComponent<N>> {
    
    /**
     * Determines whether the node <code>n</code> has been visited.
     * 
     * @param n Node in question
     * @return If it ha been visited
     */
    protected abstract boolean visited(N n);

    /**
     * Set the visited value <code>val</code> for node <code>n</code>.
     * 
     * @param n Node in question
     * @param val New visited value
     */
    protected abstract void setVisited(N n, boolean val);

    /**
     * Method which determines if the node <code>n</code> should be included in
     * the Tarjan problem and result.
     * 
     * @param n Node in question
     * @return true if the node should be included, otherwise false.
     */
    protected abstract boolean shouldVisit(N n);

    /**
     * Computes predecessors for the node <code>n</code>. Implementing classes
     * should add predecessors to the collection <code>predecessors</code>.
     * 
     * For efficiency the result list is given as argument instead of returning
     * a collection from this method.
     * 
     * @param n Node in question
     * @param predecessors A collection where predecessors are added
     */
    protected abstract void addPredecessors(N n, Collection<N> predecessors);

    /**
     * Get the Tarjan index for the node <code>n</code>
     * 
     * @param n Node in question
     * @return Tarjan index
     */
    protected abstract int getIndex(N n);

    /**
     * Set the Tarjan index for the node <code>n</code>
     * 
     * @param n Node in question
     * @param val new Tarjan index
     */
    protected abstract void setIndex(N n, int val);

    /**
     * Get the Tarjan low link index for the node <code>n</code>
     * 
     * @param n Node in question
     * @return Tarjan low link index
     */
    protected abstract int getLowLink(N n);

    /**
     * Get the Tarjan low link index for the node <code>n</code>
     * 
     * @param n Node in question
     * @param val new Tarjan low link index
     */
    protected abstract void setLowLink(N n, int val);

    /**
     * By adding nodes to the collection <code>members</code> they are forced
     * into the same component as the node <code>n</code>.
     * 
     * This method is optional, default implementation is to do nothing.
     * 
     * @param n Node in question
     * @param members
     *      A collection where nodes forced into the same block are added
     */
    protected void forceIntoSame(N n, Set<N> members) {
        // Do nothing by default
    }

    /**
     * Creates a new and empty component
     * @return An empty component
     */
    protected abstract C createComponent();

    /**
     * Computes strongly connected components.
     * @param nodes The list of nodes to sort
     * @return A computation order of nodes
     */
    public Collection<C> tarjan(Collection<N> nodes) {
        Enumerator indexer = new Enumerator();
        HashStack<N> stack = new HashStack<>();
        Collection<C> components = new ArrayList<>();
        Map<N, Collection<N>> predecessorCache = new HashMap<>();
        
        for (N n : nodes) {
            if (!visited(n) && shouldVisit(n))
                tarjan(n, indexer, stack, components, predecessorCache);
        }
        
        return components;
    }

    private void tarjan(N initialNode, Enumerator indexer, HashStack<N> stack, Collection<C> components,
            Map<N, Collection<N>> predecessorCache) {
        int index = indexer.next();
        
        Set<N> sameBlock = new LinkedHashSet<>();
        sameBlock.add(initialNode);
        forceIntoSame(initialNode, sameBlock);
        
        for (N n : sameBlock) {
            setIndex(n, index);
            setLowLink(n, index);
            setVisited(n, true);
            stack.push(n);
        }
    
        Collection<N> eqToVisit = new LinkedHashSet<>();
        
        for (N n : sameBlock) {
            addPredecessors(n, eqToVisit);
            predecessorCache.put(n, eqToVisit);
        }
    
        for (N predecessor : eqToVisit) {
            if (!visited(predecessor)) {
                tarjan(predecessor, indexer, stack, components, predecessorCache);
                for (N n : sameBlock) {
                    setLowLink(n, Math.min(getLowLink(n), getLowLink(predecessor)));
                }
            } else if (stack.contains(predecessor)) {
                for (N n : sameBlock) {
                    setLowLink(n, Math.min(getLowLink(n), getIndex(predecessor)));
                }
            }
        }
    
        if (getIndex(initialNode) == getLowLink(initialNode)) {
            C component = createComponent();
            N n;
            do {
                n = stack.pop();
                component.addMember(n);
                // TODO: This is rather inefficient since we insert the same predecessor list multiple times!
                component.addPredecessors(predecessorCache.remove(n)); 
                
            } while (n != initialNode);
            components.add(component);
        }
    }
}
