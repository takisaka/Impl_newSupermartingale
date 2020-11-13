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

(* abstract syntax tree *)
type ast =
  | StAssgn of assgn
  | StSkip
  | StSeq of ast * ast
  | StIf of ndbexpr * ast * ast
  | StWhile of bexpr * ast
  | StAssume of bexpr (** assume declares an invariant in the next location *)
  | StAssert of bexpr (** assert declares termination configuration *)

(** prog comes with a global invariant *)
type prog = Prog of bexpr * ast 

(** operations on data type *)
val and_affexpr : affexpr -> affexpr -> affexpr

val and_bexpr : bexpr -> bexpr -> bexpr
val or_bexpr : bexpr -> bexpr -> bexpr
val not_bexpr : bexpr -> bexpr

(** for debug *)
val string_of_id : id -> string

val string_of_const : const -> string
val string_of_dist : dist -> string
val string_of_pvar : pvar -> string

val string_of_expr : expr -> string
val string_of_literal : literal -> string
val string_of_affexpr : affexpr -> string
val string_of_bexpr : bexpr -> string
val string_of_ndbexpr : ndbexpr -> string

val string_of_dom : dom -> string
val string_of_assgn : assgn -> string
val string_of_ast : ast -> string
val string_of_prog : prog -> string
