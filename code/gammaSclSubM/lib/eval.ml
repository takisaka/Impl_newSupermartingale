open Util
open Variable
open Coefficient
open Polynomial
open Semialg
open Syntax
(* == open Pcfg ==
   we don't open Pcfg module since it's confssssing when mixed with Syntax module
*)

let cnt = ref (-1)
let get_new_location : unit -> Pcfg.l =
  fun _ -> cnt := !cnt + 1; Pcfg.l_of_string ("l" ^ (string_of_int !cnt))


let v_of_pvar (PVar id) : v = v_of_string id
let v_list_from_ast (ast: ast): v list =
  let v_list_from_const (const: const) : v list = [] in
  let v_list_from_dist (dist: dist) : v list = [] in
  let v_list_from_dom (dom: dom) : v list = [] in
  let rec v_list_from_expr (expr: expr) : v list = match expr with
    | EConst const -> v_list_from_const const
    | EVar pvar -> [v_of_pvar pvar]
    | EAdd (expr1, expr2) | ESub (expr1, expr2) | EMult (expr1, expr2) ->
      v_list_from_expr expr1 @ v_list_from_expr expr2
  in
  let rec v_list_from_literal (literal: literal) : v list = match literal with
    | LitLeq (expr1, expr2) ->
      v_list_from_expr expr1 @ v_list_from_expr expr2
    | LitGeq (expr1, expr2) ->
      v_list_from_expr expr1 @ v_list_from_expr expr2
    | LitNot literal ->
      v_list_from_literal literal
  in
  let rec v_list_from_affexpr (affexpr: affexpr) : v list = match affexpr with
    | AffUnit -> []
    | AffAnd (literal, affexpr) ->
      v_list_from_literal literal @ v_list_from_affexpr affexpr
  in
  let rec v_list_from_bexpr (bexpr: bexpr) : v list = match bexpr with
    | BexpUnit -> []
    | BexpOr (affexpr, bexpr) ->
      v_list_from_affexpr affexpr @ v_list_from_bexpr bexpr
  in
  let v_list_from_ndbexpr (ndbexpr: ndbexpr) : v list = match ndbexpr with
    | Ndet_branch -> []
    | Prob_branch const -> v_list_from_const const
    | Det_branch bexpr -> v_list_from_bexpr bexpr
  in
  let rec sub_v_list_from_ast (ast: ast) : v list =
    match ast with
    | StAssgn assgn -> 
      (match assgn with
       | AsnDet (pvar, expr) -> [v_of_pvar pvar] @ v_list_from_expr expr
       | AsnNdet (pvar, dom) -> [v_of_pvar pvar] @ v_list_from_dom dom
       | AsnProb (pvar, dist) -> [v_of_pvar pvar] @ v_list_from_dist dist
      )
    | StSkip -> []
    | StSeq (ast1, ast2) ->
      sub_v_list_from_ast ast1 @ sub_v_list_from_ast ast2
    | StIf (ndbexpr, ast1, ast2) ->
      v_list_from_ndbexpr ndbexpr @ sub_v_list_from_ast ast1 @ sub_v_list_from_ast ast2
    | StWhile (bexpr, ast) ->
      v_list_from_bexpr bexpr @ sub_v_list_from_ast ast
    | StAssume bexpr | StAssert bexpr ->
      v_list_from_bexpr bexpr 
  in
  remove_duplicates @@ sub_v_list_from_ast ast


let c_coef_polynomial_of_const (Const float: const) : c_coef polynomial =
  c_coef_polynomial_of_c_coef @@ c_coef_of_float float
let c_coef_polynomial_of_pvar (PVar id: pvar) : c_coef polynomial =
  c_coef_polynomial_of_monomial @@ monomial_of_v_int (v_of_string id) 1
let rec c_coef_polynomial_of_expr (expr: expr) : c_coef polynomial = match expr with
  | EConst const -> c_coef_polynomial_of_const const
  | EVar pvar -> c_coef_polynomial_of_pvar pvar
  | EAdd (expr1, expr2) ->
    add_c_coef_polynomial (c_coef_polynomial_of_expr expr1) (c_coef_polynomial_of_expr expr2)
  | ESub (expr1, expr2) ->
    add_c_coef_polynomial
      (c_coef_polynomial_of_expr expr1)
      (uminus_c_coef_polynomial @@ c_coef_polynomial_of_expr expr2)
  | EMult (expr1, expr2) ->
    mult_c_coef_polynomial 
      (c_coef_polynomial_of_expr expr1)
      (c_coef_polynomial_of_expr expr2)

let v_assgn_of_assgn : assgn -> Pcfg.assgn = function
  | AsnDet (pvar, expr) ->
     Pcfg.Det_assgn (v_of_pvar pvar,  c_coef_polynomial_of_expr expr)
  | AsnProb (pvar, (Dist (name, param_list) as dist)) ->
     if name = "Geom" then
       Printf.eprintf "Warning: Geom is regarded as Unshifted_geom, which takes values in {0,1,2,...}\n";
    (if name = "Unif" then
       (match param_list with
       | Const f1 :: Const f2 :: [] ->  (Pcfg.Prob_assgn (v_of_pvar pvar, Pcfg.Unif (f1, f2)))
       | _ -> failwith @@ "syntax error: " ^ string_of_dist dist
       )
    else if name = "Unshifted_geom" || name = "Geom" then
       (match param_list with
       | Const f1 :: [] ->  (Pcfg.Prob_assgn (v_of_pvar pvar, Pcfg.Unshifted_geom f1))
       | _ -> failwith @@ "syntax error: " ^ string_of_dist dist
       )
    else if name = "Shifted_geom" then
       (match param_list with
       | Const f1 :: [] ->  (Pcfg.Prob_assgn (v_of_pvar pvar, Pcfg.Shifted_geom f1))
       | _ -> failwith @@ "syntax error: " ^ string_of_dist dist
       )
    else if name = "Exp" then
       (match param_list with
       | Const f1 :: [] ->  (Pcfg.Prob_assgn (v_of_pvar pvar, Pcfg.Exp f1))
       | _ -> failwith @@ "syntax error: " ^ string_of_dist dist
       )
    else if name = "Norm" || name = "Gauss" then
       (match param_list with
       | Const f1 :: Const f2 :: [] -> (Pcfg.Prob_assgn (v_of_pvar pvar, Pcfg.Norm (f1, f2)))
       | _ -> failwith @@ "syntax error: " ^ string_of_dist dist
       )
    else if name = "Disc" then
       let rec get_prob_values ret = function
         | [] -> ret
         | Const f1 :: Const f2 :: rest -> get_prob_values ((f1,f2)::ret) rest
         | _ -> failwith @@ "syntax error: " ^ string_of_dist dist in
       Pcfg.Prob_assgn (v_of_pvar pvar, Pcfg.Disc (get_prob_values [] param_list)) 
    else
      failwith @@ "undefined distribution: " ^ name
   )
  | AsnNdet (pvar, dom) ->
    let rec semialg_of_dom : dom -> semialg = function
      | DInt -> failwith "DInt: not supported"
      | DReal -> true_semialg
      | DIntInterval (c1, c2) -> failwith "DIntInterval: not supported"
      | DRealInterval (Const f1, Const f2) ->
         semialg_of_and_ineq_list @@ 
         and_ineq_list_of_c_coef_ineq_list
           [c_coef_ineq_of_c_coef_polynomials (c_coef_polynomial_of_c_coef @@ c_coef_of_float f1, LEQ, c_coef_polynomial_of_monomial @@ monomial_of_v_int (v_of_pvar pvar) 1);
            c_coef_ineq_of_c_coef_polynomials (c_coef_polynomial_of_monomial @@ monomial_of_v_int (v_of_pvar pvar) 1, LEQ, c_coef_polynomial_of_c_coef @@ c_coef_of_float f2)] 
      | DOr (d1, d2) ->
         or_semialg (semialg_of_dom d1) (semialg_of_dom d2)
    in 
    Pcfg.Nondet_assgn (semialg_of_dom dom)


(*  exponential blowup in general *)
let rec not_bexpr (bexpr : bexpr) : bexpr =
  let rec not_bexpr_sub (resulting_bexpr : bexpr) (bexpr : bexpr) : bexpr =
  match bexpr with 
  | BexpUnit ->resulting_bexpr
  | BexpOr (affexpr, bexpr') -> 
     let rec cons_affexpr (resulting_bexpr' : bexpr) (affexpr : affexpr) : bexpr =
       match affexpr with
       | AffUnit -> resulting_bexpr'
       | AffAnd (literal, affexpr') ->
          let not_literal =
            match literal with 
            | LitNot literal' -> literal'
            | _ -> LitNot literal in
          let rec cons_literal (resulting_bexpr'' : bexpr) (base_bexpr'' : bexpr) : bexpr =
            match base_bexpr'' with
            | BexpUnit -> resulting_bexpr''
            | BexpOr (affexpr'', bexpr'') ->
               cons_literal (BexpOr (AffAnd (not_literal, affexpr''), resulting_bexpr'')) bexpr'' in
          cons_affexpr (cons_literal resulting_bexpr' resulting_bexpr) affexpr' in
     not_bexpr_sub (cons_affexpr BexpUnit affexpr) bexpr' in
(*  print_string ("\n" ^ string_of_bexpr bexpr ^ " -> ");
  print_string (string_of_bexpr (not_bexpr_sub (BexpOr(AffUnit,BexpUnit)) bexpr) ^ "\n"); *)
  not_bexpr_sub (BexpOr(AffUnit,BexpUnit)) bexpr


let rec c_coef_ineq_of_literal : literal -> c_coef ineq = function
  | LitLeq (e1, e2) ->
    c_coef_ineq_of_c_coef_polynomials (c_coef_polynomial_of_expr e1, LEQ, c_coef_polynomial_of_expr e2)
  | LitGeq (e1, e2) ->
    c_coef_ineq_of_c_coef_polynomials (c_coef_polynomial_of_expr e1, GEQ, c_coef_polynomial_of_expr e2)
  | LitNot (literal) ->
    match literal with
    | LitLeq (e1, e2) -> c_coef_ineq_of_literal (LitGeq (e1, e2)) (* relaxation *)
    | LitGeq (e1, e2) -> c_coef_ineq_of_literal (LitLeq (e1, e2))
    | LitNot (literal) -> c_coef_ineq_of_literal literal

(* semialg_of_bexpr BexpUnit = [] *)
(* and_ineq_list_of_affexpr AffUnit = [] *)
let rec (and_ineq_list_of_affexpr : affexpr -> and_ineq_list) = function
  | AffUnit -> true_and_ineq_list
  | AffAnd (literal, affexpr) -> add_ineq_to_and_ineq_list (c_coef_ineq_of_literal literal) (and_ineq_list_of_affexpr affexpr)
let rec (semialg_of_bexpr : bexpr -> semialg) =
  function
  | BexpUnit ->
     false_semialg
  | BexpOr (affexpr, bexpr) ->
     add_and_ineq_list_to_semialg (and_ineq_list_of_affexpr affexpr) (semialg_of_bexpr bexpr)



(*
let add_e_list_to_e_map (Pcfg.l l) (edge list : e_l) (edge list Pcfg.LM.t : e_map) : edge list Pcfg.LM.t =
  try
    Pcfg.LM.add l (List.rev_append e_l (Pcfg.LM.find l e_list)) e_map
  with 
  | Not_found -> Pcfg.LM.add l e_l e_map
 *)

(* (l_init, pcfg_transition, invariant, term_semialgmap, l_list) *)
let rec pcfg_of_ast (ast: ast) (l_term: Pcfg.l) : (Pcfg.l * Pcfg.pcfg_transition * Pcfg.semialgmap * Pcfg.semialgmap * Pcfg.l list) =
  match ast with 
  | StAssgn assgn ->
     let a = v_assgn_of_assgn assgn in
     let l = get_new_location () in
     (l,
      Pcfg.pcfg_transition_singleton l (Pcfg.A (a,l_term)),
      Pcfg.semialgmap_empty,
      Pcfg.semialgmap_empty,
      [l])
  | StSkip ->
     let l = get_new_location () in
     (l,
      Pcfg.pcfg_transition_singleton  l (Pcfg.P (Pcfg.fDist_of_list [(l_term, 1.)])),
      Pcfg.semialgmap_empty,
      Pcfg.semialgmap_empty,
      [l])
  | StSeq (s1, s2) ->
     let l2, pcfg_transition2, invmap2, termmap2, l_list2 = pcfg_of_ast s2 l_term in
     let l1, pcfg_transition1, invmap1, termmap1, l_list1 = pcfg_of_ast s1 l2 in
     (l1,
      Pcfg.pcfg_transition_fold_add pcfg_transition1 pcfg_transition2,
      Pcfg.semialgmap_fold_add invmap1 invmap2,
      Pcfg.semialgmap_fold_add termmap1 termmap2,
      l_list1@l_list2)
  | StIf (ndbexpr, s1, s2) -> 
     let l = get_new_location () in
     let (l1, pcfg_transition1, invmap1, termmap1, l_list1), (l2, pcfg_transition2, invmap2, termmap2, l_list2) =
       pcfg_of_ast s1 l_term, pcfg_of_ast s2 l_term in
     let pcfg_transition = Pcfg.pcfg_transition_fold_add pcfg_transition1 pcfg_transition2 in
     let invmap' = Pcfg.semialgmap_fold_add invmap1 invmap2 in
     let termmap' = Pcfg.semialgmap_fold_add termmap1 termmap2 in
     let l_list = l::(l_list1@l_list2) in
     (match ndbexpr with
      | Ndet_branch ->
         (l,
          Pcfg.pcfg_transition_add l (Pcfg.ND [(true_semialg, l1); (true_semialg, l2)]) pcfg_transition,
          invmap',
          termmap',
          l_list)
      | Prob_branch (Const f) ->
         (l,
          Pcfg.pcfg_transition_add l (Pcfg.P (Pcfg.fDist_of_list [(l1,f); (l2,1.-.f)])) pcfg_transition,
          invmap',
          termmap',
          l_list)
      | Det_branch bexpr ->
         (l,
          Pcfg.pcfg_transition_add l (Pcfg.ND [(semialg_of_bexpr bexpr, l1); (semialg_of_bexpr @@ not_bexpr bexpr, l2)]) pcfg_transition,
          invmap',
          termmap',
          l_list))
  | StWhile (bexpr, ast) ->
     let l = get_new_location () in
     let (l1,pcfg_transition,invmap,termmap,l_list) = pcfg_of_ast ast l in
     (l,
      Pcfg.pcfg_transition_add l (Pcfg.ND [(semialg_of_bexpr bexpr, l1); (semialg_of_bexpr @@ not_bexpr bexpr, l_term)]) pcfg_transition,
      invmap,
      termmap,
      l::l_list)
  | StAssume bexpr ->
     (l_term,
      Pcfg.pcfg_transition_empty,
      Pcfg.semialgmap_singleton l_term (semialg_of_bexpr bexpr),
      Pcfg.semialgmap_empty,
      [])
  | StAssert bexpr -> 
     (l_term,
      Pcfg.pcfg_transition_empty,
      Pcfg.semialgmap_empty,
      Pcfg.semialgmap_singleton l_term (semialg_of_bexpr bexpr),
      [])
(*     let l = get_new_location () in 
     (l,
      Pcfg.pcfg_transition_singleton  l (Pcfg.P (Pcfg.fDist_of_list [(l_term, 1.)])),
      Pcfg.semialgmap_empty,
      Pcfg.semialgmap_singleton l (semialg_of_bexpr bexpr),
      [l]) *)
    

let eval (Prog (bexprg, ast) : prog) : Pcfg.pcfg * Pcfg.config * Pcfg.semialgmap * Pcfg.semialgmap  =
  let glbinv = semialg_of_bexpr bexprg in
  let l_term = Pcfg.l_of_string "l_exit" in
  let (l_init, pcfg_transition, invariant, term_semialgmap, l_list) = pcfg_of_ast ast l_term in
  let pcfg_transition = Pcfg.pcfg_transition_add l_term (Pcfg.P (Pcfg.fDist_of_list [(l_term, 1.)])) pcfg_transition in
  (* l_list is the list of locations *)
  let l_list = l_term::l_list in
  (* constructing invariant. if the corresponding semialgmap is undefined at some location then put (something) *)
  let invariant =
    List.fold_left
      (fun invariant l ->
        if Pcfg.semialgmap_mem l invariant then invariant else
        Pcfg.semialgmap_add l glbinv invariant)
      invariant
      l_list in
  let v_list = v_list_from_ast ast in
  let init_config : Pcfg.config = (l_init, valuation_of_var_float_list @@ List.map (fun x -> (x,0.)) v_list) in (* initial configuration: \forall x. x=0 *)
(*  print_string @@ string_of_list Pcfg.string_of_l l_list;
  print_string @@ string_of_list (fun (l, f) -> Pcfg.string_of_l l ^ " " ^ Pcfg.string_of_f f) (Pcfg.LM.bindings pcfg_transition);
  print_string @@ "invariant: "; 
  print_string @@ Pcfg.string_of_semialgmap invariant;
  print_string @@ "terminal configuration: "; 
  print_string @@ Pcfg.string_of_semialgmap term_semialgmap ^ "\n" ; *)
  ((pcfg_transition, Pcfg.l_domain_of_l_list l_list, v_domain_of_v_list v_list), init_config, invariant, term_semialgmap)
