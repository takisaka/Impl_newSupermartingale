open Variable
open Coefficient
open Polynomial
open Matrix
open Pcfg
open Pre_expectation


(* val string_of_output_elm : lp_constraint -> string
 * val string_of_output : lp_constraint list -> string *)

(** a compiler based on the theory developed in CAV2018 *)
(* val get_sm_const : pcfg_transition -> config -> invariant -> eta -> l -> lp_constraint option list
 * val get_nonneg_const : invariant -> eta -> l -> lp_constraint
 * val get_scaling_const : config -> eta -> l -> lp_constraint option *)

val generate_linear_template : l_domain -> v_domain -> template * param_domain

