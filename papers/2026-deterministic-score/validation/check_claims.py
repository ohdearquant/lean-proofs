#!/usr/bin/env python3
"""Lightweight claim-ledger sanity check.

This intentionally avoids external YAML dependencies. It checks that the claim
file contains stable claim IDs and the minimum expected claim classes.
"""
import re
import sys
from pathlib import Path

path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("claims.yaml")
text = path.read_text(encoding="utf-8")
ids = re.findall(r"^\s*- id:\s*(C-[A-Z]+-\d+)", text, flags=re.MULTILINE)
if not ids:
    print(f"ERROR: no claim IDs found in {path}")
    sys.exit(1)
if len(ids) != len(set(ids)):
    print("ERROR: duplicate claim IDs found")
    sys.exit(1)
required_prefixes = ["C-FORMAL", "C-IMPL", "C-NONCLAIM"]
missing = [p for p in required_prefixes if not any(i.startswith(p) for i in ids)]
if missing:
    print(f"ERROR: missing claim class(es): {', '.join(missing)}")
    sys.exit(1)
print(f"OK: {len(ids)} claim IDs found in {path}")
