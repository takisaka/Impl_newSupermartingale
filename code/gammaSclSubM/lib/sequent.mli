open Variable
open Coefficient
open Polynomial
open Semialg
open Pcfg
open Pre_expectation


val sequents_of_reachability_problem : reachability_problem -> c_coef polynomial -> and_ineq_list -> template -> (string * (and_ineq_list * p_coef ineq) list) list * v list
