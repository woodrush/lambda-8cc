void putchar(char c);

int main (void) {
    for (char* s = "Hello, world!"; *s; s++) {
        putchar(*s);
    }
    return 0;
}
