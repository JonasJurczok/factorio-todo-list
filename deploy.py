#!/usr/bin/env python3

""" Factorio mod deploy script """

import os
import sys
import shutil
import glob
import zipfile
import json

## Configuration Section
mod_name = "Todo-List"
deploy_mod = True

##Get version from info.json
version = ""

with open("info.json") as info:
    version = json.load(info)["version"]
    print ("Found version " + version + ".")

if (version == ""):
    print ("No version found. Aborting")
    sys.exit(-1)

directory = mod_name + "_" + version

if not os.path.exists(directory):
    os.makedirs(directory)
    print ("Directory " + directory + " created.")
else:
    print ("Directory " + directory + " already exists. Aborting...")
    sys.exit(-2)

os.chdir('src')
print(os.getcwd())
for file in glob.glob('**/*.lua', recursive=True):
    print ("Copying " + file + "...")
    sub_dirs = os.path.split(file)[0]
    print(sub_dirs)
    if len(sub_dirs) > 0:
        os.makedirs('..' + os.sep + directory + os.sep + sub_dirs, exist_ok=True)
    shutil.copy(file, '..' + os.sep + directory + os.sep + file)
os.chdir('..')

print ("Copying locales")
shutil.copytree("locale", directory + "/locale")

print ("Copying info.json")
shutil.copy("info.json", directory)

print ("Creating zipfile...")
zipname = directory + '.zip'
zipf = zipfile.ZipFile(directory + '.zip', 'w', zipfile.ZIP_DEFLATED)

for root, dirs, files in os.walk(directory):
    for file in files:
        zipf.write(os.path.join(root, file))
zipf.close()

print ("Removing directory...")
shutil.rmtree(directory)

print ("Release " + version + " completed.")

if deploy_mod:
    destination = '/home/jgay/.factorio/mods/' + zipname
    if os.path.exists(destination):
        os.remove(destination)
    shutil.move(zipname, destination)
