LAMBDA8CC=lambda-8cc.lam
LAMBDA8CCZIP=out/lambda-8cc.lam
LAMBDA8CCLAZY=lambda-8cc.lazy

# Binary lambda calculus interpreter
UNIPP=./bin/uni++

# Tools
ASC2BIN=./bin/asc2bin
LAM2BIN=./bin/lam2bin

# Toolkit
LAMBDATOOLS=./build/lambda-calculus-devkit

# ELVM
8CC=./bin/8cc
ELC=./bin/elc
8CCLAM=./build/8cc.lam
ELCLAM=./build/elc.lam

# Other
SBCL=sbcl
LAZYK=./bin/lazyk
BLCAIT=./bin/blc-ait
BCL2SKI=./bin/bcl2ski
LATEX=latex
DVIPDFMX=dvipdfmx
target_latex=out/lambda-8cc.tex
target_pdf=lambda-8cc.pdf

# Input C file
INPUT=input.c

# lambda-8cc compilation options
OPT_C_TO_LAM  ='(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.y) (\\x.x)))'
OPT_C_TO_BLC  ='(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.z) (\\x.x)))'
OPT_C_TO_LAZY ='(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.a) (\\x.x)))'
OPT_C_TO_S    ='(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.b) (\\x.x)))'
OPT_S_TO_X86  ='(\\f.(f (\\x.\\y.y) (\\x.\\y.\\z.\\a.\\b.x) (\\x.x)))'
OPT_S_TO_LAM  ='(\\f.(f (\\x.\\y.y) (\\x.\\y.\\z.\\a.\\b.y) (\\x.x)))'
OPT_S_TO_BLC  ='(\\f.(f (\\x.\\y.y) (\\x.\\y.\\z.\\a.\\b.z) (\\x.x)))'
OPT_S_TO_LAZY ='(\\f.(f (\\x.\\y.y) (\\x.\\y.\\z.\\a.\\b.a) (\\x.x)))'


all: a.out

a.s: $(INPUT) $(LAMBDA8CCZIP) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CCZIP); printf $(OPT_C_TO_S) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@

a.out: a.s $(LAMBDA8CCZIP) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CCZIP); printf $(OPT_S_TO_X86) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@
	chmod 755 $@

a.out-onepass: $(INPUT) $(LAMBDA8CCZIP) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( cat $(LAMBDA8CCZIP) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > a.out
	chmod 755 a.out

$(INPUT): examples/hello.c
	cp examples/hello.c $@

tools: $(LAM2BIN) $(ASC2BIN) $(UNIPP)

test: test-compile

pdf: $(target_pdf)

build: $(LAMBDA8CC)


#================================================================
# Build the PDF
#================================================================
.PRECIOUS: $(target_latex)
$(target_latex):./src/lambda-8cc.cl ./tools/main.tex ./tools/make-latex.sh
	mkdir -p ./out
	./tools/make-latex.sh
	mv lambda-8cc.tex out

.PHONY: pdf
$(target_pdf): $(target_latex) $(LAMBDA8CC)
	cp ./tools/main.tex out
	cd out; $(LATEX) main.tex
	cd out; $(DVIPDFMX) main.dvi -o $@
	mv out/$@ .


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
# Compilation test
#================================================================
out/test.c:
	printf 'int main(void){return 0;}' > $@

out/test.s: out/test.c $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	mkdir -p out
	( ( cat $(LAMBDA8CC); printf $(OPT_C_TO_S) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@

out/test.bin: out/test.s $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_S_TO_X86) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@

out/test-8cc.s: out/test.c $(8CC)
	$(8CC) -S -o $@ $<

out/test-8cc.bin: out/test-8cc.s $(ELC)
	$(ELC) -x86 $< > $@

test-compile: out/test.bin out/test-8cc.bin
	diff $^ || exit 1
	echo "test-compile passed."


#================================================================
# Self-hosting test
#================================================================
out/8cc-self.s: build/8cc.c $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_C_TO_S) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@

out/elc-self.s: build/elc.c $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_C_TO_S) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@

out/8cc-self.lam: out/8cc-self.s $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_S_TO_LAM) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@

out/elc-self.lam: out/elc-self.s $(LAMBDA8CC) $(LAM2BIN) $(ASC2BIN) $(UNIPP)
	( ( cat $(LAMBDA8CC); printf $(OPT_S_TO_LAM) ) | $(LAM2BIN) | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	mv $@.tmp $@

out/lambda-8cc-self.lam: out/lambda-8cc-main.lam out/8cc-self.lam out/elc-self.lam
	( printf '('; cat $^; printf ')'; ) > $@

test-self-host: out/lambda-8cc-self.lam build/8cc.eir build/elc.eir $(8CCLAM) $(ELCLAM)
	diff out/8cc-self.s build/8cc.eir || exit 1
	diff out/elc-self.s build/elc.eir || exit 1
	diff out/8cc-self.lam $(8CCLAM) || exit 1
	diff out/elc-self.lam $(ELCLAM) || exit 1
	diff out/lambda-8cc-self.lam $(LAMBDA8CC) || exit 1


#================================================================
# Test for building build/lambda-8cc-main.lam using LambdaLisp
#================================================================
build/lambdalisp/bin/lambdalisp.blc:
	mkdir -p build
	cd build; git clone https://github.com/woodrush/lambdalisp

out/lambda-8cc-main-src.cl: src/lambdacraft.cl src/blc-numbers.cl src/usage.cl src/lambda-8cc.cl
	cat $^ > $@

out/lambda-8cc-main-lambdaisp.lam: out/lambda-8cc-main-src.cl build/lambdalisp/bin/lambdalisp.blc $(ASC2BIN) $(UNIPP)
	( cat build/lambdalisp/bin/lambdalisp.blc | $(ASC2BIN); cat $< ) | $(UNIPP) -o > $@.tmp
	cat $@.tmp | sed -e '1s/> //' > $@
	rm $@.tmp

test-lambda-8cc-main-lambdaisp: out/lambda-8cc-main-lambdaisp.lam build/lambda-8cc-main.lam
	diff $^ || exit 1


#================================================================
# Build lambda-8cc.lam
#================================================================
src/usage.cl: src/usage.txt src/compile-usage.sh
	cd src; ./compile-usage.sh > usage.cl.tmp
	mv src/usage.cl.tmp $@

build/lambda-8cc-main.lam: src/usage.cl $(wildcard src/*.cl)
	mkdir -p build
	cd src; $(SBCL) --script lambda-8cc.cl > ../$@.tmp
	mv $@.tmp $@

$(LAMBDA8CC): build/lambda-8cc-main.lam $(8CCLAM) $(ELCLAM)
	( printf '('; cat $^; printf ')'; ) > $@


out/lambda-8cc.blc: $(LAMBDA8CC) $(LAM2BIN)
	cat $(LAMBDA8CC) | $(LAM2BIN) > $@.tmp
	mv $@.tmp $@

bin/lambda-8cc.lam.zip: $(LAMBDA8CC)
	zip $@ $<

bin/lambda-8cc.blc.zip: out/lambda-8cc.blc
	zip $@ $<

$(LAMBDA8CCZIP):
	cd out; unzip ../bin/lambda-8cc.lam.zip


#================================================================
# Build lambda-8cc.lazy (WIP)
#================================================================
build/lambda-8cc-lazy.cl: src/usage.cl $(wildcard src/*.cl)
	mkdir -p build
	( echo '(defparameter compile-lazyk t)'; cat src/lambda-8cc.cl ) > build/lambda-8cc-lazy.cl

build/lambda-8cc-main.lazy: build/lambda-8cc-lazy.cl $(BLCAIT) $(BCL2SKI)
	cd src; $(SBCL) --script ../build/lambda-8cc-lazy.cl > ../build/lambda-8cc-main-lazy.lam
	$(BLCAIT) bcl build/lambda-8cc-main-lazy.lam | $(BCL2SKI) > $@.tmp
	mv $@.tmp $@

$(8CCLAM).lazy: build/8cc.eir $(ELC)
	$(ELC) -lazy $< > $@

$(ELCLAM).lazy: build/elc.eir $(ELC)
	$(ELC) -lazy $< > $@

$(LAMBDA8CCLAZY): build/lambda-8cc-main.lazy $(8CCLAM).lazy $(ELCLAM).lazy
	( printf '``'; cat $^; ) > $@


#================================================================
# Build 8cc.lam and elc.lam
#================================================================
elvm/Makefile:
	git submodule update --init --remote

.PHONY: 8cc
8cc: $(8CC)
$(8CC): elvm/Makefile
	cd elvm && make out/8cc && cp out/8cc ../bin

.PHONY: elc
elc: $(ELC)
$(ELC): elvm/Makefile
	cd elvm && make out/elc && cp out/elc ../bin

build/8cc.c: elvm/Makefile
	mkdir -p out
	cd elvm && make out/8cc.c && tools/merge_c.rb out/8cc.c > ../build/8cc.c

build/elc.c: elvm/Makefile
	mkdir -p out
	cd elvm && make out/elc.c && tools/merge_c.rb out/elc.c > ../build/elc.c

build/8cc.eir: build/8cc.c $(8CC)
	$(8CC) -S -o $@ $<

build/elc.eir: build/elc.c $(8CC)
	$(8CC) -S -o $@ $<

$(8CCLAM): build/8cc.eir $(ELC)
	$(ELC) -lam $< > $@

$(ELCLAM): build/elc.eir $(ELC)
	$(ELC) -lam $< > $@


#================================================================
# Build the lambda calculus interpreters and tools
#================================================================
$(LAMBDATOOLS):
	mkdir -p build
	cd build; git clone https://github.com/woodrush/lambda-calculus-devkit

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

.PHONY: blc-ait
blc-ait: $(BLCAIT)
$(BLCAIT): $(LAMBDATOOLS)
	mkdir -p bin
	cd $(LAMBDATOOLS) && make blc-ait && mv bin/blc-ait ../../bin

.PHONY: bcl2ski
bcl2ski: $(BCL2SKI)
$(BCL2SKI): $(LAMBDATOOLS)
	mkdir -p bin
	cd $(LAMBDATOOLS) && make bcl2ski && mv bin/bcl2ski ../../bin
