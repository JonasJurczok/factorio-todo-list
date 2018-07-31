#! python

import os, sys, shutil, glob, zipfile, json

version = ""

with open("info.json") as info:
    version = json.load(info)["version"]
    print ("Found version " + version + ".")

if (version == ""):
    print ("No version found. Aborting")
    sys.exit(-1)

directory = "Todo-List_" + version

if not os.path.exists(directory):
    os.makedirs(directory)
    print ("Directory " + directory + " created.")
else:
    print ("Directory " + directory + " already exists. Aborting...")
    sys.exit(-2)

for file in glob.glob(r'src/*.lua'):
    print ("Copying " + file + "...")
    shutil.copy(file, directory)

print ("Copying todo directory...")
shutil.copytree('src/todo', directory + "/todo")

print ("Copying locales")
shutil.copytree("locale", directory + "/locale")

print ("Copying info.json")
shutil.copy("info.json", directory)

print ("Creating zipfile...")
zipf = zipfile.ZipFile(directory + '.zip', 'w', zipfile.ZIP_DEFLATED)

for root, dirs, files in os.walk(directory):
    for file in files:
        zipf.write(os.path.join(root, file))
zipf.close()

print ("Removing directory...")
shutil.rmtree(directory)

print ("Release " + version + " completed.")
