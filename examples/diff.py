#!/usr/bin/python3
#  -*-  coding:  utf-8  -*-

"""Check test output against check files.
"""

import argparse
import re
# import os.path
# import string
# import subprocess

this = __file__
parser = argparse.ArgumentParser(
formatter_class=argparse.RawDescriptionHelpFormatter,
description="""Check test output against check files.
""",epilog="""

E.g.
{} out.check out
""".format(this))


parser.add_argument("check", help="Check output file")
parser.add_argument("new", help="New output file")

args = parser.parse_args()

mismatches = 0

with open(args.check) as CHK, open(args.new) as NEW:
  chk = "--"
  new = "--"
  while not re.match(r'^Starting',chk):
    chk = CHK.readline()
  while not re.match(r'^Starting',new):
    new = NEW.readline()
  while chk != "" and new != "":
      chk = CHK.readline()
      #  Skip blank lines and CPU time lines
      while re.match(r'CPU time', chk) or re.match(r' *$', chk):
        chk = CHK.readline()
      new = NEW.readline()
      while re.match(r'CPU time', new) or re.match(r' *$', new):
        new = NEW.readline()
      if re.match(r'Finished', chk) or re.match(r'Finished', new):
        if not re.match(r'Finished', chk):
          mismatches += 1
          print("New file finished before check file")
        elif not re.match(r'Finished', new):
          print("Extra output in new file")
        break
      new = re.sub(r'-(0.0+)\b', ' $1', new)
      chk = re.sub(r'-(0.0+)\b', ' $1', chk)
      if new != chk and not mismatches:
        print("New output file {} differs from check file {}.".format(args.new,args.check))
        mismatches += 1
        print(chk, end=' ')
        print(new)
  if mismatches:
    print("{1d} lines failed to match")
  else:
    print("New output file checked successfully")

