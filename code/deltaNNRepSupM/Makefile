export OCAMLMAKEFILE = ./OcamlMakefile





# environment variables for main
GSSM = ../gammaSclSubM
LIB = $(GSSM)/lib
LINSRCDIR = $(GSSM)/src_linear
POLYSRCDIR = $(GSSM)/src_poly
RSMSRCDIR = src_deltaNNRepSupM
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
$(RSMSRCDIR)/sequent.mli $(RSMSRCDIR)/sequent.ml \
$(LINSRCDIR)/matrix.mli $(LINSRCDIR)/matrix.ml \
$(LINSRCDIR)/linear_template.mli $(LINSRCDIR)/linear_template.ml \
$(RSMSRCDIR)/progmath.mli $(RSMSRCDIR)/progmath.ml \
$(POLYSRCDIR)/polynomial_template.mli $(POLYSRCDIR)/polynomial_template.ml \
$(RSMSRCDIR)/sostools.mli $(RSMSRCDIR)/sostools.ml \
$(RSMSRCDIR)/main.ml 


# copied sources


CPSRCDIR = .src
CPSOURCES = $(CPSRCDIR)/util.mli $(CPSRCDIR)/util.ml \
$(CPSRCDIR)/variable.mli $(CPSRCDIR)/variable.ml \
$(CPSRCDIR)/coefficient.mli $(CPSRCDIR)/coefficient.ml \
$(CPSRCDIR)/polynomial.mli $(CPSRCDIR)/polynomial.ml \
$(CPSRCDIR)/semialg.mli $(CPSRCDIR)/semialg.ml \
$(CPSRCDIR)/pcfg.mli $(CPSRCDIR)/pcfg.ml \
$(CPSRCDIR)/syntax.mli $(CPSRCDIR)/syntax.ml \
$(CPSRCDIR)/eval.mli $(CPSRCDIR)/eval.ml \
$(CPSRCDIR)/lexer.mll $(CPSRCDIR)/parser.mly \
$(CPSRCDIR)/pre_expectation.mli $(CPSRCDIR)/pre_expectation.ml \
$(CPSRCDIR)/sequent.mli $(CPSRCDIR)/sequent.ml \
$(CPSRCDIR)/matrix.mli $(CPSRCDIR)/matrix.ml \
$(CPSRCDIR)/linear_template.mli $(CPSRCDIR)/linear_template.ml \
$(CPSRCDIR)/progmath.mli $(CPSRCDIR)/progmath.ml \
$(CPSRCDIR)/polynomial_template.mli $(CPSRCDIR)/polynomial_template.ml \
$(CPSRCDIR)/sostools.mli $(CPSRCDIR)/sostools.ml \
$(CPSRCDIR)/main.ml 

MAINRESULT = main_deltaNNRepSupM

MAINVARS = SOURCES="$(CPSOURCES)" RESULT=$(MAINRESULT) 




# common environment variables 
VARS = PACKS=oUnit  OCAMLLEX=ocamllex OCAMLYACC=ocamlyacc YFLAGS=-v 

all:	main 

main: $(MAINSOURCES)
	mkdir -p $(CPSRCDIR)
	rsync -u $(MAINSOURCES) $(CPSRCDIR)
	$(MAKE) -f $(OCAMLMAKEFILE) $(MAINVARS) $(VARS)




clean:
	$(MAKE) clean -f $(OCAMLMAKEFILE) $(MAINVARS) TRASH="$(CPSRCDIR)/parser.automaton $(CPSRCDIR)/parser.conflicts"
	rm -f -r $(CPSRCDIR)

