#!/usr/bin/env python3
"""Flag high-risk phrases unless they occur in explicit non-claim context."""
import re
import sys
from pathlib import Path

path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("main.tex")
text = path.read_text(encoding="utf-8")
phrases = [
    "deterministic ranking",
    "deterministic record ranking",
    "verified Rust implementation",
    "IEEE-754 conversion correctness",
    "state-of-the-art retrieval performance",
    "SOTA retrieval performance",
    "proved Rust overflow safety",
    "mechanized Rust overflow safety",
]
errors = []
for phrase in phrases:
    for m in re.finditer(re.escape(phrase), text, flags=re.IGNORECASE):
        start = max(0, m.start() - 160)
        end = min(len(text), m.end() + 160)
        context = text[start:end].lower()
        allowed = any(token in context for token in [
            "does not claim",
            "do not claim",
            "not claim",
            "not deterministic",
            "not a verified",
            "not an ieee",
            "non-claim",
            "avoided",
            "outside the lean artifact",
        ])
        if not allowed:
            errors.append((phrase, m.start(), text[start:end].replace("\n", " ")))
if errors:
    print("ERROR: high-risk phrase(s) outside explicit non-claim context:")
    for phrase, pos, ctx in errors:
        print(f"- {phrase!r} at byte {pos}: ...{ctx}...")
    sys.exit(1)
print(f"OK: high-risk phrases are scoped as non-claims in {path}")
