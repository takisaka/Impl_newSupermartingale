open Util
open Variable
open Pcfg
open Sostools
open Sequent
open Eval
open Progmath

type template_type = Lin | Poly

let _ =
  if Array.length Sys.argv <= 1 then Printf.eprintf "Error: please specify an input file.\n" else
  if Array.get Sys.argv 1 = "-distr_usage" then print_endline distributions_usage else
  let in_file = Array.get Sys.argv 1 in
  let rec search_argv s l = match l with
    | x::y::l' ->
       (match x with
        | s' when s' = s -> Some y
        | s' -> search_argv s (y::l'))
    | _ -> None in
  let argvtl = List.tl @@ List.tl @@ Array.to_list Sys.argv in
  let file_name = try Filename.chop_extension (Filename.basename in_file) with _ -> in_file in

  let template_type =
    if List.mem "-lin" argvtl || List.mem "-linear" argvtl then Lin
    else if List.mem "-poly" argvtl || List.mem "-polynomial" argvtl then Poly
    else if List.mem "-sch" argvtl || List.mem "-schumuedgen" argvtl || List.mem "-put" argvtl || List.mem "-putinar" argvtl || List.mem "-deg" argvtl || List.mem "-sosdeg" argvtl || List.mem "-sdp_prog_name" argvtl then (print_endline ("template : polynomial"); Poly)
    else (print_endline ("template : linear"); Lin) in

  let delta, delta_str =
    match search_argv "-delta" argvtl with
    | None -> None, "D"
    | Some x -> let delta = float_of_string x in
                Some delta, string_of_int (int_of_float (10000.0 *. delta)) in

  let nn = match search_argv "-N" argvtl with
    | None -> print_endline "N : 100"; 100
    | Some s -> int_of_string s in

  
  let ic = open_in in_file in
  let prog: Syntax.prog =
    try
      let ret = Parser.program Lexer.main (Lexing.from_channel ic) in
      close_in ic;
      ret
    with e -> close_in_noerr ic; raise e in
  
  let (pcfg_transition, l_domain, v_domain), init_config, invariant, term_linpredmap = eval prog in
  let problem: reachability_problem =
      (pcfg_transition, l_domain, v_domain),
      init_config,
      invariant,
      term_linpredmap in
  let (out_file, result) : string * string =
    match template_type with
    | Lin ->
       let out_file =
         match (search_argv "-o" @@  argvtl) with
         | None ->
            let out_file =
              file_name ^ "_lin_g" ^ delta_str ^ "_" ^ (string_of_int nn) in
            if String.length out_file > 60 then String.sub out_file 0 60 ^ ".mod " else out_file ^ ".mod"
         | Some o -> o in
       let progmath = progmath_of_reachability_problem problem delta nn in
       (out_file, progmath)
    | Poly ->
       let solver =
         match search_argv "-solver"  argvtl with
         | None -> print_endline "sover : sedumi"; "sedumi"
         | Some solver -> solver in
       let vsdp =
         if List.mem "-vsdp" argvtl then true else false in
       let template_deg =
         match search_argv "-deg"  argvtl with
         | None -> print_endline "template degree = 2"; 2
         | Some deg -> int_of_string deg in
       let sos_deg = 
         match search_argv "-sosdeg"  argvtl with
         | None -> print_endline "sos degree = 1"; 1
         | Some deg -> int_of_string deg in
       let sdp_prog_name = 
         match search_argv "-sdpprogname"  argvtl with
         | None -> print_endline ("sdp prog name = " ^ file_name); file_name 
         | Some name -> name in
       let sostools_opt = List.mem "-sostools_opt" argvtl in
       let positivstellensatz = 
         if List.mem "-sch" argvtl || List.mem "-schumuedgen" argvtl then Sch else
           if List.mem "-put" argvtl || List.mem "-putinar" argvtl then Put else
             (print_endline ("Positivstellensatz : Schumuedgen"); Sch) in
       if template_deg < 0 then failwith "Error: template degree should be: 0 <= deg.\n" else
       let out_file =
         match (search_argv "-o" @@  argvtl) with
         | None ->
            let out_file =
              file_name ^ "_poly_d" ^ string_of_int template_deg ^ "_g" ^ delta_str ^ "_" ^ string_of_int nn ^ "_sd" ^ string_of_int sos_deg  ^ (if sostools_opt then "_sopt" else "") ^ (match positivstellensatz with Sch -> "_sch" | Put -> "_put") in
            if String.length out_file > 60 then String.sub out_file 0 60 ^ ".m " else out_file ^ ".m"
         | Some o -> o in
       let sostools = sostools_of_reachability_problem problem delta nn template_deg sos_deg sdp_prog_name positivstellensatz sostools_opt solver vsdp in
       (out_file, sostools) in

  let oc = open_out out_file in
  (try
    Printf.fprintf oc "%s" result;
    flush oc;
    close_out oc
  with e ->
    close_out_noerr oc;
    raise e);
  flush stdout

