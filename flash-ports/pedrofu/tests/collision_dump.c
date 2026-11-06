#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static struct {unsigned w,h;uint8_t *solid;} g;
int absi(int v){return v<0?-v:v;}
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
static void legacy_move(int *x,int *y,int *v,int dx,int bw,int bh,int *floor){
 int tx=*x/16,ty=*y/16,oldbottom=ty+bh;int step=dx<0?-1:1;
 for(int j=0;j<absi(dx);j++){int nx=*x+step;if(!body_collides(nx/16,ty,bw,bh))*x=nx;else break;}
 *floor=0;tx=*x/16;int dy=*v,ys=dy<0?-1:1;
 for(int j=0;j<absi(dy);j++){int ny=*y+ys;if(body_collides(tx,ny/16,bw,bh)){if(ys>0)*floor=1;*v=0;break;}*y=ny;}
 if(dy>=0){int bot=*y/16+bh;for(int k=0;k<2;k++){int fx=tx+(k?bw-1:0),t=tile_at(fx,bot),s=slope(t),surface=(bot/16)*16;if(s)surface+=s==1?15-(fx&15):(fx&15);if((s||t==55||(t>=62&&t<=66))&&oldbottom<=surface+5&&bot>=surface){*y=(surface-bh)*16;*v=0;*floor=1;}}}
}

static uint32_t seed=0x47ab8901;
static uint32_t rng(void){seed^=seed<<13;seed^=seed>>17;seed^=seed<<5;return seed;}
int main(int argc,char**argv){if(argc!=2)return 3;FILE*f=fopen(argv[1],"rb");if(!f)return 4;int maps=fgetc(f),tested=0,failed=0,edge=0,interior=0;uint8_t map[21000];
 for(int m=0;m<maps;m++){uint16_t head[2];if(fread(head,2,2,f)!=2)return 5;g.w=head[0];g.h=head[1];g.solid=map;if(fread(map,1,g.w*g.h,f)!=g.w*g.h)return 6;
  for(int i=0;i<30000;i++){int bw[]={8,11,19,32},bh[]={12,14,19,48},kind=rng()%4,w=bw[kind],h=bh[kind];if(g.w*16<=w||g.h*16<=h)continue;int x=(int)(rng()%((g.w*16-w)*16+16)),y=(int)(rng()%((g.h*16-h)*16+16));if(body_collides(x/16,y/16,w,h))continue;
   int dx=(int)(rng()%401)-200,vy=(int)(rng()%401)-200;if(i%20==0)dx*=8;if(i%33==0)vy*=4;
   int ax=x,ay=y,av=vy,af=-1,bx=x,by=y,bv=vy,bf=-1;legacy_move(&ax,&ay,&av,dx,w,h,&af);move_body(&bx,&by,&bv,dx,w,h,&bf);tested++;
   if(ax!=bx||ay!=by||av!=bv||af!=bf){failed++;if((ax==bx||(ax==-15&&bx==0))&&(ay==by||(ay==-15&&by==0))&&av==bv&&af==bf)edge++;else interior++;if(failed<=25)printf("D %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",m,x,y,vy,dx,w,h,ax,ay,av,af,bx,by,bv,bf);}
  }
 }
 printf("TOTAL %d %d %d %d\n",tested,failed,edge,interior);return 0;}
