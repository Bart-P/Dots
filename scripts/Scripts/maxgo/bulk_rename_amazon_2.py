import os
import sys
import csv
import subprocess
import zipfile

dir = sys.argv[1]

current_file_names = []

for file in sorted(os.listdir(dir)):
    file_name = os.fsdecode(file)

    current_file_names.append(file_name)

old_and_new_names = []

print("working on dir -> " + dir)

with open(dir + "/names.csv", mode='r') as file:
    print("reading names.csv -> " + dir)
    csvFile = csv.reader(file, delimiter='\t')
    for lines in csvFile:
        old_and_new_names.append({
            "old": lines[1],
            "new": lines[3]
        })

    old_and_new_names.pop(0)

print("creating directory for renamed files...")

os.makedirs(dir + "renamed", exist_ok=True)

print("directory 'renamed' was created in " + dir)

print("renaming...")

for file in old_and_new_names:
    old_file_name = os.path.join(dir, file['old'])
    new_file_name = os.path.join(dir, file['new'])

    subprocess.run(f"convert '{old_file_name}' '{new_file_name}'",
                   shell="True", executable="/bin/bash")

    # move the new file to renamed folder created before
    os.rename(new_file_name, os.path.join(dir, "renamed", file['new']))
    print(file['old'] + " -> " + file['new'])

print("renaming done.")
print("'zipping' it up...")

renamed_dir = os.path.join(dir, "renamed")
parent_dir = os.path.basename(os.path.abspath(dir))
zip_file = os.path.join(dir, f"{parent_dir}.zip")

with zipfile.ZipFile(zip_file, "w", zipfile.ZIP_DEFLATED) as archive:
    for root, dirs, files in os.walk(renamed_dir):
        print(list(dirs))
        for file in files:
            print(f"zipping '{file}' -> '{zip_file}'")
            file_path = os.path.join(root, file)
            archive.write(file_path, arcname=file)

print("all zipped up!")
