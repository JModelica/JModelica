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

/** \file fmi1_functions.h
 *  \brief The FMI 1.0 types
 */

#ifndef _FMI1_TYPES_H
#define _FMI1_TYPES_H


/* Platform (combination of machine, compiler, operating system) */
#define fmiModelTypesPlatform "standard32"
#define fmiPlatform "standard32"

/* Type definitions of variables passed as arguments
   Version "standard32" means:

   fmiComponent     : 32 bit pointer
   fmiValueReference: 32 bit
   fmiReal          : 64 bit
   fmiInteger       : 32 bit
   fmiBoolean       :  8 bit
   fmiString        : 32 bit pointer

*/
   typedef void*        fmiComponent;
   typedef unsigned int fmiValueReference;
   typedef double       fmiReal   ;
   typedef int          fmiInteger;
   typedef char         fmiBoolean;
   typedef const char*  fmiString ;

/* Values for fmiBoolean  */
#define fmiTrue  1
#define fmiFalse 0

/* Undefined value for fmiValueReference (largest unsigned int value) */
#define fmiUndefinedValueReference (fmiValueReference)(-1)


#endif
