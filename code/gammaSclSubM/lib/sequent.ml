open Util
open Variable
open Coefficient
open Pcfg
open Polynomial
open Semialg
open Pre_expectation



type template = p_coef polynomial LM.t
type gamma = Eq of float | Geq of float

let v_gamma = v_of_string_temporary "gamma"


let get_sm_const (pcfg_transition: pcfg_transition) (*tmpltype: tmpltype*) (gamma: c_coef polynomial) (gamma_range: and_ineq_list) (term_config: semialgmap) (invmap: semialgmap) (template: template) (l: l) : v list * (and_ineq_list * p_coef ineq) list =
  if LM.mem l pcfg_transition then
    let f = LM.find l pcfg_transition in
    let template_l = LM.find l template in
    let inv_and_ineq_list_list =
      and_ineq_list_list_of_semialg (try LM.find l invmap with Not_found -> true_semialg) in
    let term_semialg =
      try
        LM.find l term_config
      with
        Not_found -> false_semialg in
    let (v_list, pre_expectations) : v list * (and_ineq_list * p_coef polynomial) list = get_pre_expectation f template in
    let scale (pre_expectation_p_coef : p_coef polynomial) : p_coef polynomial =
      mult_p_coef_polynomial_with_c_coef_polynomial pre_expectation_p_coef gamma in
    (v_list,
     List.flatten @@
     List.map
       (fun negated_and_ineq_list ->
         List.flatten @@
         List.map
           (fun (guard_polytope, pre_expectation_p_coef) ->
             List.map
               (fun inv_polytope -> 
                 (and_ineq_list_of_and_ineq_list_list [gamma_range; negated_and_ineq_list; guard_polytope; inv_polytope],
                  p_coef_ineq_of_p_coef_polynomials (template_l, LEQ, scale pre_expectation_p_coef)))
               inv_and_ineq_list_list)
           pre_expectations)
       (and_ineq_list_list_of_semialg (not_semialg term_semialg))
    )
  else failwith "error: not_found in get_sm_const"


let get_leqone_const (gamma_range: and_ineq_list) (invmap:semialgmap) (template: template) (l: l) :(and_ineq_list * p_coef ineq) list =
  let template_l = LM.find l template in
  let inv_and_ineq_list_list =
    and_ineq_list_list_of_semialg (try LM.find l invmap with Not_found -> true_semialg) in
  List.map
    (fun inv_and_ineq_list -> (and_ineq_list_of_and_ineq_list_list [gamma_range;inv_and_ineq_list], p_coef_ineq_of_p_coef_polynomials (template_l, LEQ, p_coef_polynomial_of_p_coef @@ p_coef_of_float 1.)))
    inv_and_ineq_list_list


let get_geqzero_const (gamma_range: and_ineq_list) (invmap:semialgmap) (template: template) (l: l) :(and_ineq_list * p_coef ineq) list =
  let template_l = LM.find l template in
  let inv_and_ineq_list_list =
    and_ineq_list_list_of_semialg (try LM.find l invmap with Not_found -> true_semialg) in
  List.map
    (fun inv_and_ineq_list -> (and_ineq_list_of_and_ineq_list_list [gamma_range;inv_and_ineq_list], p_coef_ineq_of_p_coef_polynomials (template_l, GEQ, p_coef_polynomial_of_p_coef @@ p_coef_of_float (-1.))))
    inv_and_ineq_list_list
 

(** a compiler based on the theory developed in CAV2018 submission *)
let sequents_of_reachability_problem ((pcfg_transition, l_domain, v_domain), (* tmpltype, *) (l_init,init_valuation), invariant, term_config: reachability_problem) (gamma: c_coef polynomial) (gamma_range: and_ineq_list) (template: template) : (string * (and_ineq_list * p_coef ineq) list) list * v list =
  let new_vars_list, sm_const_output =
    (fun (x,y) -> (x,List.flatten y)) @@
    List.split @@
    List.map
      (get_sm_const pcfg_transition gamma gamma_range term_config invariant template)
      (l_list_of_l_domain l_domain) in
  let leqone_const_output =
    List.flatten @@
    List.map
      (get_leqone_const gamma_range invariant template)
      (l_list_of_l_domain l_domain) in
  let geqzero_const_output =
    List.flatten @@
    List.map
      (get_geqzero_const gamma_range invariant template)
      (l_list_of_l_domain l_domain) in 
  let new_vars = List.flatten new_vars_list in
  ([("leq one constraints", leqone_const_output);
(*    ("geq zero constraints", geqzero_const_output); *)
    ("supermartingale constraints", sm_const_output)],
   new_vars)
