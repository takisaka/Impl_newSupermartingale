let digit = ['0'-'9']
let space = ' ' | '\t' | '\r' | '\n'
let alpha = ['a'-'z' 'A'-'Z'] 
let ident = alpha (alpha | digit | '_')* 

rule main = parse
| space+       { main lexbuf }
| "/*" { comment lexbuf }

| "skip" {Parser.SKIP}
| ";" {Parser.SEMICOLON}
| "if" {Parser.IF}
| "then" {Parser.THEN}
| "else" {Parser.ELSE}
| "fi" {Parser.FI}
| "while" {Parser.WHILE}
| "do" {Parser.DO}
| "od" {Parser.OD}
| "assume" {Parser.ASSUME}
| "refute" {Parser.ASSERT}

| ":=" {Parser.ASSGN}
| "ndet" {Parser.NDET}
(* | "sample" {Parser.PROBASSGN} *)

| "+" {Parser.PLUS}
| "-" {Parser.MINUS}
| "*" {Parser.STAR}
| "^" {Parser.HAT}

| "Int" {Parser.INT}
| "Real" {Parser.REAL}
| "[" {Parser.LSQBRACKET}
| "," {Parser.COMMA}
| "]" {Parser.RSQBRACKET}
| "or" {Parser.OR}
| "and" {Parser.AND}
| "<" {Parser.LT}
| ">" {Parser.GT}
| "<=" {Parser.LEQ}
| ">=" {Parser.GEQ}
| "=" {Parser.EQ}
| "not" {Parser.NOT}
| "prob" {Parser.PROB}
| "true" {Parser.TRUE}
| "false" {Parser.FALSE}
| "(" {Parser.LPARAN}
| ")" {Parser.RPARAN}
| "$" {Parser.DOLLAR}
| "{" {Parser.LBRACKET}
| "}" {Parser.RBRACKET}

(* definition of distribution is modified to a parametrized version 
 *     "<dist_name>(p1,p2,...,pn)"
 * from the paper. *)
(* | "Uniform" as dist {Parser.DIST dist}
 * | "Geometric" as dist {Parser.DIST dist}
 * | "Normal" as dist {Parser.DIST dist}
 * | "Discrete" as dist {Parser.DIST dist} *)

(* | digit+ as n  { Parser.INT (int_of_string n) } *)
| digit+ as n  { Parser.POSINT (int_of_string n) }
(* | '-'(digit+ | digit+ '.' digit* | digit* '.' digit+ ) *)
| (digit+ | digit+ '.' digit* | digit* '.' digit+ ) as n  { Parser.FLOAT (float_of_string n) }
| ident  as id { Parser.ID id }
| eof          { Parser.EOF }
| _            { failwith ("Unknown Token: " ^ Lexing.lexeme lexbuf)}

and comment = parse
| "*/"(* return to the main rule *){ main lexbuf }
| _(* skip comments *){ comment lexbuf }

