open Util
open Variable
open Coefficient
open Pcfg
open Polynomial
open Semialg
open Pre_expectation



type template = p_coef polynomial LM.t

let param_delta = param_of_string_temporary "delta"


let get_sm_const (pcfg_transition: pcfg_transition) (*tmpltype: tmpltype*) (delta: p_coef) (term_config: semialgmap) (invmap: semialgmap) (template: template) (l: l) : v list * (and_ineq_list * p_coef ineq) list =
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
      add_p_coef_polynomial pre_expectation_p_coef (p_coef_polynomial_of_p_coef (mult_float_with_p_coef (-1.) delta)) in
    (v_list,
     List.flatten @@
     List.map
       (fun negated_and_ineq_list ->
         List.flatten @@
         List.map
           (fun (guard_polytope, pre_expectation_p_coef) ->
             List.map
               (fun inv_polytope -> 
                 (and_ineq_list_of_and_ineq_list_list [negated_and_ineq_list; guard_polytope; inv_polytope],
                  p_coef_ineq_of_p_coef_polynomials (template_l, GEQ, scale pre_expectation_p_coef)))
               inv_and_ineq_list_list)
           pre_expectations)
       (and_ineq_list_list_of_semialg (not_semialg term_semialg))
    )
  else failwith "error: not_found in get_sm_const"


let get_geqone_const (invmap:semialgmap) (term_config: semialgmap) (template: template) (l: l) :(and_ineq_list * p_coef ineq) list =
  let template_l = LM.find l template in
  let inv_and_ineq_list_list =
    and_ineq_list_list_of_semialg (try LM.find l invmap with Not_found -> true_semialg) in
  let term_and_ineq_list_list = 
    and_ineq_list_list_of_semialg (try LM.find l term_config with Not_found -> false_semialg) in
  List.flatten @@
  List.map
    (fun term_and_ineq_list ->
      List.map
        (fun inv_and_ineq_list ->
          (and_and_ineq_list term_and_ineq_list inv_and_ineq_list, p_coef_ineq_of_p_coef_polynomials (template_l, GEQ, p_coef_polynomial_of_p_coef @@ p_coef_of_float 1.)))
        inv_and_ineq_list_list
    )
    term_and_ineq_list_list


let get_geqzero_const (invmap:semialgmap) (template: template) (l: l) :(and_ineq_list * p_coef ineq) list =
  let template_l = LM.find l template in
  let inv_and_ineq_list_list =
    and_ineq_list_list_of_semialg (try LM.find l invmap with Not_found -> true_semialg) in
  List.map
    (fun inv_and_ineq_list -> (and_ineq_list_of_and_ineq_list_list [inv_and_ineq_list], p_coef_ineq_of_p_coef_polynomials (template_l, GEQ, p_coef_polynomial_of_p_coef @@ p_coef_of_float (0.))))
    inv_and_ineq_list_list
 

(** a compiler based on the theory developed in CAV2018 *)
let sequents_and_objective_func_of_reachability_problem ((pcfg_transition, l_domain, v_domain), (* tmpltype, *) (l_init,init_valuation), invariant, term_config: reachability_problem) (delta: float option) (nn: int) (template: template) : (string * (and_ineq_list * p_coef ineq) list) list * v list * param list * p_coef =
  let (delta, delta_geqzero_const_output, new_params) : p_coef * (and_ineq_list * p_coef ineq) list * param list =
    match delta with
    | Some x -> (p_coef_of_float x, [], [])
    | None ->
       let delta = p_coef_of_param param_delta in
       (delta,
        [(true_and_ineq_list,
          p_coef_ineq_of_p_coef_polynomials (p_coef_polynomial_of_p_coef delta, GEQ, p_coef_polynomial_of_p_coef @@ p_coef_of_float (0.))
    )],
        [param_delta]
       ) in

  let new_vars_list, sm_const_output =
    (fun (x,y) -> (x,List.flatten y)) @@
    List.split @@
    List.map
      (get_sm_const pcfg_transition delta term_config invariant template)
      (l_list_of_l_domain l_domain) in

  let geqone_const_output =
    List.flatten @@
    List.map
      (get_geqone_const invariant term_config template)
      (l_list_of_l_domain l_domain) in
  let geqzero_const_output =
    List.flatten @@
    List.map
      (get_geqzero_const invariant template)
      (l_list_of_l_domain l_domain) in
  let objective_func =
    let objective_func_temp = get_objective_func template l_init init_valuation v_domain in
    add_p_coef objective_func_temp (mult_float_with_p_coef (float_of_int nn) delta) in
  let new_vars = List.flatten new_vars_list in
  ([("delta geq zero", delta_geqzero_const_output);
    ("leq one constraints", geqone_const_output);
    ("geq zero constraints", geqzero_const_output); 
    ("supermartingale constraints", sm_const_output)],
   new_vars,
   new_params,
   objective_func
   )
