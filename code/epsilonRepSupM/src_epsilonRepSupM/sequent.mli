open Variable
open Coefficient
open Polynomial
open Semialg
open Pcfg
open Pre_expectation

type const_type = Eq of float | Param | MatVar

val sequents_and_objective_func_of_reachability_problem : reachability_problem -> p_coef polynomial -> p_coef polynomial -> template -> (string * (and_ineq_list * p_coef ineq) list) list * v list
