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

#ifndef _JMI_DYN_MEM_H
#define _JMI_DYN_MEM_H

#include <stdio.h>

#define JMI_MEMORY_POOL_SIZE (1024*1024)

typedef struct jmi_dynamic_function_memory_t {
    char* cur_pos;
    char* start_pos;
    size_t block_size;
    void* memory_block;
    size_t nbr_trailing_memory;
    size_t cur_trailing_memory;
    char** trailing_memory; /* Temporary usage when the memory block is all used up */
} jmi_dynamic_function_memory_t;

typedef struct jmi_local_dynamic_function_memory_t {
    jmi_dynamic_function_memory_t* mem;
    char* start_pos;
    size_t cur_trailing_memory;
} jmi_local_dynamic_function_memory_t;


/* Macro for declaring dynamic list variable - should be called at beginning of function */
#define JMI_DYNAMIC_INIT() \
    jmi_local_dynamic_function_memory_t dyn_mem = {NULL, NULL, 0};

/* Dynamic deallocation of all dynamically allocated arrays and record arrays - should be called before return */
#define JMI_DYNAMIC_FREE() jmi_dynamic_function_free(&dyn_mem);

/* Repoint to a persistent memory pool, used for functions that set up memory that should not
   be freed when exiting function. */
#define JMI_GLOBALS_INIT() \
    dyn_mem.mem = jmi->dyn_fcn_mem_globals;

/* Reset the pool pointer, avoiding freeing of the memory in the persistent pool */
#define JMI_GLOBALS_FREE() \
    dyn_mem.mem = NULL;

/**
 * \brief Retrieves the memory pool from the jmi struct
 *
 * @return The memory pool.
 */
jmi_dynamic_function_memory_t* jmi_dynamic_function_memory(void);

/**
 * \brief Resizes the memory pool.
 *
 * @param mem (Input) The memory pool to be resized.
 */
void jmi_dynamic_function_resize(jmi_dynamic_function_memory_t* mem);


/**
 * \brief Creates a memory pool and returns the allocated object
 *
 * This function creates and returns a memory pool given the size
 * of the pool. This pool is then used when dynamic memory is requested
 * during simulation.
 *
 * @param pool_size (Input) The size of the memory pool.
 * @return The memory pool.
 */
jmi_dynamic_function_memory_t* jmi_dynamic_function_pool_create(size_t pool_size);

/**
 * \brief Destroys the memory pool
 * 
 * @param A pointer to the memory pool to be destroyed.
 */
void jmi_dynamic_function_pool_destroy(jmi_dynamic_function_memory_t* mem);

/**
 * \brief Allocates memory from the memory pool (given a local block)
 * 
 * This function tries to allocate memory from the memory pool. If
 * there is not enough memory available in the pool, an additional
 * allocation is done to accomodate the request. The memory pool is
 * extended in jmi_dynamic_function_init() if this extra allocation
 * was necessary.
 * 
 * @param local_block A pointer to the local block
 * @param memory_size Size of the requested memory
 * @param reset_memory If the memory requested should be zeroed
 */
void *jmi_dynamic_function_pool_alloc(jmi_local_dynamic_function_memory_t* local_block, size_t memory_size, int reset_memory);

/**
 * \brief Allocates memory from the memory pool
 * 
 * This function tries to allocate memory from the memory pool. If
 * there is not enough memory available in the pool, an additional
 * allocation is done to accomodate the request. The memory pool is
 * extended in jmi_dynamic_function_init() if this extra allocation
 * was necessary.
 * 
 * @param mem The memory pool
 * @param memory_size Size of the requested memory
 * @param reset_memory If the memory requested should be zeroed
 */
void *jmi_dynamic_function_pool_direct_alloc(jmi_dynamic_function_memory_t* mem, size_t memory_size, int reset_memory);

/**
 * \brief Initializes the local block with the memory pool
 *
 * This function initializes the local block to point
 * to the current place in the memory pool. If more memory than whats 
 * contained in the pool, we also try to resize the pool.
 *
 * @param local_block (Input) The local block.
 */
void jmi_dynamic_function_init(jmi_local_dynamic_function_memory_t* local_block);

/**
 * \brief Rewinds the memory pool according to the local block.
 *
 * @param local_block (Input) The local block.
 */
void jmi_dynamic_function_free(jmi_local_dynamic_function_memory_t* local_block);

#endif /* _JMI_DYN_MEM_H */
