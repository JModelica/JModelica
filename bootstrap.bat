@echo off
setlocal

if "%~1" == "clean" (
    echo Cleaning build directory...
    rmdir /s /q build
    exit /b 0
)

echo Creating build directory...
if not exist build mkdir build

cd build
@REM cmake -G "Unix Makefiles" ..
@REM cmake -G "MSYS Makefiles" ..
@REM cmake -G "MinGW Makefiles" ..
cmake -G "Unix Makefiles" .. -DOpenMP_C_FLAGS=-fopenmp -DOpenMP_CXX_FLAGS=-fopenmp -DOpenMP_C_LIB_NAMES="libomp" -DOpenMP_CXX_LIB_NAMES="libomp" -DOpenMP_libomp_LIBRARY="C:\\tools\\msys64\\mingw64\\include"


@REM cmake --build . -- VERBOSE=1
cd ..

endlocal
exit /b 0