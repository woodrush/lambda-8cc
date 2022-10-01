int putchar(int c);

unsigned int __builtin_mod(unsigned int a, unsigned int b) {
    while (a >= b) {
        a -= b;
    }
    return a;
}

unsigned int __builtin_div(unsigned int a, unsigned int b) {
    int ret = 0;
    while (a >= b) {
        a -= b;
        ret += 1;
    }
    return ret;
}

void printstring (char* s) {
    for (; *s; s++) {
        putchar(*s);
    }
}

void printint (int n) {
    char buf_[10];
    buf_[9] = '\0';
    char* buf = buf_ + 9;
    do {
        buf--;
        *buf = '0' + (n % 10);
        n /= 10;
    } while (n);
    printstring(buf);
}

int main (void) {
    int printed;
    for (int i=1; i<=30; i++) {
        printed = 0;
        if (i % 3 == 0) {
            printstring("Fizz");
            printed = 1;
        }
        if (i % 5 == 0) {
            printstring("Buzz");
            printed = 1;
        }
        if (!printed) {
            printint(i);
        }
        putchar('\n');
    }
    return 0;
}
