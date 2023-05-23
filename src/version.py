#!/usr/bin/python3
#  -*-  coding:  utf-8  -*-

"""Construct the version.f90 file that contains version details.
"""

import argparse
import re
from datetime import datetime
# import os
# import string
import subprocess

this = __file__
parser = argparse.ArgumentParser(
formatter_class=argparse.RawDescriptionHelpFormatter,
description="""Construct the version.f90 file that contains version details.
""",epilog="""
{} args
""".format(this))


parser.add_argument("vfile", help="VERSION file path")
parser.add_argument("v90", help="version.f90 file path")
parser.add_argument("compiler", help="Compiler")

args = parser.parse_args()

with open(args.vfile) as IN:
  line = IN.readline().strip()
  version = re.sub(r"VERSION +:= +", "", line)
  line = IN.readline().strip()
  patchlevel = re.sub("PATCHLEVEL +:= +", "", line)

now = datetime.today().strftime('%d %B %Y at %H:%M:%S')
#log = subprocess.check_output("git log -n 1 --oneline", shell=True,
#                              universal_newlines=True)
#commit = log.split()[0]
commit = "e2d289a"  # TODO

with open(args.v90,"w") as OUT:
  OUT.write(f"""MODULE version

!  version.f90 is generated automatically by version.py
!  GDMA version and build date
CHARACTER(*), PARAMETER :: gdma_version = "{version}.{patchlevel}"
""")

  OUT.write(f'CHARACTER(*), PARAMETER :: commit="{commit}"\n')
  OUT.write(f'CHARACTER(*), PARAMETER :: compiler="{args.compiler}"\n')
  OUT.write(f'CHARACTER(*), PARAMETER :: compiled="{now}"\n')

  OUT.write('\nEND MODULE version\n')
