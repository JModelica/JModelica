/*
    Copyright (C) 2013 Modelon AB

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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>

#include "jmi_log_impl.h"

/*#define INLINE inline */ /* not supported in c89 */
#define INLINE 

static void create_log_file_if_needed(log_t *log);

const char* jmi_callback_log_category_to_string(jmi_log_category_t c) {
    switch(c){
    case logError:
        return "ERROR";
    case logWarning:
        return "WARNING";
    case logInfo:
        return "INFO";
    default:
        return "FATAL";
    }   
}

category_t severest(category_t c1, category_t c2) {
    /* Smaller is more severe. */
    return c1 <= c2 ? c1 : c2;
}

/* buf_t constructor and destructor. */
static void init_buffer(buf_t *buf);
static void delete_buffer(buf_t *buf);


static INLINE BOOL isempty(buf_t *buf) { return buf->len == 0; }

static void clear(buf_t *buf) {
    buf->len = 0;
    buf->msg[0] = 0;
}

static void reserve(buf_t *buf, int len) {
    if (buf->alloced < len) {
        buf->alloced = 2*len;
        buf->msg = (char *)realloc(buf->msg, buf->alloced+1); /* Allocate space for the null byte too */
        buf->msg[buf->alloced] = 0;
    }    
}

/** \brief buf_t constructor. */
static void init_buffer(buf_t *buf) {
    buf->alloced = 512;
    buf->msg = (char *)malloc(buf->alloced+1); /* Allocate space for the null byte too */
    clear(buf);    
}

/** \brief buf_t destructor. */
static void delete_buffer(buf_t *buf) {
    free(buf->msg);
    buf->msg = NULL;
    buf->alloced = buf->len = 0;
}


static INLINE char *destof(buf_t *buf) { return buf->msg + buf->len; }


 /* Raw output */

static void buffer_raw_char(buf_t *buf, char c) {
    reserve(buf, buf->len+1);
    destof(buf)[0] = c;
    ++(buf->len);
    destof(buf)[0] = 0;
}

static void buffer_char(buf_t *buf, char c) {
    if (c == '#') {
        /* Escape # as ## since it's used for value references */
        buffer_raw_char(buf, '#'); buffer_raw_char(buf, '#');
    }
    else if (c == '\n') {
        /* Escape newlines as &#10; so that they don't break JMI log filtering */
        buffer_raw_char(buf, '&');
        buffer_raw_char(buf, '#'); buffer_raw_char(buf, '#'); /* Escape # as ## here too */
        buffer_raw_char(buf, '1');
        buffer_raw_char(buf, '0');
        buffer_raw_char(buf, ';');
    }
    else {
        buffer_raw_char(buf, c);
    }
}

static void buffer(buf_t *buf, const char *str) {
    while (*str != 0) buffer_char(buf, *(str++));
}


 /* Somewhat formatted output */

static void buffer_text_char(buf_t *buf, char c) {
    if (c == '<') buffer(buf, "&lt;");
    else if (c == '>') buffer(buf, "&gt;");
    else if (c == '&') buffer(buf, "&amp;");
    else buffer_char(buf, c);
}

static void buffer_attribute_char(buf_t *buf, char c) {
    if (c == '"') buffer(buf, "&quot;");
    else buffer_text_char(buf, c);
}

static void buffer_text(buf_t *buf, const char *str) {
    while (*str != 0) buffer_text_char(buf, *(str++));
}

static void buffer_attribute(buf_t *buf, const char *str) {
    while (*str != 0) buffer_attribute_char(buf, *(str++));
}

static void buffer_attribute_be(buf_t *buf, const char *str, const char *end) {
    if (end == NULL) buffer_attribute(buf, str);
    else {
        while (*str != 0 && str != end) buffer_attribute_char(buf, *(str++));
    }
}

/** \brief Output a comment. */
static void buffer_comment(buf_t *buf, const char *msg) {    
    buffer_text(buf, msg);
}

static BOOL needs_quoting(const char *str) {
    char c = *str;
    if (c == 0) return TRUE;
    if (isdigit(c) || c == '+' || c == '-') return TRUE;
    while (*str != 0) {
        char c = *str;
        if (!(isalnum(c) || c == '_')) return TRUE;
        ++str;
    }
    return FALSE;
}

/** \brief Output a string, wrap it in quotes if necessary. */
static void buffer_string_literal(buf_t *buf, const char *value) {
    if (!needs_quoting(value)) buffer_text(buf, value);    
    else {
        buffer_char(buf, '"');
        while (*value != 0) {
            char c = *value;
            buffer_text_char(buf, c);
            if (c == '"') buffer_char(buf, '"'); /* translates " to "" */
            ++value;
        }
        buffer_char(buf, '"');
    }
}

/** \brief Output an element name, replace invalid characters with `_`. */
static void buffer_element_name(buf_t *buf, const char *type) {
    char ch = *type;
    if (ch == 0) {
        buffer_char(buf, '_');
        return;
    }
    if (isalpha(ch) || ch == '_' || ch == ':') buffer_char(buf, ch);
    else buffer_char(buf, '_');

    ++type;
    while (*type != 0) {
        char ch = *type;
        if (isalnum(ch) || ch == '_' || ch == ':' || ch == '.' || ch == '-') buffer_char(buf, ch);
        else buffer_char(buf, '_');        
        ++type;
    }
}

/** \brief Output a start tag with element name `type`, and `name `attribute `name` if not `NULL`.
 *         If `name_end` is not `NULL`, it points one char past the end of the name.
*/
static void buffer_starttag(buf_t *buf, const char *type,
                            const char *name, const char *name_end, 
                            category_t c, category_t parent_c, int flags) {
    buffer_char(buf, '<');
    buffer_element_name(buf, type);
    if (name != NULL) {
        buffer(buf, " name=\"");
        buffer_attribute_be(buf, name, name_end);
        buffer_char(buf, '"');
    }
    if (c != parent_c) {
        buffer(buf, " category=\"");
        if (c == logInfo) buffer(buf, "info");
        else if (c == logWarning) buffer(buf, "warning");
        else if (c == logError) buffer(buf, "error");
        buffer_char(buf, '"');        
    }
    if ((flags & logFlagIndex) != 0) buffer(buf, " flags=\"index\"");
    if ((flags & logFlagResidualIndex) != 0) buffer(buf, " flags=\"residual_index\"");
    buffer_char(buf, '>');
}

static void buffer_endtag(buf_t *buf, const char *type) {
    buffer(buf, "</");
    buffer_element_name(buf, type);
    buffer_char(buf, '>');
}

static void logging_error(log_t *log, const char *msg);

/* convenience typedef and functions */
static INLINE buf_t *bufof(log_t *log)    { return &(log->buf); }


/* constructor */
static void init_log(log_t *log, jmi_log_options_t* options, jmi_callbacks_t* jmi_callbacks);
static void initialize(log_t *log); /* extra initialization */

/* logging primitives */
static void emit(log_t *log);
static node_t enter_(log_t *log, category_t c, const char *type, int leafdim, 
                     const char *name, const char *name_end, int flags);
static void leave_(log_t *log, node_t node);
static void leave_all(log_t *log);
static void log_value_(log_t *log, const char *value);
static void log_comment_(log_t *log, category_t c, const char *msg);
static void log_vref_(log_t *log, char t, int vref);
static void log_fmt_(log_t *log, node_t node, category_t c, const char *fmt, va_list ap);


static void defer_comma(  log_t *log) { log->outstanding_comma = TRUE; }
static void cancel_commas(log_t *log) { log->outstanding_comma = FALSE; }

static void force_commas(log_t *log) {
    if (log->outstanding_comma) buffer(bufof(log), ", ");
    log->outstanding_comma = FALSE;
}

static INLINE int current_indent_of(log_t *log) { return 2*log->topindex; }

/** \brief Like fputs, but convert ## into #. */
static void fputs_unescape_hashmarks(const char *str, FILE *out) {
    char c;
    while ((c = *(str++)) != 0) {
        if ((c == '#') && (*str == '#')) str++;
        fputc(c, out);
    }
}

void file_logger(FILE *out, FILE *err, 
                        category_t category, category_t severest_category, 
                        const char *message) {
    switch (category) {
    case logError:
        fprintf(err, "<!-- ERROR:   --> ");
        fputs_unescape_hashmarks(message, err);
        fputc('\n', err);
        break;
    case logWarning:
        fprintf(err, "<!-- WARNING: --> ");
        fputs_unescape_hashmarks(message, err);
        fputc('\n', err);
        break;
    case logInfo:
        fputs_unescape_hashmarks(message, out);
        fputc('\n', out);
        break;
    }

    /*
    const char *fmiCategory = category_to_fmiCategory(severest_category);
    switch (category) {
    case logError:
        fprintf(stderr, "[%7s] ERROR: %s\n", fmiCategory, message);
        break;
    case logWarning:
        fprintf(stderr, "[%7s] WARNING: %s\n", fmiCategory, message);
        break;
    case logInfo:
        fprintf(stdout, "[%7s] %s\n", fmiCategory, message);
        break;
    }
    */    
}

category_t clamp_category(category_t c) { return c <= logInfo ? c : logInfo; }

/** \brief Emit the currently buffered log message, if one exists. */
static void emit(log_t *log) {
    
    buf_t *buf = bufof(log);
    force_commas(log);
    if (!isempty(buf)) {
        jmi_callbacks_t* cb = log->jmi_callbacks;

        if (!emitted_category(log, log->c)) return;

        /* Clamp the category before we emit it since we currently don't pass
           categories beyond logInfo to the outside. */
        cb->emit_log(cb, clamp_category(log->c), clamp_category(log->severest_category), buf->msg);

        create_log_file_if_needed(log);
        if (log->log_file) {
            file_logger(log->log_file, log->log_file, 
                        clamp_category(log->c), clamp_category(log->severest_category), buf->msg);
            fflush(log->log_file);
        }

        clear(buf);
        log->severest_category = logInfo;
    }
}

/** \brief Add indentation to the current line if it is empty.
 *  Should be called before adding something to the start of a line with a
 *  buffer*() function, either directly or by invoking set_category().
 */
static void indent_line(log_t *log) {
    buf_t *buf = bufof(log);
    if (isempty(buf)) {
        int i;
        int indent = current_indent_of(log);
        for (i=0; i < indent; i++) buffer_raw_char(buf, ' ');
    }
}


 /* Frame helpers */

/** \brief Return the top frame. */
static INLINE frame_t *topof(log_t *log) { return log->frames + log->topindex; } 
static INLINE BOOL can_pop(log_t *log)   { return log->topindex > 0; } /* always keep one frame */

/** \brief Set the current logging category; emit a log message if it was changed.
  * Also calls indent_line().
  */
static void set_category(log_t *log, category_t c) {
    frame_t *top;

    if (!log->initialized) {
        /* Hook to do some more initialization once everthing is set up.
           TODO: call initialize(log) at actual initialization,
           once everything is set up at that time. */
        log->initialized = TRUE;
        initialize(log);
    }
    top = topof(log);
    if (log->c != c) emit(log);
    log->c = c;
    top->severest_category = severest(top->severest_category, c);
    indent_line(log);
}

static node_t node_from_top(log_t *log) {
    node_t node={0};
    node.inner_id = topof(log)->id;
    return node;
}

/** \brief Push a new frame to the top of the stack, initialize and return it. */
static frame_t *push_frame(log_t *log, category_t c, const char *type, int leafdim) {
    frame_t *top;

    ++(log->topindex);
    if (log->topindex >= log->alloced_frames) {
        log->alloced_frames = 2*(log->topindex+1);
        log->frames = (frame_t *)realloc(log->frames, log->alloced_frames*sizeof(frame_t));
    }

    top       = log->frames + log->topindex;
    top->id   = log->id_counter + log->topindex;
    top->c    = c;
    top->type = type;
    top->severest_category = c;

    log->id_counter += 256;
    log->leafdim     = leafdim;

    return top;
}


/** log_t constructor. */
static void init_log(log_t *log, jmi_log_options_t* options, jmi_callbacks_t* jmi_callbacks) {
    log->options = options;
    init_buffer(bufof(log));

    log->filtering_enabled = TRUE;
    log->log_file = NULL;

    log->c = log->severest_category = logInfo;
    log->next_name = NULL;

    log->alloced_frames = 32;
    log->frames = (frame_t *)malloc(log->alloced_frames*sizeof(frame_t));
    log->topindex = -1;
    log->id_counter = 0;

    log->outstanding_comma = FALSE;
    push_frame(log, logInfo, "JMILog", -1);
    
    log->jmi_callbacks = jmi_callbacks;

    log->initialized = FALSE;  /* More initialization to do later */
}

static void create_log_file_if_needed(log_t *log) {
    if (log->log_file != NULL) return;

    if (log->options->copy_log_to_file_flag) {
        /* Create new log file */
        jmi_callbacks_t *cb = log->jmi_callbacks;
        const char *instance_name = cb->instance_name;
        char filename[8000];

        if(instance_name && instance_name[0]) {
            sprintf(filename, "%s_%s.xml", cb->model_name,
                                           instance_name);
        }
        else {
            sprintf(filename, "%s_runtime_log.xml", cb->model_name);
        }
        /* TODO: 
           create_log_file_if_needed need to be called several times since the options are
           updated in fmiInitialize() and at that point copy_log_to_file_flag might be set.

           Just to make this safer: if fopen fails - print a message on stderr and
           clear the option.
           */

        log->log_file = fopen(filename, "w");

        if(!log->log_file) {
            fprintf(stderr,"Could not open runtime log file %s", filename);
            log->options->copy_log_to_file_flag = 0;
        }
        else {
            fprintf(log->log_file, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<JMILog category=\"info\">\n");
        }
    }
}

char* jmi_log_get_build_date() {
    return __DATE__ " " __TIME__;
}

/** Additional log_t initialization */
static void initialize(log_t *log) {
    create_log_file_if_needed(log);

    /* Log the build date and time of the JMI runtime.
       This should be replaced with the JModelica version,
       once that becomes available.
     */
    jmi_log_set_filtering(log, FALSE); /* Allow info message to go through */
    jmi_log_node(log, logInfo, "JMIRuntime",
                 "<build_date:%s> <build_time:%s>", __DATE__, __TIME__);
    jmi_log_set_filtering(log, TRUE);
}

static void delete_log(log_t *log) {
    if (log == NULL) return;

    leave_all(log);
    if (log->log_file) {
        fprintf(log->log_file, "</JMILog>\n");
        fclose(log->log_file);
    }
    delete_buffer(bufof(log));
    free(log->frames);
    free(log);
}


 /* Logging primitives */

/** \brief Leave the top frame without printing any logging errors. */
static BOOL _leave_frame_(log_t *log) {
    frame_t *top = topof(log);
    frame_t *newtop;

    log->next_name = NULL;
    log->leafdim = -1;

    if (!can_pop(log)) return FALSE;
    --(log->topindex);

    newtop = topof(log);
    newtop->severest_category = severest(newtop->severest_category,
                                         top->severest_category);
    if (emitted_category(log, top->c)) {
        cancel_commas(log);
        set_category(log, top->c);
        log->severest_category = severest(log->severest_category,
                                          top->severest_category);
        buffer_endtag(bufof(log), top->type);
    }
    return TRUE;
}

/** \brief Leave the top frame. */
static void leave_frame_(log_t *log) {
    if (!_leave_frame_(log)) {
        logging_error(log, "leave_frame_: frame stack empty; unable to pop.");
    }
}

static void leave_all(log_t *log) {
    while (_leave_frame_(log)) {}
    emit(log);
}

static void _leave_(log_t *log, node_t node) {
    int k;
    
    for (k=log->topindex; k > 0; k--) {
        if (log->frames[k].id == node.inner_id) break;
    }
    if (k <= 0) logging_error(log, "leave_: trying to leave a node not on the stack.");
    else {
        while (can_pop(log)) {
            BOOL final = (topof(log)->id == node.inner_id);
            leave_frame_(log);
            if (final) break;
        }
    }
}

/** \brief Leave the range of log nodes given by node. */
static void leave_(log_t *log, node_t node) {
    if (topof(log)->id != node.inner_id) {
        logging_error(log, "leave_: trying to leave another node than the current one.");
    }
    _leave_(log, node);
}

/** \brief If the current node is a leaf, close it and give a logging_error. */
static void close_leaf(log_t *log) {
    if (log->leafdim >= 0) {
        _leave_frame_(log);
        logging_error(log, "trying to enter a comment or subnode within a leaf node; closing it first.");
    }
}

/** \brief Enter a frame for a node. */
static node_t enter_(log_t *log, category_t c, const char *type, int leafdim,
                     const char *name, const char *name_end, int flags) {
    category_t pc;
    close_leaf(log);
    log->next_name = NULL;

    pc = topof(log)->c;

    if (name != NULL) {
        /* A named node may be no more severe than its parent */
        if (c < pc) {
            c = pc; /* Smaller = more severe */
            logging_error(log, "A named node may be no more severe than its parent.");
        }
    }

    if (emitted_category(log, c)) {
        set_category(log, c);
        buffer_starttag(bufof(log), type, name, name_end, clamp_category(c), clamp_category(pc), flags);
    }
    cancel_commas(log);

    push_frame(log, c, type, leafdim);
    return node_from_top(log);
}

jmi_log_node_t jmi_log_get_current_node(jmi_log_t *log) {
    jmi_log_node_t node={0};
    node.inner_id = topof(log)->id;
    return node;
}


static BOOL ok_label_parent(jmi_log_t *log, jmi_log_node_t node) {
    if (topof(log)->id != node.inner_id) {
        logging_error(log, "jmi_log_label_: trying to name a child not of the current node.");
        /* todo: leave nodes until node becomes current? */
        return FALSE;
    }
    else if (log->leafdim >= 0) {
        logging_error(log, "jmi_log_label_: trying to name a child of a leaf node.");
        return FALSE;
    }
    else return TRUE;
}

void jmi_log_label_(jmi_log_t *log, jmi_log_node_t node, const char *name) {
    if (ok_label_parent(log, node)) log->next_name = name;
}


/** Log a value. */
static void log_value_(log_t *log, const char *value) {    
    indent_line(log);
    force_commas(log);
    buffer_text(bufof(log), value);
    defer_comma(log);
}

/** Log a string. */
static void log_string_literal_(log_t *log, const char *value) {    
    indent_line(log);
    force_commas(log);
    buffer_string_literal(bufof(log), value);
    defer_comma(log);
}

static int emitted_category(log_t *log, category_t c) {
    jmi_callbacks_t* cb = log->jmi_callbacks;
    if (!log->filtering_enabled) {
        return TRUE;
    }

    /* interim solution to allow to pass a log level >= 4 instead of a category */
    if (((int)c) >= 4) {
        if (cb->log_options.log_level < c) return FALSE;
        c = logInfo;
    }

    return cb->is_log_category_emitted(cb, c);
}

static void log_comment_(log_t *log, category_t c, const char *msg) {
    close_leaf(log);
    if (!emitted_category(log, c)) return;
    set_category(log, c);    
    buffer_comment(bufof(log), msg);
}

/** Log a value reference. */
static void log_vref_(log_t *log, char t, int vref) {
    buf_t *buf = bufof(log);
    char tmp[128];

    indent_line(log);
    force_commas(log);
    buffer_char(buf, '"'); buffer_raw_char(buf, '#');

    buffer_text_char(buf, t);
    sprintf(tmp, "%d", vref);
    buffer_text(buf, tmp);

    buffer_raw_char(buf, '#'); buffer_char(buf, '"'); 
    defer_comma(log);
}

static void logging_error(log_t *log, const char *msg) {
    emit(log);
    log_comment_(log, logInfo, "Logger error: ");
    log_comment_(log, logInfo, msg);
    emit(log);
}


 /* User constructor, destructor */

jmi_log_t *jmi_log_init(jmi_callbacks_t* jmi_callbacks) {
    jmi_log_options_t* options = &jmi_callbacks->log_options;
    log_t *log = (log_t *)malloc(sizeof(log_t));
    init_log(log, options, jmi_callbacks);
    return log;
}
void jmi_log_delete(log_t *log) { delete_log(log); }


 /* Entry/exit primitives */

/** \brief Enter a named list node that contains named nodes, then emit. */
node_t jmi_log_enter(log_t *log, category_t c, const char *type) {
    node_t node = jmi_log_enter_(log, c, type);
    emit(log); return node;
}
node_t jmi_log_enter_(log_t *log, category_t c, const char *type) {
    /* todo: check that type is not "vector" etc? */
    return enter_(log, c, type, -1, log->next_name, NULL, 0);
}

static node_t enter_value_(log_t *log, node_t node, category_t c, 
                           const char *name, const char *name_end, int flags) {
    if (!ok_label_parent(log, node)) { name = name_end = NULL; }
    return enter_(log, c, "value", 0, name, name_end, flags);
}
/* could be exported */
/* Un-used function */
/*
static node_t jmi_log_enter_value_(log_t *log, node_t node, category_t c, 
                                   const char *name) {
    return enter_value_(log, node, c, name, NULL);
}
*/

node_t jmi_log_enter_vector_(log_t *log, node_t node, category_t c, 
                             const char *name) {
    if (!ok_label_parent(log, node)) { name = NULL; }
    return enter_(log, c, "vector", 1, name, NULL, 0);
}

node_t jmi_log_enter_index_vector_(log_t *log, node_t node, category_t c, 
                             const char *name, char index_type) {
    int flag = 0;
    if(index_type == 'I') {
        flag = logFlagIndex;
    }
    else if (index_type == 'R') {
        flag = logFlagResidualIndex;
    }
    if (!ok_label_parent(log, node)) { name = NULL; }
    return enter_(log, c, "vector", 1, name, NULL, flag);
}


/* could be exported if we also export an interface to begin a new row. */
static node_t jmi_log_enter_matrix_(log_t *log, node_t node, category_t c, 
                                    const char *name) {
    if (!ok_label_parent(log, node)) { name = NULL; }
    return enter_(log, c, "matrix", 2, name, NULL, 0);
}

/** \brief Leave node, then emit. */
void jmi_log_leave(log_t *log, node_t node) { jmi_log_leave_(log, node); emit(log); }
void jmi_log_leave_(log_t *log, node_t node) { leave_(log, node); }

/** \brief Like jmi_log_leave, but doesn't need to take innermost node. */
void jmi_log_unwind(log_t *log, node_t node) { _leave_(log, node); emit(log); }

void jmi_log_leave_all(log_t *log) { leave_all(log); }


static BOOL contains(const char *chars, char c) {
    while (*chars) if (*(chars++) == c) return TRUE;
    return FALSE;
}

static INLINE BOOL is_name_char(char c) { return isalnum(c) || c == '_'; }

static void log_fmt_(log_t *log, node_t parent, category_t c, const char *fmt, va_list ap) {
    buf_t *buf = bufof(log);
    BOOL incomment = TRUE;

    close_leaf(log);
    if (!emitted_category(log, c)) return;
    set_category(log, c);
    while (*fmt != 0) {
        char ch = *fmt;
        if (incomment) {
            if (ch == '<') incomment = FALSE;
            else           buffer_text_char(buf, ch); /* copy comment char */
            ++fmt;
        }
        else {  /* !incomment */
            if      (ch == '>') { ++fmt; incomment = TRUE; }
            else if (isspace(ch) || ch == ',') {
                buffer_text_char(buf, ch);
                ++fmt;
            }
            else if (is_name_char(ch)) {
                /* Try to log an attribute */
                node_t node={0};
                const char *name_end;
                const char *name_start = fmt;
                
                while (is_name_char(*fmt)) ++fmt;
                name_end = fmt;
                if (name_end == name_start) { logging_error(log, "jmi_log_fmt: expected attribute name."); break; }
                while (isspace(*fmt)) ++fmt;
                if (*(fmt++) != ':') { logging_error(log, "jmi_log_fmt: expected ':'"); break; }            
                while (isspace(*fmt)) ++fmt;
            
                ch = *(fmt++);
                if (ch == '%') {
                    char f = *(fmt++);
                    int flags = (f == 'I' ? logFlagIndex : 0);
                    flags = (f == 'R' ? logFlagResidualIndex : flags);
                    if (!contains("diueEfFgGsIR", f)) { logging_error(log, "jmi_log_fmt: unknown format specifier"); break; }
                    
                    node = enter_value_(log, parent, c, name_start, name_end, flags);
                    
                    /* todo: consider: what if jmi_real_t is not double? */
                    if      (contains("diuIR", f))   jmi_log_int_(   log, va_arg(ap, int));
                    else if (contains("eEfFgG", f)) jmi_log_real_(  log, va_arg(ap, double));
                    else if (f == 's')              jmi_log_string_(log, va_arg(ap, const char *));
                    else { logging_error(log, "jmi_log_fmt: unknown format specifier"); break; }
                    
                    leave_(log, node);
                }
                else if (ch == '#') {
                    char t = *(fmt++);
                    if (!contains("ribs", t)) { logging_error(log, "jmi_log_fmt: unknown vref type"); break; }
                    if (*(fmt++) != '%') { logging_error(log, "jmi_log_fmt: expected '#<type>%d#'"); break; }
                    if (*(fmt++) != 'd') { logging_error(log, "jmi_log_fmt: expected '#<type>%d#'"); break; }
                    if (*(fmt++) != '#') { logging_error(log, "jmi_log_fmt: expected '#<type>%d#'"); break; }
                    
                    node = enter_value_(log, parent, c, name_start, name_end, 0);
                    jmi_log_vref_(log, t, va_arg(ap, int));
                    leave_(log, node);
                }
                else { logging_error(log, "jmi_log_fmt: expected '%' or '#'"); break; }
            }
            else { logging_error(log, "jmi_log_fmt: unknown format character"); break; }
        }
    }
    if (!incomment) logging_error(log, "jmi_log_fmt: format string ended while inside angle brackets.");
}

 /* Functions that involve log_fmt */

void jmi_log_fmt_(log_t *log, node_t node, category_t c, const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    log_fmt_(log, node, c, fmt, ap);
    va_end(ap);
}

void jmi_log_fmt(log_t *log, node_t node, category_t c, const char *fmt, ...) {
    va_list ap;
    if (!emitted_category(log, c)) return;
    va_start(ap, fmt);
    log_fmt_(log, node, c, fmt, ap);
    va_end(ap);
    emit(log);
}

jmi_log_node_t jmi_log_enter_fmt(log_t *log, jmi_log_category_t c, const char *type, const char* fmt, ...) {
    va_list ap;
    node_t node = jmi_log_enter_(log, c, type); 

    va_start(ap, fmt);
    log_fmt_(log, node, c, fmt, ap);
    va_end(ap);
    
    emit(log);
    return node;    
}

void jmi_log_node(log_t *log, category_t c, const char *type, const char* fmt, ...) {
    va_list ap;
    node_t node;
    if (!emitted_category(log, c)) return;
    node = jmi_log_enter_(log, c, type); 

    va_start(ap, fmt);
    log_fmt_(log, node, c, fmt, ap);
    va_end(ap);
    
    leave_(log, node); emit(log);
}


 /* Misc. */

void jmi_log_emit(log_t *log) { emit(log); }
void jmi_log_set_filtering(jmi_log_t *log, int enabled) {
    log->filtering_enabled = enabled;
}


 /* Subrow primitives */

void jmi_log_comment_(log_t *log, category_t c, const char *msg) { log_comment_(log, c, msg); }
void jmi_log_comment(log_t *log, category_t c, const char *msg) { jmi_log_comment_(log, c, msg); emit(log); }


void jmi_log_string_(log_t *log, const char *x) { log_string_literal_(log, x); }

void jmi_log_real_(log_t *log, jmi_real_t x) {
    char buf[128];
    sprintf(buf, "%30.16E", x);
    log_value_(log, buf);
}

void jmi_log_int_(log_t *log, int x) {
    char buf[128];
    sprintf(buf, "%d", x);
    log_value_(log, buf);
}

void jmi_log_vref_(log_t *log, char t, int vref) { log_vref_(log, t, vref); }


 /* Row primitives */

void jmi_log_reals(log_t *log, node_t parent, category_t c, const char *name, const jmi_real_t *data, int n) {
    int k;
    node_t node;
    if (!emitted_category(log, c)) return;
    node = jmi_log_enter_vector_(log, parent, c, name);
    for (k=0; k < n; k++) jmi_log_real_(log, data[k]);
    jmi_log_leave(log, node);
}

void jmi_log_ints(log_t *log, node_t parent, category_t c, const char *name, const int *data, int n) {
    int k;
    node_t node;
    if (!emitted_category(log, c)) return;
    node = jmi_log_enter_vector_(log, parent, c, name);
    for (k=0; k < n; k++) jmi_log_int_(log, data[k]);
    jmi_log_leave(log, node);
}

void jmi_log_strings(log_t *log, node_t parent, category_t c, const char *name, const jmi_string_t *data, int n) {
    int k;
    node_t node;
    if (!emitted_category(log, c)) return;
    node = jmi_log_enter_vector_(log, parent, c, name);
    for (k=0; k < n; k++) jmi_log_string_(log, data[k]);
    jmi_log_leave(log, node);
}

void jmi_log_vrefs(log_t *log, node_t parent, jmi_log_category_t c, const char *name, char t, const int *vrefs, int n) {
    int k;
    node_t node;
    if (!emitted_category(log, c)) return;
    node = jmi_log_enter_vector_(log, parent, c, name);
    for (k=0; k < n; k++) jmi_log_vref_(log, t, vrefs[k]);
    jmi_log_leave(log, node);    
}

void jmi_log_real_matrix(log_t *log, node_t parent, category_t c, const char *name, const jmi_real_t *data, int m, int n) {
    int k, l;
    node_t node;
    if (!emitted_category(log, c)) return;
    node = jmi_log_enter_matrix_(log, parent, c, name);
    emit(log);
    for (l=0; l < m; l++) {
        for (k=0; k < n; k++) {
            jmi_log_real_(log, data[k*m + l]);
        }
        cancel_commas(log);
        buffer_char(bufof(log), ';'); emit(log);  /* todo: better way to signal end of the row? */
    }
    jmi_log_leave(log, node);
}
