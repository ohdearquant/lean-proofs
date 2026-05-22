import Lake
open Lake DSL

package «lean-proofs» where
  version := v!"0.1.0"
  preferReleaseBuild := true

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.25.2"

@[default_target]
lean_lib «Score» where
  roots := #[`Score]
  globs := #[.submodules `Score]
