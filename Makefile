LAMBDA8CC=lambda-8cc.lam

# Binary lambda calculus interpreter
UNIPP=./bin/uni++
CLAMB=./bin/clamb

# Tools
ASC2BIN=./bin/asc2bin
LAM2BIN=./bin/lam2bin

# Toolkit
LAMBDATOOLS=./build/lambda-calculus-devkit

# ELVM
8CC=./bin/8cc
ELC=./bin/elc
8CCLAM=./8cc.lam
ELCLAM=./elc.lam

# Other
SBCL=sbcl
LAZYK=./bin/lazyk

INPUT=input.c

OPT_C_TO_LAM  ='(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.y) (\\x.x)))'
OPT_C_TO_BLC  ='(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.z) (\\x.x)))'
OPT_C_TO_LAZY ='(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.a) (\\x.x)))'
OPT_C_TO_S    ='(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.b) (\\x.x)))'
OPT_S_TO_X86  ='(\\f.(f (\\x.\\y.y) (\\x.\\y.\\z.\\a.\\b.x) (\\x.x)))'
OPT_S_TO_LAM  ='(\\f.(f (\\x.\\y.y) (\\x.\\y.\\z.\\a.\\b.y) (\\x.x)))'
OPT_S_TO_BLC  ='(\\f.(f (\\x.\\y.y) (\\x.\\y.\\z.\\a.\\b.z) (\\x.x)))'
OPT_S_TO_LAZY ='(\\f.(f (\\x.\\y.y) (\\x.\\y.\\z.\\a.\\b.a) (\\x.x)))'


all: a.out

a.s: $(INPUT) $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_C_TO_S) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@

a.out: a.s $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_S_TO_X86) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@
	chmod 755 a.out

a.out-onepass: $(INPUT) $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( cat $(LAMBDA8CC) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > a.out
	chmod 755 a.out


#================================================================
# Other output languages
#================================================================
a.lam: a.s $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_S_TO_LAM) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@

a.blc: a.s $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_S_TO_BLC) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@

a.lazy: a.s $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_S_TO_LAZY) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@

lam-onepass: $(INPUT) $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_C_TO_LAM) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > a.lam.tmp
	mv a.lam.tmp a.lam

blc-onepass: $(INPUT) $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_C_TO_BLC) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > a.blc.tmp
	mv a.blc.tmp a.blc

lazy-onepass: $(INPUT) $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_C_TO_LAZY) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > a.lazy.tmp
	mv a.lazy.tmp a.lazy


run-a.lam: $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	cat a.lam | $(LAM2BIN) | $(ASC2BIN) | $(UNIPP) -o

run-a.blc: $(ASC2BIN) $(UNIPP)
	cat a.blc | $(ASC2BIN) | $(UNIPP) -o

run-a.lazy: $(LAZYK)
	$(LAZYK) -u a.lazy


#================================================================
# Build lambda-8cc.lam
#================================================================
src/usage.cl: src/usage.txt
	cd src; ./compile-usage.sh > usage.cl.tmp
	cd src; mv usage.cl.tmp usage.cl

out/lambda-8cc-main.lam: src/usage.cl src/compile-usage.sh $(wildcard src/*.cl)
	mkdir -p out
	cd src; $(SBCL) --script lambda-8cc.cl > ../out/lambda-8cc-main.lam.tmp
	mv $@.tmp $@

$(LAMBDA8CC): out/lambda-8cc-main.lam 8cc.lam elc.lam
	( printf '('; cat out/lambda-8cc-main.lam 8cc.lam elc.lam; printf ')'; ) > $(LAMBDA8CC)


#================================================================
# Build 8cc.lam and elc.lam
#================================================================
elvm-private/Makefile:
	git submodule update --init --remote

.PHONY: 8cc
8cc: $(8CC)
$(8CC): elvm-private/Makefile
	cd elvm-private && make out/8cc && cp out/8cc ../bin

.PHONY: elc
elc: $(ELC)
$(ELC): elvm-private/Makefile
	cd elvm-private && make out/elc && cp out/elc ../bin

out/8cc.c: elvm-private/Makefile
	mkdir -p out
	cd elvm-private && make out/8cc.c && tools/merge_c.rb out/8cc.c > ../out/8cc.c

out/elc.c: elvm-private/Makefile
	mkdir -p out
	cd elvm-private && make out/elc.c && tools/merge_c.rb out/elc.c > ../out/elc.c

out/8cc.eir: out/8cc.c $(8CC)
	$(8CC) -S -o out/8cc.eir out/8cc.c

out/elc.eir: out/elc.c $(8CC)
	$(8CC) -S -o out/elc.eir out/elc.c

8cc.lam: out/8cc.eir $(ELC)
	$(ELC) -lam out/8cc.eir > 8cc.lam

elc.lam: out/elc.eir $(ELC)
	$(ELC) -lam out/elc.eir > elc.lam


#================================================================
# Build the lambda calculus interpreters and tools
#================================================================
$(LAMBDATOOLS):
	mkdir -p build
	cd build; git clone github.com:woodrush/lambda-calculus-devkit

.PHONY: uni++
uni++: $(UNIPP)
$(UNIPP): $(LAMBDATOOLS)
	mkdir -p bin
	cd $(LAMBDATOOLS) && make uni++ && mv bin/uni++ ../../bin

.PHONY: asc2bin
asc2bin: $(ASC2BIN)
$(ASC2BIN): $(LAMBDATOOLS)
	mkdir -p bin
	cd $(LAMBDATOOLS) && make asc2bin && mv bin/asc2bin ../../bin

.PHONY: lam2bin
lam2bin: $(LAM2BIN)
$(LAM2BIN): $(LAMBDATOOLS)
	mkdir -p bin
	cd $(LAMBDATOOLS) && make lam2bin && mv bin/lam2bin ../../bin

.PHONY: lazyk
lazyk: $(LAZYK)
$(LAZYK): $(LAMBDATOOLS)
	mkdir -p bin
	cd $(LAMBDATOOLS) && make lazyk && mv bin/lazyk ../../bin
