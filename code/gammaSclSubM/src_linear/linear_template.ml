open Util
open Variable
open Coefficient
open Polynomial
open Semialg
open Pcfg
open Pre_expectation


let generate_param_list (v_domain : v_domain) (l: l) : param list =
  let param_name v l = string_of_v v ^ "_" ^ string_of_l l in
  let v_list = (empty_v :: v_list_of_v_domain v_domain) in
  List.map (fun v -> param_of_string (param_name v l)) v_list

let generate_p_coef_term (v_domain : v_domain) (param_list: param list): p_coef polynomial =
  let v_list = empty_v :: v_list_of_v_domain v_domain in
  p_coef_polynomial_of_p_coef_monomial_list @@
  List.map2 (fun p v -> p_coef_of_param p, monomial_of_v_int v 1) param_list v_list

let generate_linear_template (l_domain : l_domain) (v_domain : v_domain) : template * param_domain =
  let l_list = l_list_of_l_domain l_domain in
  let (template, param_list)=
    List.fold_left
    (fun (template, param_list) l ->
      let new_param_list = generate_param_list v_domain l in
      (LM.add l (generate_p_coef_term v_domain new_param_list) template,
       param_list@new_param_list))
    (LM.empty,[])
    l_list 
  in
  (template, param_domain_of_param_list param_list)



