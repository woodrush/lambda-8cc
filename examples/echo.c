#define EOF -1

int putchar(int c);
char getchar(void);

char c;

int main (void) {
    for (;;) {
        c = getchar();
        if (c == EOF) {
            break;
        }
        putchar(c);
    }
    return 0;
}
