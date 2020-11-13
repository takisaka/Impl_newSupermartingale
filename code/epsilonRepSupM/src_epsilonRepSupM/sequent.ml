open Util
open Variable
open Coefficient
open Pcfg
open Polynomial
open Semialg
open Pre_expectation



type template = p_coef polynomial LM.t

type const_type = Eq of float | Param | MatVar

let get_range (distr: distr) : float * float = 
  match distr with
  | Unif (param1, param2) -> (param1, param2)
  | Unshifted_geom _ -> (1., infinity) (* the description "( inf )" in the .m file for c_3 was the initial 3 letters of "infinity" taken from here. *)
  | Shifted_geom _ -> (0., infinity)
  | Norm (param1, param2) -> (-.infinity, infinity)
  | Exp param -> (0., infinity)
  | Disc discrete_distr ->
     let a, s =
       match discrete_distr with
       | [] -> failwith "empty discrete distribution"
       | (a,_)::s -> (a, s) in
     List.fold_left
       (fun (ret1,ret2) (n,_) -> (min ret1 n, max ret2 n))
       (a, a)
       s

let get_next_values_list (f: f) (template: template) : v list * (and_ineq_list * p_coef polynomial) list =
  match f with  
  | A (assgn, l_next) ->
     let p_coef_polynomial = LM.find l_next template in
     (match assgn with
      | Prob_assgn (v_i, distr) ->
         let var_prob : v = v_of_string_temporary "prob" in
         let (ret1, ret2) = get_range distr in
         (*2020/11/08 bugfix*)
         let new_c_coef_and_ineq_list =
           if ret2 = infinity then
             and_ineq_list_of_c_coef_ineq_list
               [c_coef_ineq_of_c_coef_polynomials (c_coef_polynomial_of_monomial (monomial_of_v_int var_prob 1), GEQ, c_coef_polynomial_of_c_coef (c_coef_of_float ret1))]              
           else
             and_ineq_list_of_c_coef_ineq_list
               [c_coef_ineq_of_c_coef_polynomials (c_coef_polynomial_of_monomial (monomial_of_v_int var_prob 1), GEQ, c_coef_polynomial_of_c_coef (c_coef_of_float ret1));
               c_coef_ineq_of_c_coef_polynomials (c_coef_polynomial_of_monomial (monomial_of_v_int var_prob 1), LEQ, c_coef_polynomial_of_c_coef (c_coef_of_float ret2))] 
         in
         (*
         let new_c_coef_and_ineq_list =
           and_ineq_list_of_c_coef_ineq_list
             [c_coef_ineq_of_c_coef_polynomials (c_coef_polynomial_of_monomial (monomial_of_v_int var_prob 1), GEQ, c_coef_polynomial_of_c_coef (c_coef_of_float ret1));
             c_coef_ineq_of_c_coef_polynomials (c_coef_polynomial_of_monomial (monomial_of_v_int var_prob 1), LEQ, c_coef_polynomial_of_c_coef (c_coef_of_float ret2))] in
         *)
         let new_p_coef_polynomial =
           substitute_v_with_v_in_p_coef_polynomial
             v_i
             var_prob
             p_coef_polynomial
         in
         ([var_prob],
         [(new_c_coef_and_ineq_list, new_p_coef_polynomial)])
      | Nondet_assgn semialg ->
         let var_ndet (n : int) : v = v_of_string_temporary ("ndet_" ^ string_of_int n) in
         let (new_v_list_list, pre_expectation) =
           List.split @@ 
             List.map
               (fun and_ineq_list ->
                 let v_list = remove_duplicates @@ List.filter (fun v -> not (is_empty_v v)) @@ v_list_of_and_ineq_list and_ineq_list in
                 let vv_list =
                   snd @@ List.fold_left (fun (n,vv_list) v -> (n+1,(v,var_ndet n)::vv_list)) (0,[]) v_list in
                 let new_c_coef_and_ineq_list =
                   List.fold_left
                     (fun and_ineq_list (v,v') ->
                       substitute_v_with_v_in_and_ineq_list
                         v
                         v'
                         and_ineq_list)
                     and_ineq_list
                     vv_list in
                 let new_p_coef_polynomial =
                   List.fold_left
                     (fun p_coef_polynomial (v,v') ->
                       substitute_v_with_v_in_p_coef_polynomial
                         v
                         v'
                         p_coef_polynomial)
                     p_coef_polynomial
                     vv_list in
                 (List.map snd vv_list, (new_c_coef_and_ineq_list, new_p_coef_polynomial)))
               (and_ineq_list_list_of_semialg semialg) in
         (remove_duplicates (List.flatten new_v_list_list), pre_expectation)
      | Det_assgn (v_i, c_coef_polynomial) ->
         ([],
          [(true_and_ineq_list,
            substitute_v_with_c_coef_polynomial_in_p_coef_polynomial
              v_i
              c_coef_polynomial
              p_coef_polynomial)])
     )
  | P fDist ->
     ([],
      List.map
        (fun (l_next, prob) -> (true_and_ineq_list, LM.find l_next template))
        fDist)
  | ND guard_l_list ->
     ([],
      List.flatten @@
        List.map
          (fun (c_coef_semialg, l_next) ->
            let p_coef_polynomial = LM.find l_next template in
            List.map
              (fun and_ineq_list -> (and_ineq_list, p_coef_polynomial))
              (and_ineq_list_list_of_semialg c_coef_semialg)
          )
          guard_l_list) 



let get_sm_const (pcfg_transition: pcfg_transition) (epsilon: p_coef polynomial) (term_config: semialgmap)  (invmap: semialgmap) (template: template) (l: l) : v list * (and_ineq_list * p_coef ineq) list =
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
    let add_epsilon (pre_expectation_p_coef : p_coef polynomial) : p_coef polynomial =
      add_p_coef_polynomial pre_expectation_p_coef epsilon in
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
                  p_coef_ineq_of_p_coef_polynomials (template_l, GEQ, add_epsilon pre_expectation_p_coef)))
               inv_and_ineq_list_list)
           pre_expectations)
       (and_ineq_list_list_of_semialg (not_semialg term_semialg))
    )
  else failwith "error: not_found in get_sm_const"


let get_geqzero_const (term_config: semialgmap) (invmap:semialgmap) (template: template) (l: l) :(and_ineq_list * p_coef ineq) list =
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
          (and_and_ineq_list term_and_ineq_list inv_and_ineq_list, p_coef_ineq_of_p_coef_polynomials (template_l, GEQ, p_coef_polynomial_of_p_coef @@ p_coef_of_float 0.)))
        inv_and_ineq_list_list
    )
    term_and_ineq_list_list

let get_kappa_bounded_const (pcfg_transition: pcfg_transition) (kappa: p_coef polynomial) (invmap: semialgmap) (template: template) (l: l) : v list * (and_ineq_list * p_coef ineq) list =
  if LM.mem l pcfg_transition then
    let f = LM.find l pcfg_transition in
    let template_l = LM.find l template in
    let inv_and_ineq_list_list =
      and_ineq_list_list_of_semialg (try LM.find l invmap with Not_found -> true_semialg) in
    let (v_list, next_values_list) : v list * (and_ineq_list * p_coef polynomial) list = get_next_values_list f template in
    let add_kappa (pre_expectation_p_coef : p_coef polynomial) : p_coef polynomial =
      add_p_coef_polynomial pre_expectation_p_coef kappa in
    (v_list,
     List.flatten @@
     List.map
       (fun (guard_polytope, next_value_p_coef) ->
         List.flatten @@
         List.map
           (fun inv_polytope -> 
             [(and_ineq_list_of_and_ineq_list_list [guard_polytope; inv_polytope],
              p_coef_ineq_of_p_coef_polynomials (add_kappa template_l, GEQ, next_value_p_coef));
              (and_ineq_list_of_and_ineq_list_list [guard_polytope; inv_polytope],
              p_coef_ineq_of_p_coef_polynomials (template_l, LEQ, add_kappa next_value_p_coef))])
           inv_and_ineq_list_list)
       next_values_list)
  else failwith "error: not_found in get_kappa_bounded_const"



(** a compiler based on the theory developed in CAV2018 *)
let sequents_and_objective_func_of_reachability_problem ((pcfg_transition, l_domain, v_domain), (* tmpltype, *) (l_init,init_valuation), invariant, term_config: reachability_problem) (epsilon: p_coef polynomial) (kappa: p_coef polynomial)  (template: template) : (string * (and_ineq_list * p_coef ineq) list) list * v list =
  let new_vars_list, sm_const_output =
    (fun (x,y) -> (x,List.flatten y)) @@
    List.split @@
    List.map
      (get_sm_const  pcfg_transition epsilon term_config invariant template)
      (l_list_of_l_domain l_domain) in
  let geqzero_const_output =
    List.flatten @@
    List.map
      (get_geqzero_const term_config invariant template)
      (l_list_of_l_domain l_domain) in
  let new_vars_list', kappa_bounded_const_output =
    (fun (x,y) -> (x,List.flatten y)) @@
    List.split @@
    List.map
      (get_kappa_bounded_const pcfg_transition kappa invariant template)
      (l_list_of_l_domain l_domain) in
  let new_vars = List.flatten (new_vars_list@new_vars_list') in
  ([("geq zero constraints", geqzero_const_output); ("kappa bounded constraints", kappa_bounded_const_output); ("supermartingale constraints", sm_const_output)],
   new_vars)
