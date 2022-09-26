SBCL=sbcl

all: out/lambda-8cc.lam

out/lambda-8cc-wrapper.lam:
	mkdir -p out
	cd src; $(SBCL) --script lambda-8cc.cl > ../out/lambda-8cc-wrapper.lam

out/lambda-8cc.lam: out/lambda-8cc-wrapper.lam 8cc.c.eir.lam elc.c.eir.lam
	( printf '('; cat out/lambda-8cc-wrapper.lam 8cc.c.eir.lam elc.c.eir.lam; printf ')'; ) > out/lambda-8cc.lam
