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

a.s: 8cc.c.eir.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP) $(INPUT)
	( cat 8cc.c.eir.lam | $(LAM2BIN) | $(ASC2BIN); cat $(INPUT) ) | /usr/bin/time -v $(UNIPP) -o > a.s.tmp
	# ( cat 8cc.c.eir.lam | $(LAM2BIN) | $(ASC2BIN); cat $(INPUT) ) | $(CLAMB) -u > a.s.tmp
	mv a.s.tmp a.s

a.out: a.s elc.c.eir.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( cat elc.c.eir.lam | $(LAM2BIN) | $(ASC2BIN); echo "x86"; cat a.s ) | /usr/bin/time -v $(UNIPP) -o > a.out.tmp
	# ( cat elc.c.eir.lam | $(LAM2BIN) | $(ASC2BIN); echo "x86"; cat a.s ) | $(CLAMB) -u > a.out.tmp
	mv a.out.tmp a.out
	chmod 755 a.out

a.lam: a.s elc.c.eir.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( cat elc.c.eir.lam | $(LAM2BIN) | $(ASC2BIN); echo "lam"; cat a.s ) | /usr/bin/time -v$(UNIPP) -o > a.lam.tmp
	mv a.lam.tmp a.lam

run-a.lam: $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	cat a.lam | $(LAM2BIN) | $(ASC2BIN) | $(UNIPP) -o

compile-onepass-x86: out/lambda-8cc.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP) $(INPUT)
	( cat out/lambda-8cc.lam | $(LAM2BIN) | $(ASC2BIN); cat $(INPUT) ) | $(UNIPP) -o > a.out
	chmod 755 a.out


#================================================================
# Build the one-pass compiler
#================================================================
out/lambda-8cc-wrapper.lam: src/lambda-8cc.cl src/lambdacraft.cl
	mkdir -p out
	cd src; $(SBCL) --script lambda-8cc.cl > ../out/lambda-8cc-wrapper.lam

out/lambda-8cc.lam: out/lambda-8cc-wrapper.lam 8cc.c.eir.lam elc.c.eir.lam
	( printf '('; cat out/lambda-8cc-wrapper.lam 8cc.c.eir.lam elc.c.eir.lam; printf ')'; ) > out/lambda-8cc.lam


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
