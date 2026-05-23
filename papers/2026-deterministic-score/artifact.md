# Artifact Description

## Formal artifact

| Field | Value |
|-------|-------|
| Repository | `github.com/ohdearquant/lean-proofs` |
| File | `Score/DeterministicScore.lean` |
| Lean toolchain | `leanprover/lean4:v4.25.2` |
| Mathlib | `v4.25.2` |
| Theorems | 51 |
| `sorry` count | 0 |
| Commit | `dccd22b` |
| `lake-manifest.json` SHA-256 | `9780d700...` |

Validation:

```bash
lake build
grep -R "\bsorry\b\|\badmit\b" --include='*.lean' .
```

## Rust artifact — canonical implementation

| Field | Value |
|-------|-------|
| Repository | `github.com/ohdearquant/khive` |
| Crate | `crates/khive-score` |
| Core file | `src/score.rs` |
| Commit | `904a9874` |

This is the canonical `DeterministicScore` implementation. The Lean proofs were originally written against this crate.

## Rust artifact — contributed integration

| Field | Value |
|-------|-------|
| Repository | `github.com/ohdearquant/RuVector` |
| Branch | `feat/deterministic-scoring` |
| File | `ruvector-core/src/deterministic_score.rs` |
| Rust toolchain | `rustc 1.94.1 (e408947bf 2026-03-25)` |
| DeterministicScore tests | 19 |
| Full suite tests | 238 |
| Commit | `63d3ff65` |

Port of `khive-score` into the ruvector vector database, adding boundary conversion (`search_deterministic`), deterministic fusion (`deterministic_rrf`), and bug fixes (NaN-safe sorting, K=60→15).

Validation:

```bash
cargo test -p ruvector-core
```

## Scope

The artifact validates deterministic score comparison and runtime invariant preservation in the Lean model. It does not validate deterministic record ranking, full IEEE floating-point conversion semantics, Rust overflow semantics, or retrieval performance.
