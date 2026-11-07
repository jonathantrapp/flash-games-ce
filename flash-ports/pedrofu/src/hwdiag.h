/* Opt-in hardware diagnostic build (make HWDIAG=YES). Production builds compile
 * every hook below to nothing.
 *
 * Purpose: localise a physical-calculator freeze/RAM clear that the OS 5.3
 * emulator does not reproduce. Each hook paints a 6x6 block straight onto the
 * *visible* LCD buffer, so a photograph of a frozen screen shows the phase and
 * subsystem that never finished. Slots, right to left in the top-right corner:
 *   slot 0: main-loop phase  slot 1: simulation subsystem  slot 2: frame parity
 * The stack below the entry SP is painted and checked twice per second; if the
 * deepest use comes within DIAG_STACK_GUARD bytes of the 4 KB OS stack bottom
 * the game stops on a readable fault screen instead of corrupting OS RAM. */
#ifndef HWDIAG_H
#define HWDIAG_H
#include <stdint.h>

enum { DP_INPUT = 1, DP_SIM, DP_FRONTEND, DP_WAIT, DP_DRAW, DP_SWAP, DP_FILEIO };
enum { DS_NONE, DS_INTRO, DS_STORY, DS_PLAYER, DS_ENEMY, DS_SHOT, DS_PROP, DS_ARENA };

#ifdef PEDRO_HWDIAG
#include <sys/lcd.h>
#define DIAG_STACK_TOP 0xD1A87E
#define DIAG_STACK_BOTTOM (DIAG_STACK_TOP - 0x1000)
#define DIAG_STACK_GUARD 384
#define DIAG_PAINT 0xA5
extern uint8_t diag_colors[8];
extern uint24_t diag_entry_sp, diag_low_sp, diag_free_ram, diag_frames, diag_last_phase;
static inline void diag_block(int slot, uint8_t color) {
    uint8_t *vis = (uint8_t *)lcd_UpBase;
    int x0 = 314 - 8 * slot;
    for (int y = 0; y < 6; y++) for (int x = 0; x < 6; x++) vis[y * 320 + x0 + x] = color;
}
#define DIAG_PHASE(p) do { diag_last_phase = (p); diag_block(0, diag_colors[(p) & 7]); } while (0)
#define DIAG_SUB(s) diag_block(1, diag_colors[(s) & 7])
void diag_start(void);
void diag_frame(void);
#else
#define DIAG_PHASE(p) ((void)0)
#define DIAG_SUB(s) ((void)0)
#define diag_start() ((void)0)
#define diag_frame() ((void)0)
#endif
#endif
