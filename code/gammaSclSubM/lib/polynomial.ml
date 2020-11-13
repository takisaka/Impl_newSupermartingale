open Util
open Variable
open Coefficient

(** ===================================
    === polynomial over coefficient ===
    =================================== *)

(** -----------
    1. monomial
   x^i = x_1^i1 x_2^i2 ... x_n^in
   where x = (x_1, ..., x_n) and i = (i_1, ..., i_n)
   NOTE: x^0 is also allowed!
*)
type monomial = (v * int) list
let empty_monomial = []
let compare_mono_elm (v1, _) (v2, _) = compare_v v1 v2
(* in lexicographical order *)
let compare_monomial m1 m2 =
  (* assumption: m1, m2 are ordered comparing v *)
  let order1 = List.fold_left (fun b elm -> b * elm) 1 (snd @@ List.split m1) in
  let order2 = List.fold_left (fun b elm -> b * elm) 1 (snd @@ List.split m2) in
  if order1 = order2 then
    let rec compare_monomial_of_same_order m1 m2 =
      let compare_elm (v1, i1) (v2, i2) =
          let s_v1, s_v2 = string_of_v v1, string_of_v v2 in
          if s_v1 = s_v2 then
            compare i1 i2
          else
            compare s_v1 s_v2
        in
      (match m1, m2 with
       | [], [] -> compare 0 0
       | _::_, [] -> compare 10 0
       | [], _::_ ->  compare 0 10
       | hd1::tl1, hd2::tl2 -> 
         let result = compare_elm hd1 hd2 in
         if result = 0 then compare_monomial_of_same_order tl1 tl2
         else result) in
    compare_monomial_of_same_order m1 m2
  else
    compare order1 order2

let v_list_of_monomial (monomial: monomial) : v list = fst (List.split @@ List.filter (fun (_,i) -> i>0) monomial)

(** -- normalize_monomial --
   most of the specification of this module is implemented here.
   every implementation of setter in this module should go through this function
   to gurantee specification invariants.
*)
let normalize_monomial (m: monomial) : monomial =
  List.sort compare_mono_elm @@
  let rm_empty_v l =
    let is_empty_v_snd (v, _) = is_empty_v v  in
    let candidate = List.filter (fun m -> not @@ is_empty_v_snd m) l in
    if candidate = [] then empty_monomial
    else candidate
  in    
  (* remove empty monomials *)
  (* x^0 y^j -> y^(i+j) *)
  (* x^0 -> 1 *)
  let rm_empty_term l =
    let is_empty_term (_, i) = i = 0  in
    let candidate = List.filter (fun m -> not @@ is_empty_term m) l in
    if candidate = [] then empty_monomial
    else candidate
  in
  (* add up terms with same variables *)
  let rec can_add_up_elt (v_arg, i_arg) l =  match l with
    | [] -> false
    | (v, _)::_ when v = v_arg -> true
    | _::tl -> can_add_up_elt (v_arg, i_arg) tl
  in
  let add_up_elt (v_arg, i_arg) l =
    if can_add_up_elt (v_arg, i_arg) l then
      let rec sub l acc = match l with
        | [] -> acc
        | (v, i)::tl when v = v_arg -> sub tl ((v, i + i_arg)::acc)
        | hd::tl -> sub tl (hd::acc)
      in sub l []
    else
      (v_arg, i_arg) :: l
  in
  let add_up_monomial l =
    List.fold_left (fun b elm -> add_up_elt elm b) [] l
  in
  let candidate = rm_empty_v @@ rm_empty_term @@ add_up_monomial m in
  if candidate = [] then empty_monomial
  else candidate

(** setter *)
let monomial_of_v_int x i = normalize_monomial [(x, i)]
let monomial_of_v_int_list vi_list = normalize_monomial vi_list

(** getter *)
let v_int_list_of_monomial m = m

(** operations on data type *)
let mult_monomial m1 m2 = normalize_monomial @@ m1 @ m2
let exp_monomial  (m: monomial) (j: int) = normalize_monomial @@ List.map (fun (x, i) -> (x, Pervasives.( * ) i j)) m
let has_v_in_monomial arg_v monomial =
  List.fold_left (fun b (v, _) -> b || v = arg_v) false monomial
let partition_monomial_by_v (m1: monomial) (arg_v: v) : (v * int) option * monomial =
  let pred (v, _) = v = arg_v in
  match List.partition pred m1 with
  | [], rest -> None, normalize_monomial @@ rest
  | (v, target_i) :: for_assert, rest ->
    assert (for_assert = []); (* every monomial should be normalized *)
    Some (v, target_i), normalize_monomial @@ rest
(* let compose_monomial m1 v_i m2 =
 *   match partition_monomial_by_v m1 v_i with
 *     | None ,_ -> normalize_monomial @@ m1
 *     | Some (_, target_i), rest -> 
 *       normalize_monomial @@
 *       mult_monomial (exp_monomial m2 target_i) rest *)

(** for debug *)
let string_of_monomial x =
  let x = normalize_monomial x in
  if x = empty_monomial then "1"
  else
  let to_string_elm (v, i) = string_of_v v ^ "^" ^ string_of_int i in
  string_of_list_infix_string to_string_elm x " "

let is_scalar (_, m: 'coef * monomial) : bool = m = empty_monomial
  

let possible_monomial_list (v_domain: v_domain) (max_deg: int) : monomial list =
  let v_list = remove_duplicates @@ v_list_of_v_domain v_domain in
  let v_list_length = List.length v_list in
  if v_list_length <= 0 || max_deg < 0 then [] else
  if max_deg = 0 then [[]] else

  (* combination (max_deg + v_list_length) v_list_length *)
  let arr = Array.make (max_deg + 1) [] in
  arr.(0) <- [[]];

  let rec loop = function
    | [] -> ()
    | v::v_list' -> 
       for i = 0 to max_deg do
         for j = 0 to max_deg - i - 1 do
           arr.(max_deg-i) <-  List.map (fun monomial -> (v, max_deg-i-j)::monomial) arr.(j) @ arr.(max_deg-i)
         done
       done;
       loop v_list'
  in
  loop v_list;

  List.sort compare_monomial @@
  List.map monomial_of_v_int_list @@
  List.flatten @@ 
  Array.to_list arr 







(** ===================================
    === polynomial over coefficient ===
    =================================== *)
type 'coef polynomial = ('coef * monomial) list
(* let add_polynomial : ('coef -> 'coef -> 'coef) -> 'coef -> 'coef polynomial -> 'coef polynomial -> 'coef polynomial *)
(* let uminus_polynomial : ('coef ->'coef) -> 'coef polynomial -> 'coef polynomial *)
let coef_list_of_polynomial polynomial =
  fst @@ List.split polynomial
let monomial_list_of_polynomial polynomial =
  snd @@ List.split polynomial

(** --------------------
    1. c_coef polynomial
    \sum_i a_i x_i
 *)



let rec compare_c_coef_polynomial : c_coef polynomial -> c_coef polynomial -> int =
  fun poly1 poly2 ->
    let compare_coef_monomial (coef1, mono1) (coef2, mono2) =
      let candidate = compare_monomial mono1 mono2 in
      if candidate = 0 then compare_c_coef coef1 coef2
      else candidate
    in
  (* lexicographic order *)
  match poly1, poly2 with
  | [], [] -> 0
  (* 2 < 2 + 1. p1  *)
  | [], _::_ -> compare 0 1
  (* 2 + 1. p1 < 2  *)
  | _::_, [] -> compare 1 0
  (* 2 + 1. p1 + 3. p3 < 2 + 1. p1 + 2. p4 if 3. p3 < 2. p4 *)
  | cm1::[], cm2::[] ->
    compare_coef_monomial cm1 cm2
  | cm1::rest1, cm2::rest2 ->
    let candidate = compare_coef_monomial cm1 cm2 in
    if candidate = 0 then compare_c_coef_polynomial rest1 rest2
    else candidate

(** -- normalize_c_coef_polynomial --
   most of the specification of this module is implemented here.
   every implementation of setter in this module should go through this function
   to gurantee specification invariants.
*)
let normalize_c_coef_polynomial (poly: c_coef polynomial) : c_coef polynomial =
  let ret =
    (* sort term *)
    List.sort (fun (_, monomial1) (_, monomial2) -> compare_monomial monomial1 monomial2) @@
    (* remove zero term *)
    (* e.g. 0 + a x^j -> a x^j *)
    let rm_zero_term poly =
      let is_not_empty_term (coef, _) = not @@ (coef = zero_c_coef)  in
      let candidate = List.filter is_not_empty_term poly in
      if candidate = [] then [(zero_c_coef, empty_monomial)]
      else candidate
    in
    (* e.g. 0 * x^i -> 0 *)
    let simplify_zero_term poly =
      List.map (fun (coef, m) -> if coef = zero_c_coef then (zero_c_coef, empty_monomial) else (coef, m)) poly
    in
    (* add up terms with same variables *)
    (* e.g. ax + bx -> (a+b)x *)
    let rec can_add_up_elt (coef_arg, mono_arg) l =  match l with
        | [] -> false
        | (_, mono)::_ when mono = mono_arg -> true
        | _::tl -> can_add_up_elt (coef_arg, mono_arg) tl
    in
    let add_up_elt (coef_arg, mono_arg) l =
      if can_add_up_elt (coef_arg, mono_arg) l then
        let rec sub l acc = match l with
          | [] -> acc
          | (coef, mono)::tl when mono = mono_arg -> sub tl ((add_c_coef coef coef_arg, mono)::acc)
          | hd::tl -> sub tl (hd::acc)
        in sub l []
      else
        (coef_arg, mono_arg) :: l
    in
    let add_up_coef l =
      List.fold_left (fun b elm -> add_up_elt elm b) [] l
    in
    rm_zero_term @@ simplify_zero_term @@ add_up_coef poly
  in
  (* in case given list is empty *)
  if ret = [] then [(zero_c_coef, empty_monomial)]
  else ret

(** setter *)
let c_coef_polynomial_of_c_coef c_coef = normalize_c_coef_polynomial [(c_coef, empty_monomial)]
let c_coef_polynomial_of_monomial monomial = normalize_c_coef_polynomial [(unit_c_coef, monomial)]
let c_coef_polynomial_of_c_coef_monomial c m = normalize_c_coef_polynomial [(c, m)]
let c_coef_polynomial_of_c_coef_monomial_list cm_list = normalize_c_coef_polynomial cm_list

let zero_c_coef_polynomial = c_coef_polynomial_of_c_coef zero_c_coef
let unit_c_coef_polynomial = c_coef_polynomial_of_c_coef unit_c_coef

(** getter *)
let c_coef_monomial_list_of_c_coef_polynomial (c_poly: c_coef polynomial) : (c_coef * monomial) list = c_poly

let string_of_c_coef_polynomial x =
  let to_string_elm (coef, m) = string_of_c_coef coef ^ "*" ^ string_of_monomial m in
  string_of_list_infix_string to_string_elm x "+"

let v_list_of_polynomial (polynomial: 'coef polynomial) : v list =
  remove_duplicates @@ List.flatten @@ List.map (fun (_, m) -> v_list_of_monomial m) polynomial 

(** operations on data type *)
let add_c_coef_polynomial c_poly1 c_poly2 =
  normalize_c_coef_polynomial @@ c_poly1 @ c_poly2
let add_c_coef_polynomial_list c_poly_list =
  normalize_c_coef_polynomial @@ List.flatten c_poly_list
  
let uminus_c_coef_polynomial c_poly =
  normalize_c_coef_polynomial @@
  List.map (fun (coef, monomial) -> (uminus_c_coef coef, monomial)) c_poly
let mult_c_coef_polynomial c_poly1 c_poly2 =
  let cm_list1 = c_coef_monomial_list_of_c_coef_polynomial c_poly1 in
  let cm_list2 = c_coef_monomial_list_of_c_coef_polynomial c_poly2 in
  normalize_c_coef_polynomial @@ add_c_coef_polynomial_list @@ List.flatten @@
  List.map (fun (c1, m1) ->
      (* let multiplicand = c_coef_polynomial_of_c_coef_monomial_list [(c, m)] in *)
      List.map (fun (c2, m2) ->
          (* let p1 = c_coef_polynomial_of_c_coef_monomial_list [(c, m)] in *)
          let multiplied_c = mult_c_coef c1 c2 in
          let multiplied_m = mult_monomial m1 m2 in
          c_coef_polynomial_of_c_coef_monomial multiplied_c multiplied_m
        ) cm_list1)
    cm_list2

let mult_c_coef_polynomial_list c_poly_list =
  normalize_c_coef_polynomial @@
  List.fold_left (fun b elm -> mult_c_coef_polynomial b elm) unit_c_coef_polynomial c_poly_list

let exp_c_coef_polynomial c_poly i =
  (* a^0 = 1 *)
  if i = 0 then unit_c_coef_polynomial
  (* a^1 = a *)
  else if i = 1 then c_poly
  else
    normalize_c_coef_polynomial @@
    List.fold_left (fun b elm -> mult_c_coef_polynomial b elm) c_poly (list_of_length_n (i-1) c_poly)

let compose_c_coef_monomial (c, arg_m: c_coef * monomial) (v_i : v)(p: c_coef polynomial) : c_coef polynomial =
  match partition_monomial_by_v arg_m v_i with
  | None, _ -> 
    normalize_c_coef_polynomial @@ 
    c_coef_polynomial_of_c_coef_monomial c arg_m
  | Some (_, target_i), rest_monomial ->
    normalize_c_coef_polynomial @@
    mult_c_coef_polynomial_list
      [(c_coef_polynomial_of_c_coef c);
       exp_c_coef_polynomial p target_i;
       c_coef_polynomial_of_monomial rest_monomial]

let substitute_v_with_c_coef_polynomial_in_c_coef_polynomial v_i inner_c2 c1 =
  let partition_c_coef_polynomial_by_v c_poly v : (c_coef * monomial) list * c_coef polynomial =
    let pred (_, mono) = has_v_in_monomial v mono in
    List.partition pred c_poly
  in
  let target_cm_list, rest_polynomial = partition_c_coef_polynomial_by_v c1 v_i in
  normalize_c_coef_polynomial @@
  add_c_coef_polynomial_list
    [add_c_coef_polynomial_list @@ 
     List.map (fun cm -> compose_c_coef_monomial cm v_i inner_c2) target_cm_list;
     rest_polynomial]

let valuate_monomial (valuation : v valuation) (monomial : monomial) : float =
  List.fold_left
    (fun ret (v,i) ->
      let value =
        try
          value_of v valuation
        with Not_found -> Printf.eprintf "Not found in valuate_monomial: %s\n" (string_of_v v); raise Not_found in
      if i = 0 then ret else ret *. value ** (float_of_int i))
    1.
    (v_int_list_of_monomial (normalize_monomial monomial))


let get_degree_monomial (monomial : monomial) : int =
  List.fold_left
    (fun ret (_,i) -> ret + i)
    0
    (normalize_monomial monomial)

(** -----------------------
    == p_coef polynomial ==
   \sum_i (\sum_j a_j p_j) x_i
 *)
let rec compare_p_coef_polynomial : p_coef polynomial -> p_coef polynomial -> int =
  fun poly1 poly2 ->
    let compare_coef_monomial (coef1, mono1) (coef2, mono2) =
      let candidate = compare_monomial mono1 mono2 in
      if candidate = 0 then compare_p_coef coef1 coef2
      else candidate
    in
  (* lexicographic order *)
  match poly1, poly2 with
  | [], [] -> 0
  (* 2 < 2 + 1. p1  *)
  | [], _::_ -> compare 0 1
  (* 2 + 1. p1 < 2  *)
  | _::_, [] -> compare 1 0
  (* 2 + 1. p1 + 3. p3 < 2 + 1. p1 + 2. p4 if 3. p3 < 2. p4 *)
  | pm1::[], pm2::[] ->
    compare_coef_monomial pm1 pm2
  | pm1::rest1, pm2::rest2 ->
    let candidate = compare_coef_monomial pm1 pm2 in
    if candidate = 0 then compare_p_coef_polynomial rest1 rest2
    else candidate

let string_of_p_coef_polynomial x =
  let to_string_elm (coef, m) = string_of_p_coef coef ^ "*" ^ string_of_monomial m in
  string_of_list_infix_string to_string_elm x "+"

(** -- normalize_p_coef_polynomial --
   most of the specification of this module is implemented here.
   every implementation of setter in this module should go through this function
   to gurantee specification invariants.
*)
let normalize_p_coef_polynomial (poly: p_coef polynomial) : p_coef polynomial =
  let ret =
    (* sort term *)
    List.sort (fun (_, monomial1) (_, monomial2) -> compare_monomial monomial1 monomial2) @@
    (* remove zero term *)
    (* e.g. 0*x^j -> 0 *)
    let rm_zero_term poly =
      let is_empty_term (coef, _) = coef = zero_p_coef  in
      let candidate = List.filter (fun t -> not @@ is_empty_term t) poly in
      if candidate = [] then [(zero_p_coef, empty_monomial)]
      else candidate
    in
    (* add up terms with same variables *)
    (* e.g. ax + bx -> (a+b)x *)
    let rec can_add_up_elt (coef_arg, mono_arg) l =  match l with
        | [] -> false
        | (_, mono)::_ when mono = mono_arg -> true
        | _::tl -> can_add_up_elt (coef_arg, mono_arg) tl
    in
    let add_up_elt (coef_arg, mono_arg) l =
      if can_add_up_elt (coef_arg, mono_arg) l then
        let rec sub l acc = match l with
          | [] -> acc
          | (coef, mono)::tl when mono = mono_arg -> sub tl ((add_p_coef coef coef_arg, mono)::acc)
          | hd::tl -> sub tl (hd::acc)
        in sub l []
      else
        (coef_arg, mono_arg) :: l
    in
    let add_up_coef l =
      List.fold_left (fun b elm -> add_up_elt elm b) [] l
    in
    rm_zero_term @@ add_up_coef poly
    in
    (* in case given list is empty *)
    if ret = [] then [(zero_p_coef, empty_monomial)]
    else ret

let p_coef_polynomial_of_p_coef p_coef = normalize_p_coef_polynomial [(p_coef, empty_monomial)]
let p_coef_polynomial_of_monomial monomial = normalize_p_coef_polynomial [(unit_p_coef, monomial)]
let p_coef_polynomial_of_p_coef_monomial p m = normalize_p_coef_polynomial [(p, m)]
let p_coef_polynomial_of_p_coef_monomial_list pm_list =  normalize_p_coef_polynomial pm_list

let zero_p_coef_polynomial = p_coef_polynomial_of_p_coef zero_p_coef
let unit_p_coef_polynomial = p_coef_polynomial_of_p_coef unit_p_coef

let p_coef_monomial_list_of_p_coef_polynomial p_poly = p_poly

let collect_param_string_list_of_p_coef_polynomial p_poly : param list =
  List.filter (fun p -> not (is_empty_param p)) @@
  List.map snd @@
    List.flatten @@
      List.map float_param_list_of_p_coef @@ (*  *)
        List.map fst (p_coef_monomial_list_of_p_coef_polynomial p_poly) (* list the first elements of the entries in p_poly (not sure what p_coef... does) *)

(** operations on data type *)
let add_p_coef_polynomial p_poly1 p_poly2 =
  normalize_p_coef_polynomial @@ p_poly1 @ p_poly2
let add_p_coef_polynomial_list p_poly_list =
  normalize_p_coef_polynomial @@ List.flatten p_poly_list
let uminus_p_coef_polynomial p_poly =
  normalize_p_coef_polynomial @@
  List.map (fun (coef, monomial) -> (uminus_p_coef coef, monomial)) p_poly
(* let mult_p_coef_with_c_coef_monomial p c mono : p_coef polynomial =
 *   normalize_p_coef_polynomial @@
 *   p_coef_polynomial_of_p_coef_monomial (scale_p_coef (float_of_c_coef c) p) mono *)
let mult_float_with_p_coef_polynomial (f: float) (p_poly: p_coef polynomial) : p_coef polynomial =
  normalize_p_coef_polynomial @@ 
  List.map (fun (p_coef, monomial) -> (mult_float_with_p_coef f p_coef, monomial)) p_poly
let mult_p_coef_with_c_coef_polynomial p c_poly : p_coef polynomial =
  normalize_p_coef_polynomial @@
  let cm_list = c_coef_monomial_list_of_c_coef_polynomial c_poly in
  List.map (fun (c,m) -> (mult_float_with_p_coef (float_of_c_coef c) p, m)) cm_list

let mult_p_coef_polynomial_with_c_coef_monomial p_poly c mono : p_coef polynomial =
  let pm_list = p_coef_monomial_list_of_p_coef_polynomial p_poly in
  normalize_p_coef_polynomial @@
  p_coef_polynomial_of_p_coef_monomial_list @@
  List.map (fun (p_coef, m) -> (mult_float_with_p_coef (float_of_c_coef c) p_coef, mult_monomial m mono)) pm_list

let mult_p_coef_polynomial_with_c_coef_polynomial p_poly c_poly =
  let cm_list = c_coef_monomial_list_of_c_coef_polynomial c_poly in
  normalize_p_coef_polynomial @@
  add_p_coef_polynomial_list @@
  List.map (fun (c, m) -> mult_p_coef_polynomial_with_c_coef_monomial p_poly c m) cm_list

  
let substitute_v_with_c_coef_polynomial_in_p_coef_monomial (v_i : v) (c_poly: c_coef polynomial) (p, arg_m1: p_coef * monomial)  : p_coef polynomial =
  match partition_monomial_by_v arg_m1 v_i with
  | None, _ ->
    normalize_p_coef_polynomial @@
    p_coef_polynomial_of_p_coef_monomial p arg_m1    
  | Some (_, target_i), rest_monomial ->
    normalize_p_coef_polynomial @@
    let composed_elm: c_coef polynomial = exp_c_coef_polynomial c_poly target_i in
    mult_p_coef_with_c_coef_polynomial
      p
      (mult_c_coef_polynomial composed_elm (c_coef_polynomial_of_monomial rest_monomial))

let substitute_v_with_c_coef_polynomial_in_p_coef_polynomial v_i c_poly p_poly  =
  let partition_p_coef_polynomial_by_v p_poly v : (p_coef * monomial) list * p_coef polynomial =
    let pred (_, mono) = has_v_in_monomial v mono in
    List.partition pred p_poly
  in
  let target_pm_list, rest_polynomial = partition_p_coef_polynomial_by_v p_poly v_i in
  let composed_p_poly_list = 
    List.map
      (fun elm_pm -> substitute_v_with_c_coef_polynomial_in_p_coef_monomial  v_i c_poly elm_pm)
      target_pm_list
  in
  normalize_p_coef_polynomial @@
  add_p_coef_polynomial_list (rest_polynomial :: composed_p_poly_list)

let substitute_vn_with_float_in_p_coef_polynomial (v : v) (f : int -> float) (p_poly : p_coef polynomial) : p_coef polynomial  =
  normalize_p_coef_polynomial @@
  List.map
    (fun (p_coef, monomial) ->
      List.fold_left
        (fun (p_coef,new_monomial) (v',i) ->
          if v=v' then (mult_float_with_p_coef (f i) p_coef, new_monomial)
          else (p_coef, (v',i)::new_monomial))
        (p_coef,[])
        monomial)
    p_poly


let substitute_v_with_v_in_polynomial (normalize: 'coef polynomial -> 'coef polynomial)  (v : v) (v' : v) (polynomial: 'coef polynomial): 'coef polynomial =
  let rec substitute_v_with_v_in_monomial (resulting_monomial : monomial) (monomial: monomial) : monomial =
    match monomial with
    | [] -> normalize_monomial resulting_monomial
    | (v'',i)::monomial' ->
       if v = v'' then
         substitute_v_with_v_in_monomial ((v',i)::resulting_monomial) monomial'
       else
         substitute_v_with_v_in_monomial ((v'',i)::resulting_monomial) monomial' in
  let rec get_coef_and_rewrite (resulting_polynomial : 'coef polynomial) (polynomial : 'coef polynomial) : 'coef polynomial =
    match polynomial with
    | [] -> normalize resulting_polynomial
    | (coef,monomial)::polynomial' ->
       get_coef_and_rewrite ((coef,substitute_v_with_v_in_monomial [] monomial)::resulting_polynomial) polynomial'
  in
  get_coef_and_rewrite [] polynomial  

let substitute_v_with_v_in_c_coef_polynomial = substitute_v_with_v_in_polynomial normalize_c_coef_polynomial
let substitute_v_with_v_in_p_coef_polynomial = substitute_v_with_v_in_polynomial normalize_p_coef_polynomial



let get_degree_polynomial (polynomial : 'coef polynomial) : int =
  List.fold_left
    (fun ret (_, monomial) -> max ret (get_degree_monomial monomial))
    0
    polynomial

let is_linear_polynomial (polynomial : 'coef polynomial) : bool =
  get_degree_polynomial polynomial <= 1
(*  List.for_all
    (fun (_, monomial) ->  List.length (normalize_monomial monomial) <= 1)
    polynomial *)

let is_scalar_polynomial (polynomial: 'coef polynomial) : bool =
  get_degree_polynomial polynomial <= 0

