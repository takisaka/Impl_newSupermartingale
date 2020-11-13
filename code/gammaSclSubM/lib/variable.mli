(** =================
    === variables ===
    ================= *)

type 'var valuation

(** setter *)
(* duplicate valuation is not allowed; e.g. [x -> 1.; x -> 2.] *)
val valuation_of_var_float_list : ('var * float) list -> 'var valuation
val update_of_valuation : 'var valuation -> 'var -> float -> 'var valuation

(** getter *)
val value_of : 'a -> 'a valuation -> float
val var_float_list_of_valuation : 'var valuation -> ('var * float) list

(** for debug *)
val string_of_valuation : ('var -> string) -> 'var valuation -> string

(** -----------
    1. variable *)
type v
val empty_v : v
val compare_v : v -> v -> int

val is_empty_v : v -> bool

val normalize_v : v -> v

(** setter *)
(* "" will be converted into empty_v *)
val v_of_string : string -> v
val v_of_string_temporary : string -> v

(** getter *)
val string_of_v : v -> string

(** ---------------------
    1.1. set of variables *)
type v_domain

(** setter *)
(* no duplication allowed. *)
(* e.g. ["x"; "x"; "y"] -> ["x"; "y"]*)
val v_domain_of_v_list : v list -> v_domain

(** getter *)
val v_list_of_v_domain : v_domain -> v list

val string_of_v_domain : v_domain -> string
val add_v_to_v_domain : v_domain -> v -> v_domain

(** -----------------------------------
    2. parameter (or decision variable) *)
type param
val empty_param : param
val compare_param : param -> param -> int

(** setter *)
(* "" will be converted into empty_v *)
val param_of_string : string -> param
val param_of_string_temporary : string -> param

(** getter *)
val string_of_param : param -> string

(** ----------------------
    2.1. set of parameters *)
type param_domain

(** setter *)
(* "" will be converted into empty_v *)
(* no duplication allowed. *)
(* e.g. ["x"; "x"; "y"] -> ["x"; "y"]*)
val param_domain_of_param_list : param list -> param_domain

(** getter *)
val param_list_of_param_domain : param_domain -> param list

val string_of_param_domain : param_domain -> string

val is_empty_param : param -> bool
val add_param_to_param_domain : param_domain -> param -> param_domain
