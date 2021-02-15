#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""Convert assembly source from TASS format to CC65 format.
by Sean Gugler"""

import sys
import argparse
import os.path
import itertools
import re

org    = re.compile(r'\t\* = (.*)')
char   = re.compile(r'\t.charmap \$(..), (\$..)$')
define = re.compile(r'([^ \t].*) = (.*)')
# data   = re.compile(r'.BYTE (.*)')
data   = re.compile(r'.BYTE ([^;]*)\n')
branch = re.compile(r'([BJ]..) ([+-].*)')
# value  = re.compile(r'(.*)#(\$.. *);(#.*)')
# literal = re.compile(r'(.*)#(\$.. *);(#[^ -][^;]*)(;.*)?')
# literal = re.compile(r'(.*)#(\$.. *);#([^ ;]+)( *;.*)?')
# literal = re.compile(r'(.*)#(\$.. *);#([^;]+)(;.*)?')
literal = re.compile(r'(.*)(\$.*);#([^;]+)(;.*)?')
zp = re.compile(r'([^ ]*)(.*);\$([^;]+)(;.*)?')
                # LDA zp6A     ;$zp_field_type

# test1 = 'LDA #$4D     ;#tile_attack_small ;comment\n'
# m = value.match(test1)
# op,val,comment,x = m.groups()

def uscii():
    def read():
        with open('src/include/uscii.i', "rt") as f:
            for line in f.readlines():
                if m := char.search(line):
                    yield m.groups()
    trans = {usc: chr(int(asc,16))  for asc,usc in read()}
    trans['$8d'] = '\n'
    del trans['$a2']
    # trans['$a2'] = r'\"'
    return trans

def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument(u"-v", u"--verbose", action=u"store_true",
                   help=u"Verbose output.")
    p.add_argument(u"-c", u"--caps", action=u"store_true",
                   help=u"Store strings in original case.")
    p.add_argument(u"input")
    p.add_argument(u"outsrc")
    p.add_argument(u"outinc")
    args = p.parse_args(argv[1:])

    Text = uscii()
    Syms = {}
    Values = []

    with open(args.input, "rt") as f:
        lines = f.readlines()
    
    with open(args.outsrc, "wt") as f:
        # Write header
        inc = os.path.basename(args.outinc)
        f.write('\t.include "uscii.i"\n')
        f.write(f'\t.include "{inc}"\n\n')
        
        # Emit .byte statements in chunks of 8
        bytes = []
        def flush_bytes():
            it = iter(bytes)
            while b := list(itertools.islice(it,8)):
                s = ','.join(b)
                f.write(f'\t.byte {s}\n')
                # print(s)
                # raise Exception
            bytes[:] = []

        for line in lines:
            # flush = True

            # Full line comment
            if line[0] == ';':
                out = line

            # Start address
            elif m := org.match(line):
                seg = 'OVERLAY' if m.group(1) == '$8800' else 'MAIN'
                out = f'\n\n\t.segment "{seg}"'

            # Symbol Definitions
            elif m := define.match(line):
                name, value = m.groups()
                out = line.lower()
                if name in Syms:
                    assert(Syms[name] == value)
                    out = ';' + out
                elif any(c in name for c in ' +-'):
                    out = ';' + out
                Syms[name] = value

            # Instruction, with optional label
            elif '\t' in line:
                label, code = line.split('\t')
                out = '\t'

                # Write label on separate line, but
                # skip derivative labels like "symbol + 1"
                if code.startswith('='):
                    # print(f'CUT: {label}')
                    continue
                if label and not '+' in label[1:]:
                    if label in ('+','-'):
                        # f.write(':')
                        out = ':' + out
                    else:
                        flush_bytes()
                        f.write(label.lower().strip() + ':\n')
                        # out = label.lower().strip() + ':\n' + out

                # JSR j_primm  ;b'left\n\x00'
                # .BYTE $EC,$E5,$E6,$F4,$8D,$00

                # Accumulate .byte statements, detecting $00
                # as potential marker at end of a text string
                if m := data.match(code):
                    bytes.extend(m.group(1).lower().split(','))
                    try:
                        while (i := bytes.index('$00')) >= 0:
                            st = ''.join(Text[b] for b in bytes[:i])
                            if not args.caps:
                                st = st.lower()
                            st = st.replace('\n', '", $8d\n\t.byte "')
                            st = f'\t.byte "{st}", 0\n'
                            st = st.replace(' "", '  ,  ' ')
                            f.write(st)
                            bytes = bytes[i+1:]
                    except (ValueError, KeyError):
                        pass
                        # f.write(str(bytes))
                    continue

                # Branch with convenience label '+' or '-'
                elif m := branch.match(code):
                    op, label = m.groups()
                    out += f'{op.lower()} :{label}\n'

                # Replace literal values with symbols
                elif m := literal.match(code):
                    op, value, expr, comment = m.groups()
                    op, value = (x.lower() for x in (op, value))
                    if expr == '-\n':
                # LDA #$CC     ;#-
                        out += f'{op}{value}'
                        # f.write(f'\t{op}#{value}\n')
                    elif expr.startswith(' '):
                # AND #$07     ;# modulo
                        out += f'{op}{value};{expr[1:]}'
                        # f.write(f'\t{op}#{value};{symbol}')
                        # f.write(f'\t{code.lower()}')
                    else:
                # LDX #$7F     ;#file_id_smap ;saved_map
                # .BYTE $B0    ;#arena_dng_hall ; orb
                # LDA #$CF     ;#music_Overworld
                # LDX #$20     ;#object_max + 1
                        out += f'{op}{expr}{comment or ""}'
                        Values.append((value.strip(), expr.strip()))

                # Allow multiple symbols for same address
                elif m := zp.match(code):
                # LDA zp6A     ;$zp_field_type
                    op, value, expr, comment = m.groups()
                    out += f'{op.lower()} {expr}{comment or ""}'
                    Values.append((value.strip(), expr.strip()))

                elif ';' in code:
                # CMP #$18     ;row 24
                # BEQ @check_transport ;loc_world
                    asm, comment = code.split(';', 1)
                    if comment.startswith('#'):
                        comment = comment[1:]
                    out += asm.lower() + ';' + comment.strip()


                # All other statements verbatim
                else:
                    out += code.lower()
            else:
                out = line

            flush_bytes()
            f.write(out.rstrip() + '\n')

        flush_bytes()

    with open(args.outinc, "wt") as f:
        # Write definitions
        def rekey(item):
            value,symbol = item
            prefix,suffix = symbol.split('_', 1)
            return (prefix,value,suffix)

        def unique(it):
            prev = None
            for cur in it:
                if cur != prev:
                    yield cur
                prev = cur

        prev = None
        for item in unique(sorted(map(rekey, Values))):
            prefix,value,suffix = item
            if prefix != prev:
                print('', file=f)
            prev = prefix
            if any(c in suffix for c in ' +-'):
                prefix = ';' + prefix
            if value.startswith('zp'):
                value = '$' + value[2:4].lower()
            print(f'{prefix}_{suffix} = {value}', file=f)

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
