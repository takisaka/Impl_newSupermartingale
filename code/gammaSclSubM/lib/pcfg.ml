open Util
open Variable
open Coefficient
open Polynomial
open Semialg


type l = string
let l_of_string x = x
let string_of_l l = l

module LM=
  Map.Make
    (struct
      type t = l
      let compare = compare
    end)

(* type tmpltype = LIN | EXP *)

type l_domain = string list
let normalize_l_domain = remove_duplicates
let l_domain_of_l_list list = normalize_l_domain list
let l_list_of_l_domain x = x
let string_of_l_domain l_domain = string_of_list string_of_l l_domain

type semialgmap = semialg LM.t
let semialgmap_empty : semialgmap = LM.empty
let semialgmap_singleton (l : l) (semialg : semialg) : semialgmap = LM.singleton l semialg
let semialgmap_mem (l : l) (semialgmap : semialgmap) : bool = LM.mem l semialgmap
let semialgmap_add (l : l) (semialg : semialg) (semialgmap : semialgmap) : semialgmap = LM.add l semialg semialgmap 
let semialgmap_fold_add (semialgmap1 : semialgmap) (semialgmap2 : semialgmap) : semialgmap =
  LM.fold (fun l f semialgmap2 -> LM.add l f semialgmap2) semialgmap1 semialgmap2


let string_of_semialgmap (semialgmap: semialgmap) : string = "(semialgmap: " ^ string_of_list (string_of_pair string_of_l (string_of_semialg)) (LM.bindings semialgmap) ^ ")"
(* type invariant = c_coef semialg LM.t
let string_of_invariant (invariant : invariant) : string = "(invariant: " ^ string_of_list (string_of_pair string_of_l (string_of_c_coef_semialg)) (LM.bindings invariant) ^ ")"
 *)
type config = l * v valuation

let distributions_usage =
  "Unif a b :" ^ "\n\t" ^ "uniform distribution over [a, b]" ^ "\n" ^
  "Unshifted_geom p / Geom p :" ^ "\n\t" ^ "(unshifted) geometric distribution whose probability density function is p(1-p)^n" ^ "\n" ^
  "Shifted_geom p :" ^ "\n\t" ^ "(shifted) geometric distribution whose probability density function is p(1-p)^(n-1)" ^ "\n" ^
  "Norm m s / Gauss m s :" ^ "\n\t" ^ "normal distribution whose mean is m and variance is s^2" ^ "\n" ^
  "Exp l :" ^ "\n\t" ^ "sexponential distribution whose probability density function is le^{-lx}" ^ "\n" ^
  "Disc x1 p1 ... xn pn :" ^ "\n\t" ^ "discrete distribution that takes a value xi in a probability pi" ^ "\n" 


type distr =
  | Unif of float * float
  | Unshifted_geom of float
  | Shifted_geom of float
  | Norm of float * float
  | Exp of float
  | Disc of (float * float) list
let string_of_distr (distr: distr) : string = match distr with
  | Unif (p1, p2) -> "Unif" ^ string_of_float p1 ^ string_of_float p2
  | Shifted_geom p -> "Shifted_geom" ^ string_of_float p
  | Unshifted_geom p -> "Unshifted_geom" ^ string_of_float p
  | Norm (p1, p2) -> "Norm" ^ string_of_float p1 ^ string_of_float p2
  | Exp p -> "Exp" ^ string_of_float p 
  | Disc list -> "Disc" ^ string_of_list (string_of_pair string_of_float string_of_float) list

let raw_moment_from_central_moment (mean: float) (central_moment: int -> float) (n: int) : float =
  let rec loop ret i =
    if i < 0 then ret
    else
      ret +. (float_of_int (combination n i)) *. central_moment i *. (mean ** (float_of_int @@ n-i))
  in
  loop 0. n

let raw_moment (distr: distr) (n: int) : float = 
  if n < 0 then failwith "n<0 in calculating the n-th moment";
  match distr with
  | Unif (param1, param2) ->
     if param1 > param2 then failwith "raw_moment" else
     if param1 = param2 then param1 ** (float_of_int n) else
     (param2 ** (float_of_int n+.1.) -. param1 ** (float_of_int n+.1.))/. (float_of_int n+.1.) /. (param2 -. param1)
  | Unshifted_geom param ->
     param *. polylogarithm (-n) (1.-.param)
  | Shifted_geom param -> 
     (param /. (1.-.param)) *. polylogarithm (-n) (1.-.param)
  | Norm (param1, param2) ->
     let central_moment_norm n =
       if n mod 2 = 1 then 0.
       else (sqrt param2)**(float_of_int n) *. float_of_int (double_factorial (n-1)) in
     raw_moment_from_central_moment param1 central_moment_norm n
  | Exp param -> 
     (float_of_int @@ factorial n) /. (param ** (float_of_int n))
  | Disc discrete_distr ->
     List.fold_left
       (fun moment (x,p)  -> moment +. (x ** (float_of_int n)) *. p)
       0.
       discrete_distr


(*
type interval =
  DInt | DReal | DIntInterval of int * int | DRealInterval of const * const | DOr of dom * dom 
type pcfg_dom = interval list
 *)
type assgn = 
  | Prob_assgn of v * distr
  | Nondet_assgn of  semialg
  | Det_assgn of v * c_coef polynomial
let string_of_assgn (assgn: assgn) : string = match assgn with
  | Prob_assgn (v,distr) -> "Prob_asgn (" ^ string_of_v v ^ ", " ^ string_of_distr distr ^ ")"
  | Nondet_assgn pcfg_dom -> "Nondet_asgn (" ^ string_of_semialg pcfg_dom ^ ")"
  | Det_assgn (v,term) -> "Det_asgn (" ^ string_of_v v ^ ", " ^ string_of_c_coef_polynomial term ^ ")"

(*
let sup (nondet_expr: c_coef polytope) : float =
(** TODO: study polytope for the whole implementation *)
  let matrix, vector = split_c_coef_polytope nondet_expr in
  if List.length vector = 1 then
    let candidate = uminus_c_coef (List.hd vector) in
    let divisor_list = List.hd matrix in
    let c_coef =
      List.fold_left 
        max
        (div_c_coef candidate (List.hd divisor_list))
        (List.map (fun x -> div_c_coef candidate x) (List.tl divisor_list)) in
    float_of_c_coef c_coef
  else
    raise (Unsupported "only 1 variable case is supported currently")
 *)

type 'a fDist = ('a * float) list
let string_of_fDist (string_of_a: 'a -> string) (fDist: 'a fDist) : string = string_of_list (string_of_pair string_of_a string_of_float) fDist
let get_prob (fdist: 'a fDist) (a: 'a) : float = List.assoc a fdist
let fDist_of_list l = l

(* type guard = c_coef polytope list 
let string_of_guard (guard: guard) : string = "(guard: " ^ String.concat "," (List.map string_of_c_coef_polytope guard) ^ ")"
let guard_of_c_coef_polytope_list polytope_list = 
let guard_true = [true_c_coef_polytope]
*)

type f =
  | A of assgn * l    (** lpre |-i,x:=1-> l *)
  | P of l fDist           (** lpre |--> l1 w/ p, l2 w/ 1-p *)
  | ND of (semialg * l) list (** lpre |-x>=0-> l1, |-x<0-> l2 *)
let string_of_f (f: f) : string = match f with
  | A (a,l) -> "A (" ^ string_of_assgn a ^ ", " ^ string_of_l l ^ ")"
  | P f -> "P " ^ string_of_fDist string_of_l f
  | ND f -> "ND " ^ string_of_list (string_of_pair string_of_semialg string_of_l) f
type pcfg_transition = f LM.t
type pcfg = pcfg_transition * l_domain * v_domain
type reachability_problem = pcfg * config * semialgmap * semialgmap 

let pcfg_transition_empty : pcfg_transition = LM.empty
let pcfg_transition_singleton (l : l) (f : f) : pcfg_transition = LM.singleton l f
let pcfg_transition_add (l : l) (f : f) (pcfg_transition : pcfg_transition) : pcfg_transition = LM.add l f pcfg_transition
let pcfg_transition_fold_add (pcfg_transition1 : pcfg_transition) (pcfg_transition2 : pcfg_transition) : pcfg_transition =
  LM.fold (fun l f pcfg_transition2 -> LM.add l f pcfg_transition2) pcfg_transition1 pcfg_transition2
(* 
  let merge_l_list l_list1 l_list2 = function
    | Some (A (v1,assgn1,l1)), Some (A (v,assgn,l)) -> 
Some (List.rev_append l_list1 l_list2)
    | None, Some f | Some f, None -> Some f
    | None, None -> None in
  Pcfg.LM.merge merge_l_list pcfg_transition1 pcfg_transition2
 *)
