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

int isprime (int n) {
    for (int i=2; i<n; i++) {
        if (n % i == 0) {
            return 0;
        }
    }
    return 1;
}

int main (void) {
    for (int i=2; i<=100; i++) {
        if (isprime(i)) {
            printint(i);
            putchar('\n');
        }
    }
    return 0;
}
