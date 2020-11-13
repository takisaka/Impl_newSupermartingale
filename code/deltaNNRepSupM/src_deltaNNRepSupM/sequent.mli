open Variable
open Coefficient
open Polynomial
open Semialg
open Pcfg
open Pre_expectation


val sequents_and_objective_func_of_reachability_problem : reachability_problem -> float option -> int -> template -> (string * (and_ineq_list * p_coef ineq) list) list * v list * param list * p_coef 
