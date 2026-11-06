#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../src/bundle.h"
#define COUNT(a) (sizeof(a)/sizeof((a)[0]))
static const uint8_t *banks[BUNDLE_BANKS];
static uint8_t bytes[BUNDLE_BANKS][32768];static unsigned sizes[BUNDLE_BANKS];static int missing=-1;
static uint8_t ti_Open(const char*n,const char*m){(void)m;int i=atoi(n+3);return i==missing?0:i+1;}
static unsigned ti_GetSize(uint8_t f){return sizes[f-1];}
static uint8_t *ti_GetDataPtr(uint8_t f){return bytes[f-1];}
static void ti_Close(uint8_t f){(void)f;}
static bool open_banks(void){for(int i=0;i<BUNDLE_BANKS;i++){char name[9];snprintf(name,sizeof name,"PDB%02d",i);uint8_t f=ti_Open(name,"r");if(!f)return false;unsigned size=ti_GetSize(f);const uint8_t *p=ti_GetDataPtr(f);bool valid=size==bundle_bank_sizes[i]&&size>=11&&!memcmp(p,bundle_signature,8)&&p[8]==i&&(unsigned)(p[9]+256*p[10])==size;ti_Close(f);if(!valid)return false;banks[i]=p;}return true;}
static void valid_banks(void){for(unsigned i=0;i<BUNDLE_BANKS;i++){sizes[i]=bundle_bank_sizes[i];memcpy(bytes[i],bundle_signature,8);bytes[i][8]=i;bytes[i][9]=sizes[i]&255;bytes[i][10]=sizes[i]>>8;}}
int main(void){valid_banks();
 printf("R complete_banks %d 1\n",open_banks());missing=3;printf("R missing_bank %d 0\n",open_banks());missing=-1;
 sizes[3]--;printf("R truncated_bank %d 0\n",open_banks());sizes[3]=0;printf("R empty_bank %d 0\n",open_banks());
 valid_banks();bytes[3][0]^=1;printf("R mismatched_signature %d 0\n",open_banks());
 valid_banks();bytes[3][8]=4;printf("R wrong_bank_index %d 0\n",open_banks());
 valid_banks();bytes[3][9]^=1;printf("R wrong_declared_length %d 0\n",open_banks());return 0;}
