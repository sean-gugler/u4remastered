#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""Report any .binpatch edits that changed more than just capitalization"""

import os
import re

pat = re.compile(r'match."(.*)".*replace."(.*)"')

for root, dirs, files in os.walk('patches'):
    for f in files:
        pathname = os.path.join(root, f)
        with open(pathname, 'rt') as fh:
            for i,line in enumerate(fh.readlines()):
                if m := pat.search(line):
                    old, new = m.groups()
                    if not old.upper() == new.upper():
                        print(pathname, i, line.rstrip())
