# Build Status for This Generated Package

This package was generated in a sandbox that does not contain a TeX distribution, Lean, Lake, or the official LIPIcs class file.

Therefore, the following were **not** independently executed here:

- `lake build`
- `cargo test`
- `latexmk -pdf main.tex`

The package is source-complete for the paper draft, metadata, claim registry, and build instructions. To produce the final PDF, place the official `lipics-v2021.cls` v2021.1.3 files in the paper directory or install them in your TeX tree, then run:

```bash
make paper
```

Before submission, run the validation commands in `artifact.md` against the actual Lean and Rust repositories.
