theory Pair_Graph_Specs
  imports Vwalk "Map_Addons" "Set_Addons"
 begin

section \<open>A Digraph Representation for Efficient Executable Functions\<close>

text \<open>We develop a locale modelling an abstract data type (ADT) which abstractly models a graph as an
      adjacency map: i.e.\ every vertex is mapped to a \<open>set\<close> of adjacent vertices, and this latter
      set is again modelled using the ADT of sets provided in Isabelle/HOL's distribution.

      We then show that this ADT can be implemented using existing implementations of the \<open>set\<close> ADT.
\<close>

(*
record ('a, 's) Set_Rec = empty :: "'s" insert :: "'a \<Rightarrow> 's \<Rightarrow> 's" delete :: "'a \<Rightarrow> 's \<Rightarrow> 's"
                          isin :: "'s \<Rightarrow> 'a \<Rightarrow> bool" set :: "'s \<Rightarrow> 'a set" invar :: "'s \<Rightarrow> bool"

locale Set_Rec =
  fixes set_rec:: "('a,'s) Set_Rec"
  assumes "Set (empty set_rec) (insert set_rec) (delete set_rec) (isin set_rec)
               (set set_rec) (invar set_rec)"
    
record ('a,'s) Set_Choose_Rec = "('a,'s) Set_Rec" + sel :: "'s \<Rightarrow> 'a"



locale Set_Choose = Set_Rec set_rec
  for set_rec::"('a,'m) Set_Rec" + 

fixes sel ::"'m \<Rightarrow> 'a"
assumes choose: "s \<noteq> (empty set_rec) \<Longrightarrow> (isin set_rec) s (sel s)"
begin


locale Set_Map = Set
  where set = t_set for t_set +
fixes t_map ::"('a \<Rightarrow> 'a) \<Rightarrow> 'm \<Rightarrow> 'm"
assumes map: "bij_betw f (t_set s) t  \<Longrightarrow> t_set (t_map f s) = t"
*)

locale Set_Choose = set: Set 
  where set = t_set for t_set ("[_]\<^sub>s") +
fixes sel ::"'s \<Rightarrow> 'a"

assumes choose [simp]: "s \<noteq> empty \<Longrightarrow> isin s (sel s)"


begin
context
  includes set.automation
begin

(*
declare set_empty[simp] set_isin[simp] set_insert[simp] set_delete[simp]
        invar_empty[simp] invar_insert[simp] invar_delete[simp] choose[simp]
*)

subsection \<open>Abstraction lemmas\<close>

text \<open>These are lemmas for automation. Their purpose is to remove any mention of the locale set ADT
      constructs and replace it with Isabelle's native sets.\<close>

lemma choose'[simp, intro,dest]:
  "s \<noteq> empty \<Longrightarrow> invar s \<Longrightarrow> sel s \<in> t_set s"
  by(auto simp flip: set.set_isin)

lemma choose''[intro]:
  "invar s \<Longrightarrow> s \<noteq> empty \<Longrightarrow> t_set s \<subseteq> s' \<Longrightarrow> sel s \<in> s'"
  by(auto simp flip: set.set_isin)

lemma emptyD[dest]:
           "s = empty \<Longrightarrow> t_set s = {}"
           "s \<noteq> empty \<Longrightarrow> invar s \<Longrightarrow> t_set s \<noteq> {}"
           "empty = s \<Longrightarrow> t_set s = {}"
           "empty \<noteq> s \<Longrightarrow> invar s \<Longrightarrow> t_set s \<noteq> {}"
 using set.set_empty
 by auto
end
end
(*
locale Adjmap_Map_Specs = 
 adjmap: Map 
 where update = update and invar = adjmap_inv +


 vset: Set_Choose
 where empty = vset_empty and delete = vset_delete and insert = vset_insert and invar = vset_inv
      and isin = isin

 for update :: "'a \<Rightarrow> 'vset \<Rightarrow> 'adjmap \<Rightarrow> 'adjmap" and adjmap_inv :: "'adjmap \<Rightarrow> bool"  and

     vset_empty :: "'vset"  ("\<emptyset>\<^sub>N") and vset_delete :: "'a \<Rightarrow> 'vset \<Rightarrow> 'vset" and
     vset_insert and vset_inv and isin


  \<comment> \<open>Why do we need ann efficient neghbourhood test?\<close>


begin


end
*)


named_theorems Graph_Spec_Elims
named_theorems Graph_Spec_Intros
named_theorems Graph_Spec_Simps

locale Pair_Graph_Specs = 
 adjmap: Map 
 where update = update and invar = adjmap_inv +


 vset: Set_Choose
 where empty = vset_empty and delete = vset_delete and invar = vset_inv

 for update :: "'v \<Rightarrow> 'vset \<Rightarrow> 'adjmap \<Rightarrow> 'adjmap" and adjmap_inv :: "'adjmap \<Rightarrow> bool"  and

     vset_empty :: "'vset" and vset_delete :: "'v \<Rightarrow> 'vset \<Rightarrow> 'vset" and
     vset_inv
(*  Adjmap_Map_Specs where update = update
for update :: "'a \<Rightarrow> 'vset \<Rightarrow> 'adjmap \<Rightarrow> 'adjmap"*) 
begin

notation vset_empty ("\<emptyset>\<^sub>V")
notation empty ("\<emptyset>\<^sub>G")

abbreviation isin' (infixl "\<in>\<^sub>G" 50) where "isin' G v \<equiv> isin v G" 
abbreviation not_isin' (infixl "\<notin>\<^sub>G" 50) where "not_isin' G v \<equiv> \<not> isin' G v"

definition "set_of_map (m::'adjmap) = {(u,v). case (lookup m u) of Some vs \<Rightarrow> v \<in>\<^sub>G vs}"

definition "graph_inv G = (adjmap_inv G \<and> (\<forall>v vset. lookup G v = Some vset \<longrightarrow> vset_inv vset))"
definition "finite_graph G = (finite {v. (lookup G v) \<noteq> None})"
definition "finite_vsets = (\<forall>vset. finite (t_set vset))"


definition neighb::"'adjmap \<Rightarrow> 'v \<Rightarrow> 'vset" where
  "(neighb G v) = (case (lookup G v) of Some vset \<Rightarrow> vset | _ \<Rightarrow> vset_empty)"

lemmas [code] = neighb_def

notation "neighb" ("\<N>\<^sub>G _ _" 100)

definition digraph_abs ("[_]\<^sub>G") where "digraph_abs G = {(u,v). v \<in>\<^sub>G (\<N>\<^sub>G G u)}" 

definition "add_edge G u v =
( 
  case (lookup G u) of Some vset \<Rightarrow> 
  let
    vset = the (lookup G u);
    vset' = insert v vset;
    digraph' = update u vset' G
  in
    digraph'
  | _ \<Rightarrow>
  let
    vset' = insert v vset_empty;
    digraph' = update u vset' G
  in
    digraph'
)"

definition "delete_edge G u v =
( 
  case (lookup G u) of Some vset \<Rightarrow> 
  let
    vset = the (lookup G u);
    vset' = vset_delete v vset;
    digraph' = update u vset' G
  in
    digraph'
  | _ \<Rightarrow> G 
)"
(*
function (domintros) recursive_union where
"recursive_union us vs = (if us = vset_empty then vs
                          else let x= sel us in recursive_union (vset_delete x us) (insert x vs))"
  by pat_completeness auto

partial_function (tailrec) recursive_union_impl where
"recursive_union_impl us vs = (if us = vset_empty then vs
                          else let x= sel us in recursive_union_impl (vset_delete x us) (insert x vs))"

lemmas [code] = recursive_union_impl.simps

lemma recursive_union_same:
  assumes "recursive_union_dom (us, vs)"
  shows "recursive_union_impl us vs = recursive_union us vs"
  by(induction rule: recursive_union.pinduct[OF assms])
    (auto simp add: recursive_union.psimps recursive_union_impl.simps)

lemma recursive_union_finite_dom:
  assumes "card (t_set us) = n " "finite (t_set us)" "vset_inv us"
  shows "recursive_union_dom (us, vs)"
  using assms
proof(induction n arbitrary: us vs )
  case 0
  then show ?case by(auto intro: recursive_union.domintros)
next
  case (Suc n)
  show ?case 
  apply(rule recursive_union.domintros)
  using Suc(2-) 
  by (auto intro:  recursive_union.domintros Suc(1) 
        simp add: vset.set.set_delete Suc.prems(3) vset.set.invar_delete)
qed

lemma recursive_union_inv:
  assumes "recursive_union_dom (us, vs)"  "vset_inv us"  "vset_inv vs"
  shows "vset_inv ()"


definition "union_impl us vs = (if vs = vset_empty then us else recursive_union_impl us vs)"
*)

context \<comment>\<open>Locale properties\<close>
  includes vset.set.automation and adjmap.automation
  fixes G::'adjmap
begin

lemma graph_invE[elim]: 
  "graph_inv G \<Longrightarrow> (\<lbrakk>adjmap_inv G; (\<And>v vset. lookup G v = Some vset \<Longrightarrow> vset_inv vset)\<rbrakk> \<Longrightarrow> P) \<Longrightarrow> P"
  by (auto simp: graph_inv_def)

lemma graph_invI[intro]: 
  "\<lbrakk>adjmap_inv G; (\<And>v vset. lookup G v = Some vset \<Longrightarrow> vset_inv vset)\<rbrakk> \<Longrightarrow> graph_inv G"
  by (auto simp: graph_inv_def)

lemma finite_graphE[elim]: 
  "finite_graph G \<Longrightarrow> (finite {v. (lookup G v) \<noteq> None} \<Longrightarrow> P) \<Longrightarrow> P"
  by (auto simp: finite_graph_def)

lemma finite_graphI[intro]: 
  "finite {v. (lookup G v) \<noteq> None}  \<Longrightarrow> finite_graph G"
  by (auto simp: finite_graph_def)

lemma finite_vsetsE[elim]: 
  "finite_vsets \<Longrightarrow> ((\<And>N. finite (t_set N)) \<Longrightarrow> P) \<Longrightarrow> P"
  by (auto simp: finite_vsets_def)

lemma finite_vsetsI[intro]: 
  "(\<And>N. finite (t_set N)) \<Longrightarrow> finite_vsets"
  by (auto simp: finite_vsets_def)


lemma neighbourhood_invars'[simp,dest]:
   "graph_inv G \<Longrightarrow> vset_inv (\<N>\<^sub>G G v)"
  by (auto simp add: graph_inv_def neighb_def split: option.splits)


lemma finite_graph[intro!]:
  assumes "graph_inv G" "finite_graph G" "finite_vsets"
  shows "finite (digraph_abs G)"
proof-

  have "digraph_abs G \<subseteq> {v. lookup G v \<noteq> None} \<times> (\<Union> (t_set ` {N | N v. lookup G v = Some N}))"
    using assms 
    by (fastforce simp: digraph_abs_def neighb_def graph_inv_def split: option.splits)

  moreover have "finite {v. lookup G v \<noteq> None}"
    using assms
    by fastforce

  moreover have "finite (\<Union> (t_set ` {N | N v. lookup G v = Some N}))"
    using assms
    by (force elim!: finite_vsetsE finite_graphE
              intro!: finite_imageI 
                      rev_finite_subset
                        [where B = "(the o lookup G) ` {v. \<exists>y. lookup G v = Some y}"])
  ultimately show ?thesis
    by(fastforce intro!: finite_cartesian_product dest: finite_subset)+

qed

corollary finite_vertices[intro!]:
  assumes "graph_inv G" "finite_graph G" "finite_vsets"
  shows "finite (dVs (digraph_abs G))"
  using finite_graph[OF assms]
  by (simp add: finite_vertices_iff)

subsection \<open>Abstraction lemmas\<close>

text \<open>These are lemmas for automation. Their purpose is to remove any mention of the neighbourhood
      concept implemented using the locale constructs and replace it with abstract terms
      on pair graphs.\<close>

lemma are_connected_abs[simp]: 
  "graph_inv G \<Longrightarrow> v \<in> t_set (\<N>\<^sub>G G u) \<longleftrightarrow> (u,v) \<in> digraph_abs G"
  by(auto simp: digraph_abs_def neighbourhood_def option.discI graph_inv_def
          split: option.split)

lemma are_connected_absD[dest]: 
  "\<lbrakk>v \<in> t_set (\<N>\<^sub>G G u); graph_inv G\<rbrakk> \<Longrightarrow> (u,v) \<in> digraph_abs G"
  by (auto simp: are_connected_abs)

lemma are_connected_absI[intro]: 
  "\<lbrakk>(u,v) \<in> digraph_abs G; graph_inv G\<rbrakk> \<Longrightarrow> v \<in> t_set (\<N>\<^sub>G G u)"
  by (auto simp: are_connected_abs)

lemma neighbourhood_absD[dest!]:
  "\<lbrakk>t_set (\<N>\<^sub>G G x) \<noteq> {}; graph_inv G\<rbrakk> \<Longrightarrow> x \<in> dVs (digraph_abs G)"
  by blast

lemma neighbourhood_abs[simp]:
  "graph_inv G \<Longrightarrow> t_set (\<N>\<^sub>G G u) = neighbourhood (digraph_abs G) u"
  by(auto simp: digraph_abs_def neighb_def Pair_Graph.neighbourhood_def option.discI graph_inv_def
          split: option.split)

lemma adjmap_inv_insert[intro]: "graph_inv G \<Longrightarrow> graph_inv (add_edge G u v)"
  by (auto simp: add_edge_def graph_inv_def split: option.splits)

lemma digraph_abs_insert[simp]: "graph_inv G \<Longrightarrow> digraph_abs (add_edge G u v) = Set.insert (u,v) (digraph_abs G)"
  by (fastforce simp add: digraph_abs_def set_of_map_def neighb_def add_edge_def split: option.splits if_splits)

lemma adjmap_inv_delete[intro]: "graph_inv G \<Longrightarrow> graph_inv (delete_edge G u v)"
  by (auto simp: delete_edge_def graph_inv_def split: option.splits)

lemma digraph_abs_delete[simp]:  "graph_inv G \<Longrightarrow> digraph_abs (delete_edge G u v) = (digraph_abs G) - {(u,v)}"
  by (fastforce simp add: digraph_abs_def set_of_map_def neighb_def delete_edge_def split: option.splits if_splits)


end \<comment> \<open>Properties context\<close>  

end text \<open>@{const Pair_Graph_Specs}\<close>

end
