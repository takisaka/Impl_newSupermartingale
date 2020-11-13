open Util
open Variable
open Coefficient
open Polynomial

(* === inequality, semialgebraic set over coefficient === *)
(* inequality, semialg cannot be minused due to its semantics *)
(* === form polynomials from inequality, semialg === *)
type bop = LEQ | GEQ
let string_of_bop = function | LEQ -> "LEQ" | GEQ -> "GEQ"

(* ineq *)
type 'coef ineq = 'coef polynomial
(* IMPLEMENTATIN NOTE: ineq is interpreted as [ polynomial >= 0] !! *)
(* NOTE: we ignore the distinction of strict inequality and weak inequlatiy !! *)


let substitute_v_with_v_in_c_coef_ineq = substitute_v_with_v_in_c_coef_polynomial
let substitute_v_with_v_in_p_coef_ineq = substitute_v_with_v_in_p_coef_polynomial

let v_list_of_ineq = v_list_of_polynomial

let string_of_c_coef_ineq (ineq: c_coef ineq) : string =
  "(ineq: " ^ string_of_c_coef_polynomial ineq ^ ")"
let true_c_coef_ineq : c_coef ineq = unit_c_coef_polynomial (* 1 >= 0*)
(* not (a >= 0) = a <= 0 ~= -a >= 0*)
let not_c_coef_ineq = uminus_c_coef_polynomial
let false_c_coef_ineq : c_coef ineq = not_c_coef_ineq true_c_coef_ineq
let c_coef_ineq_of_c_coef_polynomials (t1, bop, t2 : c_coef polynomial * bop * c_coef polynomial): c_coef ineq =
  match bop with
    LEQ -> add_c_coef_polynomial (uminus_c_coef_polynomial t1) t2 (* t1 <= t2 <=> t2 - t1 >= 0 *)
  | GEQ -> add_c_coef_polynomial t1 (uminus_c_coef_polynomial t2) (* t1 >= t2 <=> t1 - t2 >= 0 *)
let c_coef_polynomial_of_c_coef_ineq x = x
let compare_c_coef_ineq : c_coef ineq -> c_coef ineq -> int =
  fun c_ineq1 c_ineq2 ->
    let c_poly1, c_poly2 = c_coef_polynomial_of_c_coef_ineq c_ineq1, c_coef_polynomial_of_c_coef_ineq c_ineq2 in
    compare_c_coef_polynomial c_poly1 c_poly2

let string_of_p_coef_ineq (ineq: p_coef ineq) : string =
  "(ineq: " ^ string_of_p_coef_polynomial ineq ^ ")"
let true_p_coef_ineq : p_coef ineq = unit_p_coef_polynomial (* 1 >= 0*)
let not_p_coef_ineq = uminus_p_coef_polynomial
let false_p_coef_ineq : p_coef ineq = not_p_coef_ineq true_p_coef_ineq
let p_coef_ineq_of_p_coef_polynomials (t1, bop, t2 : p_coef polynomial * bop * p_coef polynomial): p_coef ineq =
  match bop with
    LEQ -> add_p_coef_polynomial (uminus_p_coef_polynomial t1) t2 (* t1 <= t2 <=> t2 - t1 >= 0 *)
  | GEQ -> add_p_coef_polynomial t1 (uminus_p_coef_polynomial t2) (* t1 >= t2 <=> t1 - t2 >= 0 *)
let p_coef_polynomial_of_p_coef_ineq x = x
let compare_p_coef_ineq : p_coef ineq -> p_coef ineq -> int =
  fun p_ineq1 p_ineq2 ->
    let p_poly1, p_poly2 = p_coef_polynomial_of_p_coef_ineq p_ineq1, p_coef_polynomial_of_p_coef_ineq p_ineq2 in
    compare_p_coef_polynomial p_poly1 p_poly2


(* disjunction normal form *)
type and_ineq_list = c_coef ineq list
let true_and_ineq_list = []
let false_and_ineq_list = [false_c_coef_ineq]


let is_trivially_true_c_coef_ineq c_coef_ineq =
  if not (is_scalar_polynomial c_coef_ineq) then false else
  let v = List.fold_left
    (fun ret (c_coef, _) -> ret +. float_of_c_coef c_coef)
    0.
    (c_coef_monomial_list_of_c_coef_polynomial (c_coef_polynomial_of_c_coef_ineq c_coef_ineq)) in
  v >= 0.

let is_trivially_false_c_coef_ineq c_coef_ineq =
  if not (is_scalar_polynomial c_coef_ineq) then false else
  let v = List.fold_left
    (fun ret (c_coef, _) -> ret +. float_of_c_coef c_coef)
    0.
    (c_coef_monomial_list_of_c_coef_polynomial (c_coef_polynomial_of_c_coef_ineq c_coef_ineq)) in
  v < 0.


(** setter *)
let normalize_and_ineq_list and_ineq_list =
  let and_ineq_list = List.sort compare_c_coef_ineq @@ remove_duplicates @@ List.filter (fun x -> not (is_trivially_true_c_coef_ineq x)) and_ineq_list in
  if and_ineq_list = [true_c_coef_ineq] then true_and_ineq_list
  else if List.exists is_trivially_false_c_coef_ineq and_ineq_list then false_and_ineq_list
  else and_ineq_list

let and_ineq_list_of_c_coef_ineq_list : c_coef ineq list -> and_ineq_list =
  fun ineq_list ->
  normalize_and_ineq_list ineq_list

let and_ineq_list_of_and_ineq_list_list list = normalize_and_ineq_list (List.flatten list)

  
(** getter *)
let c_coef_ineq_list_of_and_ineq_list and_ineq_list = and_ineq_list

(** operations on data type *)
let substitute_v_with_v_in_and_ineq_list (v: v) (v':v) (and_ineq_list: and_ineq_list) : and_ineq_list =
  normalize_and_ineq_list @@ List.map (fun ineq -> substitute_v_with_v_in_c_coef_ineq v v' ineq ) and_ineq_list

let v_list_of_and_ineq_list (and_ineq_list: and_ineq_list): v list =
  List.flatten @@ List.map (fun ineq -> v_list_of_ineq ineq) and_ineq_list


let add_ineq_to_and_ineq_list : c_coef ineq -> and_ineq_list -> and_ineq_list =
  fun ineq list -> normalize_and_ineq_list @@ ineq :: list

let and_and_ineq_list : and_ineq_list -> and_ineq_list -> and_ineq_list =
  fun list1 list2 -> normalize_and_ineq_list @@ list1 @ list2

let rec compare_and_ineq_list list1 list2 =
  let c_ineq_list1, c_ineq_list2 = c_coef_ineq_list_of_and_ineq_list list1, c_coef_ineq_list_of_and_ineq_list list2 in
  (* lexicographic order *)
  match c_ineq_list1, c_ineq_list2 with
  | [], [] -> 0
  (* 2 < 2 + 1. p1  *)
  | [], _::_ -> compare 0 1
  (* 2 + 1. p1 < 2  *)
  | _::_, [] -> compare 1 0
  (* 2 + 1. p1 + 3. p3 < 2 + 1. p1 + 2. p4 if 3. p3 < 2. p4 *)
  | c_ineq1::rest1, c_ineq2::rest2 ->
    let candidate = compare_c_coef_ineq c_ineq1 c_ineq2 in
    if candidate = 0 then compare_and_ineq_list (and_ineq_list_of_c_coef_ineq_list rest1) (and_ineq_list_of_c_coef_ineq_list rest2)
    else candidate

let string_of_and_ineq_list and_ineq_list = string_of_list string_of_c_coef_ineq and_ineq_list

(* semialg is of disjunction normal form; \/ /\ \phi_i *)
type semialg = and_ineq_list list
let true_semialg = [true_and_ineq_list]
let false_semialg = []



(** setter *)
let normalize_semialg semialg = List.sort compare_and_ineq_list @@ remove_duplicates semialg
let semialg_of_and_ineq_list : and_ineq_list -> semialg =
  fun and_ineq_list -> normalize_semialg [and_ineq_list]

(** getter *)
let and_ineq_list_list_of_semialg semialg = semialg  

(** operations on data type *)
let v_list_of_semialg (semialg: semialg): v list =
  List.flatten @@ List.map (fun and_ineq_list -> v_list_of_and_ineq_list and_ineq_list) semialg

let add_and_ineq_list_to_semialg : and_ineq_list -> semialg -> semialg =
  fun list semialg -> normalize_semialg @@ list :: semialg


let not_and_ineq_list and_ineq_list =
  normalize_semialg @@ List.map (fun c_ineq -> [not_c_coef_ineq c_ineq]) (c_coef_ineq_list_of_and_ineq_list and_ineq_list)

let or_semialg semialg1 semialg2 = normalize_semialg @@ semialg1 @ semialg2
let or_semialg_list semialg_list = normalize_semialg @@ List.flatten semialg_list
(* definition is by the following distributive law *)
(* (\/i /\ Ai) /\ B = \/i (/\ Ai /\ B) *)
let and_semialg_and_ineq_list semialg arg_and_ineq_list =
  normalize_semialg @@
  or_semialg_list @@ List.map (fun and_ineq_list -> semialg_of_and_ineq_list @@ and_and_ineq_list and_ineq_list arg_and_ineq_list) semialg
let and_semialg semialg1 semialg2 =
  normalize_semialg @@
  or_semialg_list @@ List.map (fun and_ineq_list -> and_semialg_and_ineq_list semialg2 and_ineq_list) semialg1
let and_semialg_list semialg_list =
  normalize_semialg @@
  List.fold_left (fun b elm -> and_semialg b elm) [] semialg_list

(* definition is by the DeMorgan law,  exponential blowup in general *)
let rec not_semialg (semialg : semialg) : semialg =
  let rec not_semialg_sub (resulting_semialg : semialg) (semialg : semialg) : semialg =
  match semialg with 
  | [] ->resulting_semialg
  | and_ineq_list::semialg' -> 
     let rec cons_and_ineq_list (resulting_semialg' : semialg) (and_ineq_list : and_ineq_list) : semialg =
       match and_ineq_list with
       | [] -> resulting_semialg'
       | c_coef_ineq::and_ineq_list' ->
          let rec cons_c_coef_ineq (resulting_semialg'' : semialg) (base_semialg'' : semialg) : semialg =
            match base_semialg'' with
            | [] -> resulting_semialg''
            | and_ineq_list''::semialg'' ->
               cons_c_coef_ineq ((not_c_coef_ineq c_coef_ineq::and_ineq_list'')::resulting_semialg'') semialg'' in
          cons_and_ineq_list (cons_c_coef_ineq resulting_semialg' resulting_semialg) and_ineq_list' in
     not_semialg_sub (cons_and_ineq_list false_semialg and_ineq_list) semialg' in
  not_semialg_sub true_semialg semialg


let string_of_semialg semialg = string_of_list string_of_and_ineq_list semialg

let rec is_linear_ineq : 'coef ineq -> bool = is_linear_polynomial
  
