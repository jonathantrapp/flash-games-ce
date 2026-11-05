#include "game.h"
void fire_shot(int type,int side,int x,int y,int vx,int vy,int damage){for(int i=0;i<MAX_SHOTS;i++)if(!g.shot[i].active){g.shot[i]=(Shot){x*16,y*16,vx,vy,damage,type==56?9:type==54?12:type==53?60:180,type,side,1,0,vx<0?-1:1};return;}}
void projectile_update(void){
 for(int i=0;i<MAX_SHOTS;i++){Shot *s=&g.shot[i];if(!s->active)continue;if(--s->ttl<=0){s->active=0;continue;}
  if(s->side==2){s->frame=(9-s->ttl)/2;s->frame=clampi(s->frame,0,5);continue;}
  if(s->type==49)s->vy+=2;
  if(s->type==51||s->type==57){int tx=g.px,ty=g.py;if(!s->side){int best=999999;for(int j=0;j<g.enemies;j++)if(g.enemy[j].active){int d=absi(g.enemy[j].x-s->x)+absi(g.enemy[j].y-s->y);if(d<best){best=d;tx=g.enemy[j].x;ty=g.enemy[j].y;}}}int dx=tx-s->x,dy=ty-s->y,n=absi(dx)+absi(dy);if(n){s->vx=approach(s->vx,dx*40/n,2);s->vy=approach(s->vy,dy*40/n,2);}}
  s->x+=s->vx;s->y+=s->vy;s->face=s->vx<0?-1:1;
  if(s->type==53){s->frame=(60-s->ttl)/6;s->frame=clampi(s->frame,0,9);}
  if(s->side==1&&absi(s->x-g.px)<10*16&&absi(s->y-g.py)<16*16){if(g.action==PA_FURYHEAL&&rand()%100<progress.skills[FURIOUSSHIELD]*20){s->side=0;s->vx=-s->vx;s->damage=1000;}else if(!g.invul&&!g.dodge){player_hurt(s->damage,s->face,20,-40);s->active=0;}}
  if(s->side==0)for(int j=0;j<g.enemies;j++)if(g.enemy[j].active&&absi(s->x-g.enemy[j].x)<12*16&&absi(s->y-g.enemy[j].y)<g.enemy[j].bh*16){enemy_hit(&g.enemy[j],s->damage,10,false);s->active=0;break;}
  if(s->type!=53&&s->type!=52&&blocked(s->x/16,s->y/16))s->active=0;
 }
}
