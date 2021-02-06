#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""Convert strings embedded in .s files to upper-case"""

import sys
import re

srcFile = sys.argv[1]
dstFile = sys.argv[2] if len(sys.argv) > 2  else srcFile

pat = re.compile(r'.byte "(.*)"')
repl = lambda match: f'.byte "{match.group(1).upper()}"'

with open(srcFile, 'rt', encoding='utf-8') as f:
	src = f.read()
with open(dstFile, 'wt', encoding='utf-8') as f:
	dst = pat.sub(repl, src)
	f.write(dst)
