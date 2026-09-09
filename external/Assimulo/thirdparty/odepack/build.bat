RMDIR /S /Q build
MKDIR build
CD build
SET "PATH=C:\Windows\System32\;C:\Program Files\CMake\bin;"
CALL "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"
cmake -G "NMake Makefiles" .. -DCMAKE_Fortran_COMPILER=ifort
cmake --build .
CD ..

