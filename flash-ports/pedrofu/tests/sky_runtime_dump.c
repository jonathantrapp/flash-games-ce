#define GAME_H
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "../src/sky_runtime.h"
const uint8_t *uidata[3][2];
static unsigned memory=100000,size,exists,archived,fail_open,fail_resize,deletes,bank;
static uint8_t storage[2][38000];
static size_t os_MemChk(void*p){(void)p;return memory;}
static uint8_t ti_Open(const char*n,const char*m){assert(!strcmp(n,SKY_TEMP_NAME));if(fail_open)return 0;if(*m=='w'){exists=1;size=0;}return exists;}
static void ti_Close(uint8_t f){assert(f==1);}
static int ti_Delete(const char*n){assert(!strcmp(n,SKY_TEMP_NAME));exists=archived=size=0;deletes++;return 0;}
static bool ti_IsArchived(uint8_t f){assert(f==1);return archived;}
static unsigned ti_GetSize(uint8_t f){assert(f==1);return size;}
static uint8_t *ti_GetDataPtr(uint8_t f){assert(f==1);return storage[bank];}
static int ti_Resize(size_t n,uint8_t f){assert(f==1);if(fail_resize)return 0;size=n;return n;}
#include "../src/sky_runtime.c"
static uint8_t halves[2][38402];
int main(void){
 FILE*f=fopen("data/PDU20.bin","rb");assert(f);assert(fread(halves[0],1,38402,f)==38402);fclose(f);
 f=fopen("data/PDU21.bin","rb");assert(f);assert(fread(halves[1],1,38402,f)==38402);fclose(f);
 uidata[2][0]=halves[0];uidata[2][1]=halves[1];
 exists=archived=1;size=111;sky_runtime_start();assert(deletes==1&&!archived&&sky_ram_pixels&&size==SKY_ROW_BYTES);
 unsigned compared=0;
 for(unsigned y=0;y<240;y++)for(unsigned x=0;x<320;x++){
  unsigned char actual=sky_row_offsets[y]==65535?sky_row_colors[y]:sky_ram_pixels[sky_row_offsets[y]+x];
  assert(actual==halves[x/160][2+y*160+x%160]);compared++;
 }
 memcpy(storage[1],storage[0],SKY_ROW_BYTES);bank=1;sky_runtime_refresh();assert(sky_ram_pixels==storage[1]);
 sky_runtime_stop();assert(!exists&&!sky_ram_pixels);
 memory=SKY_ROW_BYTES+SKY_RAM_RESERVE+31;sky_runtime_start();assert(!exists&&!sky_ram_pixels);
 memory++;sky_runtime_start();assert(exists&&sky_ram_pixels);sky_runtime_stop();
 fail_open=1;sky_runtime_start();assert(!exists&&!sky_ram_pixels);fail_open=0;
 fail_resize=1;sky_runtime_start();assert(!exists&&!sky_ram_pixels);fail_resize=0;
 sky_runtime_start();size--;sky_runtime_refresh();assert(!sky_ram_pixels);
 size=SKY_ROW_BYTES;archived=1;sky_runtime_refresh();assert(!sky_ram_pixels);
 sky_runtime_stop();assert(!exists&&!sky_ram_pixels);
 printf("%u pixels; lifecycle assertions passed\n",compared);return 0;
}
