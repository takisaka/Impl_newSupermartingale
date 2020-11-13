open Util

(* === variables === *)
type 'a var = Empty_var | Var of 'a | Temporary of 'a
let string_of_string_var (v: string var) : string = match v with
  | Empty_var -> ""
  | Var a | Temporary a ->  a

type 'var valuation = ('var * float) list
let normalize_v_valuation v_valuation =
  let var_list, _ = List.split v_valuation in
  if is_duplicate var_list then
    failwith "v_valuation is duplicate. (I don't know which to assign)"
  else
    v_valuation
let value_of v valuation = List.assoc v valuation
let update_of_valuation valuation v f = normalize_v_valuation @@ (v, f) :: List.remove_assoc v valuation
let valuation_of_var_float_list x = normalize_v_valuation x
let var_float_list_of_valuation valuation = valuation
(* let string_of_valuation valuation = string_of_list (string_of_pair string_of_v string_of_float) valuation *)

let string_of_valuation : ('var -> string) -> 'var valuation -> string =
  fun string_of_var valuation ->
    string_of_list (string_of_pair string_of_var string_of_float) valuation

(* v *)
type v = V of string var
let normalize_v (V v) =
  match v with
  | Empty_var -> V Empty_var
  | Var a | Temporary a ->
    if a = "" then V Empty_var
    else V v
let empty_v : v = V Empty_var
let is_empty_v (V v) = (v=Empty_var)
let string_of_v (V v: v) : string =
  match v with
  | Empty_var -> ""
  | Var a -> "v_" ^ a
  | Temporary a -> "tempv_" ^ a
let v_of_string (string: string) : v =
  normalize_v @@ V (Var string)
let v_of_string_temporary (string: string) : v =
  normalize_v @@ V (Temporary string)
let compare_v v1 v2 = compare (string_of_v v1) (string_of_v v2)

type v_domain = v list
let normalize_v_domain  (v_domain: v_domain) : v_domain =
  List.sort compare_v @@
  remove_duplicates @@
  (List.map (fun (V v) ->
       match v with
       | Empty_var -> V v
       | Var a | Temporary a ->
         if a = "" then empty_v
         else V v)
      v_domain)
let v_domain_of_v_list v_list = normalize_v_domain v_list
let v_list_of_v_domain v_domain = normalize_v_domain v_domain
let string_of_v_domain v_domain = string_of_list string_of_v v_domain
let add_v_to_v_domain v_domain v = normalize_v_domain (v::v_domain)

(* param *)
type param = Param of string var
let normalize_param (Param p) =
  match p with
  | Empty_var -> Param p
  | Var a | Temporary a ->
    if a = "" then Param Empty_var
    else Param p
let empty_param : param = Param Empty_var
let is_empty_param (Param param) = (param = Empty_var)
let string_of_param (Param p: param) : string = 
  match p with
  | Empty_var -> "param_"
  | Var a -> "param_" ^ a
  | Temporary a -> "tempparam_" ^ a
let param_of_string (string: string) : param =
  normalize_param @@ Param (Var string)
let param_of_string_temporary (string: string) : param =
  normalize_param @@ Param (Temporary string)

let compare_param p1 p2 = compare (string_of_param p1) (string_of_param p2)

type param_domain = param list
let normalize_param_domain  (p_domain: param_domain) : param_domain =
  List.sort compare_param @@
  remove_duplicates @@
  (List.map normalize_param
      p_domain)
let param_domain_of_param_list param_list = normalize_param_domain param_list
let param_list_of_param_domain param_domain = normalize_param_domain param_domain
let string_of_param_domain param_domain = string_of_list string_of_param param_domain
let add_param_to_param_domain param_domain param = normalize_param_domain (param::param_domain)
