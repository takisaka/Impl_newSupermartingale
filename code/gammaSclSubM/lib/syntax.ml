type id = string 

type const = Const  of float
type dist = Dist of id * const list
type pvar = PVar of id

type expr =
  | EConst of const
  | EVar of pvar
  | EAdd of expr * expr
  | ESub of expr * expr
  | EMult of expr * expr
type literal =
  | LitLeq of expr * expr
  | LitGeq of expr * expr
  | LitNot of literal
type affexpr =
  | AffUnit
  | AffAnd of literal * affexpr
type bexpr =
  | BexpUnit
  | BexpOr of affexpr * bexpr
type ndbexpr =
  | Ndet_branch
  | Prob_branch of const
  | Det_branch of bexpr

type dom =
  | DInt
  | DReal
  | DIntInterval of const * const
  | DRealInterval of const * const
  | DOr of dom * dom

type assgn =
  | AsnDet of pvar * expr
  | AsnNdet of pvar * dom
  | AsnProb of pvar * dist 

type ast =
  | StAssgn of assgn
  | StSkip
  | StSeq of ast * ast
  | StIf of ndbexpr * ast * ast | StWhile of bexpr * ast
  | StAssume of bexpr (** assume declares an invariant in the next location *)
  | StAssert of bexpr (** assert declares termination configuration *)

(** prog comes with a global invariant *)
type prog = Prog of bexpr * ast 

(** operations on data type *)
let rec or_bexpr (arg_b1: bexpr) (arg_b2: bexpr) : bexpr =
  (* termination proof: b1 < arg_b1 *)
  match arg_b1 with
  | BexpUnit -> arg_b2
  | BexpOr(a1, b1) -> BexpOr (a1, or_bexpr b1 arg_b2) 

let rec and_affexpr (arg_a1: affexpr) (arg_a2: affexpr) : affexpr =
  (* termination proof: a1 < arg_a1 *)
  match arg_a1, arg_a2 with
  | AffUnit, a | a, AffUnit -> a
  | AffAnd (l1, a1), AffAnd (l2, a2) -> AffAnd (l1, AffAnd(l2, and_affexpr a1 a2))

let rec and_bexpr (arg_b1: bexpr) (arg_b2: bexpr) : bexpr =
  let rec and_affexpr_bexpr (arg_a1: affexpr) (arg_b2: bexpr) : bexpr =
    (* termination proof: a2 < arg_a2 and b2 < arg_b2 *)
    match arg_b2 with
    | BexpUnit -> BexpUnit
    | BexpOr (a2, b2) ->
      (* argA1 /\ (A2 \/ B2) = (argA1 /\ A2) \/ (argA1 /\ B2) *)
      BexpOr(and_affexpr arg_a1 a2, and_affexpr_bexpr arg_a1 b2)
  in
  (* termination proof: b1 < arg_b1 *)
  match arg_b1, arg_b2 with
  | BexpUnit, _ | _, BexpUnit -> BexpUnit (* since for all x. false /\ x = false *)
  | BexpOr (a1, b1), arg_b2 ->
    (* (A1 \/ B1) /\ (A2 \/ B2)
       = (A1 /\ (A2 \/ B2)) \/ (B1 /\ (A2 \/ B2))
    *)
    or_bexpr (and_affexpr_bexpr a1 arg_b2) (and_bexpr b1 arg_b2)

let rec not_bexpr : bexpr -> bexpr =
  let rec bexp_of_not_affexpr : affexpr -> bexpr = function
    | AffUnit -> BexpUnit
    | AffAnd (literal, affexpr) ->
      (* not (A1 /\ A2) = not A1 \/ not A2 *)
      BexpOr (AffAnd(LitNot literal, AffUnit), bexp_of_not_affexpr affexpr)
  in
  function
  | BexpUnit -> BexpOr(AffUnit, BexpUnit)
  | BexpOr (affexpr, bexpr) ->
    (* not (A1 \/ A2) = not A1 /\ not A2 *)
    and_bexpr (bexp_of_not_affexpr affexpr) (not_bexpr bexpr)

(** for debug *)
let string_of_id x = x

let string_of_const (Const x) = "Const " ^ string_of_float x
let string_of_list (string_of_a: 'a -> string) (list: 'a list) : string =
  let rec sub list = 
    match list with
    | [] -> ""
    | a::[] -> string_of_a a
    | a::b::list-> string_of_a a  ^ "; " ^ sub (b::list)
  in "[" ^ sub list ^ "]"  
let string_of_dist (Dist(id, const_list)) = "Dist (" ^ id ^ ", "^ string_of_list string_of_const const_list ^ ")"
let string_of_pvar (PVar id) = "PVar " ^ id

let rec string_of_expr = function
  | EConst const -> "EConst " ^ string_of_const const
  | EVar pvar -> "EVar " ^ string_of_pvar pvar
  | EAdd (e1, e2) -> "EAdd (" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | ESub (e1, e2) -> "ESub (" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | EMult (e1, e2) -> "EMult (" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
let rec string_of_literal = function
  | LitLeq (e1, e2) -> "LitLeq (" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | LitGeq (e1, e2) -> "LitGeq (" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | LitNot literal ->  "LitNot " ^ string_of_literal literal
let rec string_of_affexpr = function
  | AffAnd (lit,AffUnit) -> "AffAnd (" ^ string_of_literal lit ^ ", AffUnit)"
  | AffAnd (lit, aff) -> "AffAnd (" ^ string_of_literal lit ^ ", " ^ string_of_affexpr aff  ^ ")"
  | AffUnit -> "AffUnit (True)"
let rec string_of_bexpr = function
  | BexpOr (affexpr, BexpUnit) -> "BexpOr( " ^ string_of_affexpr affexpr ^ ", BexpUnit)"
  | BexpOr (affexpr, bexpr) -> "BexpOr (" ^ string_of_affexpr affexpr ^ ", " ^ string_of_bexpr bexpr  ^ ")"
  | BexpUnit -> "BexpUnit (False)"
let string_of_ndbexpr = function
  | Ndet_branch -> "Ndet_branch"
  | Prob_branch const -> "Prob_branch " ^ string_of_const const
  | Det_branch bexpr -> "Det_branch " ^ string_of_bexpr bexpr
let rec string_of_dom = function
  | DInt -> "DInt"
  | DReal -> "DReal"
  | DIntInterval (c1, c2) -> "DIntInterval (" ^ string_of_const c1 ^ ", " ^ string_of_const c2 ^ ")" 
  | DRealInterval (c1, c2) -> "DRealInterval (" ^ string_of_const c1 ^ ", " ^ string_of_const c2 ^ ")" 
  | DOr (d1, d2) -> "DOr (" ^ string_of_dom d1 ^ ", " ^ string_of_dom d2 ^ ")" 
let string_of_assgn = function
  | AsnDet (pvar, expr) -> "Det_assgn (" ^ string_of_pvar pvar ^ ", " ^ string_of_expr expr ^ ")"
  | AsnNdet (pvar, dom) -> "Ndet_assgn (" ^ string_of_pvar pvar ^ ", " ^ string_of_dom dom ^ ")"
  | AsnProb (pvar, dist) -> "Prob_assgn (" ^ string_of_pvar pvar ^ ", " ^ string_of_dist dist ^ ")"
let rec string_of_ast = function
  | StAssgn assgn -> "StAssgn " ^ string_of_assgn assgn
  | StSkip -> "StSkip"
  | StSeq (s1, s2) -> "StSeq (" ^ string_of_ast s1 ^ ", " ^ string_of_ast s2 ^ ")"
  | StIf (ndbexpr, s1, s2) -> "StIf (" ^ string_of_ndbexpr ndbexpr ^ ", " ^ string_of_ast s1 ^ ", " ^ string_of_ast s2 ^ ")"
  | StWhile (bexpr, ast) -> "StWhile (" ^ string_of_bexpr bexpr ^ ", " ^ string_of_ast ast ^ ")"
  | StAssume bexpr -> "StAssume (" ^ string_of_bexpr bexpr ^  ")"
  | StAssert bexpr -> "StAssert (" ^ string_of_bexpr bexpr ^  ")"

let string_of_prog = function
  | Prog (bexprg, ast) -> "<" ^ string_of_bexpr bexprg ^ "> " ^ string_of_ast ast 
