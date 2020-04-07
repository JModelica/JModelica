 /*
    Copyright (C) 2014 Modelon AB

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

/** \file jmi_delay_impl.h
 *  \brief Delay simulation private include file.
 */

#ifndef _JMI_DELAY_IMPL_H
#define _JMI_DELAY_IMPL_H
 
#include "jmi_types.h"
#include "jmi_delay.h"

#define JMI_DELAY_MAX_INTERPOLATION_POINTS 2 /* Linear interpolation */

/*
Delay buffers
=============
A delay buffer contains a sequence of samples ordered from left to right/first to last,
each represented by a `jmi_delay_point_t`. Samples may be added and discarded at either end.

There may be an event between two consecutive samples. 
 * If there is, their time values `t` must be the same.
 * Otherwise, `t_right` must be > `t_left`

Two samples with no events between them are considered to belong to the same _segment_.
The segments end at the ends of the buffer, so there is always an implicit event to the left
of the leftmost sample and to the right of the rightmost sample in the buffer.


Sample indices
--------------
Samples are identified by their index. At any one point, samples with index

    head_index <= index <= tail_index

are present in the buffer. `head_index` and `tail_index` will change as samples are added and
removed to the left and right.

Internally, a ring buffer `buf` is used to store the samples, and indices are mapped to
ring buffer positions using the function `index2pos`. This mapping will change each time
the ring buffer is reallocated.


Representation of events in delay buffers
-----------------------------------------
The delay buffer must be able to support two kinds of event-related queries:
 * Is there en event to the left/right of a given sample?
 * Where is the first event to the left/right of a given sample?
The event representation is designed to support these queries.

Each sample has a segment index that encodes the presence of events:
It increases by noe across events and stays constant otherwise.

The segment index also indexes into the _event buffer_ `event_buf`:
 * The event with index `segment` is at the left end of the segment
 * The event with index `segment+1` is at the right end of the segment
Thus, there must always be one more event in the event buffer than segments among the samples.
The first and last events always point to the left and right boundaries between present and
absent samples.
Event indices are mapped to ring buffer positions in `event_buf` using the `ev2pos` function.

The event buffer stores the index of the sample to the left of the corresponding event.
Thus, the first event points to the sample just before the first sample, and the last event
points to the last sample.
*/

typedef struct {
    jmi_real_t t; /**< \brief Increases between points, except at events, where it remains the same. There may never be two events in a row without an event-free interval in between. */
    jmi_real_t y;
    int segment;  /**< \brief Index of the segment this sample belongs to. Increases by one accross events. Indexes into the events buffer. */
} jmi_delay_point_t;

/** \brief Represents the history of a signal. */
typedef struct {
    int capacity;    /**< \brief Number of allocated points in buf. Must be a power of two! This simplifies ring buffer management a lot. */
    int size;        /**< \brief Number of used points in buf. */
    int head_index;  /**< \brief Logical index associated with the head position. */
    jmi_delay_point_t *buf; /**< \brief Buffer of history points. */

    int event_capacity; /**< \brief Number of allocated points in event_buf. Must be a power of two! This simplifies ring buffer management a lot. */
    int *event_buf; /**< brief Indices to the left sample of each event. */

    jmi_real_t max_delay;   /**< \brief Maximum delay relative to the last recorded sample that the buffer will be queried for. */
} jmi_delaybuffer_t;

/** \brief Represents the current position in a `jmi_delaybuffer_t`, including state needed to trigger events. */
typedef struct {
    int curr_interval;        /**< \brief Index of the left end point of the current interval. */
} jmi_delay_position_t;

/** \brief Represents a single delay block (free or fixed delay). Wraps a delaybuffer_t with the history and adds additional state. */
struct jmi_delay_t {
    jmi_delaybuffer_t buffer;       /**< \brief The actual history. */
    jmi_boolean fixed;              /**< \brief True if this is a fixed delay. */
    jmi_boolean no_event;           /**< \brief True if this delay should not generate any events - it will cross events in the history anyway. */
    jmi_delay_position_t position;  /**< \brief Current buffer position, including state needed to trigger events. */
};

/** \brief Represents a single spatialDistribution block. Wraps a delaybuffer_t with the contents and adds additional state. */
struct jmi_spatialdist_t {
    jmi_delaybuffer_t buffer;        /**< \brief The actual history. */
    jmi_boolean no_event;            /**< \brief True if this spatialDistribution should not generate any events - it will cross events in the history anyway. */
    jmi_delay_position_t lposition;  /**< \brief Current buffer position for the left endpoint, including state needed to trigger events. */
    jmi_delay_position_t rposition;  /**< \brief Current buffer position for the right endpoint, including state needed to trigger events. */
    jmi_real_t last_x;               /**< \brief Last recorded x position. */
};


#endif
