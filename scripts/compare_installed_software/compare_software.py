# takes a list of CSV's exported from MDE's Software Inventory Page and gets common software installed
# takes an optional CSV that will be used as a set difference

import argparse
import csv
import pprint


def getSoftware(filename):
    # opens passed file, skips the first line and returns the column data for Name
    # unless the Vendor is Microsoft or Pnnl
    with open(filename, "r") as file:
        next(file)
        filecontents = csv.DictReader(file)

        return set(
            [
                row["Name"]
                for row in filecontents
                if row["Vendor"] not in ("Pnnl", "Microsoft")
            ]
        )


# setup arg parser
parser = argparse.ArgumentParser()
parser.add_argument("-f", "--hostfiles", nargs="+", required=True)
parser.add_argument("-d", "--differencefiles")
args = parser.parse_args()

filenames = args.hostfiles

# pull out installed software for each host from the CSV
software = [getSoftware(filename) for filename in filenames]


# print out the intersection between the lists of installed software
union = set.intersection(*software)
pp = pprint.PrettyPrinter(indent=4)
print(f'Union between {" ".join(args.hostfiles)}:')
pp.pprint(list(union))

# Optional: run check to see difference between hosts and additional computer
if args.differencefiles:
    print(f'Set difference between {" ".join(args.hostfiles)} and {args.differencefiles}')
    pp.pprint(list(union - getSoftware(args.differencefiles)))
