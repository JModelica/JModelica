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


#include "jmi_simple_newton.h"
#include "jmi_block_solver_impl.h"

#define JMI_SIMPLE_NEWTON_TOL 1e-8
#define JMI_SIMPLE_NEWTON_MAX_ITER 100
#define JMI_SIMPLE_NEWTON_FD_TOL 1e-4

void jmi_simple_newton_delete(jmi_block_solver_t *block) {}

int jmi_simple_newton_solve(jmi_block_solver_t *block) {

    int i, INCX, nbr_iter;
    double err_norm;

    int N = block->n;
    int NRHS = 1;
    int LDA = block->n;
    int LDB = block->n;
    int INFO = 0;

    /* Initialize the work vector */
    block->F(block->problem_data,block->x,block->res,JMI_BLOCK_INITIALIZE);

    /* Evaluate */
    block->F(block->problem_data,block->x,block->res,JMI_BLOCK_EVALUATE);

/*  for (i=0;i<block->n;i++) {
        printf(" %f, %f\n",block->x[i],block->res[i]);
    } */

    /* Compute norm */
    INCX = 1;
    err_norm = dnrm2_(&N,block->res,&INCX);

/*  printf ("Initial norm error: %f\n",err_norm); */

    /* Iterate */
    nbr_iter = 0;
    while (err_norm>=JMI_SIMPLE_NEWTON_TOL) {

        if (nbr_iter>JMI_SIMPLE_NEWTON_MAX_ITER) {
            return -1;
        }

        /*
        printf("-- x and res %d --\n",nbr_iter);
        for (i=0;i<block->n;i++) {
            printf(" %f, %f\n",block->x[i],block->res[i]);
        }
        printf("-- x and res --\n");
         */

        /* Compute jacobian */
        jmi_simple_newton_jac(block);

        block->F(block->problem_data,block->x,block->res,JMI_BLOCK_EVALUATE);

        /*
        printf("-- Jacobian at iteration %d --\n",nbr_iter);
        for (i=0;i<N;i++) {
            for (j=0;j<N;j++) {
                printf("%12.12f, ",block->jac[j*N + i]);
            }
            printf("\n");
        }
        printf("-- Jacobian --\n");
        */

        /* Solve linear system to get the step */
        /* J_{k}*dx_{k} = F_{k} */


        /*
        for (i=0;i<block->n;i++) {
            printf(">> %12.12f, %12.12f\n", block->res[i], block->x[i]);
        }
        */

        dgesv_( &N, &NRHS, block->jac, &LDA, block->ipiv, block->res,
                &LDB, &INFO );

        /*printf("Info: %d\n",INFO); */

        /*
        for (i=0;i<block->n;i++) {
            printf("** %12.12f, %12.12f\n", block->res[i], block->x[i]);
        }
        */

        /* Compute new x */
        /* x_{k+1} = x_{k} - dx_{k} */
        for (i=0;i<block->n;i++) {
            block->x[i] = block->x[i] - block->res[i];
        }

        /* Evaluate residual with new x */
        block->F(block->problem_data,block->x,block->res,JMI_BLOCK_EVALUATE);

        /* Compute norm of the residual */
        INCX = 1;
        err_norm = dnrm2_(&N,block->res,&INCX);

/*      printf ("Norm error after iteration %d: %12.12f\n",nbr_iter,err_norm); */

        nbr_iter++;

    }
    return 0;
}

int jmi_simple_newton_jac(jmi_block_solver_t *block) {

    int i,j;

    for (i=0;i<block->n;i++) {
        for (j=0;j<block->n;j++) {
            block->jac[i*(block->n) + j] = block->res[j];
/*          printf(" - %12.12f\n",block->jac[i*(block->n) + j]); */
        }
    }

    for (i=0;i<block->n;i++) {
        block->x[i] += JMI_SIMPLE_NEWTON_FD_TOL;
        block->F(block->problem_data,block->x,block->res,JMI_BLOCK_EVALUATE);
        for (j=0;j<block->n;j++) {
/*          printf(" * %12.12f\n",block->res[j]); */
            block->jac[i*(block->n) + j] = (block->res[j]-block->jac[i*(block->n) + j])/(JMI_SIMPLE_NEWTON_FD_TOL);
        }
        block->x[i] -= JMI_SIMPLE_NEWTON_FD_TOL;
    }

    return 0;

}
