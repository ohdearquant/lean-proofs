# Limitations

These limitations are intentionally reflected in `main.tex`.

1. **Score comparison, not record ranking.** The Lean artifact proves total comparison for score values. Equal-score tie-breaking over records is implemented in Rust but not formalized in Lean.
2. **Abstract float conversion.** `FloatClass` models classification and rounded integer conversion. It is not a mechanized proof of IEEE-754 conversion or Rust `from_f64` behavior.
3. **Rust correspondence is engineering evidence.** The Rust implementation is tested and structurally mapped to the Lean model, but no Rust semantics or extraction proof is provided.
4. **Overflow safety is assumed at the implementation boundary.** Rust operations are intended to compute in a widened representation before clamping. This assumption is not mechanized.
5. **No retrieval-performance claim.** The paper does not report retrieval-performance leadership, benchmark improvements, or speedups.
6. **External RRF proof.** The K=15 RRF design note relies on a separate proof file and is not a theorem of `Score/DeterministicScore.lean`.
