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

#include "jmi.h"
#include "jmi_util.h"
#include "jmi_chattering.h"

#define CHATTERING_CLEARED_LIMIT    (3)
#define CHATTERING_DETECTION_LIMIT  (5)
#define CHATTERING_MAX_LOGGING      (5)

static void jmi_chattering_log(jmi_t* jmi) {
    jmi_log_node_t node;
    
    node = jmi_log_enter_fmt(jmi->log, logWarning, "Chattering", 
                                 "Possible chattering detected at <t:%E>", jmi_get_t(jmi)[0]);
                                 
                                 
    jmi_log_reals(jmi->log, node, logWarning, "pre-switches ", jmi->chattering->pre_switches,   jmi->n_sw);
    jmi_log_reals(jmi->log, node, logWarning, "post-switches", jmi_get_sw(jmi),                 jmi->n_sw);
    jmi_log_reals(jmi->log, node, logWarning, "states",        jmi_get_real_x(jmi),             jmi->n_real_x);
    /* TODO: Add derivatives or event indicators? */
    
    jmi_log_leave(jmi->log, node);
}

static void jmi_chattering_save_switches(jmi_t* jmi) {
    int i;
    
    for (i = 0; i < jmi->n_sw; i++) {
        jmi->chattering->pre_switches[i] = jmi_get_sw(jmi)[i];
    }
}

void jmi_chattering_completed_integrator_step(jmi_t* jmi) {
    int i;
    jmi_chattering_t* chattering = jmi->chattering;
    
    if (!chattering->chattering_detection_mode) {
        return;
    }
    
    chattering->clear_counter++;
    if (chattering->clear_counter >= CHATTERING_CLEARED_LIMIT) {
        if (chattering->max_chattering > CHATTERING_DETECTION_LIMIT) {
            jmi_log_node(jmi->log, logWarning, "Chattering",
                "Leaving event cluster at <t:%E>, have taken <n_steps:%d> integrator steps without detecting any events.",
                jmi_get_t(jmi)[0], CHATTERING_CLEARED_LIMIT);
        }
        
        for (i = 0; i < jmi->n_sw; i++) {
            chattering->chattering[i] = 0;
        }
        chattering->max_chattering = 0;
        chattering->logging_counter = 0;
        chattering->chattering_detection_mode = 0;
    }
}

void jmi_chattering_check(jmi_t* jmi) {
    int i;
    jmi_chattering_t* chattering = jmi->chattering;
    
    chattering->clear_counter = 0;
    chattering->chattering_detection_mode = 1;
    
    for (i = 0; i < jmi->n_sw; i++) {
        if (chattering->pre_switches[i] != jmi_get_sw(jmi)[i]) {
            chattering->chattering[i]++;
            
            if (chattering->chattering[i] > chattering->max_chattering) {
                chattering->max_chattering = chattering->chattering[i];
            }
        }
    }
    
    if (chattering->max_chattering > CHATTERING_DETECTION_LIMIT &&
        chattering->logging_counter < CHATTERING_MAX_LOGGING)
    {
        chattering->logging_counter++;
        jmi_chattering_log(jmi);
    }
    
    /* Copy switches to pre switches */
    jmi_chattering_save_switches(jmi);
}

void jmi_chattering_delete(jmi_chattering_t* chattering) {
    if (chattering == NULL) {
        return;
    }
    
    free(chattering->pre_switches);
    free(chattering->chattering);
    free(chattering);
}

jmi_chattering_t* jmi_chattering_create(jmi_int_t n_sw) {
    jmi_chattering_t* chattering;
    
    chattering = calloc(1, sizeof(jmi_chattering_t));
    chattering->pre_switches = calloc(n_sw, sizeof(jmi_real_t));
    chattering->chattering = calloc(n_sw, sizeof(jmi_int_t));
    
    return chattering;
}

void jmi_chattering_init(jmi_t* jmi) {
    jmi_chattering_save_switches(jmi);
}
