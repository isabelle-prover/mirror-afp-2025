(***********************************************************************************
 * Copyright (c) 2016-2020 The University of Sheffield, UK
 *               2019-2020 University of Exeter, UK
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ********************************************************************************\***)

section \<open>The Shadow DOM Data Model\<close>

theory ShadowRootClass
  imports
    Core_DOM.ShadowRootPointer
    Core_DOM.DocumentClass
begin

subsection \<open>ShadowRoot\<close>

datatype shadow_root_mode = Open | Closed
record ('node_ptr, 'element_ptr, 'character_data_ptr) RShadowRoot = RObject +
  nothing :: unit
  mode :: shadow_root_mode
  child_nodes :: "('node_ptr, 'element_ptr, 'character_data_ptr) node_ptr list"
type_synonym ('node_ptr, 'element_ptr, 'character_data_ptr, 'ShadowRoot) ShadowRoot
  = "('node_ptr, 'element_ptr, 'character_data_ptr, 'ShadowRoot option) RShadowRoot_scheme"
register_default_tvars "('node_ptr, 'element_ptr, 'character_data_ptr, 'ShadowRoot) ShadowRoot"
type_synonym ('node_ptr, 'element_ptr, 'character_data_ptr, 'shadow_root_ptr, 'Object, 'Node,
    'Element, 'CharacterData, 'Document,
    'ShadowRoot) Object
  = "('node_ptr, 'element_ptr, 'character_data_ptr, 'shadow_root_ptr, ('node_ptr, 'element_ptr,
'character_data_ptr, 'ShadowRoot option)
      RShadowRoot_ext + 'Object, 'Node, 'Element, 'CharacterData, 'Document) Object"
register_default_tvars "('node_ptr, 'element_ptr, 'character_data_ptr, 'shadow_root_ptr, 'Object,
'Node, 'Element, 'CharacterData,
    'Document, 'ShadowRoot) Object"

type_synonym ('object_ptr, 'node_ptr, 'element_ptr, 'character_data_ptr, 'document_ptr,
    'shadow_root_ptr, 'Object, 'Node,
    'Element, 'CharacterData, 'Document, 'ShadowRoot) heap
  = "('object_ptr, 'node_ptr, 'element_ptr, 'character_data_ptr, 'document_ptr, 'shadow_root_ptr,
('node_ptr, 'element_ptr,
      'character_data_ptr, 'ShadowRoot option) RShadowRoot_ext + 'Object, 'Node, 'Element,
'CharacterData, 'Document) heap"
register_default_tvars "('object_ptr, 'node_ptr, 'element_ptr, 'character_data_ptr, 'document_ptr,
'shadow_root_ptr, 'Object,
    'Node, 'Element, 'CharacterData, 'Document, 'ShadowRoot) heap"
type_synonym "heap\<^sub>f\<^sub>i\<^sub>n\<^sub>a\<^sub>l" = "(unit, unit, unit, unit, unit, unit, unit, unit, unit, unit, unit, unit) heap"



definition shadow_root_ptr_kinds :: "(_) heap \<Rightarrow> (_) shadow_root_ptr fset"
  where
    "shadow_root_ptr_kinds heap =
the |`| (cast |`| (ffilter is_shadow_root_ptr_kind (object_ptr_kinds heap)))"

lemma shadow_root_ptr_kinds_simp [simp]:
  "shadow_root_ptr_kinds (Heap (fmupd (cast shadow_root_ptr) shadow_root (the_heap h))) =
{|shadow_root_ptr|} |\<union>| shadow_root_ptr_kinds h"
  by (auto simp add: shadow_root_ptr_kinds_def)

definition shadow_root_ptrs :: "(_) heap \<Rightarrow> (_) shadow_root_ptr fset"
  where
    "shadow_root_ptrs heap = ffilter is_shadow_root_ptr (shadow_root_ptr_kinds heap)"

definition cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t :: "(_) Object \<Rightarrow> (_) ShadowRoot option"
  where
    "cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t obj = (case RObject.more obj of
      Inr (Inr (Inl shadow_root)) \<Rightarrow> Some (RObject.extend (RObject.truncate obj) shadow_root)
    | _ \<Rightarrow> None)"
adhoc_overloading cast \<rightleftharpoons> cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t

definition cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t:: "(_) ShadowRoot \<Rightarrow> (_) Object"
  where
    "cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t shadow_root =
(RObject.extend (RObject.truncate shadow_root) (Inr (Inr (Inl (RObject.more shadow_root)))))"
adhoc_overloading cast \<rightleftharpoons> cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t

definition is_shadow_root_kind :: "(_) Object \<Rightarrow> bool"
  where
    "is_shadow_root_kind ptr \<longleftrightarrow> cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr \<noteq> None"

lemma shadow_root_ptr_kinds_heap_upd [simp]:
  "shadow_root_ptr_kinds (Heap (fmupd (cast shadow_root_ptr) shadow_root (the_heap h))) =
{|shadow_root_ptr|} |\<union>| shadow_root_ptr_kinds h"
  by (auto simp add: shadow_root_ptr_kinds_def)

lemma shadow_root_ptr_kinds_commutes [simp]:
  "cast shadow_root_ptr |\<in>| object_ptr_kinds h \<longleftrightarrow> shadow_root_ptr |\<in>| shadow_root_ptr_kinds h"
proof (rule iffI)
  show "cast shadow_root_ptr |\<in>| object_ptr_kinds h \<Longrightarrow> shadow_root_ptr |\<in>| shadow_root_ptr_kinds h"
    by (metis (no_types, opaque_lifting) finsertI1 finsert_absorb funion_finsert_left
        funion_finsert_right put\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def put\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_put_ptrs shadow_root_ptr_kinds_def
        shadow_root_ptr_kinds_heap_upd sup_bot.right_neutral)
next
  show "shadow_root_ptr |\<in>| shadow_root_ptr_kinds h \<Longrightarrow> cast shadow_root_ptr |\<in>| object_ptr_kinds h"
    by (auto simp add: object_ptr_kinds_def shadow_root_ptr_kinds_def)
qed

definition get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t :: "(_) shadow_root_ptr \<Rightarrow> (_) heap \<Rightarrow> (_) ShadowRoot option"
  where
    "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h = Option.bind (get (cast shadow_root_ptr) h) cast"
adhoc_overloading get \<rightleftharpoons> get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t

locale l_type_wf_def\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t
begin
definition a_type_wf :: "(_) heap \<Rightarrow> bool"
  where
    "a_type_wf h = (DocumentClass.type_wf h \<and> (\<forall>shadow_root_ptr \<in> fset (shadow_root_ptr_kinds h).
get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h \<noteq> None))"
end
global_interpretation l_type_wf_def\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t defines type_wf = a_type_wf .
lemmas type_wf_defs = a_type_wf_def

locale l_type_wf\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t = l_type_wf type_wf for type_wf :: "((_) heap \<Rightarrow> bool)" +
  assumes type_wf\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t: "type_wf h \<Longrightarrow> ShadowRootClass.type_wf h"

sublocale l_type_wf\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t \<subseteq> l_type_wf\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t
  apply(unfold_locales)
  by (metis (full_types) ShadowRootClass.type_wf_def a_type_wf_def l_type_wf\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_axioms
      l_type_wf\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)

lemma type_wf_implies_previous: "type_wf h \<Longrightarrow> DocumentClass.type_wf h"
  by(simp add: type_wf_defs)

locale l_get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_lemmas = l_type_wf\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t
begin
sublocale l_get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t_lemmas by unfold_locales
lemma get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_type_wf:
  assumes "type_wf h"
  shows "shadow_root_ptr |\<in>| shadow_root_ptr_kinds h \<longleftrightarrow> get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h \<noteq> None"
  using l_type_wf\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_axioms assms
  apply(simp add: type_wf_defs get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def l_type_wf\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)
  by (metis is_none_bind is_none_simps(1) is_none_simps(2) local.get\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_type_wf
      shadow_root_ptr_kinds_commutes)
end

global_interpretation l_get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_lemmas type_wf by unfold_locales

definition put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t :: "(_) shadow_root_ptr \<Rightarrow> (_) ShadowRoot \<Rightarrow> (_) heap \<Rightarrow> (_) heap"
  where
    "put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr shadow_root = put (cast shadow_root_ptr) (cast shadow_root)"
adhoc_overloading put \<rightleftharpoons> put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t

lemma put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_ptr_in_heap:
  assumes "put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr shadow_root h = h'"
  shows "shadow_root_ptr |\<in>| shadow_root_ptr_kinds h'"
  using assms
  unfolding put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def
  by (metis shadow_root_ptr_kinds_commutes put\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_ptr_in_heap)

lemma put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_put_ptrs:
  assumes "put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr shadow_root h = h'"
  shows "object_ptr_kinds h' = object_ptr_kinds h |\<union>| {|cast shadow_root_ptr|}"
  using assms
  by (simp add: put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_put_ptrs)


lemma cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_inject [simp]: "cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t x = cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t y \<longleftrightarrow> x = y"
  apply(simp add: cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def RObject.extend_def)
  by (metis (full_types) RObject.surjective old.unit.exhaust)

lemma cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_none [simp]:
  "cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t obj = None \<longleftrightarrow> \<not> (\<exists>shadow_root. cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t shadow_root = obj)"
  apply(auto simp add: cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def RObject.extend_def
      split: sum.splits)[1]
  by (metis (full_types) RObject.select_convs(2) RObject.surjective old.unit.exhaust)

lemma cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_some [simp]:
  "cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t obj = Some shadow_root \<longleftrightarrow> cast shadow_root = obj"
  by(auto simp add: cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def RObject.extend_def split: sum.splits)

lemma cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_inv [simp]: "cast\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t\<^sub>2\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t (cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t shadow_root) = Some shadow_root"
  by simp

lemma cast_shadow_root_not_node [simp]:
  "cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t shadow_root \<noteq> cast\<^sub>N\<^sub>o\<^sub>d\<^sub>e\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t node"
  "cast\<^sub>N\<^sub>o\<^sub>d\<^sub>e\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t node \<noteq> cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t shadow_root"
  by(auto simp add: cast\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def cast\<^sub>N\<^sub>o\<^sub>d\<^sub>e\<^sub>2\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def RObject.extend_def)


lemma get_shadow_root_ptr_simp1 [simp]:
  "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr (put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr shadow_root h) = Some shadow_root"
  by(auto simp add: get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)
lemma get_shadow_root_ptr_simp2 [simp]:
  "shadow_root_ptr \<noteq> shadow_root_ptr'
   \<Longrightarrow> get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr (put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr' shadow_root h) =
get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h"
  by(auto simp add: get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)

lemma get_shadow_root_ptr_simp3 [simp]:
  "get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t element_ptr (put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr f h) = get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t element_ptr h"
  by(auto simp add: get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def get\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)
lemma get_shadow_root_ptr_simp4 [simp]:
  "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr (put\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t element_ptr f h) = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h"
  by(auto simp add: get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def put\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def)
lemma get_shadow_root_ptr_simp5 [simp]:
  "get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a character_data_ptr (put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr f h) = get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a character_data_ptr h"
  by(auto simp add: get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a_def get\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)
lemma get_shadow_root_ptr_simp6 [simp]:
  "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr (put\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a character_data_ptr f h) = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h"
  by(auto simp add: get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a_def put\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def)
lemma get_shadow_root_ptr_simp7 [simp]:
  "get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t document_ptr (put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr f h) = get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t document_ptr h"
  by(auto simp add: get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def get\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)
lemma get_shadow_root_ptr_simp8 [simp]:
  "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr (put\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t document_ptr f h) = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h"
  by(auto simp add: get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def put\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def)

lemma new\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t_get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t [simp]:
  assumes "new\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t h = (new_element_ptr, h')"
  shows "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr h = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr h'"
  using assms
  by(auto simp add: new\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def Let_def)

lemma new\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a_get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t [simp]:
  assumes "new\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a h = (new_character_data_ptr, h')"
  shows "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr h = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr h'"
  using assms
  by(auto simp add: new\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a_def Let_def)

lemma new\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t_get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t [simp]:
  assumes "new\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t h = (new_document_ptr, h')"
  shows "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr h = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr h'"
  using assms
  by(auto simp add: new\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def Let_def)


abbreviation "create_shadow_root_obj mode_arg child_nodes_arg
  \<equiv> \<lparr> RObject.nothing = (), RShadowRoot.nothing = (), mode = mode_arg,
RShadowRoot.child_nodes = child_nodes_arg, \<dots> = None \<rparr>"

definition new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t :: "(_)heap \<Rightarrow> ((_) shadow_root_ptr \<times> (_) heap)"
  where
    "new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t h = (let new_shadow_root_ptr =
shadow_root_ptr.Ref (Suc (fMax (shadow_root_ptr.the_ref |`| (shadow_root_ptrs h)))) in
      (new_shadow_root_ptr, put new_shadow_root_ptr (create_shadow_root_obj Open []) h))"

lemma new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_ptr_in_heap:
  assumes "new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t h = (new_shadow_root_ptr, h')"
  shows "new_shadow_root_ptr |\<in>| shadow_root_ptr_kinds h'"
  using assms
  unfolding new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def Let_def
  using put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_ptr_in_heap by blast

lemma new_shadow_root_ptr_new:
  "shadow_root_ptr.Ref (Suc (fMax (finsert 0 (shadow_root_ptr.the_ref |`| shadow_root_ptrs h)))) |\<notin>|
shadow_root_ptrs h"
  by (metis Suc_n_not_le_n shadow_root_ptr.sel(1) fMax_ge fimage_finsert finsertI1 finsertI2 set_finsert)

lemma new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_ptr_not_in_heap:
  assumes "new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t h = (new_shadow_root_ptr, h')"
  shows "new_shadow_root_ptr |\<notin>| shadow_root_ptr_kinds h"
  using assms
  unfolding new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def
  by (metis Pair_inject shadow_root_ptrs_def fMax_finsert fempty_iff ffmember_filter
      fimage_is_fempty is_shadow_root_ptr_ref max_0L new_shadow_root_ptr_new)

lemma new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_new_ptr:
  assumes "new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t h = (new_shadow_root_ptr, h')"
  shows "object_ptr_kinds h' = object_ptr_kinds h |\<union>| {|cast new_shadow_root_ptr|}"
  using assms
  by (metis Pair_inject new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_put_ptrs)

lemma new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_is_shadow_root_ptr:
  assumes "new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t h = (new_shadow_root_ptr, h')"
  shows "is_shadow_root_ptr new_shadow_root_ptr"
  using assms
  by(auto simp add: new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def Let_def)


lemma new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_get\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t [simp]:
  assumes "new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t h = (new_shadow_root_ptr, h')"
  assumes "ptr \<noteq> cast new_shadow_root_ptr"
  shows "get\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t ptr h = get\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t ptr h'"
  using assms
  by(auto simp add: new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def Let_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)

lemma new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_get\<^sub>N\<^sub>o\<^sub>d\<^sub>e [simp]:
  assumes "new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t h = (new_shadow_root_ptr, h')"
  shows "get\<^sub>N\<^sub>o\<^sub>d\<^sub>e ptr h = get\<^sub>N\<^sub>o\<^sub>d\<^sub>e ptr h'"
  using assms
  apply(simp add: new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def Let_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)
  by(auto simp add: get\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def)

lemma new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t [simp]:
  assumes "new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t h = (new_shadow_root_ptr, h')"
  shows "get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t ptr h = get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t ptr h'"
  using assms
  by(auto simp add: new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def Let_def)

lemma new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a [simp]:
  assumes "new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t h = (new_shadow_root_ptr, h')"
  shows "get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a ptr h = get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a ptr h'"
  using assms
  by(auto simp add: new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def Let_def)

lemma new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t [simp]:
  assumes "new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t h = (new_shadow_root_ptr, h')"
  shows "get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t ptr h = get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t ptr h'"
  using assms
  apply(simp add: new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def Let_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)
  by(auto simp add: get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def)

lemma new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t [simp]:
  assumes "new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t h = (new_shadow_root_ptr, h')"
  assumes "ptr \<noteq> new_shadow_root_ptr"
  shows "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr h = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr h'"
  using assms
  by(auto simp add: new\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def Let_def)


locale l_known_ptr\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t
begin
definition a_known_ptr :: "(_) object_ptr \<Rightarrow> bool"
  where
    "a_known_ptr ptr = (known_ptr ptr \<or> is_shadow_root_ptr ptr)"

lemma known_ptr_not_shadow_root_ptr: "a_known_ptr ptr \<Longrightarrow> \<not>is_shadow_root_ptr ptr \<Longrightarrow> known_ptr ptr"
  by(simp add: a_known_ptr_def)
lemma known_ptr_new_shadow_root_ptr: "a_known_ptr ptr \<Longrightarrow> \<not>known_ptr ptr \<Longrightarrow> is_shadow_root_ptr ptr"
  using l_known_ptr\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t.known_ptr_not_shadow_root_ptr by blast

end
global_interpretation l_known_ptr\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t defines known_ptr = a_known_ptr .
lemmas known_ptr_defs = a_known_ptr_def

locale l_known_ptrs\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t = l_known_ptr known_ptr for known_ptr :: "(_) object_ptr \<Rightarrow> bool"
begin
definition a_known_ptrs :: "(_) heap \<Rightarrow> bool"
  where
    "a_known_ptrs h = (\<forall>ptr \<in> fset (object_ptr_kinds h). known_ptr ptr)"

lemma known_ptrs_known_ptr: "a_known_ptrs h \<Longrightarrow> ptr |\<in>| object_ptr_kinds h \<Longrightarrow> known_ptr ptr"
  by (simp add: a_known_ptrs_def)

lemma known_ptrs_preserved:
  "object_ptr_kinds h = object_ptr_kinds h' \<Longrightarrow> a_known_ptrs h = a_known_ptrs h'"
  by(auto simp add: a_known_ptrs_def)
lemma known_ptrs_subset:
  "object_ptr_kinds h' |\<subseteq>| object_ptr_kinds h \<Longrightarrow> a_known_ptrs h \<Longrightarrow> a_known_ptrs h'"
  by (simp add: less_eq_fset.rep_eq local.a_known_ptrs_def subsetD)
lemma known_ptrs_new_ptr:
  "object_ptr_kinds h' = object_ptr_kinds h |\<union>| {|new_ptr|} \<Longrightarrow> known_ptr new_ptr \<Longrightarrow>
a_known_ptrs h \<Longrightarrow> a_known_ptrs h'"
  by(simp add: a_known_ptrs_def)
end
global_interpretation l_known_ptrs\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t known_ptr defines known_ptrs = a_known_ptrs .
lemmas known_ptrs_defs = a_known_ptrs_def

lemma known_ptrs_is_l_known_ptrs  [instances]: "l_known_ptrs known_ptr known_ptrs"
  using known_ptrs_known_ptr known_ptrs_preserved l_known_ptrs_def known_ptrs_subset
    known_ptrs_new_ptr
  by blast


lemma shadow_root_get_put_1 [simp]:
  "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr (put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr shadow_root h) = Some shadow_root"
  by(auto simp add: get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)
lemma shadow_root_different_get_put [simp]:
  "shadow_root_ptr \<noteq> shadow_root_ptr' \<Longrightarrow>
get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr (put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr' shadow_root h) = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h"
  by(auto simp add: get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)


lemma shadow_root_get_put_2 [simp]:
  "get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t element_ptr (put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr f h) = get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t element_ptr h"
  by(auto simp add: get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def get\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)
lemma shadow_root_get_put_3 [simp]:
  "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t element_ptr (put\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t shadow_root_ptr f h) = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t element_ptr h"
  by(auto simp add: get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def put\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def)
lemma shadow_root_get_put_4 [simp]:
  "get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a character_data_ptr (put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr f h) = get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a character_data_ptr h"
  by(auto simp add: get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a_def get\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)
lemma shadow_root_get_put_5 [simp]:
  "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t character_data_ptr (put\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a shadow_root_ptr f h) = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t character_data_ptr h"
  by(auto simp add: get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a_def put\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def)
lemma shadow_root_get_put_6 [simp]:
  "get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t document_ptr (put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr f h) = get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t document_ptr h"
  by(auto simp add: get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def get\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def put\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)
lemma shadow_root_get_put_7 [simp]:
  "get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t document_ptr (put\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t shadow_root_ptr f h) = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t document_ptr h"
  by(auto simp add: get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def put\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def put\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def)

lemma known_ptrs_implies: "DocumentClass.known_ptrs h \<Longrightarrow> ShadowRootClass.known_ptrs h"
  by(auto simp add: DocumentClass.known_ptrs_defs DocumentClass.known_ptr_defs
      ShadowRootClass.known_ptrs_defs ShadowRootClass.known_ptr_defs)

definition delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t :: "(_) shadow_root_ptr \<Rightarrow> (_) heap \<Rightarrow> (_) heap option" where
  "delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr = delete\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t (cast shadow_root_ptr)"

lemma delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_pointer_removed:
  assumes "delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr h = Some h'"
  shows "ptr |\<notin>| shadow_root_ptr_kinds h'"
  using assms
  by(auto simp add: delete\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_pointer_removed delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def shadow_root_ptr_kinds_def
      split: if_splits)

lemma delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_pointer_ptr_in_heap:
  assumes "delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr h = Some h'"
  shows "ptr |\<in>| shadow_root_ptr_kinds h"
  using assms
  apply(auto simp add: delete\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_pointer_ptr_in_heap delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def split: if_splits)[1]
  using delete\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_pointer_ptr_in_heap
  by fastforce

lemma delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_ok:
  assumes "ptr |\<in>| shadow_root_ptr_kinds h"
  shows "delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t ptr h \<noteq> None"
  using assms
  by (simp add: delete\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_ok delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def)

lemma shadow_root_delete_get_1 [simp]:
  "delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h = Some h' \<Longrightarrow> get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h' = None"
  by(auto simp add: delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def delete\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def get\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def split: if_splits)
lemma shadow_root_different_delete_get [simp]:
  "shadow_root_ptr \<noteq> shadow_root_ptr' \<Longrightarrow> delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr' h = Some h' \<Longrightarrow>
get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h' = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h"
  by(auto simp add: delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def delete\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def get\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def split: if_splits)


lemma shadow_root_delete_get_2 [simp]:
  "delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h = Some h' \<Longrightarrow> object_ptr \<noteq> cast shadow_root_ptr \<Longrightarrow>
get\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t object_ptr h' = get\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t object_ptr h"
  by(auto simp add: delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def delete\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def get\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def split: if_splits)
lemma shadow_root_delete_get_3 [simp]:
  "delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h = Some h' \<Longrightarrow> get\<^sub>N\<^sub>o\<^sub>d\<^sub>e node_ptr h' = get\<^sub>N\<^sub>o\<^sub>d\<^sub>e node_ptr h"
  by(auto simp add: get\<^sub>N\<^sub>o\<^sub>d\<^sub>e_def)
lemma shadow_root_delete_get_4 [simp]:
  "delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h = Some h' \<Longrightarrow> get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t element_ptr h' = get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t element_ptr h"
  by(simp add: get\<^sub>E\<^sub>l\<^sub>e\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def)
lemma shadow_root_delete_get_5 [simp]:
  "delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h = Some h' \<Longrightarrow>
get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a character_data_ptr h' = get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a character_data_ptr h"
  by(simp add: get\<^sub>C\<^sub>h\<^sub>a\<^sub>r\<^sub>a\<^sub>c\<^sub>t\<^sub>e\<^sub>r\<^sub>D\<^sub>a\<^sub>t\<^sub>a_def)
lemma shadow_root_delete_get_6 [simp]:
  "delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h = Some h' \<Longrightarrow> get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t document_ptr h' = get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t document_ptr h"
  by(simp add: get\<^sub>D\<^sub>o\<^sub>c\<^sub>u\<^sub>m\<^sub>e\<^sub>n\<^sub>t_def)
lemma shadow_root_delete_get_7 [simp]:
  "delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr h = Some h' \<Longrightarrow> shadow_root_ptr' \<noteq> shadow_root_ptr \<Longrightarrow>
get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr' h' = get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t shadow_root_ptr' h"
  by(auto simp add: delete\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def delete\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def get\<^sub>S\<^sub>h\<^sub>a\<^sub>d\<^sub>o\<^sub>w\<^sub>R\<^sub>o\<^sub>o\<^sub>t_def get\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def split: if_splits)
end
