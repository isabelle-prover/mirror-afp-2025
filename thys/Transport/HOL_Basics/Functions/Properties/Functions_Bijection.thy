\<^marker>\<open>creator "Kevin Kappelmann"\<close>
subsubsection \<open>Bijections\<close>
theory Functions_Bijection
  imports
    Functions_Inverse
    Functions_Monotone
begin

consts bijection_on :: "'a \<Rightarrow> 'b \<Rightarrow> 'c \<Rightarrow> 'd \<Rightarrow> bool"

definition "bijection_on_pred (P :: 'a \<Rightarrow> bool) (Q :: 'b \<Rightarrow> bool) f g \<equiv>
  (P \<Rightarrow> Q) f \<and>
  (Q \<Rightarrow> P) g \<and>
  inverse_on P f g \<and>
  inverse_on Q g f"
adhoc_overloading bijection_on \<rightleftharpoons> bijection_on_pred

context
  fixes P :: "'a \<Rightarrow> bool" and Q :: "'b \<Rightarrow> bool" and f :: "'a \<Rightarrow> 'b" and g :: "'b \<Rightarrow> 'a"
begin

lemma bijection_onI [intro]:
  assumes "(P \<Rightarrow> Q) f"
  and "(Q \<Rightarrow> P) g"
  and "inverse_on P f g"
  and "inverse_on Q g f"
  shows "bijection_on P Q f g"
  using assms unfolding bijection_on_pred_def by blast

lemma bijection_onE [elim]:
  assumes "bijection_on P Q f g"
  obtains "(P \<Rightarrow> Q) f" "(Q \<Rightarrow> P) g"
    "inverse_on P f g" "inverse_on Q g f"
  using assms unfolding bijection_on_pred_def by blast

lemma mono_wrt_pred_if_bijection_on_left:
  assumes "bijection_on P Q f g"
  shows "(P \<Rightarrow> Q) f"
  using assms by (elim bijection_onE)

lemma mono_wrt_pred_if_bijection_on_right:
  assumes "bijection_on P Q f g"
  shows "(Q \<Rightarrow> P) g"
  using assms by (elim bijection_onE)

lemma bijection_on_pred_right:
  assumes "bijection_on P Q f g"
  and "P x"
  shows "Q (f x)"
  using assms by blast

lemma bijection_on_pred_left:
  assumes "bijection_on P Q f g"
  and "Q y"
  shows "P (g y)"
  using assms by blast

lemma inverse_on_if_bijection_on_left_right:
  assumes "bijection_on P Q f g"
  shows "inverse_on P f g"
  using assms by (elim bijection_onE)

lemma inverse_on_if_bijection_on_right_left:
  assumes "bijection_on P Q f g"
  shows "inverse_on Q g f"
  using assms by (elim bijection_onE)

lemma bijection_on_left_right_eq_self:
  assumes "bijection_on P Q f g"
  and "P x"
  shows "g (f x) = x"
  using assms inverse_on_if_bijection_on_left_right
  by (intro inverse_onD)

lemma bijection_on_right_left_eq_self':
  assumes "bijection_on P Q f g"
  and "Q y"
  shows "f (g y) = y"
  using assms inverse_on_if_bijection_on_right_left by (intro inverse_onD)

end

lemma bijection_on_has_inverse_on_the_inverse_on_if_injective_on:
  assumes "injective_on P f"
  shows "bijection_on P (has_inverse_on P f) f (the_inverse_on P f)"
  using assms by (intro bijection_onI inverse_on_has_inverse_on_the_inverse_on_if_injective_on
    inverse_on_the_inverse_on_if_injective_on)
  fastforce+

context
  fixes P :: "'a \<Rightarrow> bool" and Q :: "'b \<Rightarrow> bool" and f :: "'a \<Rightarrow> 'b" and g :: "'b \<Rightarrow> 'a"
begin

lemma bijection_on_right_left_if_bijection_on_left_right:
  assumes "bijection_on P Q f g"
  shows "bijection_on Q P g f"
  using assms by auto

lemma injective_on_if_bijection_on_left:
  assumes "bijection_on P Q f g"
  shows "injective_on P f"
  using assms
  by (intro injective_on_if_inverse_on inverse_on_if_bijection_on_left_right)

lemma injective_on_if_bijection_on_right:
  assumes "bijection_on P Q f g"
  shows "injective_on Q g"
  by (intro injective_on_if_inverse_on)
  (fact inverse_on_if_bijection_on_right_left[OF assms])

end

lemma bijection_on_compI:
  fixes P :: "'a \<Rightarrow> bool" and P' :: "'b \<Rightarrow> bool" and Q :: "'c \<Rightarrow> bool"
  assumes "bijection_on P P' f g"
  and "bijection_on P' Q f' g'"
  shows "bijection_on P Q (f' \<circ> f) (g \<circ> g')"
  using assms by (intro bijection_onI)
  (auto intro: dep_mono_wrt_pred_comp_dep_mono_wrt_pred_compI' inverse_on_compI
    elim!: bijection_onE simp: mono_wrt_pred_eq_dep_mono_wrt_pred)


consts bijection :: "'a \<Rightarrow> 'b \<Rightarrow> bool"

definition "(bijection_rel :: ('a \<Rightarrow> 'b) \<Rightarrow> ('b \<Rightarrow> 'a) \<Rightarrow> bool) \<equiv>
  bijection_on (\<top> :: 'a \<Rightarrow> bool) (\<top> :: 'b \<Rightarrow> bool)"
adhoc_overloading bijection \<rightleftharpoons> bijection_rel

lemma bijection_eq_bijection_on:
  "(bijection :: ('a \<Rightarrow> 'b) \<Rightarrow> ('b \<Rightarrow> 'a) \<Rightarrow> bool) = bijection_on (\<top> :: 'a \<Rightarrow> bool) (\<top> :: 'b \<Rightarrow> bool)"
  unfolding bijection_rel_def ..

lemma bijection_eq_bijection_on_uhint [uhint]:
  assumes "P \<equiv> (\<top> :: 'a \<Rightarrow> bool)"
  and "Q \<equiv> (\<top> :: 'b \<Rightarrow> bool)"
  shows "(bijection :: ('a \<Rightarrow> 'b) \<Rightarrow> ('b \<Rightarrow> 'a) \<Rightarrow> bool) = bijection_on P Q"
  using assms by (simp add: bijection_eq_bijection_on)

context
  fixes P :: "'a \<Rightarrow> bool" and Q :: "'b \<Rightarrow> bool" and f :: "'a \<Rightarrow> 'b" and g :: "'b \<Rightarrow> 'a"
begin

lemma bijectionI [intro]:
  assumes "inverse f g"
  and "inverse g f"
  shows "bijection f g"
  by (urule bijection_onI) (simp | urule assms)+

lemma bijectionE [elim]:
  assumes "bijection f g"
  obtains "inverse f g" "inverse g f"
  using assms by (urule (e) bijection_onE)

lemma inverse_if_bijection_left_right:
  assumes "bijection f g"
  shows "inverse f g"
  using assms by (elim bijectionE)

lemma inverse_if_bijection_right_left:
  assumes "bijection f g"
  shows "inverse g f"
  using assms by (elim bijectionE)

end

lemma bijection_right_left_if_bijection_left_right:
  fixes f :: "'a \<Rightarrow> 'b" and g :: "'b \<Rightarrow> 'a"
  assumes "bijection f g"
  shows "bijection g f"
  using assms by auto

paragraph \<open>Instantiations\<close>

lemma bijection_on_self_id: "bijection_on (P :: 'a \<Rightarrow> bool) P id id"
  by (intro bijection_onI inverse_onI mono_wrt_predI) simp_all


end