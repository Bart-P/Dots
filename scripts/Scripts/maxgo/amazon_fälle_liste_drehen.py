import csv
import sys

file_in = sys.argv[1]
file_out = sys.argv[2]

table = []
row = []
with open(file_in, mode='r') as file:
    csvFile = csv.reader(file, delimiter='\t')
    for index, line in enumerate(csvFile):
        if line:
            row.append(line[0])

        if (index + 1) % 10 == 0:
            table.append(row)
            row = []
            counter = 0


with open(file_out, mode="w", newline="") as file:
    writer = csv.writer(file)
    writer.writerows(table)
