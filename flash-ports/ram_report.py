"""Summarise TI-84 Plus CE RAM layout from a CEmu RAM dump (native-ram.bin).

Free RAM = OPS - FPS: the gap between the floating-point stack top and the
operator stack/VAT bottom. asm_prgm_size is the running program's inserted
size. Usage: python ram_report.py path/to/native-ram.bin [map file]
"""
import sys
from pathlib import Path

ram = Path(sys.argv[1]).read_bytes()
BASE = 0xD00000
def u24(addr):
    o = addr - BASE
    return ram[o] | ram[o + 1] << 8 | ram[o + 2] << 16
vals = {n: u24(a) for n, a in dict(asm_prgm_size=0xD0118C, tempMem=0xD02587, FPBase=0xD0258A, FPS=0xD0258D,
                                    OPBase=0xD02590, OPS=0xD02593, pTemp=0xD0259A, progPtr=0xD0259D).items()}
for k, v in vals.items():
    print(f'{k:14s} 0x{v:06X}' + (f' ({v})' if k == 'asm_prgm_size' else ''))
print('program end    0x%06X' % (0xD1A881 + vals['asm_prgm_size']))
print('free RAM (OPS-FPS):', vals['OPS'] - vals['FPS'])
print('symTable-OPBase gap (includes VAT):', 0xD3FFFF - vals['OPBase'])
print('symTable-progPtr gap (not total VAT):', 0xD3FFFF - vals['progPtr'])
