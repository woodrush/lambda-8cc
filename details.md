# lambda-8cc Details
Here I will explain further details about lambda-8cc.

## How Does it Work?
To build lambda-8cc, I first made [LambdaVM](https://github.com/woodrush/lambdavm),
a programmable virtual CPU with an arbitrarily configurable ROM/RAM address size and word size with an arbitrary number of registers,
all expressed as a single lambda calculus term.

The entire lambda calclus term for LambdaVM, the core of lambda-8cc, is very small. Here is its entire lambda calculus term in plaintext:

```text
\x.\y.\z.\a.\b.((\c.((\d.((\e.((\f.((\g.((\h.(a ((\i.(i (d (\j.\k.(k (\l.\m.\n.\
o.(o k (j m))) k)) a) (\j.(i z (d (\k.\l.\m.\n.\o.\p.((\q.((\r.((\s.(n (\t.\u.\v
.\w.v) (\t.t) (\t.\u.\v.u) (\t.\u.u) (o (\t.\u.\v.(o (k l m) p)) o) (n (\t.\u.((
\v.(t (\w.\A.\B.((\C.(A (C B) (s B C))) (\C.\D.(w (D ((\E.(m (\F.\G.\H.(E (y (\I
.\J.(J (\K.\L.K) I)) F) G)) (E c m))) (\E.\F.(r B E (k l F u o)))) (\E.(E (y (\F
.(F (\G.\H.H))) C) (v p))) A) (D (\E.\F.\G.\H.((\I.(F (I G) (s G I))) (s H (\I.\
J.(E (e I C) (q J) (v p))))))) (D (\E.\F.((\G.(f (\H.\I.I) (E (s F e C)) G G (\H
.(r F)))) c)) v) (q C) (h l C (r D) v) (s D (g l C) k m u o p) (D (\E.\F.(s E (f
 F F) C (\G.(r E)))) v) (r D C v))))))) (k l m u o)))))) (h p))) (g p))) (\q.(h 
j q (\r.(r (k l m) p))))))))))) (\i.\j.(d (\k.\l.\m.\n.(l (\o.\p.\q.(m (\r.\s.\t
.(k l s (\u.\v.(k v s (\w.(n (\A.(A u w)))))))) (l n))) (n l l))) i c (\k.\l.(j 
k)))) b) (\i.\j.j))) (d (\h.\i.\j.\k.(i (\l.\m.\n.(j (\o.\p.\q.(o (h l) (h m) p 
k)) (k i))) (k c)))))) (d (\g.\h.\i.\j.\k.(i (\l.\m.\n.((\o.(h (\p.\q.\r.(l (h o
) (o q p))) (o (\p.\q.q) (\p.\q.q)))) (\o.(g o m j (\p.\q.(l (k (\r.(r p q))) (k
 (\r.(r q p))))))))) (k j)))))) (d (\f.\g.\h.\i.\j.\k.(i (\l.\m.\n.(j (\o.\p.(f 
g h m p (\q.\r.((\s.((\t.((\u.((\v.(t s q (v (\w.\A.w)) (v (\w.\A.A)))) (t q (q 
(\v.\w.w) (\v.\w.v)) (u (\v.\w.v)) (u (\v.\w.w))))) (\u.\v.(k v (\w.(w u r))))))
 (\t.\u.(l (s t u) (s u t))))) (h o (o (\s.\t.t) (\s.\t.s))))))))) (k g i)))))) 
(d (\e.\f.\g.(f (\h.\i.\j.(g (\k.\l.((\m.(h (k m (\n.\o.\p.o)) (k (\n.\o.\p.p) m
))) (e i l))))) (\h.\i.\j.h)))))) (\d.((\e.(d (e e))) (\e.(d (e e))))))) ((\c.(y
 c (x c (\d.\e.e)))) (\c.\d.(d (\e.\f.e) c))))
```

Shown here is a lambda calculus term featuring a RAM unit with 8 instructions including I/O and memory operations.
lambda-8cc is written by passing the assembly code for 8cc, written in lambda calculus terms, to LambdaVM.

lambda-8cc is a port of [8cc](https://github.com/rui314/8cc) written by [Rui Ueyama](https://github.com/rui314) to lambda calculus, written in C.
lambda-8cc is made by running 8cc on LambdaVM.
To do this, I modified the [ELVM](https://github.com/shinh/elvm) infrastrucuture written by [Shinichiro Hamaji](https://github.com/shinh) to compile C to a lambda calculus term compatible with LambdaVM.

For more information on LambdaVM, please see the [LambdaVM repo](https://github.com/woodrush/lambdavm).


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
