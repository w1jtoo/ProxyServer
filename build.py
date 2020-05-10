import os
from sys import platform

result_path = "bin"
FILE_NAME = "ProxyServer"

print("Preparing paths...")
if not os.path.exists(result_path):
    os.mkdir(result_path)

release_path = os.path.join(result_path, "release")
if not os.path.exists(release_path):
    os.mkdir(release_path)

debug_path = os.path.join(result_path, "debug")
if not os.path.exists(debug_path):
    os.mkdir(debug_path)


# DEBUG FILE COMPILING 
print("Building debug ...")
os.system(f"nim c -d:ssl --debugger:native src/{FILE_NAME}.nim")

if platform == "linux" or platform == "linux2":
    os.system(f"mv src/{FILE_NAME} {debug_path}")
elif platform == "win32":
    os.system(f"move src\{FILE_NAME}.exe {debug_path}")
else: 
    print("Can't detect os.")
print("Success!")

# RELEASE FILE COMPILING 
print("Building release ...")
os.system(f"nim c -d:ssl -d:release src/{FILE_NAME}.nim")

if platform == "linux" or platform == "linux2":
    os.system(f"mv src/{FILE_NAME} {release_path}")
elif platform == "win32":
    os.system(f"move src\{FILE_NAME}.exe {release_path}")
else: 
    print("Can't detect os.")
print("Success!")
       

