/* Bounded formatter for the game's closed format vocabulary. No floating
 * point or 64-bit arithmetic: CE int is 24 bits, long is 32 bits.
 * Supports %% %s %d %u %X %lu, decimal width and zero padding.
 * Return/termination follow snprintf, including capacity zero. */
#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>

static void put(char *dest, size_t capacity, size_t *length, char c) {
    if (capacity && *length < capacity - 1) dest[*length] = c;
    ++*length;
}

int snprintf(char *restrict dest, size_t capacity, const char *restrict format, ...) {
    va_list args;
    size_t length = 0;
    va_start(args, format);
    while (*format) {
        if (*format != '%') { put(dest, capacity, &length, *format++); continue; }
        ++format;
        bool zero = *format == '0';
        unsigned width = 0;
        while (*format >= '0' && *format <= '9') width = width * 10 + *format++ - '0';
        bool wide = *format == 'l';
        if (wide) ++format;
        char type = *format;
        if (!type) break;
        ++format;
        if (type == '%') { put(dest, capacity, &length, '%'); continue; }
        if (type == 's') {
            const char *s = va_arg(args, const char *);
            while (*s) put(dest, capacity, &length, *s++);
            continue;
        }
        if (type != 'd' && type != 'u' && type != 'X') continue;
        unsigned long value;
        bool negative = false;
        if (type == 'd') {
            long signed_value = wide ? va_arg(args, long) : va_arg(args, int);
            negative = signed_value < 0;
            /* Unsigned subtraction also handles LONG_MIN without overflow. */
            value = negative ? 0UL - (unsigned long)signed_value : (unsigned long)signed_value;
        } else value = wide ? va_arg(args, unsigned long) : va_arg(args, unsigned int);
        char digits[sizeof(unsigned long) * 3];
        unsigned count = 0, base = type == 'X' ? 16 : 10;
        do { digits[count++] = "0123456789ABCDEF"[value % base]; value /= base; } while (value);
        unsigned used = count + negative;
        if (negative && zero) put(dest, capacity, &length, '-');
        while (width > used) { put(dest, capacity, &length, zero ? '0' : ' '); --width; }
        if (negative && !zero) put(dest, capacity, &length, '-');
        while (count) put(dest, capacity, &length, digits[--count]);
    }
    va_end(args);
    if (capacity) dest[length < capacity ? length : capacity - 1] = 0;
    return (int)length;
}
