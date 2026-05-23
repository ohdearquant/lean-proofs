/-
Score/DeterministicScore.lean
=============================

DeterministicScore total order — fixed-point integer scoring.
Fixed-point integer representation supports deterministic score comparison.
Record-level ranking requires an explicit deterministic tie-breaker (outside this file).

THEOREMS: 51
STATUS: PROOFS COMPLETE
-/

import Mathlib.Data.Int.Basic
import Mathlib.Order.Basic
import Mathlib.Tactic

namespace Score

/-! =========== DETERMINISTIC SCORE TYPE =========== -/

/-- The i64 bounds for valid DeterministicScores -/
def I64_MIN : Int := -9223372036854775808
def I64_MAX : Int := 9223372036854775807

/-- DeterministicScore using fixed-point integer representation.
    Internal: i64 scaled by 2^32 (~9 decimal places precision)

    INVARIANT: The value is an integer, so there is no IEEE-754 NaN inhabitant.
    INVARIANT: Same input → same output (deterministic)

    NOTE: In Rust this is bounded by i64, but in Lean Int is unbounded.
    Use `Valid` for raw i64 bounds and `RuntimeValid` for values produced
    by the arithmetic/conversion API. -/
structure DeterministicScore where
  raw : Int
deriving DecidableEq, Repr

/-- Validity predicate: the score is within i64 bounds.
    This corresponds to the Rust invariant that the raw value fits in i64. -/
def Valid (s : DeterministicScore) : Prop :=
  I64_MIN ≤ s.raw ∧ s.raw ≤ I64_MAX

namespace DeterministicScore

/-! =========== CONSTANTS =========== -/

/-- Scaling factor: 2^32 for ~9 decimal places precision -/
def SCALE : Int := 4294967296  -- 2^32

/-- Zero score -/
def ZERO : DeterministicScore := ⟨0⟩

/-- Reserved raw sentinel at i64::MIN.
    Runtime arithmetic and float conversion avoid this value (see `RuntimeValid`). -/
def MIN : DeterministicScore := ⟨I64_MIN⟩

/-- Maximum score (represents +Infinity) -/
def MAX : DeterministicScore := ⟨I64_MAX⟩

/-- Near-minimum score (represents -Infinity) -/
def NEG_INF : DeterministicScore := ⟨I64_MIN + 1⟩

/-! =========== ORDERING =========== -/

/-- Ordering on DeterministicScore via underlying Int -/
instance : LE DeterministicScore where
  le a b := a.raw ≤ b.raw

instance : LT DeterministicScore where
  lt a b := a.raw < b.raw

/-! =========== RUNTIME REACHABILITY =========== -/

/-- Runtime-reachable scores exclude the reserved MIN sentinel and lie in [NEG_INF, MAX].
    Stronger than `Valid`, which only states raw i64 boundedness. -/
def RuntimeValid (s : DeterministicScore) : Prop :=
  NEG_INF.raw ≤ s.raw ∧ s.raw ≤ MAX.raw

/-- Runtime-valid scores are raw-i64 valid. -/
theorem runtime_valid_valid {s : DeterministicScore}
    (hr : RuntimeValid s) : Valid s := by
  constructor
  · calc I64_MIN ≤ NEG_INF.raw := by norm_num [NEG_INF, I64_MIN]
      _ ≤ s.raw := hr.1
  · calc s.raw ≤ MAX.raw := hr.2
      _ ≤ I64_MAX := by norm_num [MAX, I64_MAX]

/-- Runtime-valid scores are not the reserved MIN sentinel. -/
theorem runtime_valid_ne_min {s : DeterministicScore}
    (hr : RuntimeValid s) : s ≠ MIN := by
  intro h
  have hraw := congr_arg DeterministicScore.raw h
  simp only [MIN, I64_MIN] at hraw
  simp only [RuntimeValid, NEG_INF, I64_MIN] at hr
  omega

/-! =========== ORDER CHARACTERIZATION =========== -/

/-- Ordering is exactly raw integer ordering -/
theorem le_iff_raw (a b : DeterministicScore) :
    a ≤ b ↔ a.raw ≤ b.raw := Iff.rfl

/-- Strict ordering is exactly raw integer strict ordering -/
theorem lt_iff_raw (a b : DeterministicScore) :
    a < b ↔ a.raw < b.raw := Iff.rfl

/-! =========== TOTAL ORDER THEOREMS =========== -/

/-- Reflexivity: s ≤ s
    Proof: Delegate to Int.le_refl since ordering is defined on raw : Int -/
theorem le_refl (s : DeterministicScore) : s ≤ s :=
  Int.le_refl s.raw

/-- Antisymmetry: a ≤ b ∧ b ≤ a → a = b
    Proof: Destruct structures, apply Int.le_antisymm on raw fields -/
theorem le_antisymm {a b : DeterministicScore} (hab : a ≤ b) (hba : b ≤ a) :
    a = b := by
  cases a; cases b
  simp only [LE.le] at hab hba
  congr
  exact Int.le_antisymm hab hba

/-- Transitivity: a ≤ b ∧ b ≤ c → a ≤ c
    Proof: Direct delegation to Int.le_trans -/
theorem le_trans {a b c : DeterministicScore} (hab : a ≤ b) (hbc : b ≤ c) :
    a ≤ c :=
  Int.le_trans hab hbc

/-- Totality: a ≤ b ∨ b ≤ a
    Proof: Direct delegation to Int.le_total -/
theorem le_total (a b : DeterministicScore) : a ≤ b ∨ b ≤ a :=
  Int.le_total a.raw b.raw

/-- Trichotomy: exactly one of <, =, > holds
    Proof: Case split on Int.lt_trichotomy, use Int.lt_irrefl/asymm for exclusivity -/
theorem trichotomy (a b : DeterministicScore) :
    (a < b ∧ a ≠ b ∧ ¬(b < a)) ∨
    (a = b ∧ ¬(a < b) ∧ ¬(b < a)) ∨
    (b < a ∧ a ≠ b ∧ ¬(a < b)) := by
  rcases Int.lt_trichotomy a.raw b.raw with h | h | h
  · -- Case: a.raw < b.raw
    left
    refine ⟨h, ?_, Int.lt_asymm h⟩
    intro heq
    rw [heq] at h
    exact Int.lt_irrefl _ h
  · -- Case: a.raw = b.raw
    right; left
    refine ⟨?_, ?_, ?_⟩
    · cases a; cases b; simp at h ⊢; exact h
    · simp only [LT.lt, h]; exact Int.lt_irrefl _
    · simp only [LT.lt, h]; exact Int.lt_irrefl _
  · -- Case: b.raw < a.raw
    right; right
    refine ⟨h, ?_, Int.lt_asymm h⟩
    intro heq
    rw [← heq] at h
    exact Int.lt_irrefl _ h

/-! =========== VALIDITY OF CONSTANTS =========== -/

theorem valid_MIN : Valid MIN := by
  norm_num [Valid, MIN, I64_MIN, I64_MAX]

theorem valid_MAX : Valid MAX := by
  norm_num [Valid, MAX, I64_MIN, I64_MAX]

theorem valid_ZERO : Valid ZERO := by
  norm_num [Valid, ZERO, I64_MIN, I64_MAX]

theorem valid_NEG_INF : Valid NEG_INF := by
  norm_num [Valid, NEG_INF, I64_MIN, I64_MAX]

/-! =========== SPECIAL VALUE THEOREMS =========== -/

/-- MIN is the minimum element FOR VALID SCORES.
    NOTE: This is conditional on Valid because Lean Int is unbounded. -/
theorem min_is_bot (s : DeterministicScore) (hv : Valid s) : MIN ≤ s := by
  simp only [LE.le, MIN, Valid, I64_MIN] at *
  exact hv.1

/-- MAX is the maximum element FOR VALID SCORES.
    NOTE: This is conditional on Valid because Lean Int is unbounded. -/
theorem max_is_top (s : DeterministicScore) (hv : Valid s) : s ≤ MAX := by
  simp only [LE.le, MAX, Valid, I64_MAX] at *
  exact hv.2

/-- Special value ordering: MIN < NEG_INF < ZERO < MAX
    Proof: Numeric computation via norm_num on the concrete i64 constants -/
theorem special_value_ordering :
    MIN < NEG_INF ∧ NEG_INF < ZERO ∧ ZERO < MAX := by
  refine ⟨?_, ?_, ?_⟩
  · show MIN.raw < NEG_INF.raw; norm_num [MIN, NEG_INF, I64_MIN]
  · show NEG_INF.raw < ZERO.raw; norm_num [NEG_INF, ZERO, I64_MIN]
  · show ZERO.raw < MAX.raw; norm_num [ZERO, MAX, I64_MAX]

/-! =========== COMPARABILITY =========== -/

/-- Every pair of scores is comparable — no unordered pairs (unlike IEEE 754 NaN).
    This is the key advantage over Float: total comparability is guaranteed. -/
theorem no_unordered_pair (a b : DeterministicScore) :
    a ≤ b ∨ b ≤ a :=
  le_total a b

/-- Self comparison: s ≤ s ∧ ¬(s < s)
    Proof: Combine le_refl with Int.lt_irrefl -/
theorem self_le_and_not_self_lt (s : DeterministicScore) : s ≤ s ∧ ¬(s < s) :=
  ⟨le_refl s, Int.lt_irrefl s.raw⟩

/-! =========== ARITHMETIC OPERATIONS =========== -/

/-- Addition of scores -/
def add (a b : DeterministicScore) : DeterministicScore := ⟨a.raw + b.raw⟩

/-- Subtraction of scores -/
def sub (a b : DeterministicScore) : DeterministicScore := ⟨a.raw - b.raw⟩

/-- Saturating addition (clamps to [NEG_INF, MAX]).
    Matches Rust `from_arithmetic_raw`: MIN (i64::MIN) is reserved as
    an unreachable NaN sentinel — arithmetic never produces it. -/
def add_saturating (a b : DeterministicScore) : DeterministicScore :=
  let sum := a.raw + b.raw
  if sum > MAX.raw then MAX
  else if sum < NEG_INF.raw then NEG_INF
  else ⟨sum⟩

/-! =========== ARITHMETIC THEOREMS =========== -/

/-- Addition is commutative
    Proof: Unfold add, apply Int.add_comm on raw fields -/
theorem add_comm (a b : DeterministicScore) : add a b = add b a := by
  simp only [add]
  congr 1
  exact Int.add_comm a.raw b.raw

/-- Addition is associative
    Proof: Unfold add, apply Int.add_assoc on raw fields -/
theorem add_assoc (a b c : DeterministicScore) :
    add (add a b) c = add a (add b c) := by
  simp only [add]
  congr 1
  exact Int.add_assoc a.raw b.raw c.raw

/-- Zero is identity for addition
    Proof: Unfold add/ZERO, apply Int.add_zero -/
theorem add_zero (a : DeterministicScore) : add a ZERO = a := by
  simp only [add, ZERO]
  congr 1
  exact Int.add_zero a.raw

/-- Subtraction inverse
    Proof: Unfold sub/ZERO, apply Int.sub_self -/
theorem sub_self (a : DeterministicScore) : sub a a = ZERO := by
  simp only [sub, ZERO]
  congr 1
  exact Int.sub_self a.raw

/-- Saturating addition result is in [NEG_INF, MAX].
    MIN (i64::MIN) is unreachable — matches Rust from_arithmetic_raw. -/
theorem add_saturating_bounded (a b : DeterministicScore) :
    NEG_INF ≤ add_saturating a b ∧ add_saturating a b ≤ MAX := by
  unfold add_saturating
  simp only [LE.le]
  split_ifs with h1 h2
  · constructor
    · show NEG_INF.raw ≤ MAX.raw; norm_num [NEG_INF, MAX, I64_MIN, I64_MAX]
    · exact Int.le_refl _
  · constructor
    · exact Int.le_refl _
    · show NEG_INF.raw ≤ MAX.raw; norm_num [NEG_INF, MAX, I64_MIN, I64_MAX]
  · constructor
    · exact Int.not_lt.mp h2
    · exact le_of_not_gt h1

/-- Saturating addition preserves runtime reachability -/
theorem add_saturating_runtime_valid (a b : DeterministicScore) :
    RuntimeValid (add_saturating a b) :=
  add_saturating_bounded a b

/-- Saturating addition preserves validity (NEG_INF is within i64 bounds) -/
theorem add_saturating_valid (a b : DeterministicScore) :
    Valid (add_saturating a b) :=
  runtime_valid_valid (add_saturating_runtime_valid a b)

/-- Saturating addition never produces the reserved MIN sentinel -/
theorem add_saturating_ne_min (a b : DeterministicScore) :
    add_saturating a b ≠ MIN :=
  runtime_valid_ne_min (add_saturating_runtime_valid a b)

/-! =========== SATURATING BRANCH SPECS =========== -/

/-- Overflow clamps to MAX -/
theorem add_saturating_eq_max_of_overflow
    (a b : DeterministicScore)
    (h : MAX.raw < a.raw + b.raw) :
    add_saturating a b = MAX := by
  unfold add_saturating
  simp [show a.raw + b.raw > MAX.raw from h]

/-- Underflow clamps to NEG_INF (not MIN — MIN is the unreachable NaN sentinel) -/
theorem add_saturating_eq_neg_inf_of_underflow
    (a b : DeterministicScore)
    (hmax : ¬(MAX.raw < a.raw + b.raw))
    (hmin : a.raw + b.raw < NEG_INF.raw) :
    add_saturating a b = NEG_INF := by
  unfold add_saturating
  simp [show ¬(a.raw + b.raw > MAX.raw) from hmax, hmin]

/-- In-range sum returns exact result -/
theorem add_saturating_eq_sum_of_in_bounds
    (a b : DeterministicScore)
    (hmin : NEG_INF.raw ≤ a.raw + b.raw)
    (hmax : a.raw + b.raw ≤ MAX.raw) :
    add_saturating a b = ⟨a.raw + b.raw⟩ := by
  unfold add_saturating
  simp [show ¬(a.raw + b.raw > MAX.raw) from not_lt.mpr hmax,
        show ¬(a.raw + b.raw < NEG_INF.raw) from not_lt.mpr hmin]

/-- Saturating addition is commutative -/
theorem add_saturating_comm (a b : DeterministicScore) :
    add_saturating a b = add_saturating b a := by
  unfold add_saturating
  rw [Int.add_comm a.raw b.raw]

/-! =========== CONDITIONAL VALIDITY FOR RAW ARITHMETIC =========== -/

/-- Raw addition preserves validity when sum is in bounds -/
theorem add_valid_of_raw_bounds
    (a b : DeterministicScore)
    (hmin : I64_MIN ≤ a.raw + b.raw)
    (hmax : a.raw + b.raw ≤ I64_MAX) :
    Valid (add a b) :=
  ⟨hmin, hmax⟩

/-- Raw subtraction preserves validity when difference is in bounds -/
theorem sub_valid_of_raw_bounds
    (a b : DeterministicScore)
    (hmin : I64_MIN ≤ a.raw - b.raw)
    (hmax : a.raw - b.raw ≤ I64_MAX) :
    Valid (sub a b) :=
  ⟨hmin, hmax⟩

/-! =========== SCALE =========== -/

theorem scale_pos : 0 < SCALE := by
  norm_num [SCALE]

theorem scale_ne_zero : SCALE ≠ 0 := by
  norm_num [SCALE]

/-! =========== FLOAT CONVERSION MODEL =========== -/

/-- Classification of a floating-point value for the abstract conversion model.
    `finite n` represents the integer value after `(val * SCALE).round()`.
    This abstracts away IEEE-754 and Rust conversion details. -/
inductive FloatClass where
  | nan : FloatClass
  | posInf : FloatClass
  | negInf : FloatClass
  | finite : Int → FloatClass

/-- Conversion from abstract float classification to DeterministicScore.
    - NaN → ZERO under deterministic NaN policy
    - +Inf → MAX
    - -Inf → NEG_INF
    - Finite: clamp to [NEG_INF, MAX], preserving MIN as unreachable
    NOTE: This is a mathematical model. Rust correspondence requires
    separate validation of actual f64 conversion behavior. -/
def from_float : FloatClass → DeterministicScore
  | .nan => ZERO
  | .posInf => MAX
  | .negInf => NEG_INF
  | .finite n =>
    if I64_MAX ≤ n then MAX
    else if n ≤ I64_MIN then NEG_INF
    else ⟨n⟩

theorem from_float_nan : from_float .nan = ZERO := rfl
theorem from_float_pos_inf : from_float .posInf = MAX := rfl
theorem from_float_neg_inf : from_float .negInf = NEG_INF := rfl

/-- from_float always produces a Valid score -/
theorem from_float_valid (fc : FloatClass) : Valid (from_float fc) := by
  cases fc with
  | nan => exact valid_ZERO
  | posInf => exact valid_MAX
  | negInf => exact valid_NEG_INF
  | finite n =>
    simp only [from_float]
    split_ifs with h1 h2
    · exact valid_MAX
    · exact valid_NEG_INF
    · constructor
      · show I64_MIN ≤ n; simp [I64_MIN] at h2 ⊢; omega
      · show n ≤ I64_MAX; simp [I64_MAX] at h1 ⊢; omega

/-- MIN (i64::MIN) is unreachable by from_float.
    NaN maps to ZERO, underflow maps to NEG_INF (i64::MIN + 1). -/
theorem from_float_ne_min (fc : FloatClass) : from_float fc ≠ MIN := by
  cases fc with
  | nan =>
    show ZERO ≠ MIN
    intro h; exact absurd (congr_arg DeterministicScore.raw h) (by norm_num [ZERO, MIN, I64_MIN])
  | posInf =>
    show MAX ≠ MIN
    intro h; exact absurd (congr_arg DeterministicScore.raw h) (by norm_num [MAX, MIN, I64_MIN, I64_MAX])
  | negInf =>
    show NEG_INF ≠ MIN
    intro h; exact absurd (congr_arg DeterministicScore.raw h) (by norm_num [NEG_INF, MIN, I64_MIN])
  | finite n =>
    simp only [from_float]
    split_ifs with h1 h2
    · intro h; exact absurd (congr_arg DeterministicScore.raw h) (by norm_num [MAX, MIN, I64_MIN, I64_MAX])
    · intro h; exact absurd (congr_arg DeterministicScore.raw h) (by norm_num [NEG_INF, MIN, I64_MIN])
    · intro h
      have hraw := congr_arg DeterministicScore.raw h
      simp only [MIN, I64_MIN] at hraw h2
      omega

/-- from_float always produces a runtime-reachable score -/
theorem from_float_runtime_valid (fc : FloatClass) : RuntimeValid (from_float fc) := by
  cases fc with
  | nan =>
    constructor
    · show NEG_INF.raw ≤ ZERO.raw; norm_num [NEG_INF, ZERO, I64_MIN]
    · show ZERO.raw ≤ MAX.raw; norm_num [ZERO, MAX, I64_MAX]
  | posInf =>
    constructor
    · show NEG_INF.raw ≤ MAX.raw; norm_num [NEG_INF, MAX, I64_MIN, I64_MAX]
    · exact Int.le_refl _
  | negInf =>
    constructor
    · exact Int.le_refl _
    · show NEG_INF.raw ≤ MAX.raw; norm_num [NEG_INF, MAX, I64_MIN, I64_MAX]
  | finite n =>
    simp only [from_float]
    split_ifs with h1 h2
    · constructor
      · show NEG_INF.raw ≤ MAX.raw; norm_num [NEG_INF, MAX, I64_MIN, I64_MAX]
      · exact Int.le_refl _
    · constructor
      · exact Int.le_refl _
      · show NEG_INF.raw ≤ MAX.raw; norm_num [NEG_INF, MAX, I64_MIN, I64_MAX]
    · constructor
      · show NEG_INF.raw ≤ n; simp only [NEG_INF, I64_MIN] at h2 ⊢; omega
      · show n ≤ MAX.raw; simp only [MAX, I64_MAX] at h1 ⊢; omega

/-- from_float preserves ordering for finite already-rounded integer inputs
    that are strictly inside the saturation bounds. -/
theorem from_float_mono {m n : Int}
    (hmn : m ≤ n)
    (hm_lo : ¬(m ≤ I64_MIN)) (hm_hi : ¬(I64_MAX ≤ m))
    (hn_lo : ¬(n ≤ I64_MIN)) (hn_hi : ¬(I64_MAX ≤ n)) :
    from_float (.finite m) ≤ from_float (.finite n) := by
  show (from_float (.finite m)).raw ≤ (from_float (.finite n)).raw
  simp only [from_float, ite_false, hm_hi, hm_lo, hn_hi, hn_lo]
  exact hmn

/-! =========== SCALAR MULTIPLICATION =========== -/

/-- Mathematical multiplication by integer scalar with saturation to [NEG_INF, MAX].
    Rust correspondence requires that the product is computed in a widened
    representation (e.g. i128) before clamping. -/
def mul_i64 (s : DeterministicScore) (n : Int) : DeterministicScore :=
  if s.raw * n > MAX.raw then MAX
  else if s.raw * n < NEG_INF.raw then NEG_INF
  else ⟨s.raw * n⟩

/-- mul_i64 always produces a Valid score -/
theorem mul_i64_valid (s : DeterministicScore) (n : Int) :
    Valid (mul_i64 s n) := by
  simp only [mul_i64]
  split_ifs with h1 h2
  · exact valid_MAX
  · exact valid_NEG_INF
  · constructor
    · show I64_MIN ≤ s.raw * n
      have := le_of_not_gt h2
      simp only [NEG_INF, I64_MIN] at this ⊢; omega
    · show s.raw * n ≤ I64_MAX
      simp only [MAX, I64_MAX] at h1 ⊢; omega

/-- mul_i64 result is in [NEG_INF, MAX] -/
theorem mul_i64_bounded (s : DeterministicScore) (n : Int) :
    NEG_INF ≤ mul_i64 s n ∧ mul_i64 s n ≤ MAX := by
  simp only [mul_i64, LE.le]
  split_ifs with h1 h2
  · constructor
    · show NEG_INF.raw ≤ MAX.raw; norm_num [NEG_INF, MAX, I64_MIN, I64_MAX]
    · exact Int.le_refl _
  · constructor
    · exact Int.le_refl _
    · show NEG_INF.raw ≤ MAX.raw; norm_num [NEG_INF, MAX, I64_MIN, I64_MAX]
  · exact ⟨le_of_not_gt h2, le_of_not_gt h1⟩

/-- mul_i64 preserves runtime reachability -/
theorem mul_i64_runtime_valid (s : DeterministicScore) (n : Int) :
    RuntimeValid (mul_i64 s n) :=
  mul_i64_bounded s n

/-- Scalar multiplication never produces the reserved MIN sentinel -/
theorem mul_i64_ne_min (s : DeterministicScore) (n : Int) :
    mul_i64 s n ≠ MIN :=
  runtime_valid_ne_min (mul_i64_runtime_valid s n)

/-! =========== SCALAR DIVISION =========== -/

/-- Mathematical integer division by scalar.
    Zero-division policy: 0/0 → ZERO, pos/0 → MAX, neg/0 → NEG_INF.
    Non-zero: saturating division to [NEG_INF, MAX].
    Lean Int.div truncates toward zero (matches Rust). -/
def div_i64 (s : DeterministicScore) (n : Int) : DeterministicScore :=
  if n = 0 then
    if s.raw = 0 then ZERO
    else if s.raw > 0 then MAX
    else NEG_INF
  else
    if s.raw / n > MAX.raw then MAX
    else if s.raw / n < NEG_INF.raw then NEG_INF
    else ⟨s.raw / n⟩

/-- div_i64 always produces a Valid score -/
theorem div_i64_valid (s : DeterministicScore) (n : Int) :
    Valid (div_i64 s n) := by
  simp only [div_i64]
  split_ifs <;> first
  | exact valid_ZERO
  | exact valid_MAX
  | exact valid_NEG_INF
  | (constructor <;> simp_all only [NEG_INF, MAX, I64_MIN, I64_MAX] <;> omega)

/-- div_i64 preserves runtime reachability -/
theorem div_i64_runtime_valid (s : DeterministicScore) (n : Int) :
    RuntimeValid (div_i64 s n) := by
  simp only [div_i64, RuntimeValid]
  split_ifs <;> first
  | (simp only [ZERO, NEG_INF, MAX, I64_MIN, I64_MAX]; omega)
  | exact ⟨by norm_num [NEG_INF, MAX, I64_MIN, I64_MAX], Int.le_refl _⟩
  | exact ⟨Int.le_refl _, by norm_num [NEG_INF, MAX, I64_MIN, I64_MAX]⟩
  | exact ⟨Int.not_lt.mp ‹_›, le_of_not_gt ‹_›⟩

/-- Division never produces the reserved MIN sentinel -/
theorem div_i64_ne_min (s : DeterministicScore) (n : Int) :
    div_i64 s n ≠ MIN :=
  runtime_valid_ne_min (div_i64_runtime_valid s n)

/-- Division by zero follows deterministic sign-based policy -/
theorem div_zero_of_zero : div_i64 ZERO 0 = ZERO := by
  simp [div_i64, ZERO]

theorem div_zero_of_pos (s : DeterministicScore) (h : s.raw > 0) :
    div_i64 s 0 = MAX := by
  simp only [div_i64]
  simp [show s.raw ≠ 0 by omega, h]

theorem div_zero_of_neg (s : DeterministicScore) (h : s.raw < 0) :
    div_i64 s 0 = NEG_INF := by
  simp only [div_i64]
  simp [show s.raw ≠ 0 by omega, show ¬(s.raw > 0) by omega]

end DeterministicScore

end Score
