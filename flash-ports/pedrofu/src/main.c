#include <tice.h>
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* Fixed point, 16 units/pixel, 30 simulation steps/sec. */
volatile uint8_t pedro_diag[4]; /* menu=0, play=1, pause=2, dead=3, win=4; level, hp, mail */
static uint8_t map[21000], *back,*solid,*decor,*good;
static const uint8_t *tiles[2],*actors;
static unsigned w,h,n;
static int px,py,vy,face=1,cx,cy,ground,jumps,hp,fury,attack,attackcool,invul,dash;
static int level,selected,mailleft,kills,total,frame,mode,unlocked;
static bool lastjump,lastfury,lastpause,lastenter,lastleft,lastright;
typedef struct {int x,y,vy,hp,face,cool; uint8_t type,tag,active;} Enemy;
static Enemy enemy[128];
static int enemies;
static uint16_t palette[256];
static int absint(int a){return a<0?-a:a;}
static void text(int x,int y,const char *s){gfx_PrintStringXY(s,x,y);}
static void num(int x,int y,int v){gfx_SetTextXY(x,y);gfx_PrintInt(v,1);}
static void center(int y,const char *s){text((320-gfx_GetStringWidth(s))/2,y,s);}
static uint8_t *openptr(const char *name,unsigned expected){uint8_t f=ti_Open(name,"r");if(!f||ti_GetSize(f)<expected){if(f)ti_Close(f);return NULL;}return ti_GetDataPtr(f);}
static bool assets(void){tiles[0]=openptr("PDTILE0",148*258);tiles[1]=openptr("PDTILE1",148*258);actors=openptr("PDACTOR",46532);return tiles[0]&&tiles[1]&&actors;}
static void save(void){uint8_t f=ti_Open("PDSAVE","w");if(f){uint8_t s[3]={0x50,0x44,(uint8_t)unlocked};ti_Write(s,1,3,f);ti_SetArchiveStatus(true,f);ti_Close(f);}}
static int tileat(int x,int y){if(x<0||x>=(int)w*16)return 1;if(y<0)return 1;if(y>=(int)h*16)return 0;return solid[(y/16)*w+x/16];}
static int slopetype(int t){switch(t){case 14:case 86:case 121:case 123:case 171:return 1;case 18:case 90:case 122:case 125:case 170:return 2;default:return 0;}}
static bool blocked(int x,int y){int t=tileat(x,y);return t && !slopetype(t) && t!=55 && (t<62||t>66);}
static bool box(int x,int y,int bw,int bh){return blocked(x,y)||blocked(x+bw-1,y)||blocked(x,y+bh-1)||blocked(x+bw-1,y+bh-1);}
static void movebody(int *x,int *y,int *v,int dx,int bw,int bh,int *floor){
 int tx=*x/16,ty=*y/16,oldbottom=ty+bh;int step=dx<0?-1:1;
 for(int j=0;j<absint(dx);j++){int nx=*x+step;if(!box(nx/16,ty,bw,bh))*x=nx;else break;}
 *floor=0;tx=*x/16;int dy=*v,ys=dy<0?-1:1;
 for(int j=0;j<absint(dy);j++){int ny=*y+ys;if(box(tx,ny/16,bw,bh)){if(ys>0)*floor=1;*v=0;break;}*y=ny;}
 if(dy>=0){int bot=*y/16+bh;for(int k=0;k<2;k++){int fx=tx+(k?bw-1:0),t=tileat(fx,bot),s=slopetype(t),surface=(bot/16)*16;if(s)surface+=s==1?15-(fx&15):(fx&15);if((s||t==55||(t>=62&&t<=66))&&oldbottom<=surface+5&&bot>=surface){*y=(surface-bh)*16;*v=0;*floor=1;}}}
}
static void loadlevel(void){
 char name[9];snprintf(name,sizeof name,"PDLV%02d",level+1);uint8_t f=ti_Open(name,"r");unsigned sz=f?ti_GetSize(f):0;uint8_t header[4];
 if(sz<4||sz>21004){if(f)ti_Close(f);mode=0;return;}ti_Read(header,1,4,f);w=header[0]+256*header[1];h=header[2]+256*header[3];n=w*h;
 if(!w||!h||n>5250||sz!=4+4*n){ti_Close(f);mode=0;return;}ti_Read(map,1,n*4,f);ti_Close(f);back=map;solid=map+n;decor=map+n*2;good=map+n*3;
 enemies=mailleft=kills=0;hp=100;fury=50;vy=0;attack=attackcool=invul=dash=0;ground=0;jumps=0;px=32*16;py=32*16;
 for(unsigned i=0;i<n;i++){int t=good[i],x=(i%w)*16,y=(i/w)*16;
  if(t==1){px=(x+4)*16;py=(y-10)*16;}
  if(t==12)mailleft++;
  if((t==2||t==16||t==17||t==29||t==35||(t>=38&&t<=42)||t==45||t==46||t==47)&&enemies<128){Enemy *e=&enemy[enemies++];*e=(Enemy){(x+3)*16,(y-3)*16,0,10+(t!=2)*8+(t>=38)*10,-1,0,t,0,1};if(i>=w&&good[i-w]>=26&&good[i-w]<=28)e->tag=good[i-w]-25;}
 }
 total=mailleft;mode=1;frame=0;
}
static void hit(Enemy *e,int damage){if(!e->active)return;e->hp-=damage;e->x+=face*3*16;e->cool=18;if(e->hp<=0){e->active=0;kills++;fury+=12;if(fury>100)fury=100;hp+=3;if(hp>100)hp=100;if(e->tag){bool any=false;for(int i=0;i<enemies;i++)if(enemy[i].active&&enemy[i].tag==e->tag)any=true;if(!any)for(unsigned i=0;i<n;i++)if(solid[i]==55+e->tag)solid[i]=0;}}}
static void update(void){
 bool jump=(kb_Data[7]&kb_Up)||(kb_Data[1]&kb_2nd),punch=kb_Data[2]&kb_Alpha,fr=kb_Data[1]&kb_Del,pa=kb_Data[1]&kb_Mode;
 if(pa&&!lastpause){mode=2;}lastpause=pa;
 int dx=0;if(kb_Data[7]&kb_Left){dx=-37;face=-1;}if(kb_Data[7]&kb_Right){dx=37;face=1;}
 if((kb_Data[2]&kb_Math)&&!dash&&fury>=8){dash=9;fury-=8;}if(dash){dash--;dx=face*85;attack=2;}
 if(jump&&!lastjump&&jumps<2){vy=-68;jumps++;ground=0;}lastjump=jump;
 if(punch&&!attackcool){attack=8;attackcool=15;}
 if(fr&&!lastfury&&fury>=40){fury-=40;attack=14;for(int i=0;i<enemies;i++)if(absint(enemy[i].x-px)<140*16&&absint(enemy[i].y-py)<100*16)hit(&enemy[i],22);}lastfury=fr;
 vy+=5;if(vy>120)vy=120;movebody(&px,&py,&vy,dx,8,(kb_Data[7]&kb_Down)?9:15,&ground);if(ground)jumps=0;
 if(attackcool)attackcool--;if(attack)attack--;if(invul)invul--;
 for(int i=0;i<enemies;i++){Enemy *e=&enemy[i];if(!e->active)continue;int distance=absint(e->x-px);if(distance>400*16)continue;
  if(attack&&distance<29*16&&absint(e->y-py)<25*16&&(dash||((e->x>px)==(face>0)))&&(attack==7||attack==1))hit(e,jumps?10:7);
  if(!e->active)continue;if(e->cool)e->cool--;e->face=e->x<px?1:-1;int edx=e->cool?0:e->face*(e->type==35?20:10);int floor;
  e->vy+=5;if(e->vy>100)e->vy=100;int oldx=e->x;movebody(&e->x,&e->y,&e->vy,edx,11,14,&floor);
  if(floor&&e->x==oldx&&distance<180*16)e->vy=-60;
  if(distance<13*16&&absint(e->y-py)<18*16&&!invul){hp-=9;invul=35;vy=-40;px-=e->face*6*16;}
 }
 int tx=(px/16+4)/16,ty=(py/16+8)/16;
 for(int yy=ty-1;yy<=ty+1;yy++)for(int xx=tx-1;xx<=tx+1;xx++)if(xx>=0&&xx<(int)w&&yy>=0&&yy<(int)h){int i=yy*w+xx,t=good[i];if(absint(xx*16-px/16)<17&&absint(yy*16-py/16)<20){if(t==12){good[i]=0;mailleft--;}else if(t==6||t==37){good[i]=0;hp+=30;if(hp>100)hp=100;}else if(t==7||t==8||t==9||t==36){good[i]=0;fury=100;}}}
 if(py/16>(int)h*16+32)hp=0;
 if(tileat(px/16+4,py/16+15)==63&&!invul){hp-=5;invul=20;vy=-55;}
 if(hp<=0){hp=0;mode=3;}
 if((total&&mailleft==0)||(!total&&kills==enemies)){mode=4;if(level+1>unlocked&&level<14){unlocked=level+1;save();}}
 frame++;
}
static void tile(int t,int x,int y){if(t<=0||t>=296)return;gfx_TransparentSprite((gfx_sprite_t *)(tiles[t/148]+(t%148)*258),x,y);}
static void actor(int kind,int fr,int facing,int x,int y){const uint8_t *s=actors;if(kind)s+=80*382+(facing<0?22:0)*363+fr*363;else s+=((facing<0?40:0)+fr)*382;gfx_TransparentSprite((gfx_sprite_t *)s,x,y);}
static void draw(void){
 gfx_FillScreen(111);cx=px/16-152;cy=py/16-116;if(cx<0)cx=0;if(cy<0)cy=0;if(cx>(int)w*16-320)cx=w*16-320;if(cy>(int)h*16-218)cy=h*16-218;if(cx<0)cx=0;if(cy<0)cy=0;
 gfx_SetClipRegion(0,22,320,240);
 for(int y=cy/16;y<(cy+218)/16+2&&y<(int)h;y++)for(int x=cx/16;x<(cx+320)/16+2&&x<(int)w;x++){int i=y*w+x,sx=x*16-cx,sy=y*16-cy+22;tile(back[i],sx,sy);tile(solid[i],sx,sy);int t=good[i];if(t==12){gfx_SetColor(255);gfx_FillRectangle(sx+2,sy+4,12,8);gfx_SetColor(32);gfx_Line(sx+2,sy+4,sx+8,sy+8);gfx_Line(sx+14,sy+4,sx+8,sy+8);}else if(t==6||t==37){gfx_SetColor(224);gfx_FillCircle(sx+8,sy+8,4);}else if(t==7||t==8||t==9||t==36){gfx_SetColor(252);gfx_FillCircle(sx+8,sy+8,4);}}
 for(int i=0;i<enemies;i++){Enemy *e=&enemy[i];if(e->active&&absint(e->x/16-cx-160)<180&&absint(e->y/16-cy-109)<130){int sx=e->x/16-cx-4,sy=e->y/16-cy+18;actor(1,e->cool?15:((frame/5)%4),e->face,sx,sy);if(e->type!=2){gfx_SetColor(e->type==16?255:224);gfx_HorizLine(sx,sy-2,16);}}}
 if(!invul||frame%4<2){int fr=ground?((kb_Data[7]&(kb_Left|kb_Right))?(frame/4)%5:0):15;if(attack)fr=21;if(dash)fr=30;actor(0,fr,face,px/16-cx-6,py/16-cy+19);}
 if(attack){gfx_SetColor(252);gfx_Circle(px/16-cx+4+face*14,py/16-cy+29,8);}
 for(int y=cy/16;y<(cy+218)/16+2&&y<(int)h;y++)for(int x=cx/16;x<(cx+320)/16+2&&x<(int)w;x++)tile(decor[y*w+x],x*16-cx,y*16-cy+22);
 gfx_SetClipRegion(0,0,320,240);gfx_SetColor(1);gfx_FillRectangle(0,0,320,22);gfx_SetTextFGColor(255);text(3,3,"HP");num(23,3,hp);text(60,3,"FURY");num(93,3,fury);text(133,3,"MAIL");num(166,3,mailleft);text(205,3,"LEVEL");num(247,3,level+1);text(3,13,"2nd jump  Alpha hit  Del fury  Mode pause");
}
static void overlay(const char *a,const char *b){gfx_SetColor(1);gfx_FillRectangle(14,83,292,74);gfx_SetColor(255);gfx_Rectangle(14,83,292,74);center(97,a);center(119,b);}
int main(void){
 ti_CloseAll();gfx_Begin();gfx_SetDrawBuffer();for(unsigned i=0;i<256;i++){unsigned r=((i>>5)&7)*31/7,g=((i>>2)&7)*31/7,b=(i&3)*31/3;palette[i]=(r<<10)|(g<<5)|b;}gfx_SetPalette(palette,512,0);gfx_SetTransparentColor(0);gfx_SetTextTransparentColor(0);gfx_SetTextBGColor(0);gfx_SetTextFGColor(255);
 if(!assets()){gfx_FillScreen(1);center(70,"PEDRO KICKS BACK CE");center(100,"Missing game data AppVars.");center(120,"Send all .8xv files in the ZIP.");center(160,"Press CLEAR to exit.");gfx_SwapDraw();do{kb_Scan();}while(!(kb_Data[6]&kb_Clear));gfx_End();ti_CloseAll();return 0;}
 uint8_t f=ti_Open("PDSAVE","r"),s[3];if(f){if(ti_Read(s,1,3,f)==3&&s[0]==0x50&&s[1]==0x44&&s[2]<15)unlocked=s[2];ti_Close(f);}selected=unlocked;
 while(1){kb_Scan();if(kb_Data[6]&kb_Clear)break;bool enter=kb_Data[6]&kb_Enter,left=kb_Data[7]&kb_Left,right=kb_Data[7]&kb_Right;
  if(mode==0){if(left&&!lastleft)selected=(selected+14)%15;if(right&&!lastright)selected=(selected+1)%15;if(enter&&!lastenter){level=selected;loadlevel();}
   gfx_FillScreen(1);gfx_SetTextScale(2,2);center(25,"PEDRO");gfx_SetTextScale(1,1);center(48,"KICKS BACK CE");center(64,"Native calculator adaptation");center(88,"Original art and 15 original maps");center(111,"LEFT / RIGHT: choose stage");text(104,131,"STAGE");num(154,131,selected+1);center(153,"ENTER: play     CLEAR: exit");center(177,"Arrows move / Up or 2nd jump");center(191,"Alpha punch / Math dash / Del fury");center(213,"Collect every envelope to finish.");center(230,"Original: Hamumu Software, 2012");
  }else{if(mode==1)update();draw();if(mode==2){overlay("PAUSED","ENTER resume / MODE stage menu");if(enter&&!lastenter)mode=1;if((kb_Data[1]&kb_Mode)&&!lastpause)mode=0;lastpause=kb_Data[1]&kb_Mode;}else if(mode==3){overlay("PEDRO WAS DEFEATED","ENTER retry / MODE stage menu");if(enter&&!lastenter)loadlevel();if(kb_Data[1]&kb_Mode)mode=0;}else if(mode==4){overlay(level==14?"DELIVERY COMPLETE!":"MAIL COLLECTED!","ENTER next stage / MODE stage menu");if(enter&&!lastenter){level=(level+1)%15;selected=level;loadlevel();}if(kb_Data[1]&kb_Mode)mode=0;}}
  pedro_diag[0]=mode;pedro_diag[1]=level;pedro_diag[2]=hp;pedro_diag[3]=mailleft;lastenter=enter;lastleft=left;lastright=right;gfx_SwapDraw();delay(25);
 }
 ti_CloseAll();gfx_End();return 0;
}
