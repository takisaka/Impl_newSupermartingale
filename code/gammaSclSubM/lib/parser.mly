%{
  open Syntax
  (* ここに書いたものは，ExampleParser.mliに入らないので注意 *)
%}

%token <float>  FLOAT
%token <int>  POSINT
%token <string> ID
%token SKIP SEMICOLON IF THEN ELSE FI WHILE DO OD ASSUME ASSERT TRUE FALSE
%token ASSGN NDET
%token PLUS STAR MINUS AND OR HAT
%token INT REAL LSQBRACKET COMMA RSQBRACKET LT GT LEQ GEQ EQ NOT PROB LPARAN RPARAN DOLLAR LBRACKET RBRACKET
%left SEMICOLON RBRACKET RSQBRACKET
%left AND OR
%left PLUS MINUS 
%left STAR
%right HAT
/* %token <string> DIST */
%token EOF

%start program
%type <Syntax.prog> program
%% 

/* define the grammer of the whole program. the option glabal specifies the default invariant
   at each location; if global is not given, then the default invariant is false. */
program:
  | global stmt EOF { Prog ($1,$2) }
  | stmt EOF { Prog (BexpOr (AffUnit,BexpUnit),$1) }
;

stmt:
  | assgn { StAssgn $1 }
  | SKIP { StSkip }
  | LPARAN stmt RPARAN { $2 }
  | stmt SEMICOLON stmt { StSeq ($1, $3) }
  | IF ndbexpr THEN stmt ELSE stmt FI { StIf ($2, $4, $6) }
  | WHILE bexpr DO stmt OD { StWhile ($2, $4) }
  | LBRACKET bexpr RBRACKET { StAssume $2 }
  | LSQBRACKET bexpr RSQBRACKET { StAssert $2 }
  | ASSUME bexpr { StAssume $2 }
  | LBRACKET bexpr RBRACKET stmt { StSeq(StAssume $2, $4) }
  | LSQBRACKET bexpr RSQBRACKET stmt { StSeq(StAssert $2, $4) }
  | ASSERT bexpr { StAssert $2 }
;

assgn:
  | pvar ASSGN expr { AsnDet ($1, $3) }
  | pvar ASSGN NDET dom { AsnNdet ($1, $4) }
  | pvar ASSGN dist { AsnProb ($1, $3) }
;

expr:
  | const { EConst $1 }
  | pvar { EVar $1 }
  | LPARAN expr RPARAN { $2 }
  | expr PLUS expr { EAdd ($1, $3) }
  | expr MINUS expr { ESub ($1, $3) }
  | expr STAR expr { EMult ($1, $3) }
  | expr HAT POSINT {
        let rec exp b i =
          if i < 0 then
            failwith "exponent should be greater than 0. (form poly_parser.mly)"
          else if i = 0 then
            EConst (Const 1.)
          else if i = 1 then
            b
          else
            EMult (b, (exp b (i -1)))
        in exp $1 $3
      }
;

dom:
  | LPARAN dom RPARAN { $2 }
  | dom_basis { $1 }
  | dom_basis OR dom { DOr ($1, $3) }
;
dom_basis:
  | INT { DInt }
  | REAL { DReal }
  | INT LSQBRACKET const COMMA const RSQBRACKET { DIntInterval ($3, $5) }
  | REAL LSQBRACKET const COMMA const RSQBRACKET { DRealInterval ($3, $5) }
;

bexpr:
  | affexpr { BexpOr ($1,BexpUnit) }
  | affexpr OR bexpr { BexpOr ($1, $3) }
;

affexpr:
  | LPARAN affexpr RPARAN { $2 } 
  | expr EQ expr { AffAnd (LitGeq ($1, $3), AffAnd(LitLeq ($1, $3),AffUnit)) }
  | literal { AffAnd ($1,AffUnit) }
  | affexpr AND affexpr { and_affexpr $1 $3 }
;

literal:
  | TRUE { LitLeq (EConst (Const 0.), EConst (Const 1.)) }
  | FALSE { LitLeq (EConst (Const 0.), EConst (Const (-1.))) }
  | expr LEQ expr { LitLeq ($1, $3) }
  | expr GEQ expr { LitGeq ($1, $3) }
  | expr LT expr { LitNot (LitLeq ($3, $1)) }
  | expr GT expr { LitNot (LitGeq ($3, $1)) }
  | NOT literal { LitNot $2 }
;

ndbexpr:
  | STAR { Ndet_branch }
  | PROB LPARAN const RPARAN { Prob_branch $3 }
  | bexpr { Det_branch $1 }
;

pvar:
  | ID { PVar $1 }
;

dist:
  | ID LPARAN const_list RPARAN { Dist ($1, $3) }
;

const_list:
  | const { [$1] }
  | const COMMA const_list { $1 :: $3 }
;

const:
  | POSINT { Const (float_of_int $1) }
  | FLOAT { Const $1 }
  | MINUS POSINT { Const (float_of_int (-$2)) }
  | MINUS FLOAT { Const (-1. *. $2) }
;

global:
  | DOLLAR bexpr { $2 }
;

