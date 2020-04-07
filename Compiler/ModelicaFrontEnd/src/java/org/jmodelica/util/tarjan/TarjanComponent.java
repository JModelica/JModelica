package org.jmodelica.util.tarjan;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

public class TarjanComponent<N> implements Iterable<N> {
    private Collection<N> members = new LinkedHashSet<>();
    private Collection<N> predecessors = null;

    public void addPredecessors(Collection<N> newPredecessors) {
        if (predecessors == null) {
            predecessors = new LinkedHashSet<>();
        }
        for (N node : newPredecessors) {
            if (!members.contains(node)) {
                predecessors.add(node);
            }
        }
    }

    public void addMember(N member) {
        // Ensure that the member isn't in the list of predecessors
        if (predecessors != null) {
            predecessors.remove(member);
        }
        members.add(member);
    }

    public void mergeWith(TarjanComponent<N> other) {
        members.addAll(other.members);
        if (predecessors != null) {
            predecessors.removeAll(other.members);
        }
        if (other.predecessors != null) {
            addPredecessors(other.predecessors);
        }
    }

    @Override
    public Iterator<N> iterator() {
        return members.iterator();
    }

    public Collection<N> getMembers() {
        return members;
    }

    public boolean hasPredecessorInfo() {
        return predecessors != null;
    }

    public Collection<N> getPredecessors() {
        return predecessors;
    }

    @Override
    public String toString() {
        return members.toString();
    }

    public static <C extends TarjanComponent<N>, N> Map<C, Collection<C>>
    computePredecessorsMap(Collection<C> components) {
        Map<N, C> nodeToComponentMap = new HashMap<>();
        for (C component : components) {
            for (N node : component.getMembers()) {
                nodeToComponentMap.put(node, component);
            }
        }
        Map<C, Collection<C>> res = new HashMap<>();
        for (C component : components) {
            Set<C> predecessors = new LinkedHashSet<>();
            for (N predecessor : component.getPredecessors()) {
                predecessors.add(nodeToComponentMap.get(predecessor));
            }
            res.put(component, new ArrayList<>(predecessors));
        }
        return res;
    }

}
