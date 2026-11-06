#ifndef SCOUT_INPUT_H
#define SCOUT_INPUT_H
#include <stdbool.h>
#include <stdint.h>
/* Polling records transitions without changing the input being handled.
 * A press and release during a draw must still reach the next update. */
extern uint8_t input_held[8],input_pressed[8];
extern volatile uint32_t scout_input_stats[3]; /* max gap ticks, overflows, transitions */
void input_poll(void);
bool input_next(void);
bool input_pending(void);
#endif
