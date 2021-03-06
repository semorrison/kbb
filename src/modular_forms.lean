import tactic.ring
import group_theory.group_action
import algebra.module
import algebra.pi_instances
import linear_algebra.subtype_module
import .holomorphic_functions
import .upper_half_space

universes u v

open complex

local notation `ℍ` := upper_half_space

def is_Petersson_weight_ (k : ℕ) := { f : ℍ → ℂ | ∀ M : SL2Z, ∀ z : ℍ, f (SL2Z_H M z) = (M.c*z + M.d)^k * f z }

def is_bound_at_infinity := { f : ℍ → ℂ | ∃ (M A : ℝ), ∀ z : ℍ, im z ≥ A → abs (f z) ≤ M }

def is_zero_at_infinity := { f : ℍ → ℂ | ∀ ε : ℝ, ε > 0 → ∃ A : ℝ, ∀ z : ℍ, im z ≥ A → abs (f z) ≤ ε }

instance (k : ℕ) : is_submodule (is_Petersson_weight_ k) :=
{ zero_ := λ M z, by simp,
  add_  := λ f g hf hg M z, begin
    suffices : f (SL2Z_H M z) + g (SL2Z_H M z) = (↑(M.c) * ↑z + ↑(M.d)) ^ k * (f z + g z),
      by simp at *; assumption,
    rw [hf, hg],
    ring
  end,
  smul  := λ c f hyp M z, begin
    suffices : c * f (SL2Z_H M z) = (↑(M.c) * ↑z + ↑(M.d)) ^ k * (c * f z),
      by simp at *; assumption,
    rw hyp M z,
    ring 
  end }

instance : is_submodule is_bound_at_infinity :=
{ zero_ := ⟨0, ⟨0, λ z h, by simp⟩⟩,
  add_  := λ f g hf hg, begin
    cases hf with Mf hMf,
    cases hg with Mg hMg,
    cases hMf with Af hAMf,
    cases hMg with Ag hAMg,
    existsi (Mf + Mg),
    existsi (max Af Ag),
    intros z hz,
    simp,
    apply le_trans (complex.abs_add _ _),
    apply add_le_add,
    { refine hAMf z _,
      exact le_trans (le_max_left _ _) hz },
    { refine hAMg z _,
      exact le_trans (le_max_right _ _) hz }
  end,
  smul  := λ c f hyp, begin
    cases hyp with M hM,
    cases hM with A hAM,
    existsi (abs c * M),
    existsi A,
    intros z hz,
    simp,
    apply mul_le_mul_of_nonneg_left (hAM z hz) (complex.abs_nonneg c)
  end }

instance : is_submodule is_zero_at_infinity :=
{ zero_ := λ ε hε, ⟨1, λ z hz, by simp; exact le_of_lt hε⟩,
  add_  := λ f g hf hg ε hε, begin
    cases hf (ε/2) (half_pos hε) with Af hAf,
    cases hg (ε/2) (half_pos hε) with Ag hAg,
    existsi (max Af Ag),
    intros z hz,
    simp,
    apply le_trans (complex.abs_add _ _),
    rw show ε = ε / 2 + ε / 2, by simp,
    apply add_le_add,
    { refine hAf z (le_trans (le_max_left _ _) hz) },
    { refine hAg z (le_trans (le_max_right _ _) hz) }
  end,
  smul  := λ c f hyp ε hε, begin
    by_cases hc : (c = 0),
    { existsi (0 : ℝ ), intros, simp [hc], exact le_of_lt hε },
    { cases hyp (ε / abs c) (lt_div_of_mul_lt (by simp [hc]) (by simp; exact hε)) with A hA,
      existsi A,
      intros z hz,
      simp,
      rw show ε = abs c * (ε / abs c),
      begin
        rw [mul_comm],
        refine (div_mul_cancel _ _).symm,
        simp [hc]
      end,
      apply mul_le_mul_of_nonneg_left (hA z hz) (complex.abs_nonneg c), }
  end }

lemma is_bound_at_infinity_of_is_zero_at_infinity {f : ℍ → ℂ} (h : is_zero_at_infinity f) :
is_bound_at_infinity f := ⟨1, h 1 zero_lt_one⟩

-- structure is_modular_form (k : ℕ) (f : ℍ → ℂ) : Prop :=
-- (hol      : is_holomorphic f)
-- (transf   : ∀ M : SL2Z, ∀ z : ℍ, f (SL2Z_H M z) = (M.c*z + M.d)^k * f z)
-- (infinity : ∃ (M A : ℝ), ∀ z : ℍ, im z ≥ A → abs (f z) ≤ M)

def is_modular_form (k : ℕ) := {f : ℍ → ℂ | is_holomorphic f} ∩ (is_Petersson_weight_ k) ∩ is_bound_at_infinity

def is_cusp_form (k : ℕ) := {f : ℍ → ℂ | is_holomorphic f} ∩ (is_Petersson_weight_ k) ∩ is_zero_at_infinity

lemma is_modular_form_of_is_cusp_form {k : ℕ} (f : ℍ → ℂ) (h : is_cusp_form k f) : is_modular_form k f :=
⟨h.1, is_bound_at_infinity_of_is_zero_at_infinity h.2⟩

instance (k : ℕ) : is_submodule (is_modular_form k) := is_submodule.inter_submodule

instance (k : ℕ) : is_submodule (is_cusp_form k) := is_submodule.inter_submodule

/- def Hecke_operator {k : ℕ} (m : ℤ) : modular_forms k → modular_forms k :=
λ f,
(m^k.pred : ℂ) • (sorry : modular_forms k) -- why is this • failing?
 -/
 