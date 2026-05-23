# Source Notes

Checked on 2026-05-22.

## Venue

- ITP 2026 CFP: regular papers are no more than 16 pages excluding bibliographic references, no appendix, and in LIPIcs format.
- ITP 2026 CFP: submissions use lightweight double-blind review.
- ITP 2026 CFP: papers must be prepared in LaTeX using `lipics-v2021` v2021.1.3 and accompanied by anonymized supplementary material containing verifiable implementation/formalization evidence.

## LIPIcs style

- Dagstuhl LIPIcs author instructions require BibTeX with `plainurl` bibliography style.
- Dagstuhl LIPIcs author instructions discourage layout overrides and unsupported packages.
- The paper uses `listings` instead of `minted` to avoid shell-escape dependency.

## Artifact facts

The following facts are author-supplied and must be revalidated from CI logs before submission:

- Lean toolchain: Lean 4.25.2 + Mathlib v4.25.2.
- Lean theorem count: 49.
- Lean status: zero `sorry`, clean compile.
- Rust file: `ruvector-core/src/deterministic_score.rs`.
- Rust branch: `feat/deterministic-scoring`.
- Test evidence: repository tests pass, including deterministic-score-specific tests.
