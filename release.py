#!/usr/bin/env python
import sys
import json
from enum import Enum
import subprocess
from datetime import date
import os

class Action(Enum):
    PATCH = 1
    MINOR = 2
    MAJOR = 3

# verify options
action = Action.PATCH
if (len(sys.argv) == 1):
    print("Usage 'release.py [MAJOR|MINOR|PATCH]'. PATCH is default.")
    print("No version element provided. Defaulting to PATCH.")
else:
    action = Action[sys.argv[1].upper()]
    print("Incrementing version element " + action.name)

# get current version
with open('info.json') as f:
  data = json.load(f)
  current = data['version']
  print("Current version is " + current)

# increment according to provided option
split_version = current.split('.')
if (action == Action.PATCH):
    split_version[2] = str(int(split_version[2]) + 1)
elif (action == Action.MINOR):
    split_version[1] = str(int(split_version[1]) + 1)
    split_version[2] = "0"
elif (action == Action.MAJOR):
    split_version[0] = str(int(split_version[0]) + 1)
    split_version[1] = "0"
    split_version[2] = "0"

new_version = ".".join(split_version)
print("New version is " + new_version)
with open('info.json') as f:
  data = json.load(f)
  data['version'] = new_version
  with open('info.json', 'w') as file:
      json.dump(data, file, indent=2)

# generate changelog
result = subprocess.run(['git', 'log', current + '..HEAD', '--pretty=format:"%s%n  %b"'], stdout=subprocess.PIPE)
commits = result.stdout.decode('utf-8').replace('"', '')
commits = os.linesep.join(["#" + s for s in commits.splitlines() if s.strip() != ""])

today = date.today()

changelog = """---------------------------------------------------------------------------------------------------
Version: {new_version}
Date: {today}
# Commits since last tag.
# Remove all lines with # in the beginning and order the content into the categories below.
{commits}
  Major Features:
    - sample entry
      Continued
  Features:
  Minor Features:
  Graphics:
  Sounds:
  Optimisations:
  Balancing:
  Combat Balancing:
  Circuit Network:
  Changes:
  Bugfixes:
  Modding:
  Scripting:
  Gui:
  Control:
  Translation:
  Debug:
  Ease of use:
  Info:
  Locale:
  Other:
---------------------------------------------------------------------------------------------------
""".format(**locals())

with open("changelog.txt") as f:
    lines = f.readlines()
lines[0] = changelog
with open("changelog.txt", "w") as f:
    f.writelines(lines)

# wait for user to edit changelog
input("Please edit the changelog and then press [ENTER]")

# commit
subprocess.run(['git', 'commit', '-am"Release version ' + new_version + '"'])
# tag with new version
subprocess.run(['git', 'tag', new_version])

