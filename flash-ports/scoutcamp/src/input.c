#include "input.h"
#include <keypadc.h>
#include <sys/timers.h>
#include <string.h>
#define INPUT_QUEUE 16
static uint8_t queue[INPUT_QUEUE][8],observed[8],read_index,write_index,count;
static uint32_t last_poll;
uint8_t input_held[8],input_pressed[8];
volatile uint32_t scout_input_stats[3];
void input_poll(void) {
    uint32_t now=timer_GetSafe(1,TIMER_UP),gap=now-last_poll;
    if(gap<262)return; /* about 125 Hz; do not rescan at every drawn tile row */
    if(last_poll&&gap>scout_input_stats[0])scout_input_stats[0]=gap;
    last_poll=now;
    kb_Scan();
    uint8_t current[8];
    /* keypadc's kb_Data indexes 16-bit hardware rows; it is not a byte array. */
    for(unsigned i=0;i<8;i++)current[i]=kb_Data[i];
    if(!memcmp(observed,current,8))return;
    if(count==INPUT_QUEUE){scout_input_stats[1]++;return;}
    memcpy(observed,current,8);
    scout_input_stats[2]++;
    memcpy(queue[write_index],observed,8);
    write_index=(write_index+1)%INPUT_QUEUE;count++;
}
bool input_pending(void){return count!=0;}
bool input_next(void) {
    memset(input_pressed,0,sizeof input_pressed);
    if(!count)return false;
    for(unsigned i=0;i<8;i++){
        input_pressed[i]=queue[read_index][i]&~input_held[i];
        input_held[i]=queue[read_index][i];
    }
    read_index=(read_index+1)%INPUT_QUEUE;count--;
    return true;
}
