open Util
open Variable
open Coefficient
open Pcfg
open Polynomial
open Semialg



type template = p_coef polynomial LM.t



let get_objective_func (template: template) (l_init: l) (x_init: v valuation) (v_domain: v_domain) : p_coef =
  let template_l_init = LM.find l_init template in
  (* \eta_l_init (\vec(x)_init)*)
  List.fold_left
    (fun current_p_coef (p_coef, monomial) ->
      add_p_coef
        current_p_coef
        (mult_float_with_p_coef (valuate_monomial x_init monomial) p_coef))
    zero_p_coef
    (p_coef_monomial_list_of_p_coef_polynomial template_l_init)


let get_pre_expectation (f: f) (template: template) : v list * (and_ineq_list * p_coef polynomial) list =
  match f with  
  | A (assgn, l_next) ->
     let p_coef_polynomial = LM.find l_next template in
     (match assgn with
      | Prob_assgn (v_i, distr) ->
         ([],
          [(true_and_ineq_list,
            substitute_vn_with_float_in_p_coef_polynomial
              v_i
              (raw_moment distr)
              p_coef_polynomial 
         )])
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
      [(true_and_ineq_list,
        List.fold_left
          add_p_coef_polynomial
          zero_p_coef_polynomial
          (List.map
             (fun (l_next, prob) ->
               let p_coef_polynomial = LM.find l_next template in
               mult_float_with_p_coef_polynomial prob p_coef_polynomial)
             fDist))])
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




