export OCAMLMAKEFILE = ./OcamlMakefile

LIB = lib



# environment variables for main
LINSRCDIR = src_linear
POLYSRCDIR = src_poly
MAINSOURCES = $(LIB)/util.mli $(LIB)/util.ml \
$(LIB)/variable.mli $(LIB)/variable.ml \
$(LIB)/coefficient.mli $(LIB)/coefficient.ml \
$(LIB)/polynomial.mli $(LIB)/polynomial.ml \
$(LIB)/semialg.mli $(LIB)/semialg.ml \
$(LIB)/pcfg.mli $(LIB)/pcfg.ml \
$(LIB)/syntax.mli $(LIB)/syntax.ml \
$(LIB)/eval.mli $(LIB)/eval.ml \
$(LIB)/lexer.mll $(LIB)/parser.mly \
$(LIB)/pre_expectation.mli $(LIB)/pre_expectation.ml \
$(LIB)/sequent.mli $(LIB)/sequent.ml \
$(LINSRCDIR)/matrix.mli $(LINSRCDIR)/matrix.ml \
$(LINSRCDIR)/linear_template.mli $(LINSRCDIR)/linear_template.ml \
$(LINSRCDIR)/progmath.mli $(LINSRCDIR)/progmath.ml \
$(POLYSRCDIR)/polynomial_template.mli $(POLYSRCDIR)/polynomial_template.ml \
$(POLYSRCDIR)/sostools.mli $(POLYSRCDIR)/sostools.ml \
$(LIB)/main.ml 

MAINRESULT = main_gammaSclSubM

MAINVARS = SOURCES="$(MAINSOURCES)" RESULT=$(MAINRESULT) 


# common environment variables 
VARS = PACKS=oUnit  OCAMLLEX=ocamllex OCAMLYACC=ocamlyacc YFLAGS=-v 

all:	main

main: $(MAINSOURCES) 
	$(MAKE) -f $(OCAMLMAKEFILE) $(MAINVARS) $(VARS)

clean:
	$(MAKE) clean -f $(OCAMLMAKEFILE) $(MAINVARS) TRASH="$(MAINSRCDIR)/poly_parser.automaton $(MAINSRCDIR)/poly_parser.conflicts"
