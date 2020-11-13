open Coefficient
open Polynomial
open Pcfg
open Sequent


type positivstellensatz = Sch | Put



val sostools_of_reachability_problem : reachability_problem -> float option -> const_type -> int -> int -> string -> string -> positivstellensatz -> bool -> string
