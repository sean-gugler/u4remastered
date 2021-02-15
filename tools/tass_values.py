#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""Generats TASS comments from list of Value literals
by Sean Gugler"""

import sys
import argparse
import os.path
import itertools
import re
from collections import defaultdict

FORCE = ''
IF_FLAGGED = '-'
def replace(table, line, match):
    addr = line[:4]
    comment = line[5:]
    prev = table.get(addr, '')
    if prev.startswith(match):
        table[addr] = comment
    else:
        del table[addr]

# $8d = char_newline
def parse_values(file):
    V = defaultdict(list)
    with open(file, "rt") as f:
        for n,sym in [kv.split()  for kv in f.read().split('\n')  if kv]:
            V[n.lower()].append(sym)
    return V

# $409A  LDA #$8d
def parse_disasm(file):
    asm = re.compile(r'^\$(....):[^;]*#(...)')
    with open(file, "rt") as f:
        for line in f.readlines():
            if m := asm.match(line):
                yield m.groups()

# :SIDE COMMENTS
# 4009 mode_loading|dir_north
def parse_regen(args):
    V = parse_values(args.values)
    hand = {}
    prev = {}
    with open(args.regen, "rt") as f:
        mode = 'copy'
        for line in f.readlines():
            if mode == 'gen':
                if line.startswith(':'):
                    for addr,val in parse_disasm(args.disasm):
                        if v := V.get(val.lower()):
                            if not addr in hand:
                                comment = prev.get(addr, '')
                                if not comment.startswith('#'):
                                    comment = '|'.join(v)
                                yield f'{addr} {comment}\n'
                    mode = 'copy'
                else:
                    addr, comment = line[:4], line[5:]
                    prev[addr] = comment.rstrip()
                    continue
            if mode == 'read':
                if line.startswith('5E8B'):
                    mode = 'gen'
                else:
                    addr, comment = line[:4], line[5:]
                    hand[addr] = comment
            if mode == 'copy':
                if line.startswith(':SIDE COMMENTS'):
                    mode = 'read'
            yield line


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"-c", u"--caps", action=u"store_true",
                   help=u"Store strings in all-caps.")
    p.add_argument(u"values", help=u"File of '$nn description' lines")
    p.add_argument(u"disasm", help=u"File pasted from 'copy full' in Regenerator")
    p.add_argument(u"regen", help=u"Config file for Regenerator")
    args = p.parse_args(argv[1:])

    lines = list(parse_regen(args))
    for line in lines:
        print(line, end='')

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
