/*
    Copyright (C) 2009 Modelon AB

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

#include <string.h>
#include <cvode/cvode.h>             /* main integrator header file */
#include <cvode/cvode_dense.h>       /* use CVDENSE linear solver */
#include <nvector/nvector_serial.h>  /* serial N_Vector types, fct. and macros */
#include <sundials/sundials_types.h> /* definition of realtype */
#include <sundials/sundials_math.h>  /* contains the macros ABS, SQR, and EXP*/
#include "jmi_ode_solver_impl.h"
#include "jmi_ode_problem.h"
#include "jmi_ode_cvode.h"
#include "jmi_log.h"

int cv_rhs(realtype t, N_Vector yy, N_Vector yydot, void *problem_data){
    realtype *y, *ydot;
    int flag;
    jmi_ode_solver_t* solver = (jmi_ode_solver_t*)problem_data;
    jmi_ode_problem_t* p = solver -> ode_problem;

    y = NV_DATA_S(yy); /*y is now a vector of realtype*/
    ydot = NV_DATA_S(yydot); /*ydot is now a vector of realtype*/

    flag = p->ode_callbacks.rhs_func(t, y, ydot, p->sizes, p->problem_data);
    if(flag != 0) {
        jmi_log_node(p->log, logWarning, "Warning", "Evaluating the derivatives failed (recoverable error). "
                     "Returned with <warningFlag: %d>", flag);
        return 1; /* Recoverable failure */
    }
    
    if (p->sizes.states == 0){
        ydot[0] = 0.0;
    }

    return CV_SUCCESS;
}

int cv_root(realtype t, N_Vector yy, realtype *gout,  void* problem_data){
    realtype *y;
    int flag;
    jmi_ode_solver_t* solver = (jmi_ode_solver_t*)problem_data;
    jmi_ode_problem_t* p = solver -> ode_problem;

    y = NV_DATA_S(yy); /*y is now a vector of realtype*/

    flag = p->ode_callbacks.root_func(t, y, gout, p->sizes, p->problem_data);
    if(flag != 0) {
        jmi_log_node(p->log, logError, "Error", "Evaluating the event indicators failed. "
                     "Returned with <error_flag: %d>", flag);
        return -1; /* Failure */
    }
    
    return CV_SUCCESS;
}

void cv_err(int error_code, const char *module,const char *function, char *msg, void *problem_data){
    jmi_ode_solver_t* solver = (jmi_ode_solver_t*)problem_data;
    jmi_ode_problem_t* problem = solver -> ode_problem;
    
    if (error_code == CV_WARNING){
        jmi_log_node(problem->log, logWarning, "Warning", "Warning from <function: %s>, <msg: %s>", function, msg);
    } else {
        jmi_log_node(problem->log, logError, "Error", "Error from <function: %s>, < msg: %s>", function, msg);
    }        
}

jmi_ode_status_t jmi_ode_cvode_solve(jmi_ode_solver_t* solver, realtype time_final, int initialize) {
    int flag = 0,retval = 0;
    jmi_ode_cvode_t* integrator = (jmi_ode_cvode_t*)solver->integrator;
    jmi_ode_problem_t* problem = solver -> ode_problem;
    realtype tret/*,*y*/;
    realtype time;
    char step_event = 0; /* boolean step_event = FALSE */
    char terminate = 0;
    
    if (initialize == TRUE){
        /* statements unused*/
        /*
        if (problem->n_real_x > 0) {
            y = NV_DATA_S(integrator->y_work);
            y = problem->states;
        }
        */
		memcpy (NV_DATA_S(integrator->y_work), problem->states, problem->sizes.states*sizeof(jmi_real_t));
        time = problem->time;
        flag = CVodeReInit(integrator->cvode_mem, time, integrator->y_work);
        if (flag<0){
            jmi_log_node(problem->log, logError, "Error", "Failed to re-initialize the solver. "
                         "Returned with <error_flag: %d>", flag);
            return JMI_ODE_ERROR;
        }
    }
    
    /* Dont integrate past t_stop */
    flag = CVodeSetStopTime(integrator->cvode_mem, time_final);
    if (flag < 0){
        jmi_log_node(problem->log, logError, "Error", "Failed to specify the stop time. "
                     "Returned with <error_flag: %d>", flag);
        return JMI_ODE_ERROR;
    }
    
    flag = CV_SUCCESS;
    while (flag == CV_SUCCESS) {
        
        /* Perform a step */
        flag = CVode(integrator->cvode_mem, time_final, integrator->y_work, &tret, CV_ONE_STEP);
        if(flag<0){
            jmi_log_node(problem->log, logError, "Error", "Failed to calculate the next step. "
                     "Returned with <error_flag: %d>", flag);
            return JMI_ODE_ERROR;
        }
        
        /* Set time */
        problem->time = tret;
        /* Set states */
        memcpy (problem->states, NV_DATA_S(integrator->y_work), problem->sizes.states*sizeof(jmi_real_t));
        
        /* Log information */
        if (problem->jmi_callbacks->log_options.log_level >= 4) {
            jmi_log_node_t node = jmi_log_enter_fmt(problem->log, logInfo, "CVode", 
                                "CVode completed a step at <time:%f>", tret);
            jmi_real_t last_h = 0.0, next_h = 0.0;
            int    last_order, next_order;
            
            CVodeGetLastOrder(integrator->cvode_mem, &last_order);
            CVodeGetCurrentOrder(integrator->cvode_mem, &next_order);
            CVodeGetLastStep(integrator->cvode_mem, &last_h);
            CVodeGetCurrentStep(integrator->cvode_mem, &next_h);
            
            jmi_log_fmt(problem->log, node, logInfo, 
                "<lastUsedOrder: %d, newOrder: %d, lastUsedStepsize: %g, newStepsize: %g>",
                last_order, next_order, last_h, next_h);
            jmi_log_leave(problem->log, node);
        }
        
        /* After each step call completed integrator step */
        retval = problem->ode_callbacks.complete_step_func(&step_event, &terminate, problem->problem_data);
        if (retval != 0) {
            jmi_log_node(problem->log, logError, "Error", "Failed to complete an integrator step. "
                     "Returned with <error_flag: %d>", retval);
            return JMI_ODE_ERROR;
        }
        
        if (step_event == TRUE) {
            jmi_log_node(problem->log, logInfo, "StepEvent", "An event was detected at <t:%g>", tret);
            return JMI_ODE_EVENT;
        }
        
        if (terminate == TRUE) {
            jmi_log_node(problem->log, logInfo, "Terminate",
                "Terminating simulation after a signal from the model at <t:%g>", tret);
            return JMI_ODE_TERMINATE;
        }
    }
    
    if (flag == CV_ROOT_RETURN) {
        jmi_log_node(problem->log, logInfo, "StateEvent", "An event was detected at <t:%g>", tret);
        return JMI_ODE_EVENT;
    }
    return JMI_ODE_OK;
}

int jmi_ode_cvode_new(jmi_ode_cvode_t** integrator_ptr, jmi_ode_solver_t* solver) {
    jmi_ode_cvode_t* integrator;
    jmi_ode_problem_t* problem = solver -> ode_problem;
    int flag = 0;
    void* cvode_mem;
    jmi_real_t* y;
    jmi_real_t* atol_nv;
    int i;
    
    integrator = (jmi_ode_cvode_t*)calloc(1,sizeof(jmi_ode_cvode_t));
    if(!integrator){
        jmi_log_node(problem->log, logError, "Error", "Failed to allocate the internal CVODE struct.");
        return -1;
    }

    /* DEFAULT VALUES NEEDS TO BE IMPROVED*/
    integrator->lmm  = CV_BDF;
    integrator->iter = CV_NEWTON;
    /* integrator->rtol = 1e-4; */
    integrator->rtol = solver->rel_tol;
    
    if (problem->sizes.states > 0) {
        integrator->atol = N_VNew_Serial(problem->sizes.states);
    } else {
        integrator->atol = N_VNew_Serial(1);
    }
    atol_nv = NV_DATA_S(integrator->atol);
    
    if (problem->sizes.states > 0) {
        for (i = 0; i < problem->sizes.states; i++) {
            atol_nv[i] = 0.01*integrator->rtol*problem->nominals[i];
        }
    }else{
        atol_nv[0] = 0.01*integrator->rtol*1.0;
    }

    cvode_mem = CVodeCreate(integrator->lmm,integrator->iter);
    if(!cvode_mem){
        jmi_log_node(problem->log, logError, "Error", "Failed to allocate the CVODE struct.");
        return -1;
    }

    /* Get the default values for the time and states */
    if (problem->sizes.states > 0) {
        integrator->y_work = N_VNew_Serial(problem->sizes.states);
        y = NV_DATA_S(integrator->y_work);
		memcpy (y, problem->states, problem->sizes.states*sizeof(jmi_real_t));
    }else{
        integrator->y_work = N_VNew_Serial(1);
        y = NV_DATA_S(integrator->y_work);
        y[0] = 0.0;
    }
    
    flag = CVodeInit(cvode_mem, cv_rhs, problem->time, integrator->y_work);
    if(flag != 0) {
        jmi_log_node(problem->log, logError, "Error", "Failed to initialize CVODE. Returned with <error_flag: %d>", flag);
        return -1;
    }

    flag = CVodeSVtolerances(cvode_mem, integrator->rtol, integrator->atol);
    if(flag!=0){
        jmi_log_node(problem->log, logError, "Error", "Failed to specify the tolerances. Returned with <error_flag: %d>", flag);
        return -1;
    }

    if (problem->sizes.states > 0) {
        flag = CVDense(cvode_mem, problem->sizes.states);
    }else{
        flag = CVDense(cvode_mem, 1);
    }
    if(flag!=0){
        jmi_log_node(problem->log, logError, "Error", "Failed to specify the linear solver. Returned with <error_flag: %d>", flag);
        return -1;
    }

    flag = CVodeSetUserData(cvode_mem, (void*)solver);
    if(flag!=0){
        jmi_log_node(problem->log, logError, "Error", "Failed to specify the user data. Returned with <error_flag: %d>", flag);
        return -1;
    }
    
    if (problem->sizes.event_indicators > 0){
        flag = CVodeRootInit(cvode_mem, problem->sizes.event_indicators, cv_root);
        if(flag!=0){
            jmi_log_node(problem->log, logError, "Error", "Failed to specify the event indicator function. Returned with <error_flag: %d>", flag);
            return -1;
        }
    }
    
    flag = CVodeSetErrHandlerFn(cvode_mem, cv_err, (void*)solver);
    if(flag!=0){
        jmi_log_node(problem->log, logError, "Error", "Failed to specify the error handling function. Returned with <error_flag: %d>", flag);
        return -1;
    }

    integrator->cvode_mem = cvode_mem;    
      
    *integrator_ptr = integrator;
    return 0;
}

void jmi_ode_cvode_delete(jmi_ode_solver_t* solver) {
    
    if((jmi_ode_cvode_t*)(solver->integrator)){
        jmi_ode_cvode_t* integrator = (jmi_ode_cvode_t*)solver->integrator;
        jmi_ode_problem_t* problem = solver -> ode_problem;
        jmi_log_node_t node;
        long int nsteps = 0, nfevals = 0, nlinsetups = 0, netfails = 0;
        long int nniters = 0, nncfails = 0;
        int qcur = 0, qlast = 0;
        realtype hinused = 0.0, hlast = 0.0, hcur = 0.0, tcur = 0.0;
        
        /* Get statistics */
        CVodeGetIntegratorStats(integrator->cvode_mem, &nsteps, &nfevals, &nlinsetups, &netfails, &qlast,
                                           &qcur, &hinused, &hlast, &hcur, &tcur);
        CVodeGetNonlinSolvStats(integrator->cvode_mem, &nniters, &nncfails);
        
        node = jmi_log_enter_fmt(problem->log, logInfo, "CVodeStatistics", 
                                     "Simulation statistics");
        jmi_log_fmt(problem->log, node, logInfo, "<nsteps: %d>", nsteps);
        jmi_log_fmt(problem->log, node, logInfo, "<nfevals: %d>", nfevals);
        jmi_log_fmt(problem->log, node, logInfo, "<nerrfails: %d>", netfails);
        jmi_log_fmt(problem->log, node, logInfo, "<nniters: %d>", nniters);
        jmi_log_fmt(problem->log, node, logInfo, "<nnfails: %d>", nncfails);
        jmi_log_leave(problem->log, node);
        
        /*Deallocate work vectors.*/
        N_VDestroy_Serial((((jmi_ode_cvode_t*)(solver->integrator))->y_work));
        N_VDestroy_Serial((((jmi_ode_cvode_t*)(solver->integrator))->atol));
        /*Deallocate CVode */
        CVodeFree(&(((jmi_ode_cvode_t*)(solver->integrator))->cvode_mem));
        
        free((jmi_ode_cvode_t*)(solver->integrator));     
    }
}
