#ifndef SKY_RUNTIME_H
#define SKY_RUNTIME_H
#include <stdint.h>
/* Private, disposable unarchived AppVar. Never a save or a resource bank. */
#define SKY_TEMP_NAME "PDSKYTMP"
#define SKY_RAM_RESERVE 6144
extern const uint8_t *sky_ram_pixels;
void sky_runtime_start(void);
void sky_runtime_refresh(void);
void sky_runtime_stop(void);
#endif
