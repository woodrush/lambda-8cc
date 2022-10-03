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

INPUT=input.c

all: x86

x86: a.out
lam: a.lam

x86-onepass: $(INPUT) lambda-8cc.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( cat lambda-8cc.lam | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > a.out
	chmod 755 a.out

a.s: $(INPUT) lambda-8cc.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat lambda-8cc.lam; printf '(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.b) (\\x.x)))' ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > a.s.tmp
	mv a.s.tmp a.s

a.out: a.s lambda-8cc.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat lambda-8cc.lam; printf '(\\f.(f (\\x.\\y.y) (\\x.\\y.\\z.\\a.\\b.x) (\\x.x)))' ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > a.out.tmp
	mv a.out.tmp a.out
	chmod 755 a.out

a.lam: a.s elc.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( cat elc.lam | $(LAM2BIN) | $(ASC2BIN); echo "lam"; cat a.s ) | /usr/bin/time -v $(UNIPP) -o > a.lam.tmp
	mv a.lam.tmp a.lam

run-a.lam: $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	cat a.lam | $(LAM2BIN) | $(ASC2BIN) | $(UNIPP) -o

lam-onepass: lambda-8cc.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP) $(INPUT)
	( ( cat lambda-8cc.lam; printf '(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.y) (\\x.x)))' ) | $(LAM2BIN) | $(ASC2BIN); cat $(INPUT) ) | $(UNIPP) -o > a.lam.tmp
	mv a.lam.tmp a.lam

blc-onepass: lambda-8cc.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP) $(INPUT)
	( ( cat lambda-8cc.lam; printf '(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.z) (\\x.x)))' ) | $(LAM2BIN) | $(ASC2BIN); cat $(INPUT) ) | $(UNIPP) -o > a.blc.tmp
	mv a.blc.tmp a.blc

lazy-onepass: lambda-8cc.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP) $(INPUT)
	( ( cat lambda-8cc.lam; printf '(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.a) (\\x.x)))' ) | $(LAM2BIN) | $(ASC2BIN); cat $(INPUT) ) | $(UNIPP) -o > a.lazy.tmp
	mv a.lazy.tmp a.lazy

s-onepass: lambda-8cc.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP) $(INPUT)
	( ( cat lambda-8cc.lam; printf '(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.b) (\\x.x)))' ) | $(LAM2BIN) | $(ASC2BIN); cat $(INPUT) ) | $(UNIPP) -o > a.s.tmp
	mv a.s.tmp a.s



#================================================================
# Build the one-pass compiler
#================================================================
out/lambda-8cc-wrapper.lam: src/lambda-8cc.cl src/lambdacraft.cl
	mkdir -p out
	cd src; $(SBCL) --script lambda-8cc.cl > ../out/lambda-8cc-wrapper.lam

lambda-8cc.lam: out/lambda-8cc-wrapper.lam 8cc.lam elc.lam
	( printf '('; cat out/lambda-8cc-wrapper.lam 8cc.lam elc.lam; printf ')'; ) > lambda-8cc.lam


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
