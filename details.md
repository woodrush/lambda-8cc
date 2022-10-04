# lambda-8cc Details
Here I will explain further details about lambda-8cc.


## Building From Source
### Requirements
- gcc (11.2.0)
- ruby (3.0.2p107) (used for building 8cc.c and elc.c in ELVM)
- SBCL (2.1.11) (used for building lambda-8cc-main.lam)


### Building
lambda-8cc.lam can be built from source by simply running:

```sh
make lambda-8cc.lam
```


## Self-Hosting Test
When running `make lambda-8cc.lam`, the source files `build/8cc.c` and `build/elc.c` are created.
These are the files that are used to create `build/8cc.lam` and `build/elc.lam` which are linked to create `lambda-8cc.lam`.
Since the files `build/8cc.c` and `build/elc.c` are compilable by the x86-64 versions of 8cc and elc,
which is lambda-8cc itself, lambda-8cc.lam should be able to compile these C sources as well.

The following Make rule does this exact thing:

```sh
make test-self-host
```

This compiles 8cc.c and elc.c, the source codes for [8cc](https://github.com/rui314/8cc) and [elc](https://github.com/shinh/elvm/blob/master/target/elc.c) (a part of [ELVM](https://github.com/shinh/elvm)) using lambda-8cc, and compares its outputs with the results compiled by the x86-64 versions of 8cc and elc.
As mentioned in [README.md](README.md), since this takes a lot of time and memory, this test is still yet unconfirmed.


### A Full Lambda-Closed Build - Building lambda-8cc-main.lam with LambdaLisp
lambda-8cc.lam depends on three *.lam files, 8cc.lam, elc.lam, and lambda-8cc-main.lam.
8cc.lam, elc.lam are built from C as explained before.
Currently, build/lambda-8cc-main.lam is built by running src/lambda-8cc.cl on Common Lisp, which is a non-lambda-calculus tool.
However, src/lambda-8cc.cl is actually written as a polyglot program for my other project
[LambdaLisp](https://github.com/woodrush/lambdalisp), a Lisp interpreter implemented in lambda calculus.

Using LambdaLisp, lambda-8cc should be able to be built in a full lambda-closed build.
This is unconfirmed yet since it takes a lot of time, but it should be possible since the examples/lambdacraft.cl test is passing in the [LambdaLisp](https://github.com/woodrush/lambdalisp) repo.

lambda-8cc-main.lam can be built by running:

```sh
out/lambda-8cc-main-lambdaisp.lam
```

Testing if it matches the Common Lisp version can be done by:

```sh
make test-lambda-8cc-main-lambdaisp
```

This will build `out/lambda-8cc-main-lambdaisp.lam` using LambdaLisp and `diff` it with `build/lambda-8cc-main.lam`.
Replacing `build/lambda-8cc-main.lam` with `out/lambda-8cc-main-lambdaisp.lam`, you can build the entire lambda-8cc.lam term by solely using tools built on lambda calculus.


## Programming in Lambda Calculus
In my other project [LambdaLisp](https://github.com/woodrush/lambdalisp),
I implemented a Lisp interpreter featuring closures and object-oriented programming in untyped lambda calculus.
A thorough explanation of techniques used in this project is explained in [my blog post](https://woodrush.github.io/blog/lambdalisp.html) about LambdaLisp.
A lot of techniques explained here are used to make lambda-8cc as well.


## Dependent Projects
lambda-8cc is a combination of the following 3 projects:

- [LambdaVM](https://github.com/woodrush/lambdavm) (written by the author of this repository (lambda-8cc), Hikaru Ikuta [@woodrush](https://github.com/woodrush))
  - LambdaVM is a virtual CPU with the Harvard Architecture supporting an extended [ELVM](https://github.com/shinh/elvm) instruction set written in untyped lambda calculus.
  - The VM has an arbitrarily configurable ROM/RAM address bit size and word size, and an arbitrarily configurable number of registers. In lambda-8cc, it is configured to a 24-bit machine with 6 registers to emulate ELVM in lambda calculus.
- [ELVM](https://github.com/shinh/elvm)
  - Written by Shinichiro Hamaji [@shinh](https://github.com/shinh)
  - ELVM (the Esoteric Language Virtual Machine) is a virtual machine architecture for compiling C to a rich set of [esoteric programming languages](https://en.wikipedia.org/wiki/Esoteric_programming_language).
  - I (@woodrush) implemented ELVM's lambda calculus backend by integrating LambdaVM into ELVM.
  - lambda-8cc ports [elc](https://github.com/shinh/elvm/blob/master/target/elc.c), a part of ELVM, to lambda calculus, using the ELVM lambda calculus backend. `elc` compiles ELVM assembly to various languages including x86 and lambda calculus.
- [8cc](https://github.com/rui314/8cc)
  - Written by Rui Ueyama [@rui314](https://github.com/rui314)
  - 8cc is a self-hosting C11 compiler written in C, with a minimal source code size. It is able to compile its own source code, 8cc.c.
  - ELVM uses 8cc to compile C to ELVM assembly. lambda-8cc ports this ELVM version of 8cc to lambda calculus.


## Detailed Stats
Detailed stats for the compilation time and memory usage on [Melvin Zhang](https://github.com/melvinzhang)'s [lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus) is summarized here:

| Program                              | Compilation Time (a.s + a.out) | Max. Compilation RAM Usage (a.s, a.out) | x86 Binary Size         |
|--------------------------------------|--------------------------------|-----------------------------------------|-------------------------|
| [putchar.c](./examples/putchar.c)    | 1.8 min (1.5 min + 0.3 min)    | 31 GB (31 GB, 7 GB)                     | 342 bytes               |
| [hello.c](./examples/hello.c)        | 2.4 min (1.6 min + 0.8 min)    | 42 GB (42 GB, 22 GB)                    | 802 bytes               |
| [echo.c](./examples/echo.c)          | 2.5 min (1.8 min + 0.7 min)    | 46 GB (46 GB, 17 GB)                    | 663 bytes               |
| [rot13.c](./examples/rot13.c)        | 7.7 min (5.0 min + 2.7 min)    | 84 GB (84 GB, 65 GB)                    | 2,118 bytes             |
| [fizzbuzz.c](./examples/fizzbuzz.c)  | 49.7 min (22.2 min + 27.5 min) | 240 GB (177 GB, 240 GB)                 | 5,512 bytes             |
| [primes.c](./examples/primes.c)      | 53.0 min (24.0 min + 29.0 min) | 241 GB (172 GB, 241 GB)                 | 5,500 bytes             |


