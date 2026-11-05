#include <stddef.h>
#include <stdint.h>
static inline uint8_t ti_Open(const char*a,const char*b){(void)a;(void)b;return 0;}
static inline size_t ti_Read(void*a,size_t b,size_t c,uint8_t d){(void)a;(void)b;(void)c;(void)d;return 0;}
static inline size_t ti_Write(const void*a,size_t b,size_t c,uint8_t d){(void)a;(void)b;(void)d;return c;}
static inline size_t ti_GetSize(uint8_t a){(void)a;return 0;}
static inline void ti_Close(uint8_t a){(void)a;}
static inline void ti_SetArchiveStatus(int a,uint8_t b){(void)a;(void)b;}
