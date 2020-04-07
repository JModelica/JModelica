/*
Copyright (C) 2013 Modelon AB

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <iostream>
#include "initjcc.h"

#include "sharedTransferFunctionality.hpp"

void setUpJVM() {
    std::cout << "Creating JVM" << std::endl;
    jint version = initJVM();
    std::cout << "Created JVM, JNI version " << (version>>16) << "." << (version&0xffff) << '\n' << std::endl;
}

void tearDownJVM() {
    // Make sure that no JCC proxy objects live in this scope, as they will then  
    // try to free their java objects after the JVM has been destroyed. 
    std::cout << "\nDestroying JVM" << std::endl;
    destroyJVM();
    std::cout << "Destroyed JVM" << std::endl;
}


