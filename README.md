# lambda-8cc: x86 C Compiler Written in Untyped Lambda Calculus
lambda-8cc is a C compiler written as a monolithic closed untyped lambda calculus term.
The entire plaintext lambda term is 40MB, available as a zipped file [./bin/lambda-8cc.lam.zip](./bin/lambda-8cc.lam.zip).

lambda-8cc is a port of [8cc](https://github.com/rui314/8cc) written by [Rui Ueyama](https://github.com/rui314) to lambda calculus, written in C.
To run C on lambda calculus, I first made another project [LambdaVM](https://github.com/woodrush/lambdavm),
and modified the [ELVM](https://github.com/shinh/elvm) infrastrucuture written by [Shinichiro Hamaji](https://github.com/shinh)
to compile C to lambda calculus.

<!-- 8cc is a minimal C compiler written in C, capable of compiling its own source code, 8cc.c.

To implement lambda-8cc, I first built [LambdaVM](https://github.com/woodrush/lambdavm), a virtual CPU with an arbitrarily configurable ROM/RAM address size and word size with an arbitrarily configurable number of registers, all expressed as a closed lambda calculus term.
Using LambdaVM, I emulated the [ELVM](https://github.com/shinh/elvm) architecture written by Shinichiro Hamaji [@shinh](https://github.com/shinh).
lambda-8cc is made by compiling 8cc to ELVM assembly, and running that assembly (expressed as lambda calculus terms) on LambdaVM.
The 8cc implementation used here is also part of ELVM, modified by [@shinh](https://github.com/shinh) and others.
Compilation from C to ELVM assembly is done using ELVM's lambda calculus backend, implemented by myself by integrating LambdaVM into ELVM. -->


## Overview
lambda-8cc is a closed untyped lambda calculus term `lambda-8cc = \x. ...` which takes a C program written as a string as an input and outputs a x86 executable expressed as a list of bytes.
Characters and bytes are encoded as a list of bits with `0 = \x.\y.x`, `1 = \x.\y.y`,
and lists are encoded in the [Scott encoding](https://en.wikipedia.org/wiki/Mogensen%E2%80%93Scott_encoding) with `cons = \x.\y.\f.(f x y)`, `nil = \x.\y.y`.

Therefore, _everything_ in the computation process, even including integers, is expressed as pure lambda terms,
without the need of introducing any non-lambda type object whatsoever.
lambda-8cc makes [beta reduction](https://en.wikipedia.org/wiki/Lambda_calculus#%CE%B2-reduction) the sole requirement for compiling C to x86.
Note that the process doesn't depend on the choice of variable names as well.
Instead of encoding the character `A` as a variable with the name `A`, it is encoded as a list of bits of its ASCII encoding `01000001`.

The nice thing about lambda calculus is that the language specs are extremely simple.
With lambda-8cc, in a way we are preserving knowledge about how to compile C in a timeless method.
Even if humanity loses knowledge about the x86 instruction set,
as long as we remember the rules for lambda calculus and have the lambda term for lambda-8cc,
we can still use the entire C language through lambda-8cc and build everything on top of it again.

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
Detailed usage instructions are available in the [Usage](#usage) section.
Running time stats are available in the [Running Times and Memory Usage](#running-times-and-memory-usage) section.

<!-- This takes about 8 minutes to compile using about a whopping 120 GB of RAM.
If you have a free HDD or USB drive, you can use a [swap file](https://askubuntu.com/questions/178712/how-to-increase-swap-space)
to dynamically extend your swap region without changing the partition settings for running lambda-8cc.
I suspect that the RAM usage can probably be improved by introducing mark-and-sweep garbage collection in the interpreter.
The RAM usage can be halved to 65 GB by separately compiling the assembly `a.s` and the x86 executable `a.out` as described in the [Usage](#usage) section.
Smaller programs such as [putchar.c](./examples/putchar.c) can be compiled in 2 minutes using 31 GB of RAM. -->

lambda-8cc.Blc is lambda-8cc.lam ([./bin/lambda-8cc.lam.zip](./bin/lambda-8cc.lam.zip)) written in [binary lambda calculus](https://tromp.github.io/cl/Binary_lambda_calculus.html#Lambda_encoding) notation, made as follows:

```sh
$ cat lambda-8cc.lam | bin/lam2bin | bin/asc2bin > lambda-8cc.Blc
```

lam2bin is a utility that converts plaintext lambda calculus notation such as `\x.x` to [binary lambda calculus](https://tromp.github.io/cl/Binary_lambda_calculus.html#Lambda_encoding) notation, written by [Justine Tunney](https://github.com/jart) (available at [https://justine.lol/lambda/](https://justine.lol/lambda/)).
Binary lambda calculus (BLC) is a highly compact notation for writing lambda calculus terms using only `0` and `1`, proposed by [John Tromp](https://github.com/tromp).
Any lambda term with an arbitrary number of variables can be rewritten to BLC notation.
For example, `\x.x` becomes `0010`.
I've written details on the BLC notation in my [blog post](https://woodrush.github.io/blog/lambdalisp.html#the-binary-lambda-calculus-notation).

[asc2bin](https://github.com/woodrush/lambda-calculus-devkit/blob/main/src/asc2bin.c) is a utility that packs the 0/1 ASCII bitstream to a byte stream.
Using this tool, the encoding `0010` for `\x.x` becomes only half a byte.
The interpreter uni++ accepts lambda terms in the byte-packed BLC format, converted above using lam2bin and asc2bin.


## Features
Not only can lambda-8cc compile C to x86, it can compile C to lambda calculus itself.
Compiled lambda calculus terms run on the same lambda calculus interpreter used to run lambda-8cc.

Here is a full list of features supported by lambda-8cc:

- Compile C to a x86 executable (a.out)
- Compile C to a lambda calculus term (executable on the terminal with a lambda calculus interpreter)
- Compile C to a [SKI combinator calculus](https://en.wikipedia.org/wiki/SKI_combinator_calculus) term (executable as a [Lazy K](https://tromp.github.io/cl/lazy-k.html) program)
- Compile C to an [ELVM](https://github.com/shinh/elvm) assembly listing
- Compile ELVM assembly to x86/lambda calculus/SKI combinator calculus

lambda-8cc being written in lambda calculus, naturally, its compiler options are written in lambda calculus terms as well.
The behavior of the lambda term `lambda-8cc` can be changed by applying a compiler option as `(lambda-8cc option)` beforehand of the input.
Here are the options:

| Input         | Output                          | Compiler Option                                                                                                      |
|---------------|---------------------------------|----------------------------------------------------------------------------------------------------------------------|
| C             | x86 executable                  | $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.x) ~ (\lambda x.x))$ |
| C             | Plaintext lambda calculus term  | $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.y) ~ (\lambda x.x))$ |
| C             | Binary lambda calculus notation | $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.z) ~ (\lambda x.x))$ |
| C             | SKI combinator calculus         | $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.a) ~ (\lambda x.x))$ |
| C             | ELVM assembly                   | $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.b) ~ (\lambda x.x))$ |
| ELVM assembly | x86 executable                  | $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.x) ~ (\lambda x.x))$ |
| ELVM assembly | Plaintext lambda calculus term  | $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.y) ~ (\lambda x.x))$ |
| ELVM assembly | Binary lambda calculus notation | $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.z) ~ (\lambda x.x))$ |
| ELVM assembly | SKI combinator calculus         | $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.a) ~ (\lambda x.x))$ |

<!-- 
- $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.x) ~ (\lambda x.x))$ : C to x86 (defualt)
- $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.y) ~ (\lambda x.x))$ : C to lambda calculus
- $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.z) ~ (\lambda x.x))$ : C to binary lambda calculus notation
- $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.a) ~ (\lambda x.x))$ : C to SKI combinator calculus
- $\lambda f. (f ~ (\lambda x. \lambda y. x) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.b) ~ (\lambda x.x))$ : C to ELVM assembly
- $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.x) ~ (\lambda x.x))$ : ELVM assembly to x86
- $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.y) ~ (\lambda x.x))$ : ELVM assembly to lambda calculus
- $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.z) ~ (\lambda x.x))$ : ELVM assembly to binary lambda calculus notation
- $\lambda f. (f ~ (\lambda x. \lambda y. y) ~ (\lambda x.\lambda y.\lambda z.\lambda a.\lambda b.a) ~ (\lambda x.x))$ : ELVM assembly to SKI combinator calculus -->

Not only can lambda-8cc compile C to x86, it can compile C to a standalone lambda calculus term that runs on a lambda calculus interpreter.
This makes lambda-8cc self-contained in the realm of lambda calculus.
Compiled lambda terms run on minimal interpreters such as the 521-byte lambda calculus interpreter [SectorLambda](https://justine.lol/lambda/) written by Justine Tunney,
and the [IOCCC](https://www.ioccc.org/) 2012 ["Most functional"](https://www.ioccc.org/2012/tromp/hint.html) interpreter written by John Tromp (the [source](https://www.ioccc.org/2012/tromp/tromp.c) is in the shape of a λ).
lambda-8cc itself should run on these interpreters as well, but currently it takes a lot of time.



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

To compile programs that require a lot of memory, you can extend your swap region without changing the partition settings by using a swap file.
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


## Theoretically Self-Hosting
Since 8cc can compile its own source code 8cc.c, theoretically, lambda-8cc can compile its own C source code as well.
Therefore, lambda-8cc is theoretically a self-hosting C compiler.
However, on currently existing lambda calculus interpreters, the RAM usage explodes for such large programs. 
It would be exciting to have a lambda calculus interpreter that runs lambda-8cc in a practical time and memory.



## Usage
To compile [input.c](./input.c) to x86 using lambda-8cc, simply run:

```sh
make
```

This will unzip [lambda-8cc.zip](./bin/lambda-8cc.zip), build the [lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus) `uni++` written by [Melvin Zhang](https://github.com/melvinzhang), and run lambda-8cc on `uni++` creating `a.out`. You can then run `a.out` as the following, just as you would do in gcc:

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



### Compile C to Lambda Calculus
You can also compile C to lambda calculus:

```

```


### Run in Lazy K
lambda-8cc is also available in Lazy K, a language based on the [SKI combinator calculus](https://en.wikipedia.org/wiki/SKI_combinator_calculus).


## How Does it Work?
lambda-8cc is a port of [8cc](https://github.com/rui314/8cc) written by Rui Ueyama [@rui314](https://github.com/rui314) to lambda calculus.
8cc is a minimal C compiler written in C, capable of compiling its own source code, 8cc.c.

To implement lambda-8cc, I first built [LambdaVM](https://github.com/woodrush/lambdavm), a virtual CPU with an arbitrarily configurable ROM/RAM address size and word size with an arbitrarily configurable number of registers.
Using LambdaVM, I emulated the [ELVM](https://github.com/shinh/elvm) architecture written by Shinichiro Hamaji [@shinh](https://github.com/shinh),
compiled 8cc to ELVM assembly, and ran that assembly on LambdaVM.

The entire lambda calclus term for LambdaVM, the core of lambda-8cc, is very small. Here is its entire lambda calculus term:

![The lambda calculus term for LambdaVM.](./bin/lambdavm.png)

Shown here is a lambda calculus term featuring a RAM unit with 8 instructions including I/O and memory operations.
lambda-8cc is written by passing the assembly code for 8cc, written in lambda calculus terms, to LambdaVM.


## Code Size Efficiency
Compiling [lisp.c](https://github.com/shinh/elvm/blob/master/test/lisp.c), a minimal Lisp implementation from the ELVM repository, to a lambda calculus term using ELVM's lambda calculus backend yields a lambda calculus term over 19,000 lines. On the other hand, the [PDF](https://woodrush.github.io/lambdalisp.pdf) showing the entire lambd a calculus term for [LambdaLisp](https://github.com/woodrush/lambdalisp) is 42 pages, with 28 lines per page, which is 1,176 lines, which is about 16 times smaller than lisp.c. It is strongly expected that further optimizations can shorten LambdaLisp's source lambda term. This large size difference highlights the fact that writing programs in the native style of lambda calculus contribute to a significant size optimization.
Nevertheless, as mentioned earlier, it is important that we have expressed the C compilation process in lambda calculus, which is a simple and universal format of expressing algorithms.

## Credits
lambda-8cc is a combination of 3 projects, [LambdaVM](https://github.com/woodrush/lambdavm), [ELVM](https://github.com/shinh/elvm), and [8cc](https://github.com/rui314/8cc).
[LambdaVM](https://github.com/woodrush/lambdavm) was written by [Hikaru Ikuta](https://github.com/woodrush), the author of this repository (lambda-8cc).
The [ELVM](https://github.com/shinh/elvm) architecture was written by [Shinichiro Hamaji](https://github.com/shinh).
[8cc](https://github.com/rui314/8cc) was written by [Rui Ueyama](https://github.com/rui314).
The version of 8cc used in lambda-8cc is a modified version of 8cc included as a part of ELVM, modified by Shinichiro Hamaji and others.
lambda-8cc also includes elc, a part of ELVM, which compiles ELVM assembly to x86 and lambda calculus, written by Shinichiro Hamaji.
The lambda calculus backend for ELVM was written by Hikaru Ikuta, by integrating LambdaVM into ELVM.
The running time and memory usage statistics were measured using a [lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus) written by [Melvin Zhang](https://github.com/melvinzhang).


## Detailed Stats
Using a lambda calculus interpreter that runs on the terminal, lambda-8cc can be used to compile programs on your computer. Usage instructions are available in the next section.
The compilation time and memory usage on [Melvin Zhang](https://github.com/melvinzhang)'s [lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus) is summarized here:

| Program                              | Compilation Time (a.s + a.out) | Max. Compilation RAM Usage (a.s, a.out) | x86 Binary Size         |
|--------------------------------------|--------------------------------|-----------------------------------------|-------------------------|
| [putchar.c](./examples/putchar.c)    | 1.8 min (1.5 min + 0.3 min)    | 31 GB (31 GB, 7 GB)                     | 342 bytes               |
| [hello.c](./examples/hello.c)        | 2.4 min (1.6 min + 0.8 min)    | 42 GB (42 GB, 22 GB)                    | 802 bytes               |
| [echo.c](./examples/echo.c)          | 2.5 min (1.8 min + 0.7 min)    | 46 GB (46 GB, 17 GB)                    | 663 bytes               |
| [rot13.c](./examples/rot13.c)        | 7.7 min (5.0 min + 2.7 min)    | TODO GB (TODO GB, 65 GB)                | 2,118 bytes             |
| [fizzbuzz.c](./examples/fizzbuzz.c)  | 49.7 min (22.2 min + 27.5 min) | 200 GB (177 GB, 200 GB)                 | 5,512 bytes             |
| [primes.c](./examples/primes.c)      | 53.0 min (24.0 min + 29.0 min) | (172 GB, ? GB)                          | 5,500 bytes             |
