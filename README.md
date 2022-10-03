# lambda-8cc: x86 C Compiler Written in Untyped Lambda Calculus
lambda-8cc is a C compiler written as a monolithic closed untyped lambda calculus term.
The entire plaintext lambda term is 40MB, available as a zipped file [./bin/lambda-8cc.lam.zip](./bin/lambda-8cc.lam.zip).

To build lambda-8cc, I first made [LambdaVM](https://github.com/woodrush/lambdavm),
a programmable virtual CPU with an arbitrarily configurable ROM/RAM address size and word size with an arbitrary number of registers,
all expressed as a single lambda calculus term.
Despite its rather rich capability, LambdaVM has a very small lambda calculus term shown in [lambdavm.png](./bin/lambdavm.png).

lambda-8cc is a port of [8cc](https://github.com/rui314/8cc) written by [Rui Ueyama](https://github.com/rui314) to lambda calculus, written in C.
lambda-8cc is made by running 8cc on LambdaVM.
To do this, I modified the [ELVM](https://github.com/shinh/elvm) infrastrucuture written by [Shinichiro Hamaji](https://github.com/shinh) to compile C to a lambda calculus term compatible with LambdaVM.


## Overview
### Everything is Done as Lambdas
lambda-8cc is a closed untyped lambda calculus term `lambda-8cc = \x. ...` which takes a C program written as a string as an input and outputs a x86 executable expressed as a list of bytes.
Characters and bytes are encoded as a list of bits with `0 = \x.\y.x`, `1 = \x.\y.y`,
and lists are encoded in the [Scott encoding](https://en.wikipedia.org/wiki/Mogensen%E2%80%93Scott_encoding) with `cons = \x.\y.\f.(f x y)`, `nil = \x.\y.y`.

Therefore, _everything_ in the computation process, even including integers, is expressed as pure lambda terms,
without the need of introducing any non-lambda type object whatsoever.
lambda-8cc makes [beta reduction](https://en.wikipedia.org/wiki/Lambda_calculus#%CE%B2-reduction) the sole requirement for compiling C to x86.
Note that the process doesn't depend on the choice of variable names as well.
Instead of encoding the character `A` as a variable with the name `A`, it is encoded as a list of bits of its ASCII encoding `01000001`.

### C to Lambda Calculus
Not only can lambda-8cc compile C to x86, it can compile C to lambda calculus itself.
Compiled lambda calculus terms run on the same lambda calculus interpreter used to run lambda-8cc.
This makes lambda-8cc self-contained in the realm of lambda calculus.
The output program can also be run on minimal interpreters such as the 521-byte lambda calculus interpreter [SectorLambda](https://justine.lol/lambda/) written by Justine Tunney,
and the [IOCCC](https://www.ioccc.org/) 2012 ["Most functional"](https://www.ioccc.org/2012/tromp/hint.html) interpreter written by John Tromp (the [source](https://www.ioccc.org/2012/tromp/tromp.c) is in the shape of a λ).

The nice thing about lambda calculus is that the language specs are extremely simple.
With lambda-8cc, in a way we are preserving knowledge about how to compile C in a timeless method.
Even if humanity loses knowledge about the x86 instruction set,
as long as we remember the rules for lambda calculus and have the lambda term for lambda-8cc,
we can still use the entire C language through lambda-8cc and build everything on top of it again.

### Further Details
For further details on how I/O is handled and how programs are written in lambda calculus,
please see the implementation details of my other project [LambdaLisp](https://github.com/woodrush/lambdalisp),
a Lisp interpreter written as an untyped lambda calculus term.


## Example
Here is a program [rot13.c](examples/rot13.c) that encodes/decodes standard input to/from the [ROT13](https://en.wikipedia.org/wiki/ROT13) encoding.
It compiles without errors using gcc:

```c
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

The same program can be compiled by lambda-8cc out of the box as follows:

```sh
$ cat lambda-8cc.Blc examples/rot13.c | bin/uni++ -o > a.out
$ chmod 755 a.out

$ echo "Hello, world!" | ./a.out
Uryyb, jbeyq!
```

Here, uni++ is a very fast [lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus) written by [Melvin Zhang](https://github.com/melvinzhang).
This takes about 8 minutes to run on my machine.
More running time stats are available in the [Running Times and Memory Usage](#running-times-and-memory-usage) section.
Detailed usage instructions are available in the [Usage](#usage) section.


### What is lambda-8cc.Blc?
lambda-8cc.Blc is lambda-8cc.lam ([./bin/lambda-8cc.lam.zip](./bin/lambda-8cc.lam.zip)) written in [binary lambda calculus](https://tromp.github.io/cl/Binary_lambda_calculus.html#Lambda_encoding) notation, made as follows:

```sh
$ cat lambda-8cc.lam | bin/lam2bin | bin/asc2bin > lambda-8cc.Blc
```

lam2bin is a utility that converts plaintext lambda calculus notation such as `\x.x` to [binary lambda calculus](https://tromp.github.io/cl/Binary_lambda_calculus.html#Lambda_encoding) notation,
written by [Justine Tunney](https://github.com/jart) (available at [https://justine.lol/lambda/](https://justine.lol/lambda/)).
Binary lambda calculus (BLC) is a highly compact notation for writing lambda calculus terms using only `0` and `1`, proposed by [John Tromp](https://github.com/tromp).
Any lambda term with an arbitrary number of variables can be rewritten to BLC notation.
For example, `\x.x` becomes `0010`.
I've written details on the BLC notation in [one of my blog posts](https://woodrush.github.io/blog/lambdalisp.html#the-binary-lambda-calculus-notation).
The output of `cat lambda-8cc.lam | bin/lam2bin` is available as [./bin/lambda-8cc.blc.zip](./bin/lambda-8cc.blc.zip).

[asc2bin](https://github.com/woodrush/lambda-calculus-devkit/blob/main/src/asc2bin.c) is a utility that packs the 0/1 ASCII bitstream to a byte stream.
Using this tool, the encoding `0010` for `\x.x` becomes only half a byte.
The interpreter uni++ accepts lambda terms in the byte-packed BLC format, converted above using lam2bin and asc2bin.

All in all, the conversion from lambda-8cc.lam to lambda-8cc.Blc is simply a transformation of notation for a format that's accepted by the interpreter uni++.


## Features
As mentioned earlier, not only can lambda-8cc compile C to x86, it can compile C to lambda calculus itself.

Here is a full list of features supported by lambda-8cc:

- Compile C to a x86 executable (a.out)
- Compile C to a lambda calculus term (executable on the terminal with a lambda calculus interpreter)
- Compile C to a binary lambda calculus program (runnable on [SectorLambda](https://justine.lol/lambda/) and the [IOCCC](https://www.ioccc.org/) 2012 ["Most functional"](https://www.ioccc.org/2012/tromp/hint.html) interpreter)
- Compile C to a [SKI combinator calculus](https://en.wikipedia.org/wiki/SKI_combinator_calculus) term (runnable as a [Lazy K](https://tromp.github.io/cl/lazy-k.html) program)
- Compile C to an [ELVM](https://github.com/shinh/elvm) assembly listing
- Compile ELVM assembly to x86/lambda calculus/BLC/SKI combinator calculus

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

Usage of these options on the terminal are explained in the [Usage](#usage) section.


## Running Times and Memory Usage
The following table shows the compilation time and memory usage on [Melvin Zhang](https://github.com/melvinzhang)'s
[lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus).

| Program                              | Compilation Time | Max. RAM Usage at Compilation Time  | x86 Binary Size         | Description                                                                  |
|--------------------------------------|------------------|-------------------------------------|-------------------------|------------------------------------------------------------------------------|
| [putchar.c](./examples/putchar.c)    | 1.8 min          | 36 GB                               | 342 bytes               | Prints `A`                                                                   |
| [hello.c](./examples/hello.c)        | 2.8 min          | 51 GB                               | 802 bytes               | Prints `Hello, world!`                                                       |
| [echo.c](./examples/echo.c)          | 3.0 min          | 57 GB                               | 663 bytes               | Echoes standard input                                                        |
| [rot13.c](./examples/rot13.c)        | 10.5 min         | 97 GB                               | 2,118 bytes             | Encodes/decodes stdin to/from [ROT13](https://en.wikipedia.org/wiki/ROT13)   |
| [fizzbuzz.c](./examples/fizzbuzz.c)  | 53.9 min         | 240 GB                              | 5,512 bytes             | Prints FizzBuzz sequence up to 30                                            |
| [primes.c](./examples/primes.c)      | 57.3 min         | 241 GB                              | 5,500 bytes             | Prints primes up to 100                                                      |

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

This will unzip [lambda-8cc.zip](./bin/lambda-8cc.zip),
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
unzip bin/lambda-8cc.zip
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
- `asc2bin`: A tool for packing the 0/1 bitstream to a byte stream, the format accepted by `uni++`.



### Applying Compilation Options
The [compiler options](#compiler-options) shown before can be applied as follows:

```sh
( ( cat lambda-8cc.lam; printf '(\\f.(f (\\x.\\y.x) (\\x.\\y.\\z.\\a.\\b.b) (\\x.x)))' ) \
  | bin/lam2bin | bin/asc2bin; cat input.c ) | bin/uni++ -o > a.s
```

The option shown here compiles C to an ELVM assembly listing `a.s`.

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


## Run in Lazy K
lambda-8cc is also available in [Lazy K](https://tromp.github.io/cl/lazy-k.html), a language based on the [SKI combinator calculus](https://en.wikipedia.org/wiki/SKI_combinator_calculus).
For further details, please see [details.md](details.md).


## Building From Source
For details on building from source, please see [details.md](details.md).


## Credits
lambda-8cc is a combination of 3 projects, [LambdaVM](https://github.com/woodrush/lambdavm), [ELVM](https://github.com/shinh/elvm), and [8cc](https://github.com/rui314/8cc).
[LambdaVM](https://github.com/woodrush/lambdavm) was written by [Hikaru Ikuta](https://github.com/woodrush), the author of this repository (lambda-8cc).
The [ELVM](https://github.com/shinh/elvm) architecture was written by [Shinichiro Hamaji](https://github.com/shinh).
[8cc](https://github.com/rui314/8cc) was written by [Rui Ueyama](https://github.com/rui314).
The version of 8cc used in lambda-8cc is a modified version of 8cc included as a part of ELVM, modified by Shinichiro Hamaji and others.
lambda-8cc also includes elc, a part of ELVM, which compiles ELVM assembly to x86 and lambda calculus, written by Shinichiro Hamaji.
The lambda calculus backend for ELVM was written by Hikaru Ikuta, by integrating LambdaVM into ELVM.
The running time and memory usage statistics were measured using a [lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus) written by [Melvin Zhang](https://github.com/melvinzhang).
lam2bin was written by [Justine Tunney](https://github.com/jart).
