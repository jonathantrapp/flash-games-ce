#include "game.h"
#include "bundle.h"
#include "intro.h"
#include "render_cache.h"
Game g;
volatile uint8_t pedro_diag[8];
const uint8_t *artdata[60],*tiledata[2],*uidata[3][2],*uiimg[UI_COUNT];
const uint8_t *pedro_flame;
int absi(int v){return v<0?-v:v;}
int clampi(int v,int lo,int hi){return v<lo?lo:(v>hi?hi:v);}
int approach(int v,int target,int amount){return v<target?clampi(v+amount,v,target):clampi(v-amount,target,v);}
static const uint8_t *banks[BUNDLE_BANKS];
static bool open_banks(void){for(int i=0;i<BUNDLE_BANKS;i++){char name[9];snprintf(name,sizeof name,"PDB%02d",i);uint8_t f=ti_Open(name,"r");if(!f)return false;unsigned size=ti_GetSize(f);const uint8_t *p=ti_GetDataPtr(f);bool valid=size==bundle_bank_sizes[i]&&size>=11&&!memcmp(p,bundle_signature,8)&&p[8]==i&&(unsigned)(p[9]+256*p[10])==size;ti_Close(f);if(!valid)return false;banks[i]=p;}return true;}
const uint8_t *bundle_find(const char *name,unsigned *size){for(unsigned i=0;i<COUNT(bundle);i++)if(!strcmp(bundle[i].name,name)){if(size)*size=bundle[i].size;return banks[bundle[i].bank]+bundle[i].offset;}return NULL;}
static const uint8_t *resource(const char *name,unsigned min){unsigned size=0;const uint8_t *p=bundle_find(name,&size);if(p)return size>=min?p:NULL;uint8_t f=ti_Open(name,"r");if(!f)return NULL;p=ti_GetSize(f)>=min?ti_GetDataPtr(f):NULL;ti_Close(f);return p;}
bool load_resources(void){
 if(!open_banks())return false;
 pedro_flame=resource("PDPFLAME",13*722);if(!pedro_flame)return false;
 const uint8_t *pal=resource("PDCOLOR",512);if(!pal)return false;gfx_SetPalette(pal,512,0);
 tiledata[0]=resource("PDTILE0",148*258);tiledata[1]=resource("PDTILE1",148*258);
 for(int i=0;i<60;i++){char name[9];snprintf(name,sizeof name,"PDG%02d",i);if(artdef[i].frames)artdata[i]=resource(name,artdef[i].stride*artdef[i].frames*2);}
 for(int i=0;i<3;i++)for(int half=0;half<2;half++){char name[9];snprintf(name,sizeof name,"PDU%d%d",i,half);uidata[i][half]=resource(name,38402);}
 for(int i=0;i<UI_COUNT;i++)uiimg[i]=resource(uidef[i].name,uidef[i].stride*uidef[i].frames);
 return tiledata[0]&&tiledata[1]&&artdata[0]&&artdata[2]&&uidata[0][0]&&uidata[0][1]&&uidata[1][0]&&uidata[1][1]&&uidata[2][0]&&uidata[2][1]&&uiimg[UI_HEART]&&uiimg[UI_SKI]&&uiimg[UI_SKB];
}
void draw_sprite(int id,int fr,int facing,int x,int y){if(id<0||id>=60||!artdata[id])return;const ArtDef *a=&artdef[id];if(!a->frames||x>=320||y>=240||x+a->w<=0||y+a->h<=0)return;if(fr<0)fr=0;else if(fr>=a->frames)fr%=a->frames;cached_sprite(artdata[id]+((facing<0?a->frames:0)+fr)*a->stride,x,y);}
void draw_ui(int id,int fr,int x,int y){if(id<0||id>=UI_COUNT||!uiimg[id])return;const UiDef *u=&uidef[id];if(fr<0)fr=0;if(fr>=u->frames)fr=u->frames-1;gfx_TransparentSprite((gfx_sprite_t *)(uiimg[id]+fr*u->stride),x,y);}
int levels_passed(void){int n=0;while(n<15&&progress.passed[n])n++;return n;}
int tile_at(int x,int y){if(x<0||x>=(int)g.w*16)return 1;if(y<0)return 1;if(y>=(int)g.h*16)return 0;return g.solid[(y/16)*g.w+x/16];}
static int slope(int t){switch(t){case 14:case 86:case 121:case 123:case 171:return 1;case 18:case 90:case 122:case 125:case 170:return 2;default:return 0;}}
bool blocked(int x,int y){int t=tile_at(x,y);return t&&!slope(t)&&t!=55&&(t<62||t>66);}
bool body_collides(int x,int y,int bw,int bh){return blocked(x,y)||blocked(x+bw-1,y)||blocked(x,y+bh-1)||blocked(x+bw-1,y+bh-1);}
void move_body(int *x,int *y,int *v,int dx,int bw,int bh,int *floor){
 int tx=*x/16,ty=*y/16,oldbottom=ty+bh,step=dx<0?-1:1;
 int destination=*x+dx,end=destination/16;
 /* Collision changes only at whole-pixel boundaries, not at each of the
  * sixteen fixed-point fractions within a pixel. Retain the exact last
  * legal fraction while checking every crossed pixel (no tunnelling). */
 for(int xx=tx;xx!=end;){xx+=step;if(body_collides(xx,ty,bw,bh)){destination=step>0?xx*16-1:(xx+1)*16;break;}}
 *x=destination;
 *floor=0;tx=*x/16;int dy=*v,ys=dy<0?-1:1;
 destination=*y+dy;end=destination/16;
 for(int yy=ty;yy!=end;){yy+=ys;if(body_collides(tx,yy,bw,bh)){destination=ys>0?yy*16-1:(yy+1)*16;if(ys>0)*floor=1;*v=0;break;}}
 *y=destination;
 if(dy>=0){int bot=*y/16+bh;for(int k=0;k<2;k++){int fx=tx+(k?bw-1:0),t=tile_at(fx,bot),s=slope(t),surface=(bot/16)*16;if(s)surface+=s==1?15-(fx&15):(fx&15);if((s||t==55||(t>=62&&t<=66))&&oldbottom<=surface+5&&bot>=surface){*y=(surface-bh)*16;*v=0;*floor=1;}}}
}
bool load_level(int level){
 intro_cancel();
 if(level<0||level>=15)return false;char name[9];snprintf(name,sizeof name,"PDLV%02d",level+1);unsigned sz=0;const uint8_t *data=bundle_find(name,&sz);
 if(!data||sz<4||sz>21004){notice("Missing stage data.");return false;}g.w=data[0]+256*data[1];g.h=data[2]+256*data[3];g.n=g.w*g.h;
 if(!g.w||!g.h||g.n>5250||sz!=4+4*g.n)return false;
 memcpy(g.mapdata,data+4+g.n,g.n);memcpy(g.mapdata+g.n,data+4+g.n*3,g.n);
 g.back=data+4;g.solid=g.mapdata;g.decor=data+4+g.n*2;g.good=g.mapdata+g.n;g.level=level;g.selected=level;
 cache_stage_tiles(g.back,g.solid,g.decor,g.n);
 memset(g.enemy,0,sizeof g.enemy);memset(g.prop,0,sizeof g.prop);memset(g.shot,0,sizeof g.shot);
 g.enemies=g.props=g.mailleft=g.kills=0;g.hp=maxlife();g.fury=20*progress.skills[INNERFURY];g.vx=g.vy=0;g.attackcool=g.invul=g.dash=0;g.ground=0;g.doublejump=1;g.canjump=3;g.px=g.py=32*16;g.face=1;
 g.action=PA_IDLE;g.carry=-1;g.berserk=g.rage=g.inner=g.kicks=g.story_done=g.notice_timer=g.excess=0;g.story_event=-1;g.arena=-1;g.ticks=0;
 for(unsigned i=0;i<g.n;i++){
  int t=g.good[i],tx=i%g.w,ty=i/g.w,tag=(i>=g.w&&g.good[i-g.w]>=26&&g.good[i-g.w]<=28)?g.good[i-g.w]-25:0;
  if(t==1){g.px=(tx*16+4)*16;g.py=(ty*16-10)*16;}
  if(t==12)g.mailleft++;
  if((t==6&&progress.hearts[level])||(t==36&&progress.souls[level])||(t>=7&&t<=9&&progress.have[level+(t-7)*15]))g.good[i]=0;
  if(t==2||t==16||t==17||t==29||t==35||(t>=38&&t<=42)||t==45||t==46||t==47)spawn_enemy(t,tx,ty,tag);
  else if((t>=13&&t<=15)||(t>=18&&t<=25)||(t>=30&&t<=34)||t==43||t==44){if(g.props<MAX_PROPS){Prop *p=&g.prop[g.props++];*p=(Prop){tx*16,ty*16,0,t,tag,0,0,1,(t==14||t==19||(t>=23&&t<=25))?-1:1};}}
 }
 if(level==10||level==13){g.mailleft=5;g.arena=0;g.arenaround=0;arena_setup();}else if(level==14)g.mailleft=1;
 g.totalmail=g.mailleft;g.safex=g.px;g.safey=g.py;g.mode=PLAY;g.frame=0;
 if(level==0){
#ifdef PEDRO_PROFILE
  if(g.keys&QAKEY)story_start(1,-1);else
#endif
  intro_start();
 }
 return true;
}
void drop_power(int which,int x,int y){for(int i=0;i<MAX_PROPS;i++)if(!g.prop[i].active){g.prop[i]=(Prop){x,y,0,48,0,(uint8_t)which,0,1,1};if(i>=g.props)g.props=i+1;return;}}
static void tent_launch(Prop *p) {
 Enemy *e=spawn_enemy(2,p->x/16,p->y/16,p->tag);
 if(e){e->x+=(p->face>0?15:-4)*16;e->face=g.px<e->x?-1:1;e->reload=0;}
 if(g.level==0&&p->face>0&&!((g.story_done>>0)&1)){
  story_start(0,e?e-g.enemy:-1);
  for(int j=0;j<g.props;j++){Prop*q=&g.prop[j];if(q!=p&&q->active&&(q->type==13||q->type==14)&&q->state==0){q->state=2;tent_launch(q);}}
 }
}
void prop_update(void){
 for(int i=0;i<g.props;i++){Prop *p=&g.prop[i];if(!p->active)continue;int dist=absi(p->x-g.px/16)+absi(p->y-g.py/16);
  if(p->type==48){p->timer++;if(p->timer>15&&dist<24){collect_power(p->state);p->active=0;}continue;}
  if(p->type==13||p->type==14||p->type==44){
   if(!p->state&&dist<50){
    if(g.level==2||p->type==44){
     bool all=g.level==2||g.level==7;
     for(int j=0;j<g.props;j++){Prop*q=&g.prop[j];if(q->active&&!q->state&&(q==p||(all&&((p->type==44&&q->type==44)||(p->type!=44&&(q->type==13||q->type==14)))))){q->state=1;q->timer=0;q->count=0;}}
    }else{p->state=2;tent_launch(p);p->tag=0;}
   }
   if(p->state==1&&--p->timer<=0){tent_launch(p);p->count++;p->timer=(p->type==44?2:4)*FPS;if(p->count>=(p->type==44?6:4)){p->state=2;p->tag=0;}}
   continue;
  }
  if(p->type==43){if(absi(p->x+3-g.px/16-4)<10&&g.py/16+15>p->y-16&&g.py/16<p->y+16){int dir=g.px/16+4>p->x+3?1:-1;g.px=(p->x+(dir>0?12:-8))*16;player_hurt(100,dir,100,-100);}continue;}
 }
 int tx=(g.px/16+4)/16,ty=(g.py/16+8)/16;
 for(int y=ty-1;y<=ty+1;y++)for(int x=tx-1;x<=tx+1;x++)if(x>=0&&x<(int)g.w&&y>=0&&y<(int)g.h&&absi(x*16+8-g.px/16-4)+absi(y*16+8-g.py/16-8)<20){int i=y*g.w+x,t=g.good[i],which=-1;if(t==12)which=5;else if(t==6)which=0;else if(t>=7&&t<=9)which=t-6;else if(t==36)which=4;else if(t==37)which=6;if(which>=0){g.good[i]=0;collect_power(which);}}
}
