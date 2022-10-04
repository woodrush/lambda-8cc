# lambda-8cc: x86 C Compiler Written in Untyped Lambda Calculus
lambda-8cc is an x86 C compiler written as a monolithic closed untyped lambda calculus term.
The entire plaintext lambda term is 40MB, available as a zipped file [./bin/lambda-8cc.lam.zip](./bin/lambda-8cc.lam.zip).

As a sneak peek, [rot13.c](examples/rot13.c) is a program that compiles on gcc with no errors.
The exact same program can be compiled with lambda-8cc producing [rot13.bin](out/rot13.bin) runnable on x86/x86-64 Linux:

```sh
$ echo "Hello, world!" | ./rot13.bin
Uryyb, jbeyq!
$ echo "Uryyb, jbeyq!" | ./rot13.bin
Hello, world!
```

Not only can lambda-8cc compile C to x86, it can compile C to lambda calculus terms like [rot13.lam](out/rot13.lam) that runs on the same lambda calculus interpreter used to run lambda-8cc itself.
lambda-8cc first compiles C programs to an intermediate assembly like [rot13.s](out/rot13.s) and then compiles it to various formats.

lambda-8cc is based on the following 3 projects:
The first one is [LambdaVM](https://github.com/woodrush/lambdavm) written by the author of this repo [Hikaru Ikuta](https://github.com/woodrush),
a programmable virtual CPU written as an untyped lambda calculus term.
This is combined with [8cc](https://github.com/rui314/8cc) by [Rui Ueyama](https://github.com/rui314),
and a modified version of [ELVM](https://github.com/shinh/elvm) by [Shinichiro Hamaji](https://github.com/shinh).


## Overview
### Everything is Done as Lambdas
lambda-8cc is written as a closed untyped lambda calculus term ${\rm lambda8cc} = \lambda x. \cdots$ which takes an input string $x$ representing a C program and outputs an x86 executable expressed as a list of bytes.
Characters and bytes are encoded as a list of bits with $0 = \lambda x. \lambda y.x$, $1 = \lambda x. \lambda y.y$,
and lists are encoded in the [Scott encoding](https://en.wikipedia.org/wiki/Mogensen%E2%80%93Scott_encoding) with ${\rm cons} = \lambda x.\lambda y.\lambda f.(f x y)$, ${\rm nil} = \lambda x.\lambda y.y$.

Therefore, _everything_ in the computation process, even including integers, is expressed as pure lambda terms,
without the need of introducing any non-lambda type object whatsoever.
lambda-8cc makes [beta reduction](https://en.wikipedia.org/wiki/Lambda_calculus#%CE%B2-reduction) the sole requirement for compiling C to x86.
Note that the process doesn't depend on the choice of variable names as well.
Instead of encoding the character `A` as a variable with the name `A`, it is encoded as a list of bits of its ASCII encoding `01000001`.

Various lambda calculus interpreters automatically handle this I/O format so that it runs on the terminal - standard input is encoded into lambda terms, and the output lambda term is decoded and shown on the terminal.
Using these interpreters, lambda-8cc can be run on the terminal to compile C programs just like gcc.

For further details on how I/O is handled and how programs are written in lambda calculus,
please see the implementation details of my other project [LambdaLisp](https://github.com/woodrush/lambdalisp),
a Lisp interpreter written as an untyped lambda calculus term.


### C to Lambda Calculus
Not only can lambda-8cc compile C to x86, it can compile C to lambda calculus itself.
Compiled lambda calculus terms run on the same lambda calculus interpreter used to run lambda-8cc.
This makes lambda-8cc self-contained in the realm of lambda calculus.
The output program can also be run on minimal interpreters such as the 521-byte lambda calculus interpreter [SectorLambda](https://justine.lol/lambda/) written by Justine Tunney,
and the [IOCCC](https://www.ioccc.org/) 2012 ["Most functional"](https://www.ioccc.org/2012/tromp/hint.html) interpreter written by [John Tromp](https://github.com/tromp) (the [source](https://www.ioccc.org/2012/tromp/tromp.c) is in the shape of a λ).

It has long been known in computer science that lambda calculus is turing-complete.
lambda-8cc shows this in a rather straightforward way by demonstrating that C programs can directly be compiled to lambda calculus terms.

The nice thing about lambda calculus is that the language specs are extremely simple.
With lambda-8cc, in a way we are preserving knowledge about how to compile C in a timeless method.
Even if humanity loses knowledge about the x86 instruction set,
as long as we remember the rules for lambda calculus and have [the lambda term for lambda-8cc](./bin/lambda-8cc.lam.zip),
we can still use the entire C language through lambda-8cc and build everything on top of it again.


## A Quick Example
Here is a program [rot13.c](examples/rot13.c) that encodes/decodes standard input to/from the [ROT13](https://en.wikipedia.org/wiki/ROT13) cipher.
It compiles without errors using gcc:

```c
// rot13.c: Encodes/decodes standard input to/from the ROT13 cipher

#define EOF -1

int putchar(int c);
char getchar(void);

char c;
int offset;

int main (void) {
    for (;;) {
        c = getchar();
        if (c == EOF) {
            break;
        }

        offset = 0;
        if (('a' <= c && c < 'n') || ('A' <= c && c < 'N')) {
            offset = 13;
        } else if (('n' <= c && c <= 'z') || ('N' <= c && c <= 'Z')) {
            offset = -13;
        }
        putchar(c + offset);
    }
    return 0;
}
```

The same program can be compiled by lambda-8cc out of the box as follows.
First build the tools:

```sh
$ make tools  # Build the interpreter uni++ and the tools lam2bin, asc2bin
$ unzip bin/lambda-8cc.lam.zip
$ cat lambda-8cc.lam | bin/lam2bin | bin/asc2bin > lambda-8cc.Blc  # Prepare format for uni++
```

Then rot13.c can be compiled as:

```sh
$ cat lambda-8cc.Blc examples/rot13.c | bin/uni++ -o > a.out
$ chmod 755 a.out

$ echo "Hello, world!" | ./a.out
Uryyb, jbeyq!
$ echo "Uryyb, jbeyq!" | ./a.out
Hello, world!
```

The requirement here is `clang++` for building `uni++` and `gcc` or `cc` for building `lam2bin` and `asc2bin`.
Here, uni++ is a very fast [lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus) written by [Melvin Zhang](https://github.com/melvinzhang).

This runs in about 8 minutes on my machine. But be careful - it takes 145 GB of memory to run it!
If you have free HDD space or a USB drive, you can use it to [dynamically extend your swap region](https://askubuntu.com/questions/178712/how-to-increase-swap-space)
using a swap file with `mkswap` and `swapon` to run this.
Also, by compiling the assembly and x86 executable separately, you can halve down the RAM usage to 65 GB, as shown in the [Usage](#usage) section.
Small programs such as [putchar.c](examples/putchar.c) only take about 40 GB of memory.

More running time stats are available in the [Running Times and Memory Usage](#running-times-and-memory-usage) section.
More example C programs compilable by lambda-8cc can be found under [./examples](./examples).


### What is lambda-8cc.Blc?
lambda-8cc.Blc is lambda-8cc.lam ([./bin/lambda-8cc.lam.zip](./bin/lambda-8cc.lam.zip)) written in [binary lambda calculus](https://tromp.github.io/cl/Binary_lambda_calculus.html#Lambda_encoding) notation. As in the previous command, it is built as:

```sh
cat lambda-8cc.lam | bin/lam2bin | bin/asc2bin > lambda-8cc.Blc
```

lam2bin is a utility that converts plaintext lambda calculus notation such as `\x.x` to [binary lambda calculus](https://tromp.github.io/cl/Binary_lambda_calculus.html#Lambda_encoding) notation,
written by [Justine Tunney](https://github.com/jart) (available at [https://justine.lol/lambda/](https://justine.lol/lambda/)).
Binary lambda calculus (BLC) is a highly compact notation for writing lambda calculus terms using only `0` and `1`, proposed by [John Tromp](https://github.com/tromp).
Any lambda term with an arbitrary number of variables can be rewritten to BLC notation.
For example, $\lambda x.x$ becomes `0010`.
I've written details on the BLC notation in [one of my blog posts](https://woodrush.github.io/blog/lambdalisp.html#the-binary-lambda-calculus-notation).

[asc2bin](https://github.com/woodrush/lambda-calculus-devkit/blob/main/src/asc2bin.c) is a utility that packs the 0/1 BLC bitstream in ASCII to a byte stream.
Using this tool, the encoding `0010` for $\lambda x.x$ becomes only half a byte.
The interpreter uni++ accepts lambda terms in the byte-packed BLC format, converted above using lam2bin and asc2bin.

The output of `cat lambda-8cc.lam | bin/lam2bin` is available as [./bin/lambda-8cc.blc.zip](./bin/lambda-8cc.blc.zip).
Note that this is different from the uppercase lambda-8cc.Blc after passing it to asc2bin.

All in all, the conversion from lambda-8cc.lam to lambda-8cc.Blc is simply a transformation of notation for a format that's accepted by the interpreter uni++.


### Compiling C to Lambda Calculus
Not only can lambda-8cc compile C to x86, it can compile C to lambda calculus as well.
[rot13.c](examples/rot13.c) compiles to [rot13.lam](out/rot13.lam), which runs on the same lambda calculus interpreter uni++.
Here is what it looks like:

```text
((\x.\y.\z.\a.\b.((\c.((\d.((\e.((\f.((\g.((\h.(a ((\i.(i (d ( \j.\k.(k (\l.\m.\n.\o.(o k (j m))) k)) a) ...
(\f.(f((\x.\y.(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(y(x(x(y(x(x(x(\x.\y.y))))))))))))))))))))))))))(\x.\y.(y(\x.\a.x)x))(\x.\y.(y(\x.\a.a)x)))
(\f.(f((\x.\y.(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(y(y(x(x(y(x(y(\x.\y.y))))))))))))))))))))))))))(\x.\y.(y(\x.\a.x)x))(\x.\y.(y(\x.\a.a)x)))
(\f.(f((\x.\y.(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(y(y(x(y(y(x(x(\x.\y.y))))))))))))))))))))))))))(\x.\y.(y(\x.\a.x)x))(\x.\y.(y(\x.\a.a)x)))
(\f.(f((\x.\y.(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(y(y(x(y(y(x(x(\x.\y.y))))))))))))))))))))))))))(\x.\y.(y(\x.\a.x)x))(\x.\y.(y(\x.\a.a)x)))
...
(\f.(f
  (\f.(f(\f.(f(\x.\y.\z.\a.\b.\c.\d.\e.a)(\x.\y.x)((\x.\y.(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(y(\x.\y.y))))))))))))))))))))))))))(\x.\y.(y(\x.\a.x)x))(\x.\y.(y(\x.\a.a)x)))(\x.x)))(\x.\y.y)))
(\f.(f
  (\f.(f(\f.(f(\x.\y.\z.\a.\b.\c.\d.\e.e)(\x.\y.y)(\x.(x(\y.\z.z)(\x.(x(\z.\a.z)(\x.(x(\a.\b.b)(\a.\b.b)))))))(\x.(x(\y.\z.z)(\x.(x(\z.\a.a)(\x.(x(\a.\b.a)(\a.\b.b)))))))))
  (\f.(f(\f.(f(\x.\y.\z.\a.\b.\c.\d.\e.d)(\x.\y.x)((\x.\y.(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(\x.\y.y))))))))))))))))))))))))))(\x.\y.(y(\x.\a.x)x))(\x.\y.(y(\x.\a.a)x)))(\f.(f(\x.(x(\y.\z.z)(\x.(x(\z.\a.a)(\x.(x(\a.\b.a)(\a.\b.b)))))))(\x.\y.x)))))
  ...
(\f.(f
  (\f.(f(\f.(f(\x.\y.\z.\a.\b.\c.\d.\e.e)(\x.\y.y)(\x.(x(\y.\z.z)(\x.(x(\z.\a.a)(\x.(x(\a.\b.b)(\x.(x(\b.\c.b)(\b.\c.c)))))))))(\x.(x(\y.\z.z)(\x.(x(\z.\a.z)(\x.(x(\a.\b.a)(\a.\b.b)))))))))
  (\f.(f(\f.(f(\x.\y.\z.\a.\b.\c.\d.\e.d)(\x.\y.x)((\x.\y.(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(y(\x.\y.y))))))))))))))))))))))))))(\x.\y.(y(\x.\a.x)x))(\x.\y.(y(\x.\a.a)x)))(\f.(f(\x.(x(\y.\z.z)(\x.(x(\z.\a.z)(\x.(x(\a.\b.a)(\a.\b.b)))))))(\x.\y.x)))))
  ...
(\f.(f
  (\f.(f(\f.(f(\x.\y.\z.\a.\b.\c.\d.\e.a)(\x.\y.x)((\x.\y.(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(x(y(x(y(\x.\y.y))))))))))))))))))))))))))(\x.\y.(y(\x.\a.x)x))(\x.\y.(y(\x.\a.a)x)))(\x.x)))(\x.\y.y)))
...
(\x.\y.y))))))))))))))))))
```

The first line is [LambdaVM](https://github.com/woodrush/lambdavm), described in the next section.
The following few lines are memory initialization values.
The next lines with indentation are the instruction list shown in [rot13.s](out/rot13.s) encoded as lambda calculus terms
passed to LambdaVM.

rot13.lam can be run on [IOCCC](https://www.ioccc.org/) 2012 ["Most functional"](https://www.ioccc.org/2012/tromp/hint.html) binary lambda calculus interpreter written by [John Tromp](https://github.com/tromp).
It can be used to decipher its hint message [how13](https://www.ioccc.org/2012/tromp/how13), uncovering some of the secrets of the magical lambda calculus interpreter which the [source](https://www.ioccc.org/2012/tromp/tromp.c) is in shape of a λ:

```sh
wget https://www.ioccc.org/2012/tromp/tromp.c
gcc -Wall -W -std=c99 -O2 -m64 -DInt=long -DA=9999999 -DX=8 tromp.c -o tromp

wget https://www.ioccc.org/2012/tromp/how13

cat rot13.lam | bin/lam2bin | bin/asc2bin > rot13.Blc
cat rot13.Blc how13 | ./tromp
```

These commands run on Linux. Building `tromp` on a Mac is a little tricky but possible - I've covered the details [here](https://github.com/woodrush/lambdalisp#building-tromp-on-a-mac).


## How is it Done? - A Programmable Virtual CPU Written in Lambda Calculus
To build lambda-8cc, I first made [LambdaVM](https://github.com/woodrush/lambdavm),
a programmable virtual CPU with an arbitrarily configurable ROM/RAM address size and word size with an arbitrary number of registers,
all expressed as a single lambda calculus term.
Despite its rather rich capability, LambdaVM has a very small lambda calculus term.
Here is its entire lambda calculus term in plaintext:

```text
LambdaVM = \x.\y.\z.\a.\b.((\c.((\d.((\e.((\f.((\g.((\h.(a ((\i.(i (d (\j.\k.(k 
(\l.\m.\n.\o.(o k (j m))) k)) a) (\j.(i z (d (\k.\l.\m.\n.\o.\p.((\q.((\r.((\s.(
n (\t.\u.\v.\w.v) (\t.t) (\t.\u.\v.u) (\t.\u.u) (o (\t.\u.\v.(o (k l m) p)) o) (
n (\t.\u.((\v.(t (\w.\A.\B.((\C.(A (C B) (s B C))) (\C.\D.(w (D ((\E.(m (\F.\G.\
H.(E (y (\I.\J.(J (\K.\L.K) I)) F) G)) (E c m))) (\E.\F.(r B E (k l F u o)))) (\
E.(E (y (\F.(F (\G.\H.H))) C) (v p))) A) (D (\E.\F.\G.\H.((\I.(F (I G) (s G I)))
 (s H (\I.\J.(E (e I C) (q J) (v p))))))) (D (\E.\F.((\G.(f (\H.\I.I) (E (s F e 
C)) G G (\H.(r F)))) c)) v) (q C) (h l C (r D) v) (s D (g l C) k m u o p) (D (\E
.\F.(s E (f F F) C (\G.(r E)))) v) (r D C v))))))) (k l m u o)))))) (h p))) (g p
))) (\q.(h j q (\r.(r (k l m) p))))))))))) (\i.\j.(d (\k.\l.\m.\n.(l (\o.\p.\q.(
m (\r.\s.\t.(k l s (\u.\v.(k v s (\w.(n (\A.(A u w)))))))) (l n))) (n l l))) i c
 (\k.\l.(j k)))) b) (\i.\j.j))) (d (\h.\i.\j.\k.(i (\l.\m.\n.(j (\o.\p.\q.(o (h 
l) (h m) p k)) (k i))) (k c)))))) (d (\g.\h.\i.\j.\k.(i (\l.\m.\n.((\o.(h (\p.\q
.\r.(l (h o) (o q p))) (o (\p.\q.q) (\p.\q.q)))) (\o.(g o m j (\p.\q.(l (k (\r.(
r p q))) (k (\r.(r q p))))))))) (k j)))))) (d (\f.\g.\h.\i.\j.\k.(i (\l.\m.\n.(j
 (\o.\p.(f g h m p (\q.\r.((\s.((\t.((\u.((\v.(t s q (v (\w.\A.w)) (v (\w.\A.A))
)) (t q (q (\v.\w.w) (\v.\w.v)) (u (\v.\w.v)) (u (\v.\w.w))))) (\u.\v.(k v (\w.(
w u r)))))) (\t.\u.(l (s t u) (s u t))))) (h o (o (\s.\t.t) (\s.\t.s))))))))) (k
 g i)))))) (d (\e.\f.\g.(f (\h.\i.\j.(g (\k.\l.((\m.(h (k m (\n.\o.\p.o)) (k (\n
.\o.\p.p) m))) (e i l))))) (\h.\i.\j.h)))))) (\d.((\e.(d (e e))) (\e.(d (e e))))
))) ((\c.(y c (x c (\d.\e.e)))) (\c.\d.(d (\e.\f.e) c))))
```

Shown here is a lambda calculus term featuring a RAM unit with 8 instructions including I/O and memory operations.
It is also available [here](./bin/lambdavm.png) as an image.
LambdaVM is also a self-contained project where you can enjoy assembly programming in lambda calculus.

Based on LambdaVM, I built lambda-8cc by porting the C compiler [8cc](https://github.com/rui314/8cc) written in C by [Rui Ueyama](https://github.com/rui314) to LambdaVM.
This is done by compiling 8cc's C source code to an assembly for LambdaVM.
To do this, I modified the [ELVM](https://github.com/shinh/elvm) infrastrucuture written by [Shinichiro Hamaji](https://github.com/shinh)
to build a C compiler for LambdaVM, which I used to compile 8cc itself.

The entire monolithic 40MB lambda calculus term is solely handled by this tiny virtual machine to run lambda-8cc.


## Features
As mentioned earlier, not only can lambda-8cc compile C to x86, it can compile C to lambda calculus itself.

Here is a full list of features supported by lambda-8cc:

- Compile C to an x86 executable (a.out)
- Compile C to a lambda calculus term (executable on the terminal with a lambda calculus interpreter)
- Compile C to a binary lambda calculus program (runnable on [SectorLambda](https://justine.lol/lambda/) and the [IOCCC](https://www.ioccc.org/) 2012 ["Most functional"](https://www.ioccc.org/2012/tromp/hint.html) interpreter)
- Compile C to a [SKI combinator calculus](https://en.wikipedia.org/wiki/SKI_combinator_calculus) term (runnable as a [Lazy K](https://tromp.github.io/cl/lazy-k.html) program)
- Compile C to an [ELVM](https://github.com/shinh/elvm) assembly listing
- Compile ELVM assembly to x86/lambda calculus/BLC/SKI combinator calculus

[Lazy K](https://tromp.github.io/cl/lazy-k.html) is a minimal purely functional language with only 4 built-in operators.
I have covered a little bit about it on [my blog post](https://woodrush.github.io/blog/lambdalisp.html#lazy-k) as well.


### Compiler Options
The aforementioned features can be used by passing a compiler option to lambda-8cc. Being written in lambda calculus, naturally, lambda-8cc's compiler options are written in lambda calculus terms as well.

Compiler options are used by applying an optional term as `(lambda-8cc option)` beforehand of the input.
This changes the behavior of the lambda term `lambda-8cc` so that it accepts/produces a different input/output format.

Here are the full list of lambda-8cc's compiler options:

| Input         | Output                                          | Compiler Option                                                                                                      |
|---------------|-------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| C             | x86 executable                                  | $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.x) ~ (\lambda x.x))$ |
| C             | Plaintext lambda calculus term                  | $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.y) ~ (\lambda x.x))$ |
| C             | Binary lambda calculus notation (BLC program)   | $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.z) ~ (\lambda x.x))$ |
| C             | SKI combinator calculus (Lazy K program)        | $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.a) ~ (\lambda x.x))$ |
| C             | ELVM assembly                                   | $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.b) ~ (\lambda x.x))$ |
| ELVM assembly | x86 executable                                  | $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.x) ~ (\lambda x.x))$ |
| ELVM assembly | Plaintext lambda calculus term                  | $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.y) ~ (\lambda x.x))$ |
| ELVM assembly | Binary lambda calculus notation (BLC program)   | $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.z) ~ (\lambda x.x))$ |
| ELVM assembly | SKI combinator calculus (Lazy K program)        | $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.a) ~ (\lambda x.x))$ |

Each option is in the format of a 3-tuple ${\rm cons3} ~ {\rm input} ~ {\rm output} ~ X$ where ${\rm cons 3} = \lambda x. \lambda y. \lambda z. \lambda f. (f x y z)$.
The first element ${\rm input}$ is a selector of a 2-tuple that specifies the input format.
The second element ${\rm output}$ is a selector of a 5-tuple that specifies the output format.
The third element $X = \lambda x.x$ is a placeholder used to distinguish the data structure from the standard input,
also existing for backwards portatiblity in case when more options are added in the future.

Usage of these options on the terminal are explained in the [Usage](#usage) section.


## Running Times and Memory Usage
The following table shows the compilation time and memory usage on [Melvin Zhang](https://github.com/melvinzhang)'s
[lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus).

| Program                              | Compilation Time | Max. RAM Usage at Compilation Time  | x86 Binary Size         | Description                                                                  |
|--------------------------------------|------------------|-------------------------------------|-------------------------|------------------------------------------------------------------------------|
| [putchar.c](./examples/putchar.c)    | 1.8 min          | 31 GB                               | 342 bytes               | Prints `A`                                                                   |
| [hello.c](./examples/hello.c)        | 2.4 min          | 42 GB                               | 802 bytes               | Prints `Hello, world!`                                                       |
| [echo.c](./examples/echo.c)          | 2.5 min          | 46 GB                               | 663 bytes               | Echoes standard input                                                        |
| [rot13.c](./examples/rot13.c)        | 7.7 min          | 84 GB                               | 2,118 bytes             | Encodes/decodes stdin to/from [ROT13](https://en.wikipedia.org/wiki/ROT13)   |
| [fizzbuzz.c](./examples/fizzbuzz.c)  | 49.7 min         | 240 GB                              | 5,512 bytes             | Prints FizzBuzz sequence up to 30                                            |
| [primes.c](./examples/primes.c)      | 53.0 min         | 241 GB                              | 5,500 bytes             | Prints primes up to 100                                                      |

Now that is a lot of memory!
To compile programs that require a huge RAM, you can extend your swap region without changing the partition settings by using a swap file.
If you run Linux and have any storage device such as a HDD or USB drive,
you can use that storage to easily and dynamically extend your swap region using `mkswap` and `swapon`.
The stats on this table are ran with an extended swap region this way.
Instructions are explained in this [askubuntu thread](https://askubuntu.com/questions/178712/how-to-increase-swap-space).

Note that these are the compilation times - the running times for the compiled x86 binary are instantaneous.
This even holds when compiling to lambda calculus terms.
Compiled lambda terms also run instantaneously and only use a few gigabytes of memory when run on a lambda calculus interpreter.

The compilations for these stats were run on an Ubuntu 22.04.1 machine with 48 GB RAM,
16GB SSD swap (default partition), and 274GB (256GiB) HDD swap (dynamically added with `mkswap` and `swapon`).
The running time shown here is the wall clock running time including memory operations.
For swap-heavy programs, the running time could be decreased by using a RAM/storage with a faster I/O speed.


## Theoretically Self-Hosting
lambda-8cc is a port of [8cc](https://github.com/rui314/8cc).
It is also made by compiling 8cc using 8cc itself.
Therefore, given enough time and memory, lambda-8cc can compile its own C source code as well.
This makes lambda-8cc a self-hosting C compiler.
Further details are explained in [details.md](details.md).

However, on currently existing lambda calculus interpreters, the RAM usage explodes for such large programs. 
It would be very exciting to have a lambda calculus interpreter that runs lambda-8cc in a practical time and memory.



## Usage
To compile [hello.c](./examples/hello.c) to x86 using lambda-8cc, simply run:

```sh
make
```

This will unzip [lambda-8cc.lam.zip](./bin/lambda-8cc.lam.zip),
build the [lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus) `uni++` written by [Melvin Zhang](https://github.com/melvinzhang),
and run lambda-8cc on `uni++` creating `a.out`.
You can then run `a.out` as follows, just as you would do in gcc:

```text
$ ./a.out
Hello, world!
```


`make` simplifies a lot of steps. To run each step manually, do the following:

```sh
make uni++ lam2bin asc2bin
unzip bin/lambda-8cc.lam.zip
cat lambda-8cc.lam | ./bin/lam2bin > lambda-8cc.blc
cat lambda-8cc.blc | ./bin/asc2bin > lambda-8cc.Blc

cat lambda-8cc.Blc input.c | ./bin/uni++ -o > a.out
chmod 755 a.out

./a.out
```

The tools involved here are:
- [uni++](https://github.com/melvinzhang/binary-lambda-calculus): A lambda calculus interpreter written by Melvin Zhang [@melvinzhang](https://github.com/melvinzhang).
  - The original name of `uni++` is `uni`. Its source [uni.cpp](https://github.com/melvinzhang/binary-lambda-calculus/blob/master/uni.cpp) is written by Melvin Zhang. uni.cpp is a rewrite of [uni.c](https://github.com/melvinzhang/binary-lambda-calculus/blob/master/uni.c) written by John Tromp [@tromp](https://github.com/tromp), also named `uni`. To prevent the confusion, I have renamed it `uni++` here in this repository.
  - `uni++` features a lot of optimizations including memoization and marker collapsing which significantly speeds up the execution time of gigantic lambda calculus programs.
- `lam2bin`: A tool for rewriting plaintext lambda terms to [binary lambda calculus](https://woodrush.github.io/blog/lambdalisp.html#the-binary-lambda-calculus-notation) notation, which encodes lambda terms using only the characters `0` and `1`.
- `asc2bin`: A tool for packing the 0/1 BLC bitstream to a byte stream, the format accepted by `uni++`.



### Applying Compilation Options
The [compiler options](#compiler-options) shown before can be applied as follows.

To compile C to an ELVM assembly listing `a.s`:
```sh
( ( cat lambda-8cc.lam; printf '(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.b) (\\x.x)))' ) \
  | bin/lam2bin | bin/asc2bin; cat input.c ) | bin/uni++ -o > a.s
```

To compile an ELVM assembly listing `a.s` to x86 executable `a.out`:
```sh
( ( cat lambda-8cc.lam; printf '(\\f.(f (\\x.\\y.y) (\\x.\\y.\\z.\\a.\\b.x) (\\x.x)))' ) \
  | bin/lam2bin | bin/asc2bin; cat a.s ) | bin/uni++ -o > a.out
chmod 755 a.out
```

As described before, by separately compiling `a.s` and `a.out` using these commands, the maximum RAM usage can be cut in half since the memory is freed when each process finishes.

The full set of options can be shown by running lambda-8cc without any input or options,
showing a usage message:

```text
$ cat lambda-8cc.lam | bin/lam2bin | bin/asc2bin | bin/uni++ -o
lambda-8cc v1.0.0

Usage:
    apply lambda-8cc.lam [input-file]
    apply lambda-8cc.lam [option] [input-file]

Options:
    (\f.(f [input] [output] (\x.x)))
    (\f.(f (\x.\y.x) (\x.\y.\z.\a.\b.x) (\x.x))) : C to x86 (defualt)
    (\f.(f (\x.\y.x) (\x.\y.\z.\a.\b.y) (\x.x))) : C to *.lam (plaintext lambda calculus program)
    (\f.(f (\x.\y.x) (\x.\y.\z.\a.\b.z) (\x.x))) : C to *.blc (binary lambda calculus program)
    (\f.(f (\x.\y.x) (\x.\y.\z.\a.\b.a) (\x.x))) : C to *.lazy (SKI combinator calculus, as a Lazy K program)
    (\f.(f (\x.\y.x) (\x.\y.\z.\a.\b.b) (\x.x))) : C to ELVM assembly
    (\f.(f (\x.\y.y) (\x.\y.\z.\a.\b.x) (\x.x))) : ELVM assembly to x86
    (\f.(f (\x.\y.y) (\x.\y.\z.\a.\b.y) (\x.x))) : ELVM assembly to *.lam
    (\f.(f (\x.\y.y) (\x.\y.\z.\a.\b.z) (\x.x))) : ELVM assembly to *.blc
    (\f.(f (\x.\y.y) (\x.\y.\z.\a.\b.a) (\x.x))) : ELVM assembly to *.lazy

lambda-8cc includes the following projects. All of the following projects
are released under the MIT license. See the LICENSE in each location for details.
    8cc: By Rui Ueyama - https://github.com/rui314/8cc
    ELVM: By Shinichiro Hamaji - https://github.com/shinh/elvm
    LambdaVM: By Hikaru Ikuta - https://github.com/woodrush/lambdavm
    lambda-8cc: By Hikaru Ikuta - https://github.com/woodrush/lambda-8cc

```


## Building From Source
For details on building from source, please see [details.md](details.md).


## Credits
lambda-8cc is a combination of 3 projects, [LambdaVM](https://github.com/woodrush/lambdavm), [ELVM](https://github.com/shinh/elvm), and [8cc](https://github.com/rui314/8cc).
[LambdaVM](https://github.com/woodrush/lambdavm) was written by [Hikaru Ikuta](https://github.com/woodrush), the author of this repository (lambda-8cc).
The [ELVM](https://github.com/shinh/elvm) architecture was written by [Shinichiro Hamaji](https://github.com/shinh).
[8cc](https://github.com/rui314/8cc) was written by [Rui Ueyama](https://github.com/rui314).
The version of 8cc used in lambda-8cc is a modified version of 8cc included as a part of ELVM, modified by Shinichiro Hamaji and others.
lambda-8cc also includes elc, a part of ELVM written by Shinichiro Hamaji,
modified by Hikaru Ikuta so that it can compile ELVM assembly to lambda calculus.
The lambda calculus backend for ELVM was written by Hikaru Ikuta, by integrating LambdaVM into ELVM.
The running time and memory usage statistics were measured using a [lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus) written by [Melvin Zhang](https://github.com/melvinzhang).
lam2bin was written by [Justine Tunney](https://github.com/jart).
