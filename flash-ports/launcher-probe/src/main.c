/* Launcher probe: isolates which exit-time operation breaks an arTIfiCE relaunch.
 * PROBE_MODE 0: draw and exit. 1: create+write an AppVar in RAM. 2: also archive it (Pedro's exit). */
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
#include <sys/timers.h>
#ifndef PROBE_MODE
#define PROBE_MODE 0
#endif
int main(void) {
    gfx_Begin();
    gfx_FillScreen(18); gfx_SetTextFGColor(255);
    gfx_PrintStringXY("LAUNCHER PROBE", 100, 100);
    gfx_SwapDraw();
    delay(400);
    gfx_End();
#if PROBE_MODE >= 1
    uint8_t f = ti_Open("PRBSAVE", "w");
    if (f) { static uint8_t data[204]; ti_Write(data, 1, sizeof data, f); ti_Close(f); }
#endif
#if PROBE_MODE >= 2
    f = ti_Open("PRBSAVE", "r");
    if (f) { ti_SetArchiveStatus(true, f); ti_Close(f); }
#endif
    return 0;
}
