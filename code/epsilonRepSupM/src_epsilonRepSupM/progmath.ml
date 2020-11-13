open Util
open Variable
open Coefficient
open Matrix
open Pcfg
open Linear_template
open Pre_expectation
open Sequent
open Polynomial
open Semialg

type progmath = string
type lp_constraint = (c_coef matrix * c_coef vector) * (p_coef vector * p_coef)

let epsilon_param = param_of_string_temporary "epsilon"
let kappa_param = param_of_string_temporary "kappa"
let epsilon_param_string = string_of_param epsilon_param
let kappa_param_string = string_of_param kappa_param


let progmath_of_v = string_of_v
let progmath_of_param = string_of_param
let progmath_of_float (f: float) : progmath =
  let fs = string_of_float f in
  if String.get fs (String.length fs - 1) = '.' then
    "(" ^ fs ^ "0" ^ ")"
  else
    "(" ^ fs ^ ")"
let progmath_of_int = string_of_int

let progmath_of_c_coef : c_coef -> progmath =
  fun c_coef -> progmath_of_float @@ float_of_c_coef c_coef

let progmath_of_p_coef : p_coef -> progmath =
  fun p_coef ->
    let progmath_of_float_param (f, p) =
      if p = empty_param then progmath_of_float f
      else progmath_of_float f ^ "*" ^ progmath_of_param p
    in
    let float_param_list = float_param_list_of_p_coef p_coef in
  if List.length float_param_list = 0 then "0" else    
    "(" ^ string_of_list_infix_string progmath_of_float_param float_param_list "+" ^ ")"

let put_plus lst = string_of_list_infix_string (fun x -> x) lst "+"
let put_times lst = string_of_list_infix_string (fun x -> x) lst "*"

let is_trivially_true_lp_constraint (((a_mat, b_vec), _) : lp_constraint) : bool =
  List.exists
    (fun (a_row, b_elem) ->
      List.for_all (fun a_elem -> float_of_c_coef a_elem = 0.) a_row &&
      float_of_c_coef b_elem < 0.)
    (List.combine a_mat b_vec)

let progmath_of_c_coef_vec_string_list_mult (a_row: c_coef vector) (ys: string list) : string =
  if List.length a_row = 0 then "0" else
  let tmp =
    List.map
      (fun (a_elm, y_elm) -> progmath_of_c_coef a_elm ^ " * " ^ y_elm)
      (try (List.combine a_row ys) with _ -> failwith "List.combine in progmath_of_c_coef_vec_string_list_mult")
  in
  put_plus tmp

let cnt_id = ref 0
let such_that_y_list_of_output_elm (((a_mat, b_vec), (c_vec, d_sca)) : lp_constraint) : string list * string list =
  let elm_id = "a" ^ string_of_int !cnt_id in
  let () = (cnt_id := !cnt_id + 1) in

  let generate_y (cnt_id: string) (length: int) : string list =
    let ret = ref [] in
    for i = 1 to length do
      ret := !ret @ ["_y" ^ string_of_int i ^ "_" ^ cnt_id]
    done;
    !ret in
  let y = generate_y (string_of_int !cnt_id) (List.length b_vec) in
(*print_string ("\n"^ string_of_int (List.length b_vec) ^ "::");
  string_of_vector string_of_c_coef b_vec;
  print_string "\n";
  List.iter print_string y;*)

  (* non-negativeness y >= 0 *)
  let get_pos_lines elm_id y = List.map
      (fun y_elm ->
         let header =
           let title = elm_id ^ "_" ^ y_elm ^ "_pos" in
           "s.t. " ^  title ^ ": " in
         let body = y_elm ^ " >= 0;" in
         header ^ body
      )
      y in

  (* equality A^t y = c *)
  let get_eq_lines elm_id y =
    let a_t_mat = transpose_matrix (vector_size c_vec) a_mat in
    let cnt = ref 0 in
    List.map
      (fun (a_row, c_elm) ->
         let header =
           let title = elm_id ^ "_" ^ string_of_int !cnt ^ "_eq" in
           "s.t. " ^ title ^ ": " in
         let body =
           let a_t_y = progmath_of_c_coef_vec_string_list_mult a_row y in
           let c = progmath_of_p_coef c_elm in
           a_t_y ^ " = " ^ c ^ ";" in
         cnt := !cnt + 1; header ^ body
      )
      (try List.combine a_t_mat c_vec with _ -> failwith ("List.combine in get_eq_lines" ^ string_of_matrix string_of_c_coef a_t_mat ^ " vs " ^ string_of_vector string_of_p_coef c_vec)) in

  (* inequality  b^t y <= d *)
  let get_ineq_lines elm_id y =
    let header =
      let title = elm_id ^ "_ineq" in
      "s.t. " ^ title ^ ": " in
    let body =
      let b_t_y = progmath_of_c_coef_vec_string_list_mult b_vec y in
      let d = progmath_of_p_coef d_sca in
      b_t_y ^ " <= " ^ d ^ ";" in
    [header ^ body] in

  (List.fold_left
     (fun b f -> b @ f elm_id y)
     []
     [get_pos_lines; get_eq_lines; get_ineq_lines],
   y)

let progmath_of_mat_vecs (lp_constraints_list: (string * lp_constraint list) list) : string * string list=
  let _ = (cnt_id := 0) in
  let progmath_of_such_that_seed_seed such_that_seed_seed =
    List.fold_left (fun base elm -> base ^ elm ^ "\n") "" such_that_seed_seed in
  List.fold_left
    (fun (such_that_seed, y_seed) (s,lp_constraints) ->
      let (such_that_seed_seed_list, y_seed_new_list) = List.split @@ List.map such_that_y_list_of_output_elm lp_constraints in
      let such_that_seed_new =
        List.fold_left
          (fun str such_that_seed_seed ->
            str  ^ progmath_of_such_that_seed_seed such_that_seed_seed ^ "\n")
          ""
          such_that_seed_seed_list
      in
      (such_that_seed ^ "/* " ^ s ^ " */" ^ "\n" ^ such_that_seed_new, y_seed@(List.flatten y_seed_new_list)))
    ("",[])
    lp_constraints_list 

let obj_func_of_float f =
  "(" ^ string_of_float f ^ "0" ^ ")"

let obj_func_of_p_coef (p_coef : p_coef) : string =
  let obj_func_of_float_param (f, p) =
    if is_empty_param p then obj_func_of_float f
    else obj_func_of_float f ^ "*" ^ string_of_param p
  in
  let float_param_list = float_param_list_of_p_coef p_coef in
  "(" ^ string_of_list_infix_string obj_func_of_float_param float_param_list "+" ^ ")"



let progmath_of_reachability_problem (((pcfg_transition, l_domain, v_domain), (l_init,init_valuation), invariant, term_config) as problem: reachability_problem) (epsilon: float option) (kappa: const_type) : string =
  let template, template_param_domain = generate_linear_template l_domain v_domain in

  let kappa_p_coef_polynomial, const_var_list, template_param_domain, objective_func = match kappa with
    | MatVar ->
       (p_coef_polynomial_of_p_coef (p_coef_of_param kappa_param),
        [kappa_param],
        template_param_domain,
        get_objective_func template l_init init_valuation v_domain
       )
    | Param ->
       (p_coef_polynomial_of_p_coef (p_coef_of_param kappa_param),
        [],
        add_param_to_param_domain template_param_domain kappa_param,
        p_coef_of_param kappa_param
       )
    | Eq s ->
       (p_coef_polynomial_of_p_coef @@ p_coef_of_float s,
        [],
        template_param_domain,
        get_objective_func template l_init init_valuation v_domain
       )  in
  let epsilon_p_coef_polynomial, const_var_list = match epsilon with
    | None -> (p_coef_polynomial_of_p_coef (p_coef_of_param epsilon_param), epsilon_param::const_var_list)
    | Some s -> (p_coef_polynomial_of_p_coef @@ p_coef_of_float s, const_var_list) in


  let sequents, new_vars_list = sequents_and_objective_func_of_reachability_problem problem epsilon_p_coef_polynomial kappa_p_coef_polynomial template in

  let v_list_order_fixed : v list =
    remove_duplicates @@
    List.filter (fun v -> not (is_empty_v v)) @@
    List.map
      normalize_v
      (new_vars_list @ (v_list_of_v_domain v_domain)) in
  let lp_constraints_list : (string * lp_constraint list) list =
    List.map
      (fun (constraints_name, sequent) ->
        (constraints_name,
         List.map 
           (fun (c_coef_polytope, p_coef_ineq) ->
             (split_c_coef_and_ineq_list v_list_order_fixed c_coef_polytope,
              split_p_coef_ineq v_list_order_fixed p_coef_ineq))
           sequent))
      sequents in
  let lp_constraints_list = List.map (fun (s,l) -> (s, List.filter (fun x -> not @@ is_trivially_true_lp_constraint x) l)) lp_constraints_list in 
  let template_var_list = List.map string_of_param @@ param_list_of_param_domain template_param_domain in
  let objective_func_string = obj_func_of_p_coef objective_func in
  let such_that, ys = progmath_of_mat_vecs lp_constraints_list in
  let var_generate x_list = List.fold_left (fun base x -> base ^ "var " ^ x ^ ";\n") "" x_list in
  let header1 = if List.length const_var_list > 0 then "param " ^ string_of_list_infix_string string_of_param const_var_list " " ^ ";\n" else "" in
  let header2 = var_generate (ys @ template_var_list) in
  let init_nonpos = obj_func_of_p_coef (get_objective_func template l_init init_valuation v_domain) in
  (*header1 ^ header2 ^ "\n" ^ "minimize prob_bound: " ^ objective_func_string ^ ";\n" ^ such_that ^ "end;" ^ "\n"*)
  header1 ^ header2 ^ "\n" ^ "minimize prob_bound: " ^ objective_func_string ^ ";\n" ^ "s.t. nonpos: "^ init_nonpos ^ " <= 0;\n" ^ such_that ^ "end;" ^ "\n"
