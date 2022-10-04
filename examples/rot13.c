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
