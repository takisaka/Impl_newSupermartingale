open Util
open Variable

(* === coefficient === *)
type 'a coef = Zero_coef | Unit_coef | Coef of 'a
let string_of_coef (string_of_a: 'a -> string) (coef : 'a coef) : string = match coef with
  | Zero_coef -> "Zero_coef"
  | Unit_coef -> "Unit_coef"
  | Coef a -> "Coef \"" ^ string_of_a a ^ "\""

let rec add_coef (add: 'a -> 'a -> 'a) (unit: 'a) (c1: 'a coef) (c2: 'a coef) : 'a coef =
  match c1, c2 with
  | Zero_coef, c | c, Zero_coef -> c
  | Unit_coef, c | c, Unit_coef -> add_coef add unit c (Coef unit)
  | Coef c1, Coef c2 -> Coef (add c1 c2)
let mult_coef (mult: 'a -> 'a -> 'a) (c1: 'a coef) (c2: 'a coef): 'a coef =
  match c1, c2 with
  | Zero_coef, _ | _, Zero_coef -> Zero_coef
  | Unit_coef, c | c, Unit_coef -> c
  | Coef a1, Coef a2 -> Coef (mult a1 a2)

(* c_coef *)
type c_coef = C_coef of float coef
let zero_c_coef : c_coef = C_coef Zero_coef
let unit_c_coef : c_coef = C_coef Unit_coef
let normalize_c_coef (C_coef c) = match c with
  | Zero_coef -> C_coef Zero_coef
  | Unit_coef -> C_coef Unit_coef
  | Coef 0. -> C_coef Zero_coef
  | Coef 1. -> C_coef Unit_coef
  | Coef f -> C_coef (Coef f)
let string_of_float_coef (coef : float coef) : string = string_of_coef string_of_float coef
let string_of_c_coef (C_coef coef: c_coef) : string =
  string_of_float_coef coef

let c_coef_of_float (f: float) : c_coef = normalize_c_coef @@ C_coef (Coef f)

let float_of_c_coef = function
  | C_coef Zero_coef -> 0.
  | C_coef Unit_coef -> 1.
  | C_coef (Coef f) -> f
let compare_c_coef c1 c2 = compare (float_of_c_coef c1) (float_of_c_coef c2)

let add_c_coef (C_coef c1: c_coef) (C_coef c2: c_coef): c_coef =
  normalize_c_coef @@ C_coef (add_coef ( +. ) 1. c1 c2)
let mult_float_with_c_coef (f: float) (C_coef c: c_coef) : c_coef =
  normalize_c_coef @@
  (match c with
  | Zero_coef -> C_coef Zero_coef
  | Unit_coef -> C_coef (Coef f)
  | Coef a -> C_coef (Coef (f *. a)))
let mult_c_coef (C_coef c1: c_coef) (C_coef c2: c_coef): c_coef =
  normalize_c_coef @@ C_coef (mult_coef ( *. ) c1 c2)
let div_c_coef (C_coef divident: c_coef) (C_coef divisor: c_coef): c_coef =
  normalize_c_coef @@
  (match divisor, divident with
  | Zero_coef, _ -> raise Division_by_zero
  | Unit_coef, _ -> C_coef divident
  | Coef _, Zero_coef -> zero_c_coef
  | Coef c, Unit_coef -> C_coef (Coef (1. /. c))
  | Coef c, Coef a -> C_coef (Coef (a /. c)))

let uminus_c_coef (c: c_coef) : c_coef = normalize_c_coef @@ mult_float_with_c_coef (-1.) c
let exp_c_coef (c: c_coef) (i: int): c_coef =
  let float_c = float_of_c_coef c in
  normalize_c_coef @@ c_coef_of_float (float_c ** float_of_int i)

(* p_coef *)
type p_coef = P_coef of (float * param) list coef
let zero_p_coef : p_coef = P_coef Zero_coef
let unit_p_coef : p_coef = P_coef Unit_coef
let normalize_p_coef (P_coef p) = match p with
  | Zero_coef -> P_coef Zero_coef
  | Unit_coef -> P_coef Unit_coef
  | Coef lst ->
  let ret =
    (* sort term *)
    List.sort (fun (_, p1) (_, p2) -> compare_param p1 p2) @@
    (* remove zero term *)
    (* e.g. 0 + a x -> a x *)
    let rm_zero_term coef =
      let is_not_empty_term (f, _) = not @@ (f = 0.)  in
      let candidate = List.filter is_not_empty_term coef in
      if candidate = [] then [(0., empty_param)]
      else candidate
    in
    (* e.g. 0 * x -> 0 *)
    let simplify_zero_term p_coef =
      List.map (fun (f, p) -> if f = 0. then (0., empty_param) else (f, p)) p_coef
    in
    (* add up terms with same variables *)
    (* e.g. ax + bx -> (a+b)x *)
    let rec can_add_up_elt (f_arg, p_arg) l =  match l with
        | [] -> false
        | (_, p)::_ when p = p_arg -> true
        | _::tl -> can_add_up_elt (f_arg, p_arg) tl
    in
    let add_up_elt (f_arg, p_arg) l =
      if can_add_up_elt (f_arg, p_arg) l then
        let rec sub l acc = match l with
          | [] -> acc
          | (f, p)::tl when p = p_arg -> sub tl ((f +. f_arg, p)::acc)
          | hd::tl -> sub tl (hd::acc)
        in sub l []
      else
        (f_arg, p_arg) :: l
    in
    let add_up_term l =
      List.fold_left (fun b elm -> add_up_elt elm b) [] l
    in
    rm_zero_term @@ simplify_zero_term @@ add_up_term lst
  in
  (* in case given list is empty *)
  match ret with
  | [] -> P_coef Zero_coef
  | [(f, _)] when f = 0. -> P_coef Zero_coef
  | [(f, p)] when f = 1. && p = empty_param -> P_coef Unit_coef
  | _ -> P_coef (Coef ret)
      
let string_of_float_param_list (list: (float * param) list) : string =
  string_of_list (string_of_pair string_of_float string_of_param) list
let string_of_float_param_list_coef (coef : (float * param) list coef) : string = string_of_coef string_of_float_param_list coef
let string_of_p_coef (P_coef coef: p_coef) : string = string_of_float_param_list_coef coef

let float_param_list_of_float (f: float) : (float * param) list = [(f, empty_param)]
let float_param_list_of_param (p: param) : (float * param) list = [(1., p)]
let p_coef_of_float (f: float) : p_coef = normalize_p_coef @@ P_coef (Coef (float_param_list_of_float f))
let p_coef_of_param (p: param) : p_coef = normalize_p_coef @@ P_coef (Coef (float_param_list_of_param p))
let p_coef_of_float_param (f, p: float * param) : p_coef = normalize_p_coef @@ P_coef (Coef [f, p])
let p_coef_of_float_param_list (fp_list: (float * param) list) : p_coef = normalize_p_coef @@ P_coef (Coef fp_list)
let p_coef_of_c_coef (C_coef c: c_coef) : p_coef =
  normalize_p_coef @@
  match c with
  | Zero_coef -> P_coef Zero_coef
  | Unit_coef -> P_coef Unit_coef
  | Coef a -> P_coef (Coef [(a , empty_param)])

let float_param_list_of_p_coef = function
  | P_coef Zero_coef -> float_param_list_of_float 0.
  | P_coef Unit_coef -> float_param_list_of_float 1.
  | P_coef (Coef f) -> f

let rec compare_p_coef p1 p2 =
  let fp_list1, fp_list2 = float_param_list_of_p_coef p1, float_param_list_of_p_coef p2 in
  let compare_float_param (f1, p1) (f2, p2) =
  (* 1. p1 > 3. p2 if p1 > p2 *)
    let candidate = compare_param p1 p2 in
    if candidate = 0 then compare f1 f2
    else candidate
  in
  (* lexicographic order *)
  match fp_list1, fp_list2 with
  | [], [] -> 0
  (* 2 < 2 + 1. p1  *)
  | [], _::_ -> compare 0 1
  (* 2 + 1. p1 < 2  *)
  | _::_, [] -> compare 1 0
  (* 2 + 1. p1 + 3. p3 < 2 + 1. p1 + 2. p4 if 3. p3 < 2. p4 *)
  | fp1::[], fp2::[] ->
    compare_float_param fp1 fp2
  | fp1::rest1, fp2::rest2 ->
    let candidate = compare_float_param fp1 fp2 in
    if candidate = 0 then compare_p_coef (p_coef_of_float_param_list rest1) (p_coef_of_float_param_list rest2)
    else candidate

let bop_on_float_param_list (bop: float -> float -> float) (fp_list1: (float * param) list) (fp_list2: (float * param) list) : (float * param) list =
  let folder =
    (fun (b: (float * param) list) ((_, p_elm) as fp_elm: float * param) ->
       let pred (_, p) = p = p_elm in
       let collapse : (float * param) list -> (float * param) option = function
         | [] -> None
         | ((_, p1) as fp_hd) :: rest ->
           Some (List.fold_left
                   (fun (b, _) (elm, _) -> (bop b elm, p1))
                   fp_hd rest)
       in
       match collapse @@ List.filter pred (fp_elm :: b) with
       | None -> fp_elm :: b
       | Some a -> a :: (List.filter (fun x -> not @@ pred x) b)) in
  List.fold_left
    folder
    (List.fold_left folder [] fp_list1)
  fp_list2

let add_float_param_list (fp_list1: (float * param) list) (fp_list2: (float * param) list) : (float * param) list =
  bop_on_float_param_list ( +. ) fp_list1 fp_list2
(** implementation note: normalization is done in add_float_param_list *)

let add_p_coef (P_coef p1: p_coef) (P_coef p2: p_coef): p_coef =
  normalize_p_coef @@ P_coef (add_coef add_float_param_list [1., empty_param] p1 p2)

let mult_float_with_float_param_list (f: float) (float_param_list: (float * param) list) : (float * param) list =
  List.map (fun (f_elm, p_elm) -> (f_elm *. f, p_elm)) float_param_list
let mult_float_with_p_coef (f: float) (P_coef c: p_coef) : p_coef =
  normalize_p_coef @@
  match c with
  | Zero_coef -> P_coef Zero_coef
  | Unit_coef ->
    P_coef (Coef (mult_float_with_float_param_list f [(1., empty_param)]))
  | Coef a ->
    P_coef (Coef (mult_float_with_float_param_list f a))
let uminus_p_coef (p: p_coef) : p_coef = normalize_p_coef @@ mult_float_with_p_coef (-1.) p
