/* Hardware diagnostic support; see hwdiag.h. Empty in production builds. */
#include "game.h"
#include "hwdiag.h"
#ifdef PEDRO_HWDIAG
#include <sys/lcd.h>
uint8_t diag_colors[8];
uint24_t diag_entry_sp, diag_low_sp, diag_free_ram, diag_frames, diag_last_phase;

void diag_start(void) {
    volatile uint8_t marker = 0;
    diag_entry_sp = (uint24_t)&marker;
    diag_colors[0] = cBlack; diag_colors[1] = cCyan; diag_colors[2] = cGreen; diag_colors[3] = cPanel;
    diag_colors[4] = cWhite; diag_colors[5] = cYellow; diag_colors[6] = cGold; diag_colors[7] = cRed;
    /* Paint only the documented 4 KB OS stack below our current frame. */
    uint8_t *lo = (uint8_t *)DIAG_STACK_BOTTOM, *hi = (uint8_t *)(diag_entry_sp - 160);
    if (hi > lo) memset(lo, DIAG_PAINT, hi - lo);
    diag_low_sp = diag_entry_sp;
    diag_free_ram = os_MemChk(NULL);
}

static void diag_fault(const char *why) {
    char line[64];
    gfx_SetDrawBuffer(); gfx_FillScreen(cBlack); gfx_SetTextFGColor(cRed);
    print_fit("PEDRO DIAGNOSTIC STOP", 8, 8); gfx_SetTextFGColor(cWhite);
    print_fit(why, 8, 28);
    snprintf(line, sizeof line, "entry SP %06X  lowest %06X", (unsigned)diag_entry_sp, (unsigned)diag_low_sp); print_fit(line, 8, 48);
    snprintf(line, sizeof line, "stack used %u  free RAM %u", (unsigned)(DIAG_STACK_TOP - diag_low_sp), (unsigned)diag_free_ram); print_fit(line, 8, 64);
    snprintf(line, sizeof line, "frames %u  phase %u  level %d", (unsigned)diag_frames, (unsigned)diag_last_phase, g.level + 1); print_fit(line, 8, 80);
    print_fit("Photograph this screen, then press CLEAR.", 8, 112);
    gfx_SwapDraw();
    do kb_Scan(); while (!kb_IsDown(kb_KeyClear));
    gfx_End();
    exit(0);
}

void diag_frame(void) {
    char line[48];
    diag_frames++;
    if (!(diag_frames & 15)) {
        const uint8_t *p = (const uint8_t *)DIAG_STACK_BOTTOM, *end = (const uint8_t *)diag_low_sp;
        while (p < end && *p == DIAG_PAINT) p++;
        if ((uint24_t)p < diag_low_sp) diag_low_sp = (uint24_t)p;
        if (diag_low_sp < DIAG_STACK_BOTTOM + DIAG_STACK_GUARD) diag_fault("Stack nearly exhausted.");
    }
    /* Overlay strip on the frame about to be shown (diagnostic build only). */
    snprintf(line, sizeof line, "DIAG f%u stk%u ram%u", (unsigned)diag_frames, (unsigned)(DIAG_STACK_TOP - diag_low_sp), (unsigned)diag_free_ram);
    gfx_SetColor(cBlack); gfx_FillRectangle(0, 232, 200, 8); gfx_SetTextFGColor(cWhite); gfx_PrintStringXY(line, 1, 232);
    diag_block(2, diag_colors[diag_frames & 1 ? 4 : 7]);
}
#endif
