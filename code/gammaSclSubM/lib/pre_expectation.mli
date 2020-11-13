open Variable
open Coefficient
open Polynomial
open Semialg
open Pcfg

type template = p_coef polynomial LM.t

val get_objective_func : template -> l -> v valuation -> v_domain -> p_coef

val get_pre_expectation : f -> template -> v list * (and_ineq_list * p_coef polynomial) list
