# lambda-8cc: x86 C Compiler Written in Untyped Lambda Calculus
lambda-8cc is a C compiler written as a closed untyped lambda calculus term.
The entire plaintext lambda term is 160MB, available as a zipped file [./bin/lambda-8cc.zip](./bin/lambda-8cc.zip).

lambda-8cc is a closed untyped lambda calculus term `lambda-8cc = \x. ...` which takes a C program written as a string as an input and outputs a x86 executable. Characters and bytes are encoded as a list of bits with `0 = \x.\y.x`, `1 = \x.\y.y`,
and lists are encoded in the [Scott encoding](https://en.wikipedia.org/wiki/Mogensen%E2%80%93Scott_encoding) with `cons = \x.\y.\f.(f x y)`, `nil = \x.\y.y`, so the entire computation consists solely of the beta-reduction of closed lambda terms, without the need of introducing any non-lambda type object whatsoever.

For further details on handling I/O and writing programs in lambda calculus, please see the implementation details of my other project [LambdaLisp](https://github.com/woodrush/lambdalisp), a Lisp interpreter written as an untyped lambda calculus term.

lambda-8cc can do the following things depending on the compiler option:
- Compile C to a x86 executable
- Compile C to a lambda calculus term (executable on the terminal with a lambda calculus interpreter)
- Compile C to an [ELVM](https://github.com/shinh/elvm) assembly listing
- Compile ELVM assembly to x86/lambda calculus

Using a lambda calculus interpreter that runs on the terminal, lambda-8cc can be used to compile programs on your computer. Usage instructions are available in the next section.
The runtime and memory usage on [Melvin Zhang](https://github.com/melvinzhang)'s [lambda calculus interpreter](https://github.com/melvinzhang/binary-lambda-calculus) is summarized here:

| Program                         | Runtime (8cc, elc)       | Maximum RAM Usage (8cc, elc) |
|---------------------------------|--------------------------|------------------------------|
| [putchar.c](./examples/hello.c) | TODO min.                | TODO GB                      |
| [hello.c](./examples/hello.c)   | TODO min.                | TODO GB                      |
| [echo.c](./examples/echo.c)     | TODO min.                | TODO GB                      |
| [rot13.c](./examples/rot13.c)   | 6.5 min., 4 min          | 90 GB, 70GB                  |

lambda-8cc is a combination of the following 3 projects:

<!-- - [LambdaVM](https://github.com/woodrush/lambdavm) written by Hikaru Ikuta [@woodrush](https://github.com/woodrush), the author of this repository (lambda-8cc)
- [8cc](https://github.com/rui314/8cc) written by Rui Ueyama [@rui314](https://github.com/rui314)
- [ELVM](https://github.com/shinh/elvm) written by Shinichiro Hamaji [@shinh](https://github.com/shinh) -->

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
  - 8cc is a self-hosting C11 compiler written in C, with a minimal source code size.
  - ELVM uses 8cc to compile C to ELVM assembly. lambda-8cc ports this ELVM version of 8cc to lambda calculus.


Since 8cc can compile its own source code 8cc.c, theoretically, lambda-8cc can compile its own C source code as well. Therefore, lambda-8cc is theoretically a self-hosting C compiler. However, on currently existing lambda calculus interpreters, the RAM usage explodes for such large programs. It would be exciting to have a lambda calculus interpreter that runs lambda-8cc in a practical time and memory.



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
