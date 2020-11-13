type token =
  | FLOAT of (float)
  | POSINT of (int)
  | ID of (string)
  | SKIP
  | SEMICOLON
  | IF
  | THEN
  | ELSE
  | FI
  | WHILE
  | DO
  | OD
  | ASSUME
  | ASSERT
  | TRUE
  | FALSE
  | ASSGN
  | NDET
  | PLUS
  | STAR
  | MINUS
  | AND
  | OR
  | HAT
  | INT
  | REAL
  | LSQBRACKET
  | COMMA
  | RSQBRACKET
  | LT
  | GT
  | LEQ
  | GEQ
  | EQ
  | NOT
  | PROB
  | LPARAN
  | RPARAN
  | DOLLAR
  | LBRACKET
  | RBRACKET
  | EOF

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Syntax.prog
