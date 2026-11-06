#ifndef PEDRO_RENDER_CACHE_H
#define PEDRO_RENDER_CACHE_H
#include <stdint.h>
void cache_stage_tiles(const uint8_t *back,const uint8_t *solid,const uint8_t *decor,unsigned cells);
void cached_tile(int tile,int x,int y);
void cached_sprite(const uint8_t *source,int x,int y);
#endif
