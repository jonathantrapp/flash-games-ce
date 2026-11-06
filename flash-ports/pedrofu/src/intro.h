#ifndef PEDRO_INTRO_H
#define PEDRO_INTRO_H

#include <stdbool.h>
#include <stdint.h>

/* Call after loading stage 0. Other stages and leaving the stage call cancel. */
void intro_start(void);
void intro_cancel(void);
bool intro_is_active(void);

/* One call per fixed simulation tick (FPS from game.h), before normal updates.
 * Returns true if the tick belonged to the intro, including its final tick.
 * Finishing positions Pedro and starts the original event-1 conversation.
 */
bool intro_update(void);

/* Desired world-camera scroll in pixels; renderer may retain its usual easing. */
void intro_camera(int *x, int *y);

/* Draw after background/world actors, before the foreground tile layer and HUD.
 * The viewport has no artificial vertical offset: supply the actual renderer's
 * world-camera position. If normal world rendering adds +22 for its HUD strip,
 * pass camera_y - 22 so every intro actor receives the same transform.
 */
void intro_draw(int camera_x, int camera_y);

/* Read-only observability for native tests and screenshot timing.
 * phase: 0 inactive, 1 burning blimp, 2 parachute descent, 3 chute collapse.
 */
uint8_t intro_phase(void);
uint32_t intro_tick_count(void);

#endif
