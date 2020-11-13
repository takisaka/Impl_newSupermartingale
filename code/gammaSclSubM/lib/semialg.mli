open Variable
open Coefficient
open Polynomial

(** === inequality, semialgebrais set over coefficient as expressions === *)
(* inequality, semialg cannot be minused due to its semantics *)
type bop = LEQ | GEQ
val string_of_bop: bop -> string

(** ==================
    === inequality ===
    ================== *)
type 'coef ineq
(** NOTE: we ignore the distinction of strict inequality and weak inequlatiy !! *)

val substitute_v_with_v_in_c_coef_ineq : v -> v -> c_coef ineq -> c_coef ineq
val substitute_v_with_v_in_p_coef_ineq : v -> v -> p_coef ineq -> p_coef ineq

(** -----------
    c_ceof ineq *)
val compare_c_coef_ineq : c_coef ineq -> c_coef ineq -> int
  
(** setter *)
val true_c_coef_ineq : c_coef ineq
val false_c_coef_ineq : c_coef ineq
val c_coef_ineq_of_c_coef_polynomials : c_coef polynomial * bop * c_coef polynomial -> c_coef ineq

(** getter *)
val c_coef_polynomial_of_c_coef_ineq : c_coef ineq -> c_coef polynomial

(** operation on data type *)
val not_c_coef_ineq : c_coef ineq -> c_coef ineq

(** for debug *)
val string_of_c_coef_ineq : c_coef ineq -> string

(** -----------
    p_ceof ineq *)
val true_p_coef_ineq : p_coef ineq
val false_p_coef_ineq : p_coef ineq
val compare_p_coef_ineq : p_coef ineq -> p_coef ineq -> int

(** setter *)
val p_coef_ineq_of_p_coef_polynomials : p_coef polynomial * bop * p_coef polynomial -> p_coef ineq

(** getter *)
val p_coef_polynomial_of_p_coef_ineq : p_coef ineq -> p_coef polynomial

(** operation on data type *)
val not_p_coef_ineq : p_coef ineq -> p_coef ineq

(** for debug *)
val string_of_p_coef_ineq : p_coef ineq -> string

(** =========================
    === semialgebraic set ===
    ========================= *)
(* type 'coef semialg
 * 
 * (\** c_ceof semialg *\)
 * val true_c_coef_semialg : c_coef semialg
 * 
 * (\* (\\** operation on data type *\\)
 *  * val uminus_c_coef_semialg : c_coef semialg -> c_coef semialg *\)
 * 
 * (\** setter *\)
 * (\** duplication will be eliminated: [ineq2; ineq1; ineq2] = [ineq1; ineq2]*\)
 * (\** no order: [ineq1; ineq2] = [ineq2; ineq1] *\)
 * val c_coef_semialg_of_c_coef_ineq_list : c_coef ineq list -> c_coef semialg
 * val c_coef_semialg_of_c_coef_semialg_list : c_coef semialg list -> c_coef semialg
 * (\** getter *\)
 * val c_coef_ineq_list_of_c_coef_semialg : c_coef semialg -> c_coef ineq list
 * 
 * (\** for debug *\)
 * val string_of_c_coef_semialg : c_coef semialg -> string
 * 
 * (\* (\\* we don't need p_coef semialg *\\)
 *  * (\\** p_ceof semialg *\\)
 *  * val true_p_coef_semialg : p_coef semialg
 *  *   
 *  * (\\** operation on data type *\\)
 *  * val not_p_coef_semialg : p_coef semialg -> p_coef semialg
 *  *   
 *  * (\\** setter *\\)
 *  * (\\** duplication will be eliminated: [ineq2; ineq1; ineq2] = [ineq1; ineq2]*\\)
 *  * (\\** no order: [ineq1; ineq2] = [ineq2; ineq1] *\\)
 *  * val p_coef_semialg_of_p_coef_ineq_list : p_coef ineq list -> p_coef semialg
 *  * val p_coef_semialg_of_p_coef_semialg_list : p_coef semialg list -> p_coef semialg
 *  * (\\** getter *\\)
 *  * val p_coef_ineq_list_of_p_coef_semialg : p_coef semialg -> p_coef ineq list
 *  * 
 *  * (\\** for debug *\\)
 *  * val string_of_p_coef_semialg : p_coef semialg -> string *\) *)
(* disjunction normal form *)
type and_ineq_list
val true_and_ineq_list : and_ineq_list
val false_and_ineq_list : and_ineq_list

val and_ineq_list_of_and_ineq_list_list : and_ineq_list list -> and_ineq_list

(** setter *)
(* empty: [] -> true_and_ineq_list *)
(* no duplicate *)
(* no order *)
val and_ineq_list_of_c_coef_ineq_list : c_coef ineq list -> and_ineq_list 

(** getter *)
val c_coef_ineq_list_of_and_ineq_list : and_ineq_list -> c_coef ineq list

(** operations on data type *)
val substitute_v_with_v_in_and_ineq_list : v -> v -> and_ineq_list -> and_ineq_list
val v_list_of_and_ineq_list : and_ineq_list -> v list
val add_ineq_to_and_ineq_list : c_coef ineq -> and_ineq_list -> and_ineq_list
val and_and_ineq_list : and_ineq_list -> and_ineq_list -> and_ineq_list

(** for debug *)
val string_of_and_ineq_list :and_ineq_list -> string

(** semialg is of disjunction normal form; \/ /\ \phi_i *)
type semialg
val true_semialg : semialg
val false_semialg : semialg

(** setter *)
val semialg_of_and_ineq_list : and_ineq_list -> semialg

(** getter *)
val and_ineq_list_list_of_semialg : semialg -> and_ineq_list list

(** operations on data type *)
val add_and_ineq_list_to_semialg : and_ineq_list -> semialg -> semialg
val not_and_ineq_list : and_ineq_list -> semialg

val and_semialg : semialg -> semialg -> semialg
(* empty: [] -> true_semialg *)
val and_semialg_list : semialg list -> semialg
val or_semialg : semialg -> semialg -> semialg
(* empty: [] -> false_semialg *)
val or_semialg_list : semialg list -> semialg
val not_semialg : semialg -> semialg 

(** for debug *)
val string_of_semialg : semialg -> string

val is_linear_ineq : 'coef ineq -> bool
