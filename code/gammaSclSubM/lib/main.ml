open Util
open Variable
open Pcfg
open Sostools
open Sequent
open Eval
open Progmath

(* The main program. This program receives a pseudocode of probabilistic program (.pp file)
and outputs the description of reachability problem that is ready to be solved by an LP or SDP
solver (.mod file or .m file, depending on the template type). *)


(*template type: linear or polynomial*)
type template_type = Lin | Poly

let _ =
  if Array.length Sys.argv <= 1 then Printf.eprintf "Error: please specify an input file.\n" else (*notice the first element of Sys.argv is ./main*)
  if Array.get Sys.argv 1 = "-distr_usage" then print_endline distributions_usage else

  (* in_file gets the (raw) name of the input .pp file.
  the input should be declared as the first option (./main xxx.pp ...) *)
  let in_file = Array.get Sys.argv 1 in

  (* search_argv returns the element in the list l next to the element s.
  This is useful to define options of the form '-xxx yyy' *)
  let rec search_argv s l = match l with
    | x::y::l' ->
       (match x with
        | s' when s' = s -> Some y
        | s' -> search_argv s (y::l'))
    | _ -> None in

  (* argvtl returns the list of options in Sys.argv, eliminating './main xxx.pp' *)
  let argvtl = List.tl @@ List.tl @@ Array.to_list Sys.argv in

  (* file_name returns the file name of the input without directory info and extension.
  For example, if the input is hoge/huga.pp, then file_name returns huga *)
  let file_name = try Filename.chop_extension (Filename.basename in_file) with _ -> in_file in

  (* template_type defines options that specify the type of template *)
  let template_type =
    if List.mem "-lin" argvtl || List.mem "-linear" argvtl then Lin
    else if List.mem "-poly" argvtl || List.mem "-polynomial" argvtl then Poly
    else if List.mem "-sch" argvtl || List.mem "-schumuedgen" argvtl || List.mem "-put" argvtl || List.mem "-putinar" argvtl || List.mem "-deg" argvtl || List.mem "-sosdeg" argvtl || List.mem "-sdp_prog_name" argvtl then (print_endline ("template : polynomial"); Poly)
    else (print_endline ("template : linear"); Lin) in

  (* gamma defines options that specify the range of the gamma parameter (a.k.a. discount factor) *)
  let gamma =
    match search_argv "-gamma" argvtl with
    | None -> print_endline "gamma = 0.9"; Eq 0.9
    | Some gamma_s -> 
       if (String.length gamma_s >= 3 && String.sub gamma_s 0 3 = "geq") then Geq (float_of_string (String.sub gamma_s 3 (String.length gamma_s-3)))
       else if (String.length gamma_s >= 2 && String.sub gamma_s 0 2 = "eq") then Eq (float_of_string (String.sub gamma_s 2 (String.length gamma_s-2))) 
       else Eq (float_of_string gamma_s) in
     if (let s = match gamma with | Geq s | Eq s -> s in s < 0. || 1.<= s) then Printf.eprintf "Error: gamma should be: 0 <= gamma < 1.\n" else



  (* Process the input file by lexer and parser *)
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

  (* Compute the content of the output result, and the filename out_file *)
  let (out_file, result) : string * string =
    match template_type with
    | Lin ->
       let out_file =
         match (search_argv "-o" @@  argvtl) with
         | None ->
            let out_file =
              file_name ^ "_lin_g" ^ (match gamma with Eq f -> string_of_int (int_of_float (10000.0 *. f)) | Geq f -> "geq" ^ string_of_int (int_of_float (10000.0 *. f))) in
            if String.length out_file > 60 then String.sub out_file 0 60 ^ ".mod " else out_file ^ ".mod"
         | Some o -> o in
       let progmath =
         match gamma with
         | Eq s -> progmath_of_reachability_problem problem s
         | Geq _ -> failwith "-gamma >=... allowed only for polynomial templates" in
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
              file_name ^ "_poly_d" ^ string_of_int template_deg ^ "_g" ^ (match gamma with Eq f -> string_of_int (int_of_float (10000.0 *. f)) | Geq f -> "geq" ^ string_of_int (int_of_float (10000.0 *. f))) ^ "_sd" ^ string_of_int sos_deg  ^ (if sostools_opt then "_sopt" else "") ^ (match positivstellensatz with Sch -> "_sch" | Put -> "_put") in
            if String.length out_file > 60 then String.sub out_file 0 60 ^ ".m " else out_file ^ ".m"
         | Some o -> o in
       let sostools = sostools_of_reachability_problem problem gamma template_deg sos_deg sdp_prog_name positivstellensatz sostools_opt solver vsdp in
       (out_file, sostools) in


(* Output a file with its content result and its name out_file *)
  let oc = open_out out_file in
  (try
    Printf.fprintf oc "%s" result;
    flush oc;
    close_out oc
  with e ->
    close_out_noerr oc;
    raise e);
  flush stdout

