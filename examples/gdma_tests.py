#!/usr/bin/python3
#  -*-  coding:  utf-8  -*-

"""Run the gdma tests.
"""

import argparse
# import re
import os
# import string
import subprocess

this = __file__
parser = argparse.ArgumentParser(
formatter_class=argparse.RawDescriptionHelpFormatter,
description="""Run the gdma tests.
""",epilog="""
{} [-p program-file] [ test test ... ]

The available tests are 
CO_G03, H2O, C2H4_G03, formamide_G03, formamide_psi4
The default is to run all of them. Note that formamide_psi4 is much slower
than the others, as it uses a much larger basis set.
""".format(this))


here = os.environ["PWD"]
base = os.path.dirname(here)
program = os.path.join(base,"bin","gdma")
diff = os.path.join(here,"diff.py")

parser.add_argument("tests", help="Test directories", nargs="*")
parser.add_argument("-p", help="Alternative gdma program file",
                    default=program)

args = parser.parse_args()

if args.tests:
    tests = args.tests
else:
    tests = ["CO_G03", "H2O", "C2H4_G03", "formamide_G03", "formamide_psi4"]

for test in tests:
    os.chdir(test)
    print("----------")
    print(f"{test}:")
    for f in ["out", "punch"]:
        if os.path.exists(f): os.remove(f)
    with open("data") as D, open("out","w") as OUT:
        rc = subprocess.call([program], stdin=D, stdout=OUT, stderr=subprocess.STDOUT)
    if rc != 0:
        print(f"GDMA failed with return code {rc:1d}")
    else:
        subprocess.call(f"{diff} out.check out", shell=True)
    os.chdir(here)

