# Paper Standards for `lean-proofs`

**Version:** 1.0.0  
**Last updated:** 2026-05-22  
**Primary scope:** Lean 4 mechanized proofs, verified/specification-adjacent Rust systems, and proof-engineering papers generated with AI-agent assistance.  
**Default paper class:** formal-methods / interactive-theorem-proving research paper.  
**Default target venue:** ITP when LIPIcs format is required; CPP when certified-programs framing is stronger, subject to the current CFP.

This standard is written for automated paper-generation pipelines. Its purpose is to make generated papers **principled, rigid, falsifiable, validatable, and reviewable**. A paper that cannot pass this standard must be treated as a draft, not as a submission candidate.

---

## 1. Normative Language

This document uses the following terms precisely:

- **MUST**: required. A paper or artifact failing this rule is non-compliant.
- **MUST NOT**: forbidden. A paper containing this pattern is non-compliant.
- **SHOULD**: expected unless a written exception is recorded in `paper.yaml`.
- **MAY**: optional.
- **Claim**: any statement in the paper that a reviewer could reasonably ask to verify.
- **Evidence**: a compiler result, theorem declaration, source file, benchmark log, dataset, citation, or reproducible script supporting a claim.
- **Falsifier**: a concrete condition that would make a claim false.

No AI-generated prose is evidence. Only checked artifacts, cited literature, and reproducible outputs count as evidence.

---

## 2. Core Principles

### P1. Every substantive claim MUST be traceable

Every theorem, implementation, benchmark, comparison, and contribution claim MUST map to one or more evidence records in `claims.yaml`.

A claim without a corresponding evidence record MUST be deleted or explicitly marked as conjectural background.

### P2. Every main claim MUST be falsifiable

Each main claim MUST include a falsifier. Examples:

| Claim type | Acceptable falsifier |
|---|---|
| Lean theorem claim | `lake build` fails; theorem name missing; theorem statement weaker than prose claim; proof uses forbidden axiom or `sorry`. |
| Rust correspondence claim | referenced Rust function missing; test suite fails; implementation behavior diverges from stated model on generated cases. |
| Benchmark claim | reproduction script fails; metric definition changes; reported number cannot be regenerated from logged data. |
| SOTA claim | comparison set omits relevant prior work; metric is not comparable; baseline configuration is invalid. |

### P3. The paper MUST distinguish proof, implementation, and interpretation

A paper MUST NOT imply that Rust code is formally verified merely because a Lean model is verified. The paper may say:

- **Mechanized theorem**: proved in Lean.
- **Executable implementation**: implemented in Rust.
- **Correspondence evidence**: tests, refinement proof, extraction proof, symbolic model, or external verifier.
- **Unverified correspondence**: engineering evidence only.

Use “verified Rust implementation” only when the implementation itself is verified by a suitable tool or by a mechanized correspondence proof.

### P4. The theorem statement controls the prose

The prose version of a theorem MUST NOT be stronger than the exact Lean theorem statement.

If the Lean theorem is conditional, the paper statement MUST expose the condition. If the Lean model uses an unbounded `Int` with a separate validity predicate, the paper MUST NOT describe all values as bounded unless every relevant theorem carries or proves the validity condition.

### P5. SOTA claims require comparative evidence

A paper MUST NOT claim “state of the art,” “first,” “best,” “complete,” or “fully verified” unless it includes:

1. a clearly defined comparison set;
2. a metric or formal criterion;
3. citations to prior work;
4. a falsifier;
5. a table showing how the claim was established.

If these are missing, use narrower language: “we mechanize,” “we prove,” “we implement,” or “we provide evidence for.”

### P6. AI assistance MUST be disclosed when substantive

AI agents may assist with drafting, structuring, theorem search, proof repair, and artifact packaging. Human authors remain responsible for the submitted content. Substantive AI use MUST be documented in `ai-use.md` and disclosed according to the target venue policy.

AI systems MUST NOT be listed as authors.

---

## 3. Venue Policy

Venue rules are time-sensitive. Agents MUST verify the active CFP before generating a submission package. Never rely on “typical” deadlines or historical page limits.

### 3.1 Venue Fit

| Venue | Best fit | Default treatment |
|---|---|---|
| **ITP** | Lean/Rocq/Isabelle formalizations, proof engineering, theorem-prover methodology, AI for proof discovery. | Preferred when the contribution is primarily a mechanized proof or proof-engineering artifact. |
| **CPP** | Certified programs, verified systems, proof-carrying or proof-driven software, formalized correctness arguments. | Preferred when the contribution is a verified system or a proof-backed implementation story. |
| **PLDI / POPL** | Programming-language design, semantics, verification frameworks, compiler/runtime systems. | Use only if the systems or PL contribution is strong enough without relying on venue mismatch. |
| **SIGIR** | Retrieval/ranking/evaluation systems. | Use only if the retrieval contribution is primary and formal verification is supporting evidence. |

### 3.2 Current venue snapshot, verified 2026-05-22

| Venue | Current known format facts | Standard action |
|---|---|---|
| **ITP 2026** | Regular papers: max 16 pages excluding references, no appendix, LIPIcs format. Short papers: max 6 pages excluding references, subtitle “Short paper,” no appendix, LIPIcs format. Uses `lipics-v2021` style v2021.1.3. | Treat as the default LIPIcs target. |
| **CPP 2026** | Uses ACM SIGPLAN `acmart` format with `sigplan,10pt,anonymous,review`; max 12 pages including figures/tables, excluding bibliography and clearly marked appendices. | Do **not** assume CPP is LIPIcs. Generate ACM format unless the active CFP says otherwise. |

### 3.3 Required venue metadata

Each paper directory MUST include `paper.yaml` with:

```yaml
venue:
  name: "ITP"
  year: 2026
  cfp_url: "https://itp-conference-2026.github.io/cfp.html"
  cfp_verified_on: "2026-05-22"
  format: "LIPIcs"
  style_file: "lipics-v2021"
  style_version: "v2021.1.3"
  page_limit:
    regular: 16
    excludes: ["bibliographic references"]
    appendix_allowed: false
  blind_review: "lightweight double blind"
```

The agent MUST regenerate this block from the active CFP before each submission cycle.

---

## 4. LIPIcs Compliance Standard

Use this section only for LIPIcs venues such as ITP 2026.

### 4.1 Required LaTeX setup

The paper MUST use:

```latex
\documentclass[a4paper,UKenglish,cleveref,autoref,thm-restate]{lipics-v2021}
```

The paper MUST be built with an up-to-date LaTeX system and `pdflatex`, unless the venue explicitly permits otherwise.

### 4.2 Required metadata

The LaTeX source MUST include:

```latex
\title{...}
\titlerunning{...}
\author{...}{...}{...}{...}{...}
\authorrunning{...}
\Copyright{...}
\ccsdesc{...}
\keywords{...}
\begin{abstract}
...
\end{abstract}
```

If there is an artifact, preprint, or full version, the paper SHOULD include persistent metadata such as `\supplementdetails` and/or `\relatedversion`, following the venue instructions.

### 4.3 Bibliography

For LIPIcs, use BibTeX and the standard `plainurl` bibliography style unless the active venue instructions override it.

Do not use `biblatex` for LIPIcs unless the venue explicitly allows it.

### 4.4 Forbidden formatting behavior

A generated paper MUST NOT:

- override LIPIcs margins, spacing, fonts, or colors;
- use custom sectioning commands instead of the provided sectioning macros;
- hide large text blocks with comments or conditional compilation;
- include unreferenced figures or tables;
- use layout hacks to meet page limits;
- change the bibliography style;
- include venue-noncompliant packages.

---

## 5. Repository and File Organization

Each paper MUST live in its own directory.

```text
papers/
├── STANDARDS.md
└── <paper-slug>/
    ├── paper.yaml                 # Venue, build, artifact, claim metadata
    ├── claims.yaml                # Machine-checkable claim ledger
    ├── proof-map.yaml             # Paper claim ↔ Lean theorem ↔ implementation map
    ├── ai-use.md                  # Substantive AI use disclosure and audit notes
    ├── main.tex                   # Paper source
    ├── references.bib             # Bibliography
    ├── Makefile                   # Deterministic paper build
    ├── README.md                  # Human-readable build and artifact instructions
    ├── artifact/
    │   ├── README.md              # Artifact evaluator instructions
    │   ├── manifest.yaml          # Exact files, commits, commands, expected outputs
    │   └── reproduce.sh           # One-command reproduction script
    ├── figures/
    ├── tables/
    ├── scripts/
    └── build/
```

The paper directory MUST be buildable without relying on unstated local configuration.

---

## 6. Required Machine-Readable Manifests

### 6.1 `paper.yaml`

```yaml
paper:
  slug: "deterministic-score"
  title: "..."
  status: "draft"        # draft | audit-ready | submission-ready | submitted
  human_owner: "..."
  created_on: "YYYY-MM-DD"
  last_audited_on: "YYYY-MM-DD"

repository:
  commit: "<git-sha>"
  branch: "<branch>"
  dirty_tree_allowed: false

lean:
  version: "<from lean-toolchain>"
  build_command: "lake build"
  required_files:
    - "lean-toolchain"
    - "lakefile.lean"
    - "lake-manifest.json"
  forbidden_terms:
    - "sorry"
    - "admit"
    - "axiom"
    - "unsafe"
  allowed_axioms: []

rust:
  toolchain: "<rustc version or rust-toolchain>"
  build_command: "cargo build --release"
  test_command: "cargo test --all"

paper_build:
  command: "make pdf"
  expected_output: "main.pdf"

artifact:
  archive_required: true
  anonymous_archive_required_for_review: true
  public_archive_required_for_camera_ready: true
  target_badges:
    - "Artifacts Evaluated - Reusable"
    - "Artifacts Available"
```

### 6.2 `claims.yaml`

Every claim MUST have this shape:

```yaml
claims:
  - id: "C1"
    paper_location:
      section: "3"
      paragraph: 2
      theorem_label: "thm:total-order"
    claim: "DeterministicScore comparison is total."
    claim_type: "formal_theorem"
    strength: "main"              # main | supporting | background
    evidence:
      lean:
        theorem: "Score.DeterministicScore.le_total"
        file: "Score/DeterministicScore.lean"
        exact_statement_required: true
      implementation:
        rust_path: "deterministic_score::DeterministicScore::cmp"
        correspondence_status: "engineering_evidence_only"
    assumptions:
      - "Ordering is defined by the raw integer field."
    falsifier:
      - "The Lean theorem is missing or has a weaker statement."
      - "The paper claims more than totality of Lean-level comparison."
    validation:
      command: "lake build"
      expected: "exit code 0"
```

A paper MUST NOT be marked `submission-ready` until every `main` claim has a complete record.

### 6.3 `proof-map.yaml`

```yaml
mappings:
  - paper_claim: "Theorem 1: Total Order"
    lean_theorem: "Score.DeterministicScore.le_total"
    lean_file: "Score/DeterministicScore.lean"
    rust_symbol: "impl Ord for DeterministicScore"
    correspondence_level: "tested"    # proved | tested | inspected | none
    notes: "Lean theorem proves totality of model order, not full ranking determinism under ties."
```

---

## 7. Claim Taxonomy

Every sentence containing a technical assertion SHOULD be classified into one of these types.

| Type | Examples | Required evidence |
|---|---|---|
| `formal_theorem` | totality, associativity, invariant preservation, refinement theorem | Lean theorem name, exact statement, build log, no-sorry scan. |
| `formal_definition` | model definition, invariant, semantics | Lean declaration name, exact source file, scope statement. |
| `implementation_claim` | Rust type, function, trait impl, API behavior | Rust symbol path, source file, tests, correspondence status. |
| `correspondence_claim` | Rust implementation refines Lean model | Mechanized refinement proof, extraction proof, verified translation, or clearly labeled engineering evidence. |
| `artifact_claim` | build succeeds, proof is complete, benchmark reproducible | Script, command, environment, expected output, log. |
| `empirical_claim` | speed, memory, benchmark, accuracy | Benchmark script, input data, seeds, hardware, repetitions, statistics. |
| `related_work_claim` | comparison to prior systems | Citation, quoted scope boundary, comparison criterion. |
| `interpretive_claim` | design rationale, reviewer takeaway | Supporting evidence plus explicit limitation. |

---

## 8. Required Paper Structure

Generated papers MUST follow this structure unless the venue imposes a different one.

### 8.1 Abstract

The abstract MUST contain:

1. problem;
2. artifact or method;
3. main mechanized result;
4. implementation or evaluation result, if any;
5. limitation boundary.

The abstract MUST NOT include unsupported SOTA language.

### 8.2 Introduction

The introduction MUST answer:

- What is the problem?
- Why is the problem nontrivial?
- What exactly is mechanized?
- What exactly is implemented?
- What are the paper’s main contributions?
- What is outside the proof boundary?

Required contribution format:

```text
Contributions.
(1) We define ... in Lean 4.
(2) We prove ... as theorem `Namespace.theorem_name`.
(3) We implement ... in Rust and provide ... correspondence evidence.
(4) We package the artifact with ... reproducibility guarantees.
```

### 8.3 Background and Motivation

This section MUST define only the minimum needed context. It SHOULD avoid tutorial material unless it directly supports the reviewer’s understanding of the contribution.

### 8.4 Formal Model

This section MUST include:

- core definitions;
- invariants;
- special cases;
- modeling assumptions;
- the gap between mathematical model and implementation representation.

Every model invariant MUST be classified as one of:

| Invariant kind | Meaning |
|---|---|
| Type invariant | Enforced by the Lean type. |
| Predicate invariant | Requires an explicit hypothesis such as `Valid s`. |
| Construction invariant | Preserved only by constructors or smart constructors. |
| Implementation invariant | Enforced by Rust type or runtime checks, not by Lean model. |

### 8.5 Main Theorems

For each main theorem, the paper MUST show:

1. theorem name;
2. exact Lean statement or a faithful mathematical rendering;
3. assumptions;
4. proof idea;
5. why the theorem supports the paper claim;
6. what the theorem does **not** imply.

At least the main theorem statements MUST appear in the body. Proof scripts MAY be summarized if the artifact includes full source.

### 8.6 Implementation Correspondence

This section MUST separate:

- Lean model declarations;
- Rust implementation paths;
- conversion functions;
- tests;
- refinement/correspondence evidence;
- known gaps.

If correspondence is not mechanized, the section title MUST NOT use “verified implementation.” Use “Implementation and Correspondence Evidence.”

### 8.7 Evaluation / Artifact

For formal proof papers, evaluation SHOULD include:

- proof inventory: files, declarations, theorem count;
- dependency inventory: Lean version, Mathlib version, Rust version;
- build reproducibility: clean build command and result;
- proof-maintenance cost: proof size, automation use, fragile tactics if measured;
- artifact evaluator path: commands expected to run.

For empirical papers, also include:

- hardware;
- operating system;
- random seeds;
- repetitions;
- confidence intervals or variance when appropriate;
- raw data location.

### 8.8 Limitations and Threats to Validity

This section is mandatory.

It MUST state:

- model limitations;
- implementation gaps;
- theorem assumptions;
- artifact limitations;
- comparison limitations;
- whether ranking ties, NaN sentinels, overflow behavior, or validity predicates are fully captured.

### 8.9 Related Work

Related work MUST be comparative, not merely descriptive.

Each related-work paragraph SHOULD answer:

- What does prior work prove or implement?
- What does this paper prove or implement differently?
- Is the difference theorem strength, artifact quality, proof assistant, system scope, automation, performance, or usability?

### 8.10 Conclusion

The conclusion MUST restate only claims already proven or evidenced. It MUST NOT introduce new claims.

---

## 9. Lean 4 Proof Presentation Standard

### 9.1 Naming

Lean theorem names used in the paper MUST be fully qualified on first use:

```text
`Score.DeterministicScore.le_total`
```

Subsequent uses MAY use a shortened name if unambiguous.

### 9.2 Code display

Inline Lean SHOULD use a macro such as:

```latex
\newcommand{\lean}[1]{\texttt{#1}}
```

Block Lean code SHOULD show full theorem statements for main results. Proof bodies MAY be elided only if the artifact contains complete proof source.

Acceptable:

```lean
theorem le_total (a b : DeterministicScore) : a ≤ b ∨ b ≤ a := ...
```

Not acceptable:

```text
We prove totality.
```

without theorem name, statement, or proof-map entry.

### 9.3 Proof completeness

A paper MUST NOT say “all proofs are complete” unless the audit includes:

```bash
lake build
./scripts/check_no_sorry.sh
./scripts/check_no_forbidden_axioms.sh
```

The no-sorry scan MUST check at least:

- `sorry`;
- `admit`;
- unexpected `axiom` declarations;
- unexpected `unsafe` declarations;
- theorem declarations outside the claimed namespace when relevant.

Allowed axioms MUST be listed explicitly in `paper.yaml` and justified in the paper.

### 9.4 Theorem inventory

Each paper MUST include a theorem inventory table in the body or artifact README.

| Category | Count | Example theorem | Notes |
|---|---:|---|---|
| Order properties | 4 | `Score.DeterministicScore.le_total` | Supports total comparison. |
| Special values | 3 | `Score.DeterministicScore.min_is_bot` | Conditional on `Valid`. |
| Arithmetic | 5 | `Score.DeterministicScore.add_saturating_bounded` | Boundedness only unless branch specs are proved. |

Counts MUST be generated from source or manually audited with exact theorem names.

---

## 10. Rust / Implementation Standard

Rust claims MUST use fully qualified symbol paths where possible.

```text
`deterministic_score::DeterministicScore::from_f64`
`impl Ord for deterministic_score::DeterministicScore`
```

For each implementation claim, record:

| Field | Required content |
|---|---|
| Rust symbol | Function, type, trait impl, module path. |
| Source file | Path and line range if available. |
| Lean model | Corresponding definition or theorem. |
| Test evidence | Unit tests, property tests, fuzz tests, or golden tests. |
| Correspondence level | `proved`, `tested`, `inspected`, or `none`. |
| Failure mode | Concrete divergence that would falsify the claim. |

A paper MUST NOT conflate “the Lean model is correct” with “the Rust implementation is correct.”

---

## 11. Artifact Standard

### 11.1 Required files

The repository root MUST include:

```text
lean-toolchain
lakefile.lean
lake-manifest.json
```

The artifact package MUST include:

```text
artifact/README.md
artifact/manifest.yaml
artifact/reproduce.sh
```

### 11.2 Artifact README

The artifact README MUST include:

1. artifact purpose;
2. expected reviewer time;
3. hardware/software assumptions;
4. exact commands;
5. expected output snippets;
6. troubleshooting notes;
7. theorem-to-paper correspondence table;
8. known limitations.

### 11.3 One-command reproduction

The artifact MUST support:

```bash
./artifact/reproduce.sh
```

The script SHOULD run:

```bash
lake build
cargo test --all
make -C papers/<paper-slug> pdf
./scripts/check_claim_map.py papers/<paper-slug>/claims.yaml
./scripts/check_no_sorry.sh
```

If some command is intentionally omitted, the artifact README MUST explain why.

### 11.4 Badge targets

For ACM-style artifact review, target:

1. **Artifacts Evaluated - Functional**: documented, consistent, complete, exercisable.
2. **Artifacts Evaluated - Reusable**: Functional plus careful documentation and reusable structure.
3. **Artifacts Available**: archived in a persistent public repository with DOI or stable identifier.
4. **Results Validated - Reproduced**: independent evaluator obtains main results using the provided artifact.

Aim for **Reusable + Available** for formal proof artifacts.

---

## 12. Automated Pipeline Gates

A paper cannot be marked `submission-ready` until every gate passes.

| Gate | Name | Required command or check | Pass condition |
|---|---|---|---|
| G0 | Repository clean | `git status --porcelain` | Empty unless `dirty_tree_allowed: true`. |
| G1 | Lean build | `lake build` | Exit code 0. |
| G2 | Forbidden proof terms | `scripts/check_no_sorry.sh` | No forbidden terms outside allowlist. |
| G3 | Axiom audit | `scripts/check_no_forbidden_axioms.sh` | Only allowlisted axioms. |
| G4 | Theorem extraction | `scripts/extract_lean_decls.py` | All claimed theorem names exist. |
| G5 | Claim map validation | `scripts/check_claim_map.py claims.yaml` | Every main claim has evidence and falsifier. |
| G6 | Rust build/tests | `cargo test --all` | Exit code 0, if Rust is in scope. |
| G7 | Artifact reproduction | `artifact/reproduce.sh` | Exit code 0. |
| G8 | Paper build | `make pdf` | PDF generated; no fatal LaTeX errors. |
| G9 | Citation audit | `scripts/check_references.py` | No fabricated, missing, or placeholder citations. |
| G10 | Venue audit | `scripts/check_venue.py paper.yaml` | CFP URL, page limit, format, and blind-review mode verified. |
| G11 | Blind-review audit | `scripts/check_anonymity.py` | No forbidden author-identifying content for anonymous submission. |
| G12 | Scope audit | `scripts/check_scope.py claims.yaml main.tex` | No unsupported SOTA or overclaiming language. |

A failed gate MUST produce a remediation item. The paper MUST NOT silently downgrade the gate.

---

## 13. Standard for SOTA Claims

A SOTA claim is permitted only if it passes the SOTA checklist.

### 13.1 Formal-methods SOTA checklist

A formal-methods SOTA claim MUST specify the axis:

| Axis | Valid evidence |
|---|---|
| Theorem strength | Exact comparison of theorem statements and assumptions. |
| Scope | More language features, more cases, more system components, or broader model. |
| Mechanization quality | Smaller trusted base, fewer axioms, no `sorry`, better automation, reusable library design. |
| Implementation connection | Stronger refinement/extraction/verification link to executable code. |
| Artifact quality | Reusable, available, evaluator-friendly artifact with deterministic build. |

A paper MUST NOT claim global SOTA when it only improves one axis. Use precise language:

```text
Compared with prior work, our contribution strengthens the artifact-reuse axis by ...
```

### 13.2 Empirical SOTA checklist

An empirical SOTA claim MUST include:

- exact metric;
- exact datasets;
- exact baselines;
- baseline version and configuration;
- hardware/software environment;
- variance or repeated runs when appropriate;
- raw logs;
- reproduction script;
- known failed or negative cases.

No benchmark-only SOTA claim is allowed without reproducible raw data.

---

## 14. Agent Writing Protocol

AI agents MUST follow this workflow.

### A0. Ingest evidence before writing

The agent MUST first read:

- Lean files;
- Rust files;
- existing tests;
- `lakefile.lean`, `lean-toolchain`, `lake-manifest.json`;
- current venue CFP;
- relevant prior work.

The agent MUST NOT draft contribution claims before evidence ingestion.

### A1. Generate the claim ledger first

Before writing `main.tex`, the agent MUST create `claims.yaml` and `proof-map.yaml`.

### A2. Draft theorem statements before prose

For each formal result, the agent MUST write the exact theorem name and statement before the explanatory paragraph.

### A3. Generate prose only from claims

Every technical paragraph SHOULD be grounded in claim IDs. Unsupported paragraphs MUST be rewritten or deleted.

### A4. Run red-team critique

The agent MUST perform a red-team pass asking:

- Is this claim stronger than the theorem?
- Is a predicate invariant being described as a type invariant?
- Is implementation correspondence overstated?
- Is a deterministic comparison claim being inflated into deterministic ranking?
- Is a NaN sentinel being described as mathematical NaN elimination?
- Is a SOTA claim missing a comparison set?

### A5. Run reviewer simulation

The agent SHOULD produce answers to:

1. What is new?
2. Why is it nontrivial?
3. What exactly is proved?
4. What exactly is not proved?
5. How does a reviewer validate the artifact?
6. What would falsify the paper’s main claim?

### A6. Emit final package

The agent may mark the paper `submission-ready` only after all pipeline gates pass and a human owner signs off in `paper.yaml`.

---

## 15. Citation and Bibliography Standard

### 15.1 Citation rules

A generated paper MUST NOT invent citations.

Every bibliography entry MUST be traceable to one of:

- official venue or publisher page;
- peer-reviewed proceedings paper;
- arXiv/preprint with clear status label;
- official software documentation;
- artifact DOI or archived repository.

### 15.2 Required fields

For papers:

```bibtex
author
title
booktitle or journal
year
doi or url
```

For software artifacts:

```bibtex
author or organization
title
version or commit
year
url or doi
accessed date
```

### 15.3 Citation placement

A paragraph comparing prior work MUST cite the prior work in that paragraph. Do not group all citations at the end of a section.

---

## 16. Standard Correspondence Table

Every paper MUST include a correspondence table in the body or artifact appendix, subject to venue rules.

| Paper claim | Claim ID | Lean theorem / definition | Rust implementation | Correspondence level | Falsifier |
|---|---|---|---|---|---|
| Total comparison | `C1` | `Score.DeterministicScore.le_total` | `impl Ord for DeterministicScore` | tested / inspected / proved | theorem missing, weaker, or implementation comparator diverges. |
| Valid-score bounds | `C2` | `Score.DeterministicScore.min_is_bot`, `max_is_top` | constructors or smart constructors | conditional | paper omits `Valid` hypothesis. |
| Saturating addition boundedness | `C3` | `Score.DeterministicScore.add_saturating_bounded` | `add_saturating` | tested / inspected / proved | theorem only proves boundedness but paper claims exact branch behavior. |

The table MUST expose gaps. It is better to show a gap clearly than to let reviewers discover it.

---

## 17. Scope Guards for `DeterministicScore`-Style Papers

For papers based on fixed-point deterministic scores, agents MUST enforce these scope guards.

### 17.1 Validity predicate guard

If the Lean type uses `raw : Int` and a separate `Valid` predicate for i64 bounds, then:

- claims about boundedness MUST either assume `Valid s` or prove validity preservation;
- constants such as `MIN`, `MAX`, `ZERO`, and `NEG_INF` SHOULD have explicit validity lemmas;
- arithmetic functions returning unbounded `Int` wrappers MUST NOT be described as i64-safe unless a theorem proves it.

### 17.2 NaN guard

If `MIN` is used as a NaN sentinel, the paper MUST say “NaN sentinel” or “deterministic NaN policy,” not “mathematical NaN is represented.”

A theorem proving total comparability supports:

```text
Every pair of model scores is comparable under the defined order.
```

It does not automatically support:

```text
The full ranking pipeline is deterministic.
```

unless ties, conversion, and implementation ordering are also covered.

### 17.3 Ranking guard

Score totality is not ranking determinism if multiple items can have equal scores. Ranking determinism also requires a deterministic tie-breaker, such as item ID or stable input order, and this tie-breaker must be specified and tested or proved.

### 17.4 Saturating arithmetic guard

A boundedness theorem for saturating addition supports only boundedness. It does not prove exact branch behavior unless separate branch-specification theorems exist.

---

## 18. Review-Readiness Checklist

A paper is review-ready only if every item is checked.

### Formal claims

- [ ] Every theorem claim has a fully qualified Lean theorem name.
- [ ] Every main theorem appears in `claims.yaml`.
- [ ] Every theorem statement in prose is no stronger than the Lean theorem.
- [ ] Every conditional theorem exposes its assumptions.
- [ ] No paper claim depends on an unstated invariant.
- [ ] No `sorry`, `admit`, or forbidden axiom is present.

### Implementation claims

- [ ] Every Rust claim has a symbol path.
- [ ] Every Rust/Lean correspondence claim has a declared correspondence level.
- [ ] Unmechanized correspondence is labeled as engineering evidence.
- [ ] Tests or proof obligations are listed.

### Artifact

- [ ] `lake build` succeeds from a clean checkout.
- [ ] Rust tests pass, if Rust is in scope.
- [ ] `artifact/reproduce.sh` succeeds.
- [ ] The artifact README has exact commands and expected outputs.
- [ ] The archive can be evaluated anonymously when required.
- [ ] The public artifact is archived with DOI or persistent identifier for camera-ready.

### Paper

- [ ] Venue format is current and verified.
- [ ] Page limit is current and verified.
- [ ] Abstract contains no unsupported claims.
- [ ] Limitations section is present.
- [ ] Related work is comparative.
- [ ] Figures and tables are referenced.
- [ ] Bibliography has no placeholders.
- [ ] AI use disclosure is prepared when required.

---

## 19. Non-Compliant Patterns

The following patterns MUST be rejected by the pipeline or by human review.

| Pattern | Why rejected | Required fix |
|---|---|---|
| “We prove deterministic ranking” from only a total-order theorem. | Ranking also needs tie handling and pipeline determinism. | Say “deterministic score comparison” or prove ranking theorem. |
| “All scores are i64-bounded” when the Lean type wraps `Int`. | Type does not enforce bound. | Add `Valid` assumption or prove validity preservation. |
| “No NaN exists” when NaN maps to a sentinel. | Sentinel policy is not absence of conversion behavior. | Say “NaN-like inputs map to deterministic sentinel.” |
| “Verified Rust implementation” without refinement proof. | Lean model proof does not verify Rust. | Say “Rust implementation with correspondence tests.” |
| “SOTA” without baselines or prior-work table. | Not falsifiable. | Add comparison set or remove SOTA language. |
| Theorem inventory manually counted without source audit. | Counts can drift. | Generate or audit theorem list. |
| Citation generated by AI without source lookup. | High risk of fabrication. | Verify every BibTeX entry. |

---

## 20. Minimal `Makefile` Contract

Each paper directory SHOULD include:

```makefile
PDF=main.pdf

all: pdf

pdf:
	latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex

clean:
	latexmk -C
	rm -f *.bbl *.run.xml

audit:
	../../scripts/check_claim_map.py claims.yaml
	../../scripts/check_references.py references.bib
	../../scripts/check_venue.py paper.yaml
	$(MAKE) pdf
```

Repository root SHOULD include:

```makefile
paper-audit:
	lake build
	./scripts/check_no_sorry.sh
	./scripts/check_no_forbidden_axioms.sh
	./scripts/extract_lean_decls.py
	$(MAKE) -C papers/<paper-slug> audit
	./papers/<paper-slug>/artifact/reproduce.sh
```

---

## 21. Required Source Notes

Agents MUST keep a source-note block in `paper.yaml` or `README.md` recording the official sources used for venue and artifact policies.

Example:

```yaml
source_notes:
  - name: "ITP 2026 CFP"
    url: "https://itp-conference-2026.github.io/cfp.html"
    verified_on: "2026-05-22"
    used_for: ["page_limit", "format", "submission_deadline", "supplementary_material"]
  - name: "LIPIcs author instructions"
    url: "https://submission.dagstuhl.de/series/details/lipics"
    verified_on: "2026-05-22"
    used_for: ["style_version", "metadata", "bibliography", "formatting_rules"]
  - name: "CPP 2026 CFP"
    url: "https://popl26.sigplan.org/home/CPP-2026"
    verified_on: "2026-05-22"
    used_for: ["format", "page_limit", "double_blind", "supplementary_material"]
  - name: "ACM Artifact Review and Badging v1.1"
    url: "https://www.acm.org/publications/policies/artifact-review-and-badging-current"
    verified_on: "2026-05-22"
    used_for: ["artifact_badges", "reproducibility_terms"]
  - name: "Dagstuhl GenAI Statement"
    url: "https://drops.dagstuhl.de/docs/gen-ai"
    verified_on: "2026-05-22"
    used_for: ["AI_use_disclosure", "authorship_policy"]
```

---

## 22. Submission Readiness Definition

A paper is `submission-ready` only when:

1. all main claims are in `claims.yaml`;
2. all main claims have evidence and falsifiers;
3. all theorem names exist and build;
4. no forbidden proof placeholders exist;
5. all implementation claims are scoped correctly;
6. all SOTA/comparison claims have prior-work evidence;
7. the artifact reproduces;
8. the venue format is verified against the current CFP;
9. the paper compiles;
10. a human owner has reviewed and accepted responsibility.

If any item is missing, the paper status MUST remain `draft` or `audit-ready`, never `submission-ready`.

---

## 23. Default Paper Skeleton

```latex
\section{Introduction}
\paragraph*{Contributions.}

\section{Background and Problem Statement}

\section{Formal Model}

\section{Main Theorems}

\section{Implementation and Correspondence Evidence}

\section{Artifact and Evaluation}

\section{Limitations and Threats to Validity}

\section{Related Work}

\section{Conclusion}
```

For ITP 2026, do not rely on an appendix in the submission version. Any extra proof detail must be in the artifact or supplementary material, unless the active CFP changes.

---

## 24. Final Rule

A generated paper is not legitimate because it is well-written. It is legitimate only when every important sentence has a verifiable reason to be true.
