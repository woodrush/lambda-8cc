#ifndef EOF
#define EOF 0
#endif

int putchar(char c);
char getchar(void);

char c;

int main (void) {
    for (;;) {
        c = getchar();
        if (c == EOF) {
            exit(0);
        }
        putchar(c);
    }
    return 0;
}
