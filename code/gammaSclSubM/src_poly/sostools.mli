open Coefficient
open Polynomial
open Pcfg
open Sequent


type positivstellensatz = Sch | Put

type gamma = Eq of float | Geq of float 


val sostools_of_reachability_problem : reachability_problem -> gamma -> int -> int -> string -> positivstellensatz -> bool -> string -> bool -> string
