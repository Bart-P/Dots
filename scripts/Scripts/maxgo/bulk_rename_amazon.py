import os
import sys
import csv
import subprocess

dir = sys.argv[1]

current_file_names = []

for file in sorted(os.listdir(dir)):
    file_name = os.fsdecode(file)

    current_file_names.append(file_name)

old_and_new_file_name_dicts = []

print("working on dir" + dir)

with open(dir + "/names.csv", mode='r') as file:
    print("working names.csv" + dir)
    csvFile = csv.reader(file, delimiter='\t')
    for lines in csvFile:
        old_and_new_file_name_dicts.append({
            "old": lines[1],
            "new": lines[3]
        })

    old_and_new_file_name_dicts.pop(0)

print("starting renaming ...")

for file in old_and_new_file_name_dicts:
    old_file_name = os.path.join(dir, file['old'])
    new_file_name = os.path.join(dir, file['new'])

    subprocess.run(f"convert '{old_file_name}' '{new_file_name}'",
                   shell="True", executable="/bin/bash")
    print(file['old'] + " -> " + file['new'])

print("all done")
