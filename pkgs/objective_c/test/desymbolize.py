#!/usr/bin/env python3
# Desymbolizes a Dart AOT crash dump on macOS using atos.
#
# Usage:
#   python3 test/desymbolize.py <crash_file> <aot_binary>
#
# Example (without fix — produces EXC_BAD_ACCESS):
#   dart compile exe test/finalizable_test.dart -o /tmp/ft/finalizable_test
#   DYLD_INSERT_LIBRARIES=.dart_tool/lib/objective_c.dylib /tmp/ft/finalizable_test 2>&1 | tee /tmp/ft/crash.txt
#   python3 test/desymbolize.py /tmp/ft/crash.txt /tmp/ft/finalizable_test

import subprocess, re, sys, os

if len(sys.argv) != 3:
    sys.exit(f'Usage: {sys.argv[0]} <crash_file> <aot_binary>')

try:
    crash = open(sys.argv[1], encoding='utf-8', errors='replace').read()
except OSError as e:
    sys.exit(f'ERROR: Cannot read crash file: {e}')

binary = sys.argv[2]
binary_name = os.path.basename(binary)

# Detect the binary architecture for atos.
try:
    arch_out = subprocess.check_output(
        ['lipo', '-archs', binary], stderr=subprocess.DEVNULL
    ).decode().strip()
    arch = arch_out.split()[0]  # take the first arch if universal binary
except Exception:
    arch = 'arm64'  # safe default for Apple Silicon

load = None

# --- Anchor method 1: Dart_UnloadMachODylib annotation ---
# Format: "  pc 0xRUNTIME ... Dart_UnloadMachODylib+0xOFFSET"
# Present in Dart VM crash output when the symbol is annotated.
m = re.search(r'pc (0x[0-9a-f]+) .* Dart_UnloadMachODylib\+(0x[0-9a-f]+)', crash)
if m:
    runtime_start = int(m.group(1), 16) - int(m.group(2), 16)
    try:
        nm_out = subprocess.check_output(
            ['nm', '-n', binary], stderr=subprocess.DEVNULL
        ).decode()
        parts_list = [l.split() for l in nm_out.splitlines()]
        nm_addr = next(
            int(p[0], 16)
            for p in parts_list
            if len(p) >= 3 and p[1] == 'T' and 'Dart_UnloadMachODylib' in p[2]
        )
        load = hex(0x100000000 + runtime_start - nm_addr)
    except StopIteration:
        # Dart_UnloadMachODylib stripped from binary — fall through to method 2.
        pass

# --- Anchor method 2: "(in binary_name)" format ---
# Format: "  pc 0xRUNTIME  0xBINARY_RELATIVE (in binary_name) + N"
# Present in macOS crash reporter output (e.g. from a signal handler dump).
# slide = runtime_pc - binary_relative_pc
if load is None:
    m2 = re.search(
        rf'pc (0x[0-9a-f]+)\s+(0x[0-9a-f]+) \(in {re.escape(binary_name)}\)',
        crash,
    )
    if m2:
        slide = int(m2.group(1), 16) - int(m2.group(2), 16)
        load = hex(0x100000000 + slide)

if load is None:
    sys.exit(
        'ERROR: Could not determine ASLR slide.\n'
        '  Tried: "Dart_UnloadMachODylib+offset" annotation\n'
        f'  Tried: "(in {binary_name})" address pairs\n'
        'Make sure the crash file came from this binary.'
    )

print(f'load_address: {load}  arch: {arch}\n')

for line in crash.splitlines():
    m3 = re.match(r'(\s+pc )(0x[0-9a-f]+)(.*)', line)
    if not m3:
        print(line)
        continue
    annotation = m3.group(3).strip()
    # Only call atos for frames the Dart VM couldn't identify.
    # Already-annotated frames (objc_retain, gc_inject_imp, [Optimized] ...) are
    # passed through unchanged — atos only knows the Dart AOT binary anyway.
    if annotation and 'Unknown symbol' not in annotation:
        print(line)
        continue
    pc = m3.group(2)
    sym = subprocess.check_output(
        ['atos', '-o', binary, '-arch', arch, '-l', load, pc],
        stderr=subprocess.DEVNULL,
    ).decode().strip()
    # If atos returned just a hex address it didn't resolve — keep original.
    if not sym or sym.startswith('0x'):
        print(line)
    else:
        print(f'{m3.group(1)}{pc}  {sym}')
