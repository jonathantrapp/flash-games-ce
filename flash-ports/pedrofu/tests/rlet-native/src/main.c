#include <tice.h>
#include <stdbool.h>
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "../../../src/bundle.h"
#include "../../../src/resources.h"
#define COUNT(a) (sizeof(a)/sizeof((a)[0]))
static const uint8_t *banks[BUNDLE_BANKS];
static uint8_t guard[1152],decoded[4096],checker[258];
volatile uint16_t rlet_diag[7]; /* done,tiles,actorframes,guardfail,pixelfail,checkerfixtures,largeframes_skipped */
static bool load(void){for(int i=0;i<BUNDLE_BANKS;i++){char n[9];snprintf(n,sizeof n,"PDB%02d",i);uint8_t f=ti_Open(n,"r");if(!f)return false;const uint8_t*p=ti_GetDataPtr(f);unsigned sz=ti_GetSize(f);bool ok=sz==bundle_bank_sizes[i]&&!memcmp(p,bundle_signature,8)&&p[8]==i;ti_Close(f);if(!ok)return false;banks[i]=p;}return true;}
static const uint8_t *resource(const char*n){for(unsigned i=0;i<COUNT(bundle);i++)if(!strcmp(n,bundle[i].name))return banks[bundle[i].bank]+bundle[i].offset;uint8_t f=ti_Open(n,"r");if(!f)return NULL;const uint8_t*p=ti_GetDataPtr(f);ti_Close(f);return p;}
static void check(const uint8_t *source,unsigned capacity){
 memset(guard,0xa5,sizeof guard);memset(decoded,0x69,sizeof decoded);gfx_ConvertToRLETSprite((gfx_sprite_t *)source,(gfx_rletsprite_t *)(guard+64));
 for(unsigned i=0;i<sizeof guard;i++)if((i<64||i>=64+capacity)&&guard[i]!=0xa5){rlet_diag[3]++;break;}
 gfx_ConvertFromRLETSprite((gfx_rletsprite_t *)(guard+64),(gfx_sprite_t *)decoded);
 if(memcmp(decoded,source,2+(unsigned)source[0]*source[1]))rlet_diag[4]++;
}
int main(void){gfx_Begin();gfx_SetDrawBuffer();gfx_SetTransparentColor(0);gfx_SetTextBGColor(0);gfx_SetTextTransparentColor(0);uint16_t white=0x7fff,black=0;gfx_SetPalette(&white,2,255);gfx_SetPalette(&black,2,0);
 if(!load()){rlet_diag[0]=2;}else{
  const uint8_t *tiles[2]={resource("PDTILE0"),resource("PDTILE1")};
  if(!tiles[0]||!tiles[1])rlet_diag[0]=2;else{
   for(int i=0;i<296;i++){check(tiles[i/148]+(i%148)*258,410);rlet_diag[1]++;}
   for(int id=0;id<60;id++){const ArtDef*a=&artdef[id];if(!a->frames)continue;char n[9];snprintf(n,sizeof n,"PDG%02d",id);const uint8_t*p=resource(n);if(!p){rlet_diag[0]=2;break;}for(int flip=0;flip<2;flip++)for(int j=0;j<3;j++){int frame=j==0?0:j==1?a->frames/2:a->frames-1;if((a->w+1)*a->h*3/2+2<=1024&&a->w*a->h+2<=sizeof decoded){check(p+(flip*a->frames+frame)*a->stride,1024);rlet_diag[2]++;}else rlet_diag[6]++;}}
   checker[0]=checker[1]=16;for(int first=0;first<2;first++){for(int i=0;i<256;i++)checker[i+2]=((i%16+i/16+first)&1)?255:0;check(checker,410);rlet_diag[5]++;}
   if(!rlet_diag[0])rlet_diag[0]=1;
  }
 }
 gfx_FillScreen(0);gfx_SetTextFGColor(255);gfx_PrintStringXY("PDRLET native conversion QA",8,12);char text[40];for(int i=0;i<7;i++){snprintf(text,sizeof text,"%d: %d",i,rlet_diag[i]);gfx_PrintStringXY(text,12,35+i*20);}gfx_SwapDraw();while(1){kb_Scan();if(kb_Data[6]&kb_Clear)break;}gfx_End();return 0;
}
