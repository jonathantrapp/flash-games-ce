#include <stdint.h>
typedef struct{int x,y;}E;
int ex1(E*e){return e->x/256;}
int ex2(E*e){return (int16_t)((uint24_t)e->x>>8);}
int ex3(E*e){return *(const int16_t*)((const uint8_t*)&e->x+1);}
int ex4(E*e){union{int x;struct{uint8_t f;int16_t p;}part;}u;u.x=e->x;return u.part.p;}
