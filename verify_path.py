
import os
path = "/app/Compiler/build/libs/Compiler.jar"
print(f"Path: {path}")
print(f"Exists: {os.path.exists(path)}")
print(f"CWD: {os.getcwd()}")
print(f"Listdir /app/Compiler/build/libs: {os.listdir('/app/Compiler/build/libs')}")
