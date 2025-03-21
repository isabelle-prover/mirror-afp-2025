(*  Title:      HOL/MicroJava/BV/JVM.thy
    Author:     Gerwin Klein
    Copyright   2000 TUM

*)

section \<open> The JVM Type System as Semilattice \<close>

theory JVM_SemiType imports SemiType begin

type_synonym ty\<^sub>l = "ty err list"
type_synonym ty\<^sub>s = "ty list"
type_synonym ty\<^sub>i = "ty\<^sub>s \<times> ty\<^sub>l"
type_synonym ty\<^sub>i' = "ty\<^sub>i option"
type_synonym ty\<^sub>m = "ty\<^sub>i' list"
type_synonym ty\<^sub>P = "mname \<Rightarrow> cname \<Rightarrow> ty\<^sub>m"


definition stk_esl :: "'c prog \<Rightarrow> nat \<Rightarrow> ty\<^sub>s esl"
where
  "stk_esl P mxs \<equiv> upto_esl mxs (SemiType.esl P)"

definition loc_sl :: "'c prog \<Rightarrow> nat \<Rightarrow> ty\<^sub>l sl"
where
  "loc_sl P mxl \<equiv> Listn.sl mxl (Err.sl (SemiType.esl P))"

definition sl :: "'c prog \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> ty\<^sub>i' err sl"
where
  "sl P mxs mxl \<equiv>
  Err.sl(Opt.esl(Product.esl (stk_esl P mxs) (Err.esl(loc_sl P mxl))))"


definition states :: "'c prog \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> ty\<^sub>i' err set"
where "states P mxs mxl \<equiv> fst(sl P mxs mxl)"

definition le :: "'c prog \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> ty\<^sub>i' err ord"
where
  "le P mxs mxl \<equiv> fst(snd(sl P mxs mxl))"

definition sup :: "'c prog \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> ty\<^sub>i' err binop"
where
  "sup P mxs mxl \<equiv> snd(snd(sl P mxs mxl))"


definition sup_ty_opt :: "['c prog,ty err,ty err] \<Rightarrow> bool" 
    (\<open>_ \<turnstile> _ \<le>\<^sub>\<top> _\<close> [71,71,71] 70)
where
  "sup_ty_opt P \<equiv> Err.le (subtype P)"

definition sup_state :: "['c prog,ty\<^sub>i,ty\<^sub>i] \<Rightarrow> bool"   
    (\<open>_ \<turnstile> _ \<le>\<^sub>i _\<close> [71,71,71] 70)
where
  "sup_state P \<equiv> Product.le (Listn.le (subtype P)) (Listn.le (sup_ty_opt P))"

definition sup_state_opt :: "['c prog,ty\<^sub>i',ty\<^sub>i'] \<Rightarrow> bool" 
    (\<open>_ \<turnstile> _ \<le>'' _\<close> [71,71,71] 70)
where
  "sup_state_opt P \<equiv> Opt.le (sup_state P)"

abbreviation
  sup_loc :: "['c prog,ty\<^sub>l,ty\<^sub>l] \<Rightarrow> bool"  (\<open>_ \<turnstile> _ [\<le>\<^sub>\<top>] _\<close>  [71,71,71] 70)
  where "P \<turnstile> LT [\<le>\<^sub>\<top>] LT' \<equiv> list_all2 (sup_ty_opt P) LT LT'"

notation (ASCII)
  sup_ty_opt  (\<open>_ |- _ <=T _\<close> [71,71,71] 70) and
  sup_state  (\<open>_ |- _ <=i _\<close>  [71,71,71] 70) and
  sup_state_opt  (\<open>_ |- _ <=' _\<close>  [71,71,71] 70) and
  sup_loc  (\<open>_ |- _ [<=T] _\<close>  [71,71,71] 70)


subsection "Unfolding"

lemma JVM_states_unfold: 
  "states P mxs mxl \<equiv> err(opt((Union {nlists n (types P) |n. n <= mxs}) \<times>
                                 nlists mxl (err(types P))))"
(*<*)
  by (simp add: states_def sl_def Opt.esl_def Err.sl_def
         stk_esl_def loc_sl_def Product.esl_def
         Listn.sl_def upto_esl_def SemiType.esl_def Err.esl_def)
(*>*)

lemma JVM_le_unfold:
 "le P m n \<equiv> 
  Err.le(Opt.le(Product.le(Listn.le(subtype P))(Listn.le(Err.le(subtype P)))))" 
(*<*)
  by (simp add: le_def sl_def Opt.esl_def Err.sl_def
         stk_esl_def loc_sl_def Product.esl_def  
         Listn.sl_def upto_esl_def SemiType.esl_def Err.esl_def)
(*>*)
    
lemma sl_def2:
  "JVM_SemiType.sl P mxs mxl \<equiv> 
  (states P mxs mxl, JVM_SemiType.le P mxs mxl, JVM_SemiType.sup P mxs mxl)"
(*<*) by (unfold JVM_SemiType.sup_def states_def JVM_SemiType.le_def) simp (*>*)


lemma JVM_le_conv:
  "le P m n (OK t1) (OK t2) = P \<turnstile> t1 \<le>' t2"
(*<*) by (simp add: JVM_le_unfold Err.le_def lesub_def sup_state_opt_def  
                sup_state_def sup_ty_opt_def) (*>*)

lemma JVM_le_Err_conv:
  "le P m n = Err.le (sup_state_opt P)"
(*<*) by (unfold sup_state_opt_def sup_state_def  
             sup_ty_opt_def JVM_le_unfold) simp (*>*)

lemma err_le_unfold [iff]: 
  "Err.le r (OK a) (OK b) = r a b"
(*<*) by (simp add: Err.le_def lesub_def) (*>*)
  

subsection \<open> Semilattice \<close>
lemma order_sup_state_opt' [intro, simp]:
  "wf_prog wf_mb P \<Longrightarrow> 
      order (sup_state_opt P) (opt ((\<Union> {nlists n (types P) |n. n \<le> mxs} ) \<times> nlists (Suc (length Ts + mxl\<^sub>0)) (err (types P))))"   
(*<*) 
  unfolding sup_state_opt_def sup_state_def sup_ty_opt_def   
  by (blast intro:order_le_prodI) \<comment>\<open> use Listn.thy.order_listI2  \<close>
(*<*) 
lemma order_sup_state_opt'' [intro, simp]:
  "wf_prog wf_mb P \<Longrightarrow> 
      order (sup_state_opt P) (opt ((\<Union> {nlists n (types P) |n. n \<le> mxs} ) \<times> nlists ((length Ts + mxl\<^sub>0)) (err (types P))))"   
(*<*) 
  unfolding sup_state_opt_def sup_state_def sup_ty_opt_def   
  by (blast intro:order_le_prodI) \<comment>\<open> use Listn.thy.order_listI2  \<close>
(*<*)
(*
lemma order_sup_state_opt [intro, simp]: 
  "wf_prog wf_mb P \<Longrightarrow> order (sup_state_opt P)"   
(*<*) by (unfold sup_state_opt_def sup_state_def sup_ty_opt_def) blast (*>*)
*)

lemma semilat_JVM [intro?]:
  "wf_prog wf_mb P \<Longrightarrow> semilat (JVM_SemiType.sl P mxs mxl)"
(*<*)
  unfolding JVM_SemiType.sl_def stk_esl_def loc_sl_def  
  apply (blast intro: err_semilat_Product_esl err_semilat_upto_esl 
                      Listn_sl err_semilat_JType_esl)
  done
(*>*)

subsection \<open> Widening with @{text "\<top>"} \<close>

lemma subtype_refl[iff]: "subtype P t t" (*<*) by (simp add: fun_of_def) (*>*)

lemma sup_ty_opt_refl [iff]: "P \<turnstile> T \<le>\<^sub>\<top> T"
(*<*)
  unfolding sup_ty_opt_def
  by (metis le_err_refl lesub_def subtype_refl)
(*>*)

lemma Err_any_conv [iff]: "P \<turnstile> Err \<le>\<^sub>\<top> T = (T = Err)"
(*<*) by (unfold sup_ty_opt_def) (rule Err_le_conv [simplified lesub_def]) (*>*)

lemma any_Err [iff]: "P \<turnstile> T \<le>\<^sub>\<top> Err"
(*<*) by (unfold sup_ty_opt_def) (rule le_Err [simplified lesub_def]) (*>*)

lemma OK_OK_conv [iff]:
  "P \<turnstile> OK T \<le>\<^sub>\<top> OK T' = P \<turnstile> T \<le> T'"
(*<*) by (simp add: sup_ty_opt_def fun_of_def) (*>*)

lemma any_OK_conv [iff]:
  "P \<turnstile> X \<le>\<^sub>\<top> OK T' = (\<exists>T. X = OK T \<and> P \<turnstile> T \<le> T')"
(*<*)
  unfolding sup_ty_opt_def 
  by (rule le_OK_conv [simplified lesub_def])
(*>*)

lemma OK_any_conv:
 "P \<turnstile> OK T \<le>\<^sub>\<top> X = (X = Err \<or> (\<exists>T'. X = OK T' \<and> P \<turnstile> T \<le> T'))"
(*<*)
  unfolding sup_ty_opt_def 
  by (rule OK_le_conv [simplified lesub_def])
(*>*)

lemma sup_ty_opt_trans [intro?, trans]:
  "\<lbrakk>P \<turnstile> a \<le>\<^sub>\<top> b; P \<turnstile> b \<le>\<^sub>\<top> c\<rbrakk> \<Longrightarrow> P \<turnstile> a \<le>\<^sub>\<top> c"
(*<*) by (auto intro: widen_trans  
           simp add: sup_ty_opt_def Err.le_def lesub_def fun_of_def
           split: err.splits) (*>*)


subsection "Stack and Registers"

lemma stk_convert:
  "P \<turnstile> ST [\<le>] ST' = Listn.le (subtype P) ST ST'"
(*<*) by (simp add: Listn.le_def lesub_def) (*>*)

lemma sup_loc_refl [iff]: "P \<turnstile> LT [\<le>\<^sub>\<top>] LT"
(*<*) by (rule list_all2_refl) simp (*>*)

lemmas sup_loc_Cons1 [iff] = list_all2_Cons1 [of "sup_ty_opt P"] for P

lemma sup_loc_def:
  "P \<turnstile> LT [\<le>\<^sub>\<top>] LT' \<equiv> Listn.le (sup_ty_opt P) LT LT'"
(*<*) by (simp add: Listn.le_def lesub_def) (*>*)

lemma sup_loc_widens_conv [iff]:
  "P \<turnstile> map OK Ts [\<le>\<^sub>\<top>] map OK Ts' = P \<turnstile> Ts [\<le>] Ts'"
(*<*)
  by (simp add: list_all2_map1 list_all2_map2)
(*>*)


lemma sup_loc_trans [intro?, trans]:
  "\<lbrakk>P \<turnstile> a [\<le>\<^sub>\<top>] b; P \<turnstile> b [\<le>\<^sub>\<top>] c\<rbrakk> \<Longrightarrow> P \<turnstile> a [\<le>\<^sub>\<top>] c"
(*<*) by (rule list_all2_trans, rule sup_ty_opt_trans) (*>*)


subsection "State Type"

lemma sup_state_conv [iff]:
  "P \<turnstile> (ST,LT) \<le>\<^sub>i (ST',LT') = (P \<turnstile> ST [\<le>] ST' \<and> P \<turnstile> LT [\<le>\<^sub>\<top>] LT')"
(*<*) by (auto simp add: sup_state_def stk_convert lesub_def Product.le_def sup_loc_def) (*>*)
  
lemma sup_state_conv2:
  "P \<turnstile> s1 \<le>\<^sub>i s2 = (P \<turnstile> fst s1 [\<le>] fst s2 \<and> P \<turnstile> snd s1 [\<le>\<^sub>\<top>] snd s2)"
(*<*) by (cases s1, cases s2) simp (*>*)

lemma sup_state_refl [iff]: "P \<turnstile> s \<le>\<^sub>i s"
(*<*) by (auto simp add: sup_state_conv2) (*>*)

lemma sup_state_trans [intro?, trans]:
  "\<lbrakk>P \<turnstile> a \<le>\<^sub>i b; P \<turnstile> b \<le>\<^sub>i c\<rbrakk> \<Longrightarrow> P \<turnstile> a \<le>\<^sub>i c"
(*<*) by (auto intro: sup_loc_trans widens_trans simp add: sup_state_conv2) (*>*)


lemma sup_state_opt_None_any [iff]:
  "P \<turnstile> None \<le>' s"
(*<*) by (simp add: sup_state_opt_def Opt.le_def) (*>*)

lemma sup_state_opt_any_None [iff]:
  "P \<turnstile> s \<le>' None = (s = None)"
(*<*) by (simp add: sup_state_opt_def Opt.le_def) (*>*)

lemma sup_state_opt_Some_Some [iff]:
  "P \<turnstile> Some a \<le>' Some b = P \<turnstile> a \<le>\<^sub>i b"  
(*<*) by (simp add: sup_state_opt_def Opt.le_def lesub_def) (*>*)

lemma sup_state_opt_any_Some:
  "P \<turnstile> (Some s) \<le>' X = (\<exists>s'. X = Some s' \<and> P \<turnstile> s \<le>\<^sub>i s')"
(*<*) by (simp add: sup_state_opt_def Opt.le_def lesub_def) (*>*)

lemma sup_state_opt_refl [iff]: "P \<turnstile> s \<le>' s"
(*<*) by (simp add: sup_state_opt_def Opt.le_def lesub_def) (*>*)

lemma sup_state_opt_trans [intro?, trans]:
  "\<lbrakk>P \<turnstile> a \<le>' b; P \<turnstile> b \<le>' c\<rbrakk> \<Longrightarrow> P \<turnstile> a \<le>' c"
(*<*)
  unfolding sup_state_opt_def Opt.le_def lesub_def
  by (simp add: option.case_eq_if sup_state_trans)
(*>*)


lemma sup_state_opt_err  : "(Err.le (sup_state_opt P)) s s"
  unfolding JVM_le_unfold Product.le_def Opt.le_def Err.le_def lesssub_def lesub_def Listn.le_def
  by (auto split: err.splits)

lemma Cons_less_Conss1 [simp]:
  "x#xs [\<sqsubset>\<^bsub>subtype P\<^esub>] y#ys = (x \<sqsubset>\<^bsub>subtype P\<^esub> y \<and> xs [\<sqsubseteq>\<^bsub>subtype P\<^esub>] ys \<or> x = y \<and> xs [\<sqsubset>\<^bsub>subtype P\<^esub>] ys)"
  unfolding lesssub_def
  by (metis Cons_le_Cons lesub_def list.inject subtype_refl) 

lemma Cons_less_Conss2 [simp]:
  "x#xs [\<sqsubset>\<^bsub>Err.le (subtype P)\<^esub>] y#ys = (x \<sqsubset>\<^bsub>Err.le (subtype P)\<^esub> y \<and> xs [\<sqsubseteq>\<^bsub>Err.le (subtype P)\<^esub>] ys \<or> x = y \<and> xs [\<sqsubset>\<^bsub>Err.le (subtype P)\<^esub>] ys)"
  unfolding lesssub_def
  by (metis Cons_le_Cons le_err_refl lesub_def list.inject subtype_refl) 

lemma acc_le_listI1 [intro!]:
  " acc (subtype P) \<Longrightarrow> acc (Listn.le (subtype P))"
  (*<*) 
  unfolding acc_def
  apply (subgoal_tac
      "wf(UN n. {(ys,xs). size xs = n \<and> size ys = n \<and> xs <_(Listn.le (subtype P)) ys})")
   apply (erule wf_subset)

   apply (blast intro: lesssub_lengthD)
  apply (rule wf_UN)
   prefer 2
  apply force
  apply (rename_tac n)
  apply (induct_tac n)
   apply (simp add: lesssub_def cong: conj_cong)
  apply (rename_tac k)
  apply (simp add: wf_eq_minimal)
  apply (simp (no_asm) add: length_Suc_conv cong: conj_cong)
  apply clarify
  apply (rename_tac M m)
  apply (case_tac "\<exists>x xs. size xs = k \<and> x#xs \<in> M")
   prefer 2
   apply blast
  apply (erule_tac x = "{a. \<exists>xs. size xs = k \<and> a#xs:M}" in allE)
  apply (erule impE)
   apply blast
  apply (thin_tac "\<exists>x xs. P x xs" for P)
  apply clarify
  apply (rename_tac maxA xs)
  apply (erule_tac x = "{ys. size ys = size xs \<and> maxA#ys \<in> M}" in allE)
  apply (erule impE)
   apply blast
  apply clarify
  using Cons_less_Conss1 by blast

lemma acc_le_listI2 [intro!]:
  " acc (Err.le (subtype P)) \<Longrightarrow> acc (Listn.le (Err.le (subtype P)))"
  (*<*) 
  unfolding acc_def
  apply (subgoal_tac
      "wf(UN n. {(ys,xs). size xs = n \<and> size ys = n \<and> xs <_(Listn.le (Err.le (subtype P))) ys})")
   apply (erule wf_subset)

   apply (blast intro: lesssub_lengthD)
  apply (rule wf_UN)
   prefer 2
   apply force
  apply (rename_tac n)
  apply (induct_tac n)
   apply (simp add: lesssub_def cong: conj_cong)
  apply (rename_tac k)
  apply (simp add: wf_eq_minimal)
  apply (simp (no_asm) add: length_Suc_conv cong: conj_cong)
  apply clarify
  apply (rename_tac M m)
  apply (case_tac "\<exists>x xs. size xs = k \<and> x#xs \<in> M")
   prefer 2
   apply blast
  apply (erule_tac x = "{a. \<exists>xs. size xs = k \<and> a#xs:M}" in allE)
  apply (erule impE)
   apply blast
  apply (thin_tac "\<exists>x xs. P x xs" for P)
  apply clarify
  apply (rename_tac maxA xs)
  apply (erule_tac x = "{ys. size ys = size xs \<and> maxA#ys \<in> M}" in allE)
  apply (erule impE)
   apply blast
  apply clarify
  using Cons_less_Conss2 by blast

lemma acc_JVM [intro]:
  "wf_prog wf_mb P \<Longrightarrow> acc (JVM_SemiType.le P mxs mxl)"
(*<*) by (unfold JVM_le_unfold) blast (*>*)  \<comment>\<open> use acc_listI1, acc_listI2 \<close>

end
