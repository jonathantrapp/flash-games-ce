#include "../../../src/game.h"
#include "../../../src/bundle.h"
#include "../../../src/profile.c"
Game g;
const uint8_t *artdata[60],*tiledata[2],*uidata[3][2],*uiimg[UI_COUNT];
uint8_t cBlack=0,cWhite=255,cYellow=254,cGold=252,cRed=254,cGreen=254,cCyan=255,cPanel=1;
volatile uint16_t skill_ui_diag[5]; /* done,assertions,failures,badtext,maxlines */
static const uint8_t *banks[BUNDLE_BANKS];
int absi(int x){return x<0?-x:x;}
int clampi(int v,int lo,int hi){return v<lo?lo:v>hi?hi:v;}
int levels_passed(void){return 0;}
bool load_level(int level){g.level=level;g.mode=PLAY;return true;}
static const uint8_t *resource(const char *name){
 for(unsigned i=0;i<COUNT(bundle);i++)if(!strcmp(bundle[i].name,name))return banks[bundle[i].bank]+bundle[i].offset;
 uint8_t f=ti_Open(name,"r");if(!f)return NULL;const uint8_t*p=ti_GetDataPtr(f);ti_Close(f);return p;
}
static uint8_t nearest(const uint8_t *palette,int r,int g,int b){
 int best=1,distance=0x7fffff;for(int i=1;i<256;i++){
  unsigned p=palette[i*2]|((unsigned)palette[i*2+1]<<8);
  int dr=((p>>10)&31)*255/31-r,dg=((p>>5)&31)*255/31-g,db=(p&31)*255/31-b;
  int d=dr*dr+dg*dg+db*db;if(d<distance){distance=d;best=i;}
 }return best;
}
static bool load(void){
 for(int i=0;i<BUNDLE_BANKS;i++){char name[9];snprintf(name,sizeof name,"PDB%02d",i);uint8_t f=ti_Open(name,"r");if(!f)return false;const uint8_t*p=ti_GetDataPtr(f);bool valid=ti_GetSize(f)==bundle_bank_sizes[i]&&!memcmp(p,bundle_signature,8)&&p[8]==i;ti_Close(f);if(!valid)return false;banks[i]=p;}
 const uint8_t*p=resource("PDCOLOR");if(!p)return false;gfx_SetPalette(p,512,0);
 cBlack=nearest(p,0,0,0);cPanel=nearest(p,24,24,48);cCyan=nearest(p,90,220,255);
 for(int i=0;i<3;i++)for(int half=0;half<2;half++){char name[9];snprintf(name,sizeof name,"PDU%d%d",i,half);uidata[i][half]=resource(name);if(!uidata[i][half])return false;}
 for(int i=0;i<UI_COUNT;i++){uiimg[i]=resource(uidef[i].name);if(!uiimg[i])return false;}
 return true;
}
void draw_ui(int id,int fr,int x,int y){if(id<0||id>=UI_COUNT||!uiimg[id])return;const UiDef*u=&uidef[id];if(fr<0)fr=0;if(fr>=u->frames)fr=u->frames-1;gfx_TransparentSprite((gfx_sprite_t *)(uiimg[id]+fr*u->stride),x,y);}
static void checked_print(const char *s,int x,int y){
 if(x<0||y<0||y>232||x+(int)gfx_GetStringWidth(s)>320)skill_ui_diag[3]++;
 gfx_PrintStringXY(s,x,y);
}
#define gfx_PrintStringXY checked_print
void print_fit(const char *s, int x, int y) {
    if (!s || y < 0 || y > 232 || x > 315) return;
    if (x < 0) x = 0;
    if (x + (int)gfx_GetStringWidth(s) <= 316) { gfx_PrintStringXY(s, x, y); return; }
    char buffer[96] = {0}; int n = 0;
    while (s[n] && n < 90) { buffer[n] = s[n]; buffer[n + 1] = 0; if (x + (int)gfx_GetStringWidth(buffer) > 316) { buffer[n] = 0; break; } n++; }
    gfx_PrintStringXY(buffer, x, y);
}
void wrap_text(int x, int y, int width, const char *s, int step) {
    char line[96]; int n = 0;
    if (!s || width <= 0 || step <= 0) return;
    while (*s && y <= 232) {
        if (*s == '\n') { line[n] = 0; print_fit(line, x, y); n = 0; y += step; s++; continue; }
        if (*s == ' ') { if (n && n < 90) line[n++] = ' '; s++; continue; }
        int len = 0; while (s[len] && s[len] != ' ' && s[len] != '\n') len++;
        if (len > 40) len = 40;
        /* Check capacity before copying: a narrow-font line can contain many
         * characters even when it still fits the requested pixel width. */
        if (n + len >= (int)sizeof line) {
            line[n] = 0; print_fit(line, x, y); y += step; n = 0;
            if (y > 232) break;
        }
        memcpy(line + n, s, len); line[n + len] = 0;
        if (n && (int)gfx_GetStringWidth(line) > width) {
            while (n && line[n - 1] == ' ') n--;
            line[n] = 0; print_fit(line, x, y); y += step; memcpy(line, s, len); n = len; line[n] = 0;
        } else n += len;
        s += len;
    }
    line[n] = 0; if (n) print_fit(line, x, y);
}
#include "../../../src/frontend.c"
#undef gfx_PrintStringXY
static void expect(bool condition){skill_ui_diag[1]++;if(!condition)skill_ui_diag[2]++;}
static void key(unsigned value){g.tap=value;frontend_update();g.tap=0;}
int main(void){
 gfx_Begin();gfx_SetDrawBuffer();gfx_SetTransparentColor(0);gfx_SetTextTransparentColor(0);gfx_SetTextBGColor(0);
 if(!load()){skill_ui_diag[0]=2;gfx_End();return 1;}
 g.mode=SKILLS;g.previousmode=MAP;progress.points=5;
 key(HITKEY);expect(!skill_details&&g.mode==SKILLS);
 progress.have[0]=1;key(HITKEY);expect(skill_details&&skill_next&&skill_scroll==0);
 key(MENUKEY);expect(!skill_details&&g.mode==SKILLS);
 key(HITKEY);key(ACCEPT);expect(progress.skills[0]==1&&progress.points==4&&skill_details);
 key(RIGHT);expect(skill_next);draw_frontend();expect(skill_detail_total>0&&skill_detail_total<=12);
 key(LEFT);expect(!skill_next);key(DOWN);expect(skill_scroll==0);
 key(FURYKEY);expect(progress.skills[0]==0&&progress.points==5);draw_frontend();expect(skill_next);
 key(HITKEY);expect(!skill_details);key(RIGHT);expect(skill_cursor==1);
 key(MENUKEY);expect(g.mode==MAP);
 g.mode=SKILLS;skill_cursor=5;skill_details=true;skill_next=true;
 memset(progress.have,1,sizeof progress.have);memset(progress.skills,5,sizeof progress.skills);
 for(int id=0;id<45;id++){
  skill_cursor=id;for(int rank=0;rank<=5;rank++){
   progress.skills[id]=rank;skill_next=rank<5;skill_scroll=0;draw_frontend();
   expect(skill_detail_total>0&&skill_detail_total<=12);
   if(skill_detail_total>skill_ui_diag[4])skill_ui_diag[4]=skill_detail_total;
  }progress.skills[id]=5;
 }
 skill_cursor=5;skill_next=true;draw_frontend();expect(!skill_next);
 expect(skill_ui_diag[3]==0);skill_ui_diag[0]=1;
 draw_frontend();gfx_SwapDraw();
 while(1){kb_Scan();if(kb_Data[6]&kb_Clear)break;}
 gfx_End();return 0;
}
