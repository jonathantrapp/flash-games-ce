#include <stdbool.h>
#include <stdio.h>
#include <fileioc.h>
#include "art.h"
const uint8_t *artBanks[ART_BANKS];
bool art_open(void) {
    for (int i = 0; i < ART_BANKS; ++i) {
        char name[9];
        snprintf(name, sizeof name, "SCA%02u", i);
        ti_var_t file = ti_Open(name, "r");
        if (!file) return false;
        artBanks[i] = ti_GetDataPtr(file);
        ti_Close(file);
    }
    return true;
}
gfx_sprite_t *art_sprite(int id, int frame) {
    const Art *art = &artTable[id];
    unsigned offset = art->offset + (frame % art->frames) * (art->width * art->height + 2);
    return (gfx_sprite_t *)(artBanks[art->bank] + offset);
}
void art_draw(int id, int frame, int x, int y) {
    const Art *art = &artTable[id];
    if (x >= 320 || y >= 240 || x + art->width <= 0 || y + art->height <= 0) return;
    gfx_TransparentSprite(art_sprite(id,frame),x,y);
}
void art_background(int left) {
    gfx_Sprite(art_sprite(left,0),0,0);
    gfx_Sprite(art_sprite(left+1,0),160,0);
}
