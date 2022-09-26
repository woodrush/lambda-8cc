# Binary lambda calculus interpreter
UNIPP=./bin/uni++

# Tools
ASC2BIN=./bin/asc2bin
LAM2BIN=./bin/lam2bin

# Toolkit
LAMBDATOOLS=./build/lambda-calculus-devkit

# Other
SBCL=sbcl


all: out/lambda-8cc.lam

out/lambda-8cc-wrapper.lam: src/lambda-8cc.cl src/lambdacraft.cl
	mkdir -p out
	cd src; $(SBCL) --script lambda-8cc.cl > ../out/lambda-8cc-wrapper.lam

out/lambda-8cc.lam: out/lambda-8cc-wrapper.lam 8cc.c.eir.lam elc.c.eir.lam
	( printf '('; cat out/lambda-8cc-wrapper.lam 8cc.c.eir.lam elc.c.eir.lam; printf ')'; ) > out/lambda-8cc.lam

compile: out/lambda-8cc.lam $(LAM2BIN) $(ASC2BIN) $(UNIPP) input.c
	( cat out/lambda-8cc.lam | $(LAM2BIN) | $(ASC2BIN); cat input.c ) | $(UNIPP) -o > a.out
	chmod 755 a.out


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
