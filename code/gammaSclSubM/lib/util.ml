exception Err of string
exception Unsupported of string

let rec string_of_list_infix_string string_of_a ?string_of_empty_list:(string_of_empty_list="") list s =
  if list = [] then string_of_empty_list else
  let buf = Buffer.create ((String.length (string_of_a (List.hd list)) + 5) * List.length list) in
  let rec string_of_list_infix_string_sub list =
    match list with
    | [] -> failwith "string_of_list_infix_string"
    | hd :: [] -> Buffer.add_string buf (string_of_a hd)
    | hd :: tl -> Buffer.add_string buf (string_of_a hd ^ s); string_of_list_infix_string_sub tl in
  string_of_list_infix_string_sub list;
  Buffer.contents buf
(*
  let rec string_of_list_infix_string_sub ret list =
    match list with
    | [] -> failwith "string_of_list_infix_string"
    | hd :: [] -> ret ^ string_of_a hd
    | hd :: tl -> string_of_list_infix_string_sub (ret ^ string_of_a hd ^ s) tl  in
  string_of_list_infix_string_sub "" list
 *)

let string_of_list (string_of_a: 'a -> string) (list: 'a list) : string =
  "[" ^ string_of_list_infix_string string_of_a list "; " ^ "]"  

let string_of_pair (string_of_a: 'a -> string) (string_of_b: 'b -> string) ((a, b): 'a * 'b) : string =
  "(" ^ string_of_a a ^ ", " ^ string_of_b b ^ ")"

let string_of_int_binary (n: int) : string =
  let rec loop ret n =
    if n = 0 then ret
    else if n land 1 = 1 then loop ("1" ^ ret) (n lsr 1) 
    else loop ("0" ^ ret) (n lsr 1) in
  loop "" n

let string_of_int_hexadecimal (n: int) : string =
  if n = 0 then "0" else
  let rec loop ret n =
    if n = 0 then ret else
    let lower = n land 15 in
    let s =
      if lower =  0 then "0" else
      if lower =  1 then "1" else
      if lower =  2 then "2" else
      if lower =  3 then "3" else
      if lower =  4 then "4" else
      if lower =  5 then "5" else
      if lower =  6 then "6" else
      if lower =  7 then "7" else
      if lower =  8 then "8" else
      if lower =  9 then "9" else
      if lower = 10 then "a" else
      if lower = 11 then "b" else
      if lower = 12 then "c" else
      if lower = 13 then "d" else
      if lower = 14 then "e" else
      if lower = 15 then "f" else
      failwith "string_of_int_hexadecimal"
    in
    loop (s ^ ret) (n lsr 4) in
  loop "" n

let remove_elt e l =
  let rec go l acc = match l with
    | [] -> List.rev acc
    | x::xs when e = x -> go xs acc
    | x::xs -> go xs (x::acc)
  in go l []
let remove_duplicates l =
  let rec go l acc = match l with
    | [] -> List.rev acc
    | x :: xs -> go (remove_elt x xs) (x::acc)
  in go l []

let is_duplicate l =
  let rec go l = match l with
    | [] -> false
    | x :: xs -> (List.mem x xs) || go xs
  in go l  

let (--) i j = 
  let rec aux n acc =
    if n < i then acc else aux (n-1) (n :: acc)
  in aux j []

let rec list_of_length_n n a =
  if n <= 0 then []
  else a :: list_of_length_n (n-1) a

let rec n_cartesian_product = function
  | [] -> [[]]
  | x :: xs ->
    let rest = n_cartesian_product xs in
    List.concat (List.map (fun i -> List.map (fun rs -> i :: rs) rest) x)  

let cartesian list n =
  let n_of_list = list_of_length_n n list in
  n_cartesian_product n_of_list

let assoc_of_rev_pair lst l =
  let rev_pair_lst =
    let p1_lst, p2_lst = List.split lst in
    List.combine p2_lst p1_lst in
  List.assoc l rev_pair_lst

let assoc_opt_of_rev_pair lst l =
  let rev_pair_lst =
    let p1_lst, p2_lst = List.split lst in
    List.combine p2_lst p1_lst in
  List.assoc_opt l rev_pair_lst

let factorial n =
  let rec factorial_sub ret n =
    if n <= 1 then ret
    else factorial_sub (n*ret) (n-1) in
  factorial_sub 1 n

let double_factorial n =
  let rec factorial_sub ret n =
    if n <= 1 then ret
    else factorial_sub (n*ret) (n-2) in
  factorial_sub 1 n 

let combination n k =
  if k < 0 || n < k then raise (Invalid_argument "Util.stirling_partition_number");
  let arr = Array.make (k+1) 0 in
  arr.(0) <- 1;
  for i=1 to n do
    let x = max 1 (k-n+i) in
    let y = (min i k) in
    for j = 0 to y - x  do
      arr.(y-j) <- arr.(y-j-1) + arr.(y-j)
    done
  done;
  arr.(k)


let stirling_partition_number n k =
  (* stirling_partition_number (i+1) (j+1) = (j+1) * stirling_partition_number i (j+1) + stirling_partition_number i j *)
  if k < 0 || n < k then raise (Invalid_argument "Util.stirling_partition_number");
  let arr = Array.make (k+1) 0 in
  arr.(0) <- 1;
  for i=1 to n do
    let x = max 1 (k-n+i) in
    let y = (min i k) in
    for j = 0 to y - x  do
      arr.(y-j) <- (y-j) * arr.(y-j) + arr.(y-j-1)
    done;
    arr.(0) <- 0
  done;
  arr.(k)


let polylogarithm s z =
  if s > 0 then invalid_arg "Util.polylogarithm (Li_n(z) where n > 0 is not supported)";
  if s = 0 then z /. (1. -. z) else
  let n = -s in
  let rec loop ret k =
    if k < 0 then ret else
    if k mod 2 = 0 then
      loop (ret -. float_of_int (factorial k * stirling_partition_number (n+1) (k+1)) /. (1.-.z)**(float_of_int (k+1))) (k-1)
    else 
      loop (ret +. float_of_int (factorial k * stirling_partition_number (n+1) (k+1)) /. (1.-.z)**(float_of_int (k+1))) (k-1) in
  if n mod 2 = 0 then -.(loop 0. n)
  else loop 0. n
  
let pow2 n = 1 lsl n

let buffer_add_line buf s = Buffer.add_string buf (s^"\n")
