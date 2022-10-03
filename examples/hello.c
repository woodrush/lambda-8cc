int putchar(int c);

int main (void) {
    for (char* s = "Hello, world!\n"; *s; s++) {
        putchar(*s);
    }
    return 0;
}
