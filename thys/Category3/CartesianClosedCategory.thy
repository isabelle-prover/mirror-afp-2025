(*  Title:       CartesianClosedCategory
    Author:      Eugene W. Stark <stark@cs.stonybrook.edu>, 2020
    Maintainer:  Eugene W. Stark <stark@cs.stonybrook.edu>
*)

chapter "Cartesian Closed Category"

theory CartesianClosedCategory
imports CartesianCategory
begin

  text\<open>
    A \emph{cartesian closed category} is a cartesian category such that,
    for every object \<open>b\<close>, the functor \<open>prod \<hyphen> b\<close> is a left adjoint functor.
    A right adjoint to this functor takes each object \<open>c\<close> to the \emph{exponential}
    \<open>exp b c\<close>.  The adjunction yields a natural bijection between \<open>hom (prod a b) c\<close>
    and \<open>hom a (exp b c)\<close>.
  \<close>

  locale cartesian_closed_category =
    cartesian_category +
  assumes left_adjoint_prod_ax: "\<And>b. ide b \<Longrightarrow> left_adjoint_functor C C (\<lambda>x. some_prod x b)"

  locale elementary_cartesian_closed_category =
    elementary_cartesian_category C pr0 pr1 one trm
  for C :: "'a \<Rightarrow> 'a \<Rightarrow> 'a"  (infixr \<open>\<cdot>\<close> 55)
  and pr0 :: "'a \<Rightarrow> 'a \<Rightarrow> 'a"  (\<open>\<pp>\<^sub>0[_, _]\<close>)
  and pr1 :: "'a \<Rightarrow> 'a \<Rightarrow> 'a"  (\<open>\<pp>\<^sub>1[_, _]\<close>)
  and one :: "'a"              (\<open>\<one>\<close>)
  and trm :: "'a \<Rightarrow> 'a"        (\<open>\<t>[_]\<close>)
  and exp :: "'a \<Rightarrow> 'a \<Rightarrow> 'a"
  and eval :: "'a \<Rightarrow> 'a \<Rightarrow> 'a"
  and curry :: "'a \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> 'a" +
  assumes eval_in_hom_ax: "\<lbrakk> ide b; ide c \<rbrakk> \<Longrightarrow> \<guillemotleft>eval b c : prod (exp b c) b \<rightarrow> c\<guillemotright>"
  and ide_exp_ax [intro]: "\<lbrakk> ide b; ide c \<rbrakk> \<Longrightarrow> ide (exp b c)"
  and curry_in_hom: "\<lbrakk> ide a; ide b; ide c; \<guillemotleft>g : prod a b \<rightarrow> c\<guillemotright> \<rbrakk>
                          \<Longrightarrow> \<guillemotleft>curry a b c g : a \<rightarrow> exp b c\<guillemotright>"
  and uncurry_curry_ax: "\<lbrakk> ide a; ide b; ide c; \<guillemotleft>g : prod a b \<rightarrow> c\<guillemotright> \<rbrakk>
                          \<Longrightarrow> eval b c \<cdot> prod (curry a b c g) b = g"
  and curry_uncurry_ax: "\<lbrakk> ide a; ide b; ide c; \<guillemotleft>h : a \<rightarrow> exp b c\<guillemotright> \<rbrakk>
                          \<Longrightarrow> curry a b c (eval b c \<cdot> prod h b) = h"

  context cartesian_closed_category
  begin

    interpretation elementary_cartesian_category C some_pr0 some_pr1 \<open>\<one>\<^sup>?\<close> \<open>\<lambda>a. \<t>\<^sup>?[a]\<close>
      using extends_to_elementary_cartesian_category by blast

    lemma has_exponentials:
    assumes "ide b" and "ide c"
    shows "\<exists>x e. ide x \<and> \<guillemotleft>e : x \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<and>
                 (\<forall>a g. ide a \<and> \<guillemotleft>g : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<longrightarrow> (\<exists>!f. \<guillemotleft>f : a \<rightarrow> x\<guillemotright> \<and> g = e \<cdot> (f \<otimes>\<^sup>? b)))"
    proof -
      interpret F: left_adjoint_functor C C \<open>\<lambda>x. x \<otimes>\<^sup>? b\<close>
        using assms(1) left_adjoint_prod_ax by simp
      obtain x e where e: "terminal_arrow_from_functor C C (\<lambda>x. x \<otimes>\<^sup>? b) x c e"
        using assms F.ex_terminal_arrow [of c] by auto
      interpret e: terminal_arrow_from_functor C C \<open>\<lambda>x. x \<otimes>\<^sup>? b\<close> x c e
        using e by simp
      have "\<And>a g. \<lbrakk> ide a; \<guillemotleft>g : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<rbrakk> \<Longrightarrow> \<exists>!f. \<guillemotleft>f : a \<rightarrow> x\<guillemotright> \<and> g = e \<cdot> (f \<otimes>\<^sup>? b)"
        using e.is_terminal category_axioms F.functor_axioms
        unfolding e.is_coext_def arrow_from_functor_def arrow_from_functor_axioms_def
        by simp
      thus ?thesis
        using e.arrow by metis
    qed

    definition some_exp  (\<open>exp\<^sup>?\<close>)
    where "some_exp b c \<equiv> SOME x. ide x \<and>
                                    (\<exists>e. \<guillemotleft>e : x \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<and>
                                      (\<forall>a g. ide a \<and> \<guillemotleft>g : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>
                                              \<longrightarrow> (\<exists>!f. \<guillemotleft>f : a \<rightarrow> x\<guillemotright> \<and> g = e \<cdot> (f \<otimes>\<^sup>? b))))"

    definition some_eval  (\<open>eval\<^sup>?\<close>)
    where "some_eval b c \<equiv> SOME e. \<guillemotleft>e : exp\<^sup>? b c \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<and>
                                     (\<forall>a g. ide a \<and> \<guillemotleft>g : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>
                                              \<longrightarrow> (\<exists>!f. \<guillemotleft>f : a \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> g = e \<cdot>(f \<otimes>\<^sup>? b)))"

    definition some_Curry  (\<open>Curry\<^sup>?\<close>)
    where "some_Curry a b c g \<equiv> THE f. \<guillemotleft>f : a \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> g = eval\<^sup>? b c \<cdot> (f \<otimes>\<^sup>? b)"

    lemma Curry_uniqueness:
    assumes "ide b" and "ide c"
    shows "ide (exp\<^sup>? b c)"
    and "\<guillemotleft>eval\<^sup>? b c : exp\<^sup>? b c \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>"
    and "\<lbrakk> ide a; \<guillemotleft>g : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<rbrakk> \<Longrightarrow>
            \<exists>!f. \<guillemotleft>f : a \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> g = eval\<^sup>? b c \<cdot> (f \<otimes>\<^sup>? b)"
      using assms some_exp_def some_eval_def has_exponentials
            someI_ex [of "\<lambda>x. ide x \<and> (\<exists>e. \<guillemotleft>e : x \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<and>
                                           (\<forall>a g. ide a \<and> \<guillemotleft>g : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>
                                              \<longrightarrow> (\<exists>!f. \<guillemotleft>f : a \<rightarrow> x\<guillemotright> \<and> g = e \<cdot> (f \<otimes>\<^sup>? b))))"]
            someI_ex [of "\<lambda>e. \<guillemotleft>e : exp\<^sup>? b c \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<and>
                              (\<forall>a g. ide a \<and> \<guillemotleft>g : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>
                                           \<longrightarrow> (\<exists>!f. \<guillemotleft>f : a \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> g = e \<cdot> (f \<otimes>\<^sup>? b)))"]
      by auto

    lemma ide_exp [intro, simp]:
    assumes "ide b" and "ide c"
    shows "ide (exp\<^sup>? b c)"
      using assms Curry_uniqueness(1) by force

    lemma eval_in_hom [intro]:
    assumes "ide b" and "ide c" and "x = exp\<^sup>? b c \<otimes>\<^sup>? b"
    shows "\<guillemotleft>eval\<^sup>? b c : x \<rightarrow> c\<guillemotright>"
      using assms Curry_uniqueness by simp

    lemma Uncurry_Curry:
    assumes "ide a" and "ide b" and "\<guillemotleft>g : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>"
    shows "\<guillemotleft>Curry\<^sup>? a b c g : a \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> g = eval\<^sup>? b c \<cdot> (Curry\<^sup>? a b c g \<otimes>\<^sup>? b)"
    proof -
      have "ide c"
        using assms(3) by auto
      thus ?thesis
        using assms some_Curry_def Curry_uniqueness
              theI' [of "\<lambda>f. \<guillemotleft>f : a \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> g = eval\<^sup>? b c \<cdot> (f \<otimes>\<^sup>? b)"]
        by simp
    qed

    lemma Curry_Uncurry:
    assumes "ide b" and "ide c" and "\<guillemotleft>h : a \<rightarrow> exp\<^sup>? b c\<guillemotright>"
    shows "Curry\<^sup>? a b c (eval\<^sup>? b c \<cdot> (h \<otimes>\<^sup>? b)) = h"
    proof -
      have "\<exists>!f. \<guillemotleft>f : a \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> eval\<^sup>? b c \<cdot> (h \<otimes>\<^sup>? b) = eval\<^sup>? b c \<cdot> (f \<otimes>\<^sup>? b)"
      proof -
        have "ide a \<and> \<guillemotleft>eval\<^sup>? b c \<cdot> (h \<otimes>\<^sup>? b) : (a \<otimes>\<^sup>? b) \<rightarrow> c\<guillemotright>"
        proof (intro conjI)
          show "ide a"
            using assms(3) by auto
          show "\<guillemotleft>eval\<^sup>? b c \<cdot> (h \<otimes>\<^sup>? b) : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>"
            using assms by (intro comp_in_homI) auto
        qed
        thus ?thesis
          using assms Curry_uniqueness by simp
      qed
      moreover have "\<guillemotleft>h : a \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> eval\<^sup>? b c \<cdot> (h \<otimes>\<^sup>? b) = eval\<^sup>? b c \<cdot> (h \<otimes>\<^sup>? b)"
        using assms by simp
      ultimately show ?thesis
        using assms some_Curry_def Curry_uniqueness Uncurry_Curry
              the1_equality [of "\<lambda>f. \<guillemotleft>f : a \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and>
                                     eval\<^sup>? b c \<cdot> (h \<otimes>\<^sup>? b) = eval\<^sup>? b c \<cdot> (f \<otimes>\<^sup>? b)"]
        by simp
    qed

    lemma Curry_in_hom [intro]:
    assumes "ide a" and "ide b" and "\<guillemotleft>g : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>"
    shows "\<guillemotleft>Curry\<^sup>? a b c g : a \<rightarrow> exp\<^sup>? b c\<guillemotright>"
      using assms
      by (simp add: Uncurry_Curry)

    lemma Curry_simps [simp]:
    assumes "ide a" and "ide b" and "\<guillemotleft>g : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>"
    shows "arr (Curry\<^sup>? a b c g)"
    and "dom (Curry\<^sup>? a b c g) = a"
    and "cod (Curry\<^sup>? a b c g) = exp\<^sup>? b c"
      using assms Curry_in_hom by blast+

    lemma eval_simps [simp]:
    assumes "ide b" and "ide c" and "x = (exp\<^sup>? b c) \<otimes>\<^sup>? b"
    shows "arr (eval\<^sup>? b c)"
    and "dom (eval\<^sup>? b c) = x"
    and "cod (eval\<^sup>? b c) = c"
      using assms eval_in_hom by auto

    interpretation elementary_cartesian_closed_category C some_pr0 some_pr1
                     \<open>\<one>\<^sup>?\<close> \<open>\<lambda>a. \<t>\<^sup>?[a]\<close> some_exp some_eval some_Curry
      using Curry_uniqueness Uncurry_Curry Curry_Uncurry
      apply unfold_locales by auto

    lemma extends_to_elementary_cartesian_closed_category:
    shows "elementary_cartesian_closed_category C some_pr0 some_pr1
             \<one>\<^sup>? (\<lambda>a. \<t>\<^sup>?[a]) some_exp some_eval some_Curry"
      ..

    lemma has_as_exponential:
    assumes "ide b" and "ide c"
    shows "has_as_exponential b c (exp\<^sup>? b c) (eval\<^sup>? b c)"
    proof
      show "ide b" by fact
      show "ide (exp\<^sup>? b c)"
        using assms by simp
      show "\<guillemotleft>some_eval b c : exp\<^sup>? b c \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>"
        using assms by auto
      show "\<And>a g. \<lbrakk>ide a; \<guillemotleft>g : a \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>\<rbrakk> \<Longrightarrow>
                     \<exists>!f. \<guillemotleft>f : a \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> g = eval\<^sup>? b c \<cdot> (f \<otimes>\<^sup>? b)"
        by (simp add: assms Curry_uniqueness(3))
    qed

    lemma has_as_exponential_iff:
    shows "has_as_exponential b c x e \<longleftrightarrow>
           ide b \<and> \<guillemotleft>e : x \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<and>
           (\<exists>h. \<guillemotleft>h : x \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> e = eval\<^sup>? b c \<cdot> (h \<otimes>\<^sup>? b) \<and> iso h)"
    proof
      assume 1: "has_as_exponential b c x e"
      moreover have 2: "has_as_exponential b c (exp\<^sup>? b c) (eval\<^sup>? b c)"
        using 1 ide_cod has_as_exponential_def in_homE
        by (metis has_as_exponential)
      ultimately show "ide b \<and> \<guillemotleft>e : x \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<and>
                       (\<exists>h. \<guillemotleft>h : x \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> e = eval\<^sup>? b c \<cdot> (h \<otimes>\<^sup>? b) \<and> iso h)"
        by (metis exponentials_are_isomorphic(2) has_as_exponentialE)
      next
      assume 1: "ide b \<and> \<guillemotleft>e : x \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<and>
                 (\<exists>h. \<guillemotleft>h : x \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> e = eval\<^sup>? b c \<cdot> (h \<otimes>\<^sup>? b) \<and> iso h)"
      have c: "ide c"
        using 1 ide_cod in_homE by metis
      have 2: "has_as_exponential b c (exp\<^sup>? b c) (eval\<^sup>? b c)"
        by (simp add: 1 c eval_in_hom_ax Curry_uniqueness(3) has_as_exponential_def)
      obtain h where h: "\<guillemotleft>h : x \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> e = eval\<^sup>? b c \<cdot> (h \<otimes>\<^sup>? b) \<and> iso h"
        using 1 by blast
      show "has_as_exponential b c x e"
      proof (unfold has_as_exponential_def, intro conjI)
        show "ide b" and "ide x" and "\<guillemotleft>e : x \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>"
          using 1 h ide_dom by blast+
        show "\<forall>y g. ide y \<and> \<guillemotleft>g : y \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright> \<longrightarrow> (\<exists>!f. \<guillemotleft>f : y \<rightarrow> x\<guillemotright> \<and> g = e \<cdot> (f \<otimes>\<^sup>? b))"
        proof (intro allI impI)
          fix y g
          assume 3: "ide y \<and> \<guillemotleft>g : y \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>"
          obtain k where k: "\<guillemotleft>k : y \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> g = eval\<^sup>? b c \<cdot> (k \<otimes>\<^sup>? b)"
            by (metis 3 \<open>ide b\<close> c Curry_uniqueness(3))
          show "\<exists>!f. \<guillemotleft>f : y \<rightarrow> x\<guillemotright> \<and> g = e \<cdot> (f \<otimes>\<^sup>? b)"
          proof -
            let ?f = "inv h \<cdot> k"
            have f: "\<guillemotleft>?f : y \<rightarrow> x\<guillemotright>"
              by (meson comp_in_homI inv_in_hom h k)
            moreover have "g = e \<cdot> (?f \<otimes>\<^sup>? b)"
            proof -
              have "e \<cdot> some_prod ?f b = e \<cdot> some_prod (inv h \<cdot> k) (b \<cdot> b)"
                by (simp add: 1)
              also have "... = e \<cdot> (inv h \<otimes>\<^sup>? b) \<cdot> (k \<otimes>\<^sup>? b)"
                by (metis \<open>ide b\<close> f arrI comp_ide_self interchange ide_compE)
              also have "... = (e \<cdot> (inv h \<otimes>\<^sup>? b)) \<cdot> (k \<otimes>\<^sup>? b)"
                using comp_assoc by simp
              also have "... = eval\<^sup>? b c \<cdot> (k \<otimes>\<^sup>? b)"
                by (metis \<open>\<guillemotleft>e : x \<otimes>\<^sup>? b \<rightarrow> c\<guillemotright>\<close> h \<open>ide b\<close> arrI inv_prod(1-2) ide_is_iso
                    inv_ide invert_side_of_triangle(2))
              also have "... = g"
                using k by blast
              finally show ?thesis by blast
            qed
            moreover have "\<And>f'. \<guillemotleft>f' : y \<rightarrow> x\<guillemotright> \<and> g = e \<cdot> (f' \<otimes>\<^sup>? b) \<Longrightarrow> f' = ?f"
            proof -
              fix f'
              assume f': "\<guillemotleft>f' : y \<rightarrow> x\<guillemotright> \<and> g = e \<cdot> (f' \<otimes>\<^sup>? b)"
              have "\<guillemotleft>h \<cdot> f' : y \<rightarrow> exp\<^sup>? b c\<guillemotright> \<and> g = eval\<^sup>? b c \<cdot> (h \<cdot> f' \<otimes>\<^sup>? b)"
                using f' h \<open>ide b\<close> comp_assoc interchange seqI' by fastforce
              hence "C h f' = C h ?f"
                by (metis \<open>ide b\<close> arrI c h k Curry_Uncurry invert_side_of_triangle(1))
              thus "f' = ?f"
                using f h iso_cancel_left by auto
            qed
            ultimately show ?thesis by blast
          qed
        qed
      qed
    qed

  end

  context elementary_cartesian_closed_category
  begin

    lemma left_adjoint_prod:
    assumes "ide b"
    shows "left_adjoint_functor C C (\<lambda>x. x \<otimes> b)"
    proof -
      interpret "functor" C C \<open>\<lambda>x. x \<otimes> b\<close>
        using assms interchange
        apply unfold_locales
            apply auto
        using prod_def tuple_def
        by auto
      interpret left_adjoint_functor C C \<open>\<lambda>x. x \<otimes> b\<close>
      proof
        show "\<And>c. ide c \<Longrightarrow> \<exists>x e. terminal_arrow_from_functor C C (\<lambda>x. x \<otimes> b) x c e"
        proof -
          fix c
          assume c: "ide c"
          show "\<exists>x e. terminal_arrow_from_functor C C (\<lambda>x. x \<otimes> b) x c e"
          proof (intro exI)
            interpret arrow_from_functor C C \<open>\<lambda>x. x \<otimes> b\<close> \<open>exp b c\<close> c \<open>eval b c\<close>
              using assms c eval_in_hom_ax
              by (unfold_locales, auto)
            show "terminal_arrow_from_functor C C (\<lambda>x. x \<otimes> b) (exp b c) c (eval b c)"
            proof
              show "\<And>a f. arrow_from_functor C C (\<lambda>x. x \<otimes> b) a c f \<Longrightarrow>
                            \<exists>!g. arrow_from_functor.is_coext C C
                                   (\<lambda>x. x \<otimes> b) (exp b c) (eval b c) a f g"
              proof -
                fix a f
                assume f: "arrow_from_functor C C (\<lambda>x. x \<otimes> b) a c f"
                interpret f: arrow_from_functor C C \<open>\<lambda>x. x \<otimes> b\<close> a c f
                  using f by simp
                show "\<exists>!g. is_coext a f g"
                proof
                  have a: "ide a"
                    using f.arrow by simp
                  show "is_coext a f (curry a b c f)"
                    unfolding is_coext_def
                    using assms a c curry_in_hom uncurry_curry_ax f.arrow by simp
                  show "\<And>g. is_coext a f g \<Longrightarrow> g = curry a b c f"
                    unfolding is_coext_def
                    using assms a c curry_uncurry_ax f.arrow by simp
                qed
              qed
            qed
          qed
        qed
      qed
      show ?thesis ..
    qed

    sublocale cartesian_category C
      using is_cartesian_category by simp

    sublocale cartesian_closed_category C
    proof -
      interpret CCC: elementary_cartesian_category
                       C some_pr0 some_pr1 some_terminal some_terminator
        using extends_to_elementary_cartesian_category by blast
      show "cartesian_closed_category C"
      proof     
        fix b
        assume b: "ide b"
        interpret left_adjoint_functor C C \<open>\<lambda>x. CCC.prod x b\<close>
        proof -
          (*
           * We know that (\<lambda>x. x \<otimes> b) is a left adjoint functor, where \<otimes> is the
           * product ultimately defined in terms of the projections that are parameters
           * to the elementary_category_with_binary_products locale that is the present context.
           * This is not necessarily the same as (\<lambda>x. CCC.prod x b), which is defined in terms
           * of projections chosen arbitrarily in category_with_binary_products.
           * However, since they are both categorical products, they are naturally isomorphic,
           * so one is a left adjoint functor if and only if the other is.
           *)
          have "naturally_isomorphic C C (\<lambda>x. x \<otimes> b) (\<lambda>x. CCC.prod x b)"
          proof -
            interpret CC: product_category C C ..
            interpret X: binary_functor C C C \<open>\<lambda>fg. fst fg \<otimes> snd fg\<close>
              using binary_functor_Prod(1) by auto
            interpret Xb: "functor" C C \<open>\<lambda>x. x \<otimes> b\<close>
              using b X.fixing_ide_gives_functor_2 by simp
            interpret prod: binary_functor C C C \<open>\<lambda>fg. CCC.prod (fst fg) (snd fg)\<close>
              using CCC.binary_functor_Prod(1) by simp
            interpret prod_b: "functor" C C \<open>\<lambda>x. CCC.prod x b\<close>
               using b prod.fixing_ide_gives_functor_2 by simp
            interpret \<phi>: transformation_by_components C C \<open>\<lambda>x. x \<otimes> b\<close> \<open>\<lambda>x. CCC.prod x b\<close>
                           \<open>\<lambda>a. CCC.tuple \<pp>\<^sub>1[a, b] \<pp>\<^sub>0[a, b]\<close>
              using b CCC.prod_tuple by unfold_locales auto
            interpret \<phi>: natural_isomorphism C C \<open>\<lambda>x. x \<otimes> b\<close> \<open>\<lambda>x. CCC.prod x b\<close> \<phi>.map
            proof
              fix a
              assume a: "ide a"
              show "iso (\<phi>.map a)"
              proof
                show "inverse_arrows (\<phi>.map a) \<langle>some_pr1 a b, some_pr0 a b\<rangle>"
                  using a b by auto
              qed
            qed
            show ?thesis
              using naturally_isomorphic_def \<phi>.natural_isomorphism_axioms by blast
          qed
          moreover have "left_adjoint_functor C C (\<lambda>x. x \<otimes> b)"
            using b left_adjoint_prod by simp
          ultimately show "left_adjoint_functor C C (\<lambda>x. CCC.prod x b)"
            using left_adjoint_functor_respects_naturally_isomorphic by auto
        qed
        show "\<And>f. \<not> arr f \<Longrightarrow> some_prod f b = null"
          using extensionality by blast
        show "\<And>g f. seq g f \<Longrightarrow> some_prod (g \<cdot> f) b = some_prod g b \<cdot> some_prod f b"
          by simp
        show "\<And>y. ide y \<Longrightarrow> \<exists>x e. terminal_arrow_from_functor (\<cdot>) (\<cdot>) (\<lambda>x. some_prod x b) x y e"
          using ex_terminal_arrow by simp
      qed auto
    qed

    lemma is_cartesian_closed_category:
    shows "cartesian_closed_category C"
      ..

  end

end
