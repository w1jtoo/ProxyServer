import os
from sys import platform

result_path = "bin"

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
os.system("nim c -d:ssl --debugger:native src/main.nim")

if platform == "linux" or platform == "linux2":
    os.system(f"mv src/main {debug_path}")
elif platform == "win32":
    os.system(f"move src\main.exe {debug_path}")
else: 
    print("Can't detect os.")
print("Success!")

# RELEASE FILE COMPILING 
print("Building release ...")
os.system("nim c -d:ssl -d:release src/main.nim")

if platform == "linux" or platform == "linux2":
    os.system(f"mv src/main {release_path}")
elif platform == "win32":
    os.system(f"move src\main.exe {release_path}")
else: 
    print("Can't detect os.")
print("Success!")
       

