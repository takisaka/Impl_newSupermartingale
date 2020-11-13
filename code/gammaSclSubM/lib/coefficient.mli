open Variable

(** ===================
    === coefficient ===
    =================== *)

(** ---------
    1. c_coef *)
(* e.g. c_i *)
type c_coef
val compare_c_coef : c_coef -> c_coef -> int 

(** setter *)
val zero_c_coef : c_coef
val unit_c_coef : c_coef
(* c_coef_of_float 0. -> zero_c_coef *)
(* c_coef_of_float 1. -> unit_c_coef *)
val c_coef_of_float : float -> c_coef

(** getter *)
val float_of_c_coef : c_coef -> float

(** for debug *)
val string_of_c_coef : c_coef -> string

(** operations on data type *)
val add_c_coef : c_coef -> c_coef -> c_coef
val uminus_c_coef : c_coef -> c_coef
val exp_c_coef : c_coef -> int -> c_coef
val mult_c_coef : c_coef -> c_coef -> c_coef
val div_c_coef : c_coef -> c_coef -> c_coef

(** ---------
    2. p_coef *)
(* e.g. \sum_i c_i p_i *)
type p_coef
val compare_p_coef : p_coef -> p_coef -> int 

(** setter *)
val zero_p_coef : p_coef
val unit_p_coef : p_coef
(* p_coef_of_float 0. -> zero_p_coef *)
(* p_coef_of_float 1. -> unit_p_coef *)
val p_coef_of_float : float -> p_coef
(* empty_param -> unit_p_coef *)
val p_coef_of_param : param -> p_coef
(* (0., p) -> zero_p_coef *)
val p_coef_of_float_param : float * param -> p_coef
(* empty: [] -> zero_p_coef *)
(* zero term: [(0., p1); (1., p); (0., p2)] -> [(1., p)] *)
(* same param: [(2., p1); (1., p); (3., p1)] -> [(1., p); (5., p1)] *)
(* no order : [(5., p); (1., p1)] = [(1., p); (5., p1)] *)
val p_coef_of_float_param_list : (float * param) list -> p_coef

(** getter *)
val float_param_list_of_p_coef : p_coef -> (float * param) list

(** operations on data type *)
val add_p_coef : p_coef -> p_coef -> p_coef
val uminus_p_coef : p_coef -> p_coef

val mult_float_with_p_coef : float -> p_coef -> p_coef


(** data type conversion functions *)
(* zero coef consistency *)
(* unit coef consistency *)
(* float consinstency *)
val p_coef_of_c_coef : c_coef -> p_coef

(** for debug *)
val string_of_p_coef : p_coef -> string
