open Util
open Variable
open Coefficient
open Semialg

(** === slim data types === *)

(** === vector, matrix === *)
type 'coef vector = 'coef list
val string_of_vector : ('coef -> string) -> 'coef vector -> string
val vector_size : 'coef vector -> int

type 'coef matrix = 'coef vector list
val string_of_matrix : ('coef -> string) -> 'coef matrix -> string

(** operations on data types *)
val transpose_vector : 'coef vector -> 'coef matrix
val transpose_matrix : int -> 'coef matrix -> 'coef matrix

(* val split_ineq : ('coef -> 'coef) -> (('coef * v) -> bool) -> 'coef -> 'coef ineq -> 'coef vector * 'coef *)
val split_c_coef_ineq : v list -> c_coef ineq -> c_coef vector * c_coef
val split_p_coef_ineq : v list -> p_coef ineq -> p_coef vector * p_coef

(* val split_and_ineq_list : ('coef -> 'coef) -> (('coef * v) -> bool) -> 'coef -> 'coef and_ineq_list -> 'coef matrix * 'coef vector *)
val split_c_coef_and_ineq_list : v list -> and_ineq_list -> c_coef matrix * c_coef vector
