open Variable
open Polynomial
open Syntax
(* == open Pcfg ==
   we don't open Pcfg module since it's confssssing when mixed with Syntax module
*)

(* type alphabet =
 *   | AlpA of v * Pcfg.assgn
 *   | AlpD of Pcfg.guard
 *   | AlpP of float
 *   | AlpN
 * type half_edge = Pcfg.l * alphabet
 * type edge = Pcfg.l * alphabet * Pcfg.l
 * type pcfg_seed = Pcfg.l * edge list * half_edge list *)

val v_list_from_ast : ast -> v list
val eval : prog -> Pcfg.pcfg * Pcfg.config * Pcfg.semialgmap * Pcfg.semialgmap
