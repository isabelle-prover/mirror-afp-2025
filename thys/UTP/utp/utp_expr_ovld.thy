section \<open> Overloaded Expression Constructs \<close>

theory utp_expr_ovld
  imports utp
begin

subsection \<open> Overloadable Constants \<close>

text \<open> For convenience, we often want to utilise the same expression syntax for multiple constructs.
  This can be achieved using ad-hoc overloading. We create a number of polymorphic constants and then
  overload their definitions using appropriate implementations. In order for this to work,
  each collection must have its own unique type. Thus we do not use the HOL map type directly,
  but rather our own partial function type, for example. \<close>
  
consts
  \<comment> \<open> Empty elements, for example empty set, nil list, 0... \<close> 
  uempty     :: "'f"
  \<comment> \<open> Function application, map application, list application... \<close>
  uapply     :: "'f \<Rightarrow> 'k \<Rightarrow> 'v"
  \<comment> \<open> Function update, map update, list update... \<close>
  uupd       :: "'f \<Rightarrow> 'k \<Rightarrow> 'v \<Rightarrow> 'f"
  \<comment> \<open> Domain of maps, lists... \<close>
  udom       :: "'f \<Rightarrow> 'a set"
  \<comment> \<open> Range of maps, lists... \<close>
  uran       :: "'f \<Rightarrow> 'b set"
  \<comment> \<open> Domain restriction \<close>
  udomres    :: "'a set \<Rightarrow> 'f \<Rightarrow> 'f"
  \<comment> \<open> Range restriction \<close>
  uranres    :: "'f \<Rightarrow> 'b set \<Rightarrow> 'f"
  \<comment> \<open> Collection cardinality \<close>
  ucard      :: "'f \<Rightarrow> nat"
  \<comment> \<open> Collection summation \<close>
  usums      :: "'f \<Rightarrow> 'a"
  \<comment> \<open> Construct a collection from a list of entries \<close>
  uentries   :: "'k set \<Rightarrow> ('k \<Rightarrow> 'v) \<Rightarrow> 'f"
  
text \<open> We need a function corresponding to function application in order to overload. \<close>
  
definition fun_apply :: "('a \<Rightarrow> 'b) \<Rightarrow> ('a \<Rightarrow> 'b)"
where "fun_apply f x = f x"

declare fun_apply_def [simp]

definition ffun_entries :: "'k set \<Rightarrow> ('k \<Rightarrow> 'v) \<Rightarrow> ('k, 'v) ffun" where
"ffun_entries d f = graph_ffun {(k, f k) | k. k \<in> d}"

text \<open> We then set up the overloading for a number of useful constructs for various collections. \<close>
  
adhoc_overloading
  uempty \<rightleftharpoons> 0 and
  uapply \<rightleftharpoons> fun_apply and uapply \<rightleftharpoons> nth and uapply \<rightleftharpoons> pfun_app and
  uapply \<rightleftharpoons> ffun_app and
  uupd \<rightleftharpoons> pfun_upd and uupd \<rightleftharpoons> ffun_upd and uupd \<rightleftharpoons> list_augment and
  udom \<rightleftharpoons> Domain and udom \<rightleftharpoons> pdom and udom \<rightleftharpoons> fdom and udom \<rightleftharpoons> seq_dom and
  udom \<rightleftharpoons> Range and uran \<rightleftharpoons> pran and uran \<rightleftharpoons> fran and uran \<rightleftharpoons> set and
  udomres \<rightleftharpoons> pdom_res and udomres \<rightleftharpoons> fdom_res and
  uranres \<rightleftharpoons> pran_res and udomres \<rightleftharpoons> fran_res and
  ucard \<rightleftharpoons> card and ucard \<rightleftharpoons> pcard and ucard \<rightleftharpoons> length and
  usums \<rightleftharpoons> list_sum and usums \<rightleftharpoons> Sum and usums \<rightleftharpoons> pfun_sum and
  uentries \<rightleftharpoons> pfun_entries and uentries \<rightleftharpoons> ffun_entries

subsection \<open> Syntax Translations \<close>

syntax
  "_uundef"     :: "logic" (\<open>\<bottom>\<^sub>u\<close>)
  "_umap_empty" :: "logic" (\<open>[]\<^sub>u\<close>)
  "_uapply"     :: "('a \<Rightarrow> 'b, '\<alpha>) uexpr \<Rightarrow> utuple_args \<Rightarrow> ('b, '\<alpha>) uexpr" (\<open>_'(_')\<^sub>a\<close> [999,0] 999)
  "_umaplet"    :: "[logic, logic] => umaplet" (\<open>_ /\<mapsto>/ _\<close>)
  ""            :: "umaplet => umaplets"             (\<open>_\<close>)
  "_UMaplets"   :: "[umaplet, umaplets] => umaplets" (\<open>_,/ _\<close>)
  "_UMapUpd"    :: "[logic, umaplets] => logic" (\<open>_/'(_')\<^sub>u\<close> [900,0] 900)
  "_UMap"       :: "umaplets => logic" (\<open>(1[_]\<^sub>u)\<close>)
  "_ucard"      :: "logic \<Rightarrow> logic" (\<open>#\<^sub>u'(_')\<close>)
  "_udom"       :: "logic \<Rightarrow> logic" (\<open>dom\<^sub>u'(_')\<close>)
  "_uran"       :: "logic \<Rightarrow> logic" (\<open>ran\<^sub>u'(_')\<close>)
  "_usum"       :: "logic \<Rightarrow> logic" (\<open>sum\<^sub>u'(_')\<close>)
  "_udom_res"   :: "logic \<Rightarrow> logic \<Rightarrow> logic" (infixl \<open>\<lhd>\<^sub>u\<close> 85)
  "_uran_res"   :: "logic \<Rightarrow> logic \<Rightarrow> logic" (infixl \<open>\<rhd>\<^sub>u\<close> 85)
  "_uentries"   :: "logic \<Rightarrow> logic \<Rightarrow> logic" (\<open>entr\<^sub>u'(_,_')\<close>)

translations
  \<comment> \<open> Pretty printing for adhoc-overloaded constructs \<close>
  "f(x)\<^sub>a"    <= "CONST uapply f x"
  "dom\<^sub>u(f)" <= "CONST udom f"
  "ran\<^sub>u(f)" <= "CONST uran f"  
  "A \<lhd>\<^sub>u f" <= "CONST udomres A f"
  "f \<rhd>\<^sub>u A" <= "CONST uranres f A"
  "#\<^sub>u(f)" <= "CONST ucard f"
  "f(k \<mapsto> v)\<^sub>u" <= "CONST uupd f k v"
  "0" <= "CONST uempty" \<comment> \<open> We have to do this so we don't see uempty. Is there a better way of printing? \<close>

  \<comment> \<open> Overloaded construct translations \<close>
  "f(x,y,z,u)\<^sub>a" == "CONST bop CONST uapply f (x,y,z,u)\<^sub>u"
  "f(x,y,z)\<^sub>a" == "CONST bop CONST uapply f (x,y,z)\<^sub>u"
  "f(x,y)\<^sub>a"  == "CONST bop CONST uapply f (x,y)\<^sub>u"  
  "f(x)\<^sub>a"    == "CONST bop CONST uapply f x"
  "#\<^sub>u(xs)"  == "CONST uop CONST ucard xs"
  "sum\<^sub>u(A)" == "CONST uop CONST usums A"
  "dom\<^sub>u(f)" == "CONST uop CONST udom f"
  "ran\<^sub>u(f)" == "CONST uop CONST uran f"
  "[]\<^sub>u"     => "\<guillemotleft>CONST uempty\<guillemotright>"
  "\<bottom>\<^sub>u"     == "\<guillemotleft>CONST undefined\<guillemotright>"
  "A \<lhd>\<^sub>u f" == "CONST bop (CONST udomres) A f"
  "f \<rhd>\<^sub>u A" == "CONST bop (CONST uranres) f A"
  "entr\<^sub>u(d,f)" == "CONST bop CONST uentries d \<guillemotleft>f\<guillemotright>"
  "_UMapUpd m (_UMaplets xy ms)" == "_UMapUpd (_UMapUpd m xy) ms"
  "_UMapUpd m (_umaplet  x y)"   == "CONST trop CONST uupd m x y"
  "_UMap ms"                      == "_UMapUpd []\<^sub>u ms"
  "_UMap (_UMaplets ms1 ms2)"     <= "_UMapUpd (_UMap ms1) ms2"
  "_UMaplets ms1 (_UMaplets ms2 ms3)" <= "_UMaplets (_UMaplets ms1 ms2) ms3"

subsection \<open> Simplifications \<close>

lemma ufun_apply_lit [simp]: 
  "\<guillemotleft>f\<guillemotright>(\<guillemotleft>x\<guillemotright>)\<^sub>a = \<guillemotleft>f(x)\<guillemotright>"
  by (transfer, simp)

lemma lit_plus_appl [lit_norm]: "\<guillemotleft>(+)\<guillemotright>(x)\<^sub>a(y)\<^sub>a = x + y" by (simp add: uexpr_defs, transfer, simp)
lemma lit_minus_appl [lit_norm]: "\<guillemotleft>(-)\<guillemotright>(x)\<^sub>a(y)\<^sub>a = x - y" by (simp add: uexpr_defs, transfer, simp)
lemma lit_mult_appl [lit_norm]: "\<guillemotleft>times\<guillemotright>(x)\<^sub>a(y)\<^sub>a = x * y" by (simp add: uexpr_defs, transfer, simp)
lemma lit_divide_apply [lit_norm]: "\<guillemotleft>(/)\<guillemotright>(x)\<^sub>a(y)\<^sub>a = x / y" by (simp add: uexpr_defs, transfer, simp)

lemma pfun_entries_apply [simp]:
  "(entr\<^sub>u(d,f) :: (('k, 'v) pfun, '\<alpha>) uexpr)(i)\<^sub>a = ((\<guillemotleft>f\<guillemotright>(i)\<^sub>a) \<triangleleft> i \<in>\<^sub>u d \<triangleright> \<bottom>\<^sub>u)"
  by (pred_auto)
    
lemma udom_uupdate_pfun [simp]:
  fixes m :: "(('k, 'v) pfun, '\<alpha>) uexpr"
  shows "dom\<^sub>u(m(k \<mapsto> v)\<^sub>u) = {k}\<^sub>u \<union>\<^sub>u dom\<^sub>u(m)"
  by (rel_auto)

lemma uapply_uupdate_pfun [simp]:
  fixes m :: "(('k, 'v) pfun, '\<alpha>) uexpr"
  shows "(m(k \<mapsto> v)\<^sub>u)(i)\<^sub>a = v \<triangleleft> i =\<^sub>u k \<triangleright> m(i)\<^sub>a"
  by (rel_auto)

subsection \<open> Indexed Assignment \<close>

syntax
  \<comment> \<open> Indexed assignment \<close>
  "_assignment_upd" :: "svid \<Rightarrow> uexp \<Rightarrow> uexp \<Rightarrow> logic" (\<open>(_[_] :=/ _)\<close> [63, 0, 0] 62)

translations
  \<comment> \<open> Indexed assignment uses the overloaded collection update function \emph{uupd}. \<close>
  "_assignment_upd x k v" => "x := &x(k \<mapsto> v)\<^sub>u"

end