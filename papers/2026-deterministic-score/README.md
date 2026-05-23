# DeterministicScore ITP 2026 Paper Package

This directory is a LIPIcs/ITP 2026 paper source package for:

> Deterministic Score Comparison by Lean-Checked Fixed-Point Integers

The package is written for the ITP 2026 regular-paper format: LIPIcs, `lipics-v2021` style, maximum 16 pages excluding bibliographic references, and no appendix.

## Contents

```text
main.tex                 # LIPIcs paper source
references.bib           # BibTeX bibliography using plainurl style
venue.yaml               # ITP 2026 venue adapter
claims.yaml              # Machine-readable claim ledger
proof-map.yaml           # Theorem/Rust correspondence map
artifact.md              # Artifact validation instructions
ai-use.md                # GenAI disclosure draft
Makefile                 # Local paper build helper
validation/check_claims.py
validation/check_no_forbidden_claims.py
```

## Required external template files

The official LIPIcs style is not vendored in this package. Download `lipics-v2021` v2021.1.3 from Dagstuhl Publishing and place `lipics-v2021.cls` next to `main.tex`, or install it in your TeX tree.

ITP 2026 requires the `lipics-v2021` style v2021.1.3.

## Build paper

```bash
make paper
```

Equivalent manual command:

```bash
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

## Validate claims

```bash
make validate
```

The validation scripts check the claim ledger and flag forbidden overclaiming phrases in `main.tex`. They do not replace Lean or Rust compilation.

## Artifact validation expected before submission

From the Lean repository:

```bash
lake build
grep -R "\bsorry\b\|\badmit\b" --include='*.lean' .
```

From the Rust repository:

```bash
cargo test --locked
cargo fmt --check
cargo clippy --locked -- -D warnings
```

## Important status note

The paper text is intentionally scoped to the user-supplied artifact facts:

- Lean 4.25.2 + Mathlib v4.25.2;
- 51 Lean theorems;
- zero `sorry`;
- Rust implementation in `ruvector-core/src/deterministic_score.rs`;
- repository test suite evidence, including deterministic-score-specific tests.

The package does not include the Lean or Rust repositories themselves. Before submission, add exact commit hashes to `artifact.md`, `venue.yaml`, `claims.yaml`, and the supplementary material statement.
