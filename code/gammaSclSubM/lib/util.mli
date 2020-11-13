exception Err of string
exception Unsupported of string

val string_of_list : ('a -> string) -> 'a list -> string
val string_of_pair : ('a -> string) -> ('b -> string) -> 'a * 'b -> string
val string_of_int_binary : int -> string
val string_of_int_hexadecimal : int -> string
val remove_duplicates : 'a list -> 'a list
val is_duplicate : 'a list -> bool
val string_of_list_infix_string : ('a -> string) -> ?string_of_empty_list:string -> 'a list -> string -> string

val ( -- ) : int -> int -> int list

val list_of_length_n : int -> 'a -> 'a list

val n_cartesian_product : 'a list list -> 'a list list 

val cartesian : 'a list -> int -> 'a list list

val assoc_of_rev_pair : ('a * 'b) list -> 'b -> 'a

val assoc_opt_of_rev_pair : ('a * 'b) list -> 'b -> 'a option

val factorial : int -> int
val double_factorial : int -> int

val combination   : int -> int -> int
val polylogarithm : int -> float -> float

val pow2 : int -> int

val buffer_add_line : Buffer.t -> string -> unit
