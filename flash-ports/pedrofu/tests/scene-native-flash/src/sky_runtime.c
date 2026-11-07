#include "../../../src/game.h"
#include "../../../src/sky_runtime.h"
#ifndef SKY_FLASH_ROWS
#define SKY_FLASH_ROWS
#endif
#include "../../../src/sky_rows.h"

const uint8_t *sky_ram_pixels;
void sky_runtime_refresh(void) {
    sky_ram_pixels = NULL;
    uint8_t f = ti_Open(SKY_TEMP_NAME, "r");
    if (f) {
        if (!ti_IsArchived(f) && ti_GetSize(f) == SKY_ROW_BYTES) sky_ram_pixels = ti_GetDataPtr(f);
        ti_Close(f);
    }
}
void sky_runtime_stop(void) {
    sky_ram_pixels = NULL;
    ti_Delete(SKY_TEMP_NAME);
}
void sky_runtime_start(void) {
    /* Reclaim a crash leftover before considering the optional allocation.
     * Delete rather than trust its contents or silently unarchive it. */
    sky_runtime_stop();
    if (os_MemChk(NULL) < SKY_ROW_BYTES + SKY_RAM_RESERVE + 32) return;
    uint8_t f = ti_Open(SKY_TEMP_NAME, "w");
    if (!f) return;
    if (ti_Resize(SKY_ROW_BYTES, f) != SKY_ROW_BYTES) {
        ti_Close(f); sky_runtime_stop(); return;
    }
    uint8_t *pixels = ti_GetDataPtr(f);
    for (unsigned y = 0; y < 240; ++y) if (sky_row_offsets[y] != 65535) {
        memcpy(pixels + sky_row_offsets[y], uidata[2][0] + 2 + y * 160, 160);
        memcpy(pixels + sky_row_offsets[y] + 160, uidata[2][1] + 2 + y * 160, 160);
    }
    ti_Close(f);
    sky_runtime_refresh();
}
