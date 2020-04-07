/*
    Copyright (C) 2015 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/

#include "jmi_dyn_mem.h"

#include <stdlib.h>
#include <string.h>


jmi_dynamic_function_memory_t* jmi_dynamic_function_pool_create(size_t pool_size) {
    jmi_dynamic_function_memory_t* mem = (jmi_dynamic_function_memory_t*)calloc(1, sizeof(jmi_dynamic_function_memory_t));
    
    mem->memory_block = (void*)calloc(1, pool_size);
    mem->start_pos = (char*)(mem->memory_block);
    mem->cur_pos = mem->start_pos;
    mem->block_size = pool_size;
    mem->trailing_memory = NULL;
    mem->nbr_trailing_memory = 0;
    mem->cur_trailing_memory = 0;
    
    return mem;
}

void jmi_dynamic_function_pool_destroy(jmi_dynamic_function_memory_t* mem) {
    size_t i;
    
    if (mem != NULL) {
        free(mem->memory_block);
        for (i = 0; i < mem->nbr_trailing_memory; i++) { free(mem->trailing_memory[i]); }
        if (mem->trailing_memory != NULL) { free(mem->trailing_memory); }
        free(mem);
        mem = NULL;
    }
}

static size_t jmi_dynamic_function_pool_available(jmi_dynamic_function_memory_t *mem) {
    return mem->block_size - (size_t)(mem->cur_pos - mem->start_pos);
}

void *jmi_dynamic_function_pool_alloc(jmi_local_dynamic_function_memory_t* local_block, size_t block, int reset_memory) {
    if (local_block->mem == NULL) {
        jmi_dynamic_function_init(local_block);
    }
    
    return jmi_dynamic_function_pool_direct_alloc(local_block->mem, block, reset_memory);
}

void *jmi_dynamic_function_pool_direct_alloc(jmi_dynamic_function_memory_t* mem, size_t block, int reset_memory) {
    void *ptr = NULL;
    
    if (mem == NULL) {
        mem = jmi_dynamic_function_memory();
    }
    
    if (jmi_dynamic_function_pool_available(mem) < block) { /* Not enough memory in the block */
        
        /* Move current position to block end, necessary */
        mem->cur_pos += jmi_dynamic_function_pool_available(mem);
        
        if (mem->trailing_memory == NULL) {
            mem->trailing_memory = (char**)calloc(1, sizeof(char*));
            mem->trailing_memory[0] = (char*)calloc(1, block);
            mem->nbr_trailing_memory = 1;
        } else {
            mem->nbr_trailing_memory = mem->nbr_trailing_memory + 1;
            mem->trailing_memory = (char**)realloc(mem->trailing_memory, mem->nbr_trailing_memory*sizeof(char*));
            mem->trailing_memory[mem->nbr_trailing_memory-1] = (char*)calloc(1, block);
        }
        mem->cur_trailing_memory = mem->nbr_trailing_memory;
        ptr = mem->trailing_memory[mem->nbr_trailing_memory-1];
    } else {
        ptr = mem->cur_pos;
        if (reset_memory) {
            memset(ptr, 0, block); /* Zero out memory */
        }
        mem->cur_pos += block;
    }
        
    return ptr;
}

void jmi_dynamic_function_resize(jmi_dynamic_function_memory_t* mem) {
    /* If trailing memory has been used, see if we can allocate a larger block */
    size_t i;
    for (i = 0; i < mem->nbr_trailing_memory; i++) {
        free(mem->trailing_memory[i]);
    }
    mem->nbr_trailing_memory = 0;
    mem->cur_trailing_memory = 0;
    
    if (mem->trailing_memory != NULL) {
        free(mem->trailing_memory);
        mem->trailing_memory = NULL;
    
        /* More memory has been used, allocate larger block */
        mem->block_size = 2*(mem->block_size);
        mem->memory_block = (void*)realloc(mem->memory_block, mem->block_size);
        mem->start_pos = (char*)(mem->memory_block);
        mem->cur_pos = mem->start_pos;
    }
}

void jmi_dynamic_function_init(jmi_local_dynamic_function_memory_t* local_block) {
    /* If we have not already bound the local block to the global memory pool */
    if (local_block->mem == NULL) {
        local_block->mem = jmi_dynamic_function_memory();
    }
    
    /* Quick check for the most common case ... */
    if (local_block->mem->trailing_memory == NULL) {
    } else if (local_block->mem->cur_pos == local_block->mem->start_pos && local_block->mem->trailing_memory != NULL) {
        /* If trailing memory has been used, see if we can allocate a larger block */
        jmi_dynamic_function_resize(local_block->mem);
        
    } else {
        /* We do have trailing memory, but we are not at the start of the memory block */
        /* De allocate the surplus memory so that it does not grow uncontrollable */
        size_t i;
        for (i = local_block->mem->cur_trailing_memory; i < local_block->mem->nbr_trailing_memory; i++) {
            free(local_block->mem->trailing_memory[i]);
        }
        local_block->mem->nbr_trailing_memory = local_block->mem->cur_trailing_memory;
    }
    
    /* Record position */
    local_block->start_pos = local_block->mem->cur_pos;
    local_block->cur_trailing_memory = local_block->mem->nbr_trailing_memory;
}

void jmi_dynamic_function_free(jmi_local_dynamic_function_memory_t* local_block) {
    jmi_dynamic_function_memory_t* mem = local_block->mem;
    
    /* No memory used, return. */
    if (mem == NULL) {
        return;
    }

    mem->cur_pos = local_block->start_pos; /* Rewind pointer */
    mem->cur_trailing_memory = local_block->cur_trailing_memory;
}
