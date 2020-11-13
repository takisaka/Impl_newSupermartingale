open Util
open Variable
open Coefficient
open Polynomial
open Semialg
    
(* === slim data types === *)
type 'coef vector = 'coef list
let string_of_vector (string_of_coef: 'coef -> string) (vector: 'coef vector) : string =
  "(vector: " ^ string_of_list string_of_coef vector ^ ")"
let vector_of_list x = x
let vector_size x = List.length x

type 'coef matrix = 'coef vector list
let string_of_matrix (string_of_coef: 'coef -> string) (matrix: 'coef matrix) : string =
  "(matrix: " ^ string_of_list (string_of_vector string_of_coef) matrix ^ ")"

let transpose_vector (vector: 'coef vector) : 'coef matrix =
  List.map (fun elm -> [elm]) vector
let transpose_matrix (r_size : int) (matrix: 'coef matrix) : 'coef matrix =
  let rec length_n_matrix ret n c =
    if n <= 0 then ret else length_n_matrix (c::ret) (n-1) c in 
  if matrix = [] then length_n_matrix [] r_size [] else
  let tmp = List.map (fun _ -> []) (try List.hd matrix with _ -> failwith "List.hd in transpose_matrix") in
  List.fold_left
    (fun tmp vector -> List.map (fun (elm, sca) -> elm @ [sca]) (try (List.combine tmp vector) with _ -> failwith "List.combine in transpose_matrix"))
    tmp
    matrix

let c_coef_scalar_of_c_coef_ineq ineq =
  match List.filter is_scalar (c_coef_monomial_list_of_c_coef_polynomial @@ c_coef_polynomial_of_c_coef_ineq ineq) with
  | [] -> zero_c_coef
  | hd :: _ ->  fst hd

let wo_c_coef_scalar_of_c_coef_ineq v_list ineq =
  let polynomial = c_coef_polynomial_of_c_coef_ineq ineq in
  List.map
    (fun v ->
      try
        uminus_c_coef @@ fst @@ List.find (fun (_, v') -> v' = monomial_of_v_int v 1) (c_coef_monomial_list_of_c_coef_polynomial polynomial)
      with Not_found -> zero_c_coef)
    v_list

let split_c_coef_ineq (v_list : v list) (ineq: c_coef ineq) : c_coef vector * c_coef =
(*  let c_coef_vecotor_of_c_coef_ineq ineq = c_coef_list_of_c_coef_term @@ c_coef_term_of_c_coef_ineq ineq in *)
  if not (is_linear_ineq ineq) then (Printf.eprintf "Nonlinear formula in the assumption.\n"; raise (Invalid_argument ""));
  let vector = wo_c_coef_scalar_of_c_coef_ineq v_list ineq in
  let scalar = c_coef_scalar_of_c_coef_ineq ineq in
  (vector_of_list vector, scalar)


let split_c_coef_and_ineq_list (v_list : v list) (and_ineq_list: and_ineq_list) : c_coef matrix * c_coef vector =
  let and_ineq_list = c_coef_ineq_list_of_and_ineq_list and_ineq_list in
  List.split (List.map (fun p -> split_c_coef_ineq v_list p) and_ineq_list)


let p_coef_scalar_of_p_coef_ineq ineq =
  match List.filter is_scalar (p_coef_monomial_list_of_p_coef_polynomial @@ p_coef_polynomial_of_p_coef_ineq ineq) with
  | [] -> zero_p_coef
  | hd :: _ ->  fst hd

let wo_p_coef_scalar_of_p_coef_ineq v_list ineq =
  let polynomial = p_coef_polynomial_of_p_coef_ineq ineq in
  List.map
    (fun v ->
      try
        uminus_p_coef @@ fst @@ List.find (fun (_, v') -> v' = monomial_of_v_int v 1) (p_coef_monomial_list_of_p_coef_polynomial polynomial)
      with Not_found -> zero_p_coef)
    v_list

let split_p_coef_ineq (v_list : v list) (ineq: p_coef ineq) : p_coef vector * p_coef =
(*  let p_coef_vecotor_of_p_coef_ineq ineq = p_coef_list_of_p_coef_term @@ p_coef_term_of_p_coef_ineq ineq in *)
  (* check if the input is linear *)
  if not (is_linear_ineq ineq) then (Printf.eprintf "Nonlinear formula found in the consequence.\n"; raise (Invalid_argument ""));
  let vector = wo_p_coef_scalar_of_p_coef_ineq v_list ineq in
  let scalar = p_coef_scalar_of_p_coef_ineq ineq in
  (vector_of_list vector, scalar)

