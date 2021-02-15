#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""Find embedded strings and mark regions as data.
by Sean Gugler"""

import sys
import argparse
import re
from itertools import chain, takewhile
from tass_to_c65 import uscii

# def 
    
    # it = iter(src)
    # while True:
        # printable = ''.join(Text[c] for c in takewhile(lambda x: x in Text, it))
        # if printable:
            # yield f'"{printable}"'
        # yield f'{next(it):02x}'

def inline_strings(code):
    jsr_primm_xy = re.compile(rb'\x20\x1e\x08(.*?\x00)')
    jsr_primm    = re.compile(rb'\x20\x21\x08(.*?\x00)')

    Text = {int(k[1:], 16) : ord(v)  for k,v in uscii().items()}

    addr_start = 0x100 * code[1] + code[0] - 2

#    for m in chain(jsr_primm_xy.finditer(code), jsr_primm.finditer(code)):
    for m in chain(*[pat.finditer(code) for pat in (jsr_primm_xy, jsr_primm)]):
        s = addr_start + m.start(1)
        e = addr_start + m.end(1)
        # s,e = (addr_start + x for x in m.span())
        span = f'{s:04X}-{e:04X}'
        legible = f'{s-3:04X} ' + str(bytes(Text.get(c,c) for c in m.group(1)))
        yield span, legible

def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"input")
    p.add_argument(u"output")
    args = p.parse_args(argv[1:])

    with open(args.input, 'rb') as f:
        with open(args.output, 'wt') as out:
            s = inline_strings(f.read())
            spans, strings = zip(*s)
            for s in chain(spans, strings):
                print(s, file=out)

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
