open Variable
open Coefficient

(** ===================================
    === polynomial over coefficient ===
    =================================== *)

(** ------------------------------
    1. monomial
    x^i = x_1^i1 x_2^i2 ... x_n^in *)
(* where x = (x_1, ..., x_n) and i = (i_1, ..., i_n) *)
type monomial
val compare_monomial : monomial -> monomial -> int

(** setter *)
val empty_monomial : monomial
(* x^0 -> empty_monomial *)
(* empty_v^i -> empty_monomial *)
val monomial_of_v_int : v -> int -> monomial
(* empty: [] -> empty_monomial *)
(* zero term: x^0 y^i z^0 -> y^j *)
(* same term: x^i x^j -> x ^(i+j) *)
(* no order: x^i y^j = y^j x^i *)
val monomial_of_v_int_list : (v * int) list -> monomial

(** getter *)
val v_int_list_of_monomial : monomial -> (v * int) list

(** operations on data type *)
val mult_monomial : monomial -> monomial -> monomial
val exp_monomial : monomial -> int -> monomial



(** for debug *)
val string_of_monomial : monomial -> string

val is_scalar : ('coef * monomial) -> bool

(** ===================================
    === polynomial over coefficient ===
    =================================== *)
type 'coef polynomial
val coef_list_of_polynomial : 'coef polynomial -> 'coef list
val monomial_list_of_polynomial : 'coef polynomial -> monomial list

(** --------------------
    1. c_coef polynomial
    \sum_i a_i x_i       *)
val compare_c_coef_polynomial : c_coef polynomial -> c_coef polynomial -> int

(** setter *)
val zero_c_coef_polynomial : c_coef polynomial
val unit_c_coef_polynomial : c_coef polynomial
(* val c_coef_polynomial_of_float : float -> c_coef polynomial
 * val c_coef_polynomial_of_v : v -> c_coef polynomial
 * val c_coef_polynomial_of_monomial : monomial -> c_coef polynomial *)
(* zero_c_coef -> zero_c_coef_polynomial *)
(* unit_c_coef -> unit_c_coef_polynomial *)
val c_coef_polynomial_of_c_coef : c_coef -> c_coef polynomial
(* empty_monomial -> unit_c_coef_polynomial *)
val c_coef_polynomial_of_monomial : monomial -> c_coef polynomial
(* (0., m) -> zero_c_coef_polynomial *)
val c_coef_polynomial_of_c_coef_monomial : c_coef -> monomial -> c_coef polynomial
(* empty: [] -> zero_c_coef_polynomial *)
(* zero monomial: [(0., m1); (1., m); (0., m2)] -> [(1., m)] *)
(* same monomial: [(2., m1); (1., m); (3., m1)] -> [(1., m); (5., m1)] *)
(* no order : [(5., m); (1., m1)] = [(1., m1); (5., m)] *)
val c_coef_polynomial_of_c_coef_monomial_list : (c_coef * monomial) list -> c_coef polynomial

(** getter *)
val c_coef_monomial_list_of_c_coef_polynomial : c_coef polynomial -> (c_coef * monomial) list

val v_list_of_polynomial : 'coef polynomial -> v list

(** operations on data type *)
val add_c_coef_polynomial : c_coef polynomial -> c_coef polynomial -> c_coef polynomial
val add_c_coef_polynomial_list : c_coef polynomial list -> c_coef polynomial
val uminus_c_coef_polynomial : c_coef polynomial -> c_coef polynomial
val mult_c_coef_polynomial : c_coef polynomial -> c_coef polynomial -> c_coef polynomial
val mult_c_coef_polynomial_list : c_coef polynomial list -> c_coef polynomial
val exp_c_coef_polynomial : c_coef polynomial -> int -> c_coef polynomial

(* val substitute_monomial : monomial -> v -> monomial *)
val substitute_v_with_c_coef_polynomial_in_c_coef_polynomial : v -> c_coef polynomial -> c_coef polynomial -> c_coef polynomial

val valuate_monomial : v valuation -> monomial -> float

(** for debug *)
val string_of_c_coef_polynomial : c_coef polynomial -> string

(** -----------------------
    == p_coef polynomial ==
   \sum_i (\sum_j a_j p_j) x_i
 *)
val compare_p_coef_polynomial : p_coef polynomial -> p_coef polynomial -> int

(** setter *)
val zero_p_coef_polynomial : p_coef polynomial
val unit_p_coef_polynomial : p_coef polynomial
(* zero_p_coef -> zero_p_coef_polynomial *)
(* unit_p_coef -> unit_p_coef_polynomial *)
val p_coef_polynomial_of_p_coef : p_coef -> p_coef polynomial
(* empty_monomial -> unit_p_coef_polynomial *)
val p_coef_polynomial_of_monomial : monomial -> p_coef polynomial
(* (0., m) -> zero_p_coef_polynomial *)
val p_coef_polynomial_of_p_coef_monomial : p_coef -> monomial -> p_coef polynomial
(* empty: [] -> zero_p_coef_polynomial *)
(* zero monomial: [(0., m1); (1., m); (0., m2)] -> [(1., m)] *)
(* same monomial: [(2., m1); (1., m); (3., m1)] -> [(1., m); (5., m1)] *)
(* no order : [(5., m); (1., m1)] = [(1., m1); (5., m)] *)
val p_coef_polynomial_of_p_coef_monomial_list : (p_coef * monomial) list -> p_coef polynomial

(** getter *)
val p_coef_monomial_list_of_p_coef_polynomial : p_coef polynomial -> (p_coef * monomial) list

val collect_param_string_list_of_p_coef_polynomial : p_coef polynomial -> param list

(** operations on data type *)
val add_p_coef_polynomial : p_coef polynomial -> p_coef polynomial -> p_coef polynomial
val add_p_coef_polynomial_list : p_coef polynomial list -> p_coef polynomial
val uminus_p_coef_polynomial : p_coef polynomial -> p_coef polynomial
val mult_float_with_p_coef_polynomial : float -> p_coef polynomial -> p_coef polynomial

val mult_p_coef_with_c_coef_polynomial : p_coef -> c_coef polynomial -> p_coef polynomial
val mult_p_coef_polynomial_with_c_coef_monomial : p_coef polynomial -> c_coef -> monomial -> p_coef polynomial
val mult_p_coef_polynomial_with_c_coef_polynomial : p_coef polynomial -> c_coef polynomial -> p_coef polynomial

val substitute_v_with_c_coef_polynomial_in_p_coef_monomial :  v -> c_coef polynomial -> p_coef * monomial -> p_coef polynomial
val substitute_v_with_c_coef_polynomial_in_p_coef_polynomial : v -> c_coef polynomial -> p_coef polynomial -> p_coef polynomial

(** for debug *)
val string_of_p_coef_polynomial : p_coef polynomial -> string

val substitute_vn_with_float_in_p_coef_polynomial : v -> (int -> float) ->  p_coef polynomial -> p_coef polynomial

(** other utility functions *)
val substitute_v_with_v_in_c_coef_polynomial : v -> v -> c_coef polynomial -> c_coef polynomial
val substitute_v_with_v_in_p_coef_polynomial : v -> v -> p_coef polynomial -> p_coef polynomial


val is_linear_polynomial : 'coef polynomial -> bool
val is_scalar_polynomial : 'coef polynomial -> bool
