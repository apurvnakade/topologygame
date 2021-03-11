import topologia

open topological_space
open set

variables {X : Type}
variables [topological_space X] (A B : set X)

/-- Kuratowski's problem -/
example : closure (interior (closure( interior A))) = closure (interior A) :=
begin
  sorry,
end

/-- Kuratowski's problem -/
example : interior (closure( interior (closure A))) = interior (closure A) :=
begin
  sorry,
end

def is_dense (A: set X) := closure A = univ

lemma dense_iff (A : set X) : is_dense A ↔ interior (A.compl) = ∅ :=
begin
  sorry
end

lemma dense_iff' (A : set X) : is_dense A ↔
  ∀ x : X, ∀ U : set X, is_neighborhood U x → U ∩ A ≠ ∅ :=
begin
  sorry
end

def boundary (A: set X) := closure A ∩ closure Aᶜ

lemma boundary_def (A : set X) : boundary A = (closure A) \ (interior A) :=
begin
  sorry
end

lemma mem_boundary_iff (A : set X) (x : X) :
  x ∈ boundary A ↔ ∀ U : set X, is_neighborhood U x → (U ∩ A ≠ ∅ ∧ U ∩ A.compl ≠ ∅) :=
begin
  sorry
end

class kolmogorov_space (X : Type) extends topological_space X :=
(t0 : ∀ (x y : X) (h : y ≠ x) , ∃ (U : set X) (hU : is_open U), ((x ∈ U) ∧ (y ∉ U)) ∨ ((x ∉ U) ∧ (y ∈ U)))

def is_frechet_space (X : Type) [topological_space X] := 
  ∀ (x y : X) (h : y ≠ x), ∃ (U : set X) (hU : is_open U), (x ∈ U) ∧ (y ∉ U)

class frechet_space (X : Type) extends topological_space X := 
(t1 : is_frechet_space X) -- Marc : look up what's the best way to do this

namespace frechet_space

instance T1_is_T0 (X : Type) [frechet_space X] : kolmogorov_space X :=
{ t0 := 
begin
  intros x y hxy,
  obtain ⟨U, hU, hh⟩ := t1 x y hxy,
  use U,
  split,
  { exact hU },
  {
    left,
    exact hh,
  },
end
}

lemma T1_characterisation (X : Type) [topological_space X] :
  is_frechet_space X ↔ (∀ (x : X), is_closed ({x} : set X)) :=
begin
  split,
  {
    intros h x,
    unfold is_closed,
    let I := {U : set X | (x ∉ U) ∧ (is_open U)},
    have p : ⋃₀ I = {x}ᶜ,
    {
      apply subset.antisymm; intros t ht, 
      {
        rcases ht with ⟨A,⟨hxA, hA⟩, htA⟩,
        simp,
        intro htx,
        rw htx at htA,
        exact hxA htA,     
      },
      {
        have htx := (mem_compl_singleton_iff.mp ht).symm,
        obtain ⟨U, hU, hh⟩ := h t x htx,
        use U,
        exact ⟨⟨hh.2, hU⟩, hh.1⟩,
      }
    },
    rw ← p,
    have c : ∀ B ∈ I, is_open B,
      finish,
    exact topological_space.union I c,
  },
  {
    intros h x y hxy,
    use {y}ᶜ,
    exact ⟨h y, mem_compl_singleton_iff.mpr (ne.symm hxy), not_not.mpr rfl⟩,
  }
end

end frechet_space


class hausdorff_space (X : Type) extends topological_space X :=
(t2 : ∀ (x y : X) (h : y ≠ x), ∃ (U V: set X) (hU : is_open U) (hV : is_open V) (hUV : U ∩ V = ∅), (x ∈ U) ∧ (y ∈ V))

namespace hausdorff_space

instance T2_is_T1 (X : Type) [hausdorff_space X] : frechet_space X :=
{ t1 := 
begin
  intros x y hxy,
  obtain ⟨U, V, hU, hV, hUV, hh⟩ := t2 x y hxy,
  rw inter_comm at hUV,
  use U,
  exact ⟨hU, ⟨hh.1, (inter_is_not_is_empty_intersection hh.2 hUV)⟩⟩,
end }

end hausdorff_space

def is_regular (X : Type) [topological_space X] :=
  ∀ (x : X) (F : set X) (hF : is_closed F) (hxF: x ∉ F),
  ∃ (U V : set X) (hU : is_open U) (hV : is_open V) (hUV : U ∩ V = ∅), (x ∈ U) ∧ (F ⊆ V)

class T3_space (X : Type) extends frechet_space X :=
(regular : is_regular X)

namespace T3_space
open frechet_space

instance T3_is_T2 (X : Type) [T3_space X] : hausdorff_space X :=
{ t2 := 
begin
  intros x y hxy,
  obtain ⟨U, V, hU, hV, hUV, hh⟩  := regular y {x} ((T1_characterisation X).1 t1 x) hxy,
  rw inter_comm U V at hUV,
  use V, use U,
  exact ⟨hV, ⟨hU, ⟨hUV, ⟨singleton_subset_iff.mp hh.2, hh.1⟩⟩⟩⟩, 
end}

end T3_space
