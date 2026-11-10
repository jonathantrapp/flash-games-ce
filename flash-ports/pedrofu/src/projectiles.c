#include "game.h"
bool player_reflects(void);
typedef struct {int angle,gravity_remainder,turn_remainder,target;uint16_t age,frozen,scale;uint8_t phase,spread,straight,burned;} ShotExtra;
static ShotExtra shot_extra[MAX_SHOTS];
static bool rock_spiked;
static uint32_t shot_last_tick;
static int shot_last_level=-1;
static const int16_t quarter_sine[91]={0,18,36,54,71,89,107,125,143,160,178,195,213,230,248,265,282,299,316,333,350,367,384,400,416,433,449,465,481,496,512,527,543,558,573,587,602,616,630,644,658,672,685,698,711,724,737,749,761,773,784,796,807,818,828,839,849,859,868,878,887,896,904,912,920,928,935,943,949,956,962,968,974,979,984,989,994,998,1002,1005,1008,1011,1014,1016,1018,1020,1022,1023,1023,1024,1024};
static int sine_degree(int a){while(a<0)a+=360;a%=360;if(a<=90)return quarter_sine[a];if(a<=180)return quarter_sine[180-a];if(a<=270)return -quarter_sine[a-180];return -quarter_sine[360-a];}
static int vector_angle(int dx,int dy){int ax=absi(dx),ay=absi(dy),lo=0,hi=90;if(!ax&&!ay)return 0;while(lo<hi){int mid=(lo+hi)/2;if((long)ay*quarter_sine[90-mid]>(long)ax*quarter_sine[mid])lo=mid+1;else hi=mid;}int a=lo;if(dx<0)a=180-a;if(dy<0)a=360-a;return a%360;}
void combat_angle(int a,int speed,int *vx,int *vy){*vx=(int)((long)sine_degree(a+90)*speed*16/(1024L*FPS));*vy=(int)((long)sine_degree(a)*speed*16/(1024L*FPS));}
/* Integer Euclidean normalization preserves speed on diagonal trajectories. */
void combat_vector(int dx,int dy,int speed,int *vx,int *vy){
 while(absi(dx)>1024||absi(dy)>1024){dx/=2;dy/=2;}
 unsigned long value=(unsigned long)((long)dx*dx+(long)dy*dy),root=0,bit=1UL<<30;if(!value){*vx=*vy=0;return;}
 while(bit>value)bit>>=2;while(bit){if(value>=root+bit){value-=root+bit;root=(root>>1)+bit;}else root>>=1;bit>>=2;}
 *vx=(int)((long)dx*speed*16/((long)root*FPS));*vy=(int)((long)dy*speed*16/((long)root*FPS));
}
static int scale_damage(int damage){long n=damage;if(g.berserk)n*=2;if(g.rage)n=n*(100+8*progress.skills[RAGINGBURRO])/100;if(g.hp==maxlife()&&g.fury==maxfury())n=n*(100+6*progress.skills[MAXIMUMFORCE])/100;return (int)n;}
void projectile_reset_stomp(void){rock_spiked=false;}
int projectile_scale(const Shot *s){return s>=g.shot&&s<g.shot+MAX_SHOTS&&(s->type==52||(s->type==53&&s->side==0))?shot_extra[s-g.shot].scale:256;}
int projectile_frozen(const Shot *s){return s>=g.shot&&s<g.shot+MAX_SHOTS?shot_extra[s-g.shot].frozen:0;}
void projectiles_freeze(int ticks){for(int i=0;i<MAX_SHOTS;i++){Shot *s=&g.shot[i];if(!s->active||s->side!=1)continue;shot_extra[i].frozen=ticks;s->vx=s->vy=0;if(s->type==53)s->active=0;}}
void fire_shot(int type,int side,int x,int y,int vx,int vy,int damage){
 for(int i=0;i<MAX_SHOTS;i++)if(!g.shot[i].active){Shot *s=&g.shot[i];ShotExtra *m=&shot_extra[i];memset(m,0,sizeof *m);m->target=-1;m->scale=256;
 int ttl=type==60?13*FPS/30:type==56?9:type==54?6:type==53?(FPS*10+13)/14:type==51?6*FPS:type==57?8*FPS:60*FPS;
 *s=(Shot){x*16,y*16,vx,vy,damage,ttl,type,side,1,0,vx<0?-1:1};m->angle=vector_angle(vx,vy)*256;
 if(type==49)m->straight=vy==0;if(type==50)combat_vector(vx,vy,100,&s->vx,&s->vy);
 if(type==52){m->spread=clampi(vx,0,2);m->scale=51;s->vx=0;s->vy=200*16/FPS;s->damage=200;}
 if(type==53){s->vx=s->vy=0;if(side==0)m->scale=256+128*progress.skills[ATOMICPILEDRIVER];else s->damage=100;}return;}
}
void fire_straight_arrow(int x,int y,int vx,int vy,int damage){int index;for(index=0;index<MAX_SHOTS;index++)if(!g.shot[index].active)break;if(index==MAX_SHOTS)return;fire_shot(49,1,x,y,vx,vy,damage);shot_extra[index].straight=1;}
static bool line_clear(int x,int y,int tx,int ty){
 x/=16;y/=16;tx/=16;ty/=16;int dx=absi(tx-x),dy=absi(ty-y),sx=x<tx?1:-1,sy=y<ty?1:-1,err=dx-dy;
 for(int c=0;c<180;c++){if(x==tx&&y==ty)return true;if(x<0||y<0||x>=(int)g.w||y>=(int)g.h||g.solid[y*g.w+x])return false;int twice=err*2;if(twice>-dy){err-=dy;x+=sx;}if(twice<dx){err+=dx;y+=sy;}}return false;
}
static void choose_target(Shot *s,ShotExtra *m){
 long best=0x7fffffffL;m->target=-1;for(int j=0;j<g.enemies;j++){Enemy *e=&g.enemy[j];if(!e->active)continue;int dx=(e->x+e->bw*8-s->x)/16,dy=(e->y+e->bh*8-s->y)/16;long d=(long)dx*dx+(long)dy*dy;if(d<best&&line_clear(s->x/16,s->y/16,(e->x+e->bw*8)/16,(e->y+e->bh*8)/16)){best=d;m->target=j;}}
}
static void turn_shot(Shot *s,ShotExtra *m,int tx,int ty,int rate,int speed){
 int target=vector_angle(tx-s->x,ty-s->y)*256,delta=target-m->angle;while(delta>180*256)delta-=360*256;while(delta< -180*256)delta+=360*256;
 m->turn_remainder+=rate*256;int amount=m->turn_remainder/FPS;m->turn_remainder%=FPS;m->angle+=clampi(delta,-amount,amount);
 while(m->angle<0)m->angle+=360*256;while(m->angle>=360*256)m->angle-=360*256;combat_angle(m->angle/256,speed,&s->vx,&s->vy);
}
static bool player_overlap(const Shot *s,int bw,int bh){int px=g.px+4*16,py=g.py+(g.action==PA_DUCK?6:7)*16;return absi(s->x-px)<(bw+8)*8&&absi(s->y-py)<(bh+(g.action==PA_DUCK?12:15))*8;}
static void reflect_or_destroy(Shot *s,ShotExtra *m){
 player_hurt(s->damage,s->face,20,-40);if(player_reflects()){if(s->type==49){s->side=0;s->vx=-s->vx;s->damage=1000;}else if(s->type==50){s->side=0;combat_angle(m->angle/256+180,140,&s->vx,&s->vy);s->damage=1000;}else s->active=0;}else s->active=0;
}
static bool spike_spread_empty(int x,int y){switch(tile_at(x,y)){case 0:case 14:case 18:case 86:case 90:case 121:case 122:case 123:case 125:case 170:case 171:return true;default:return false;}}
static void update_spike(Shot *s,ShotExtra *m){
 int bx=s->x-13*8,by=s->y-19*8,floor;m->gravity_remainder+=400*16;s->vy+=m->gravity_remainder/(FPS*FPS);m->gravity_remainder%=FPS*FPS;
 move_body(&bx,&by,&s->vy,0,13,19,&floor);s->x=bx+13*8;s->y=by+19*8;
 if(m->phase==0){m->scale+=16*256/FPS;if(m->scale>=384){m->scale=384;m->phase=1;}
 if(!m->frozen&&!rock_spiked&&g.py+15*16>by+19*16-(int)((long)19*16*m->scale/256)&&g.px<=bx+13*16&&g.px+8*16>=bx){player_hurt(200,s->face,0,0);rock_spiked=true;}}
 else if(m->phase==1){if(m->spread&&!m->frozen){int nx=s->x/16+(m->spread==1?12:-12),ny=s->y/16;if(spike_spread_empty(nx,ny))fire_shot(52,1,nx,ny,m->spread,0,200);}m->phase=2;}
 else{int shrink=2*256/FPS;if(m->scale<=25+shrink)s->active=0;else m->scale-=shrink;}
}
void projectile_update(void){
 if(shot_last_level!=g.level||g.ticks<shot_last_tick){rock_spiked=false;shot_last_level=g.level;}shot_last_tick=g.ticks;
 Shot *s=g.shot;ShotExtra *m=shot_extra;
 for(int i=0;i<MAX_SHOTS;i++,s++,m++){if(!s->active)continue;m->age++;if(--s->ttl<=0){s->active=0;continue;}
 if(s->side==2){if(s->type==60){s->frame=clampi(m->age*30/FPS,0,12);m->gravity_remainder-=50*16;s->vy+=m->gravity_remainder/(FPS*FPS);m->gravity_remainder%=FPS*FPS;s->x+=s->vx;s->y+=s->vy;}else if(s->type==54){s->frame=clampi(m->age*20/FPS,0,3);s->vx=approach(s->vx,0,4);s->x+=s->vx;}else s->frame=clampi(m->age*20/FPS,0,5);continue;}
 if(s->type==52){if(m->frozen)m->frozen--;update_spike(s,m);continue;}
 if(m->frozen){m->frozen--;m->gravity_remainder+=400*16;s->vy+=m->gravity_remainder/(FPS*FPS);m->gravity_remainder%=FPS*FPS;s->y+=s->vy;if(blocked(s->x/16,s->y/16))s->active=0;continue;}
 int oldx=s->x,oldy=s->y;if(s->type==49&&!m->straight){m->gravity_remainder+=100*16;s->vy+=m->gravity_remainder/(FPS*FPS);m->gravity_remainder%=FPS*FPS;}
 if(s->type==53){int bx=s->x-8*16,by=s->y-8*16,floor;
 if(s->side!=0){m->gravity_remainder+=400*16;s->vy+=m->gravity_remainder/(FPS*FPS);m->gravity_remainder%=FPS*FPS;move_body(&bx,&by,&s->vy,0,16,16,&floor);s->x=bx+8*16;s->y=by+8*16;}s->frame=clampi(m->age*14/FPS,0,9);
 if(s->side==0){if(s->frame>=1&&!m->burned){m->burned=1;int halfwidth=(int)((long)8*16*m->scale/256);for(int j=0;j<g.enemies;j++){Enemy *e=&g.enemy[j];if(e->active&&e->x<s->x+halfwidth&&e->x+e->bw*16>s->x-halfwidth&&e->y<s->y+8*16&&e->y+e->bh*16>s->y-8*16){enemy_hit(e,scale_damage(s->damage),0,false);if(e->active){e->vx=e->x+e->bw*8<g.px+4*16?-48:48;e->vy=-48;}}}}continue;}
 if(s->frame>=1&&!m->burned&&!g.invul&&!g.dodge&&g.action!=PA_PILEDRIVE&&g.action!=PA_HITSTUN){m->burned=1;if(player_overlap(s,16,16)){player_hurt(100,s->face,0,0);if(player_reflects())s->active=0;}}continue;}
 s->x+=s->vx;s->y+=s->vy;s->face=s->vx<0?-1:1;int bw=s->type==49?3:s->type==50?5:7,bh=bw;
 if(s->side==1&&player_overlap(s,bw,bh)&&!g.invul&&!g.dodge&&g.action!=PA_PILEDRIVE&&g.action!=PA_HITSTUN)reflect_or_destroy(s,m);
 if(s->side==0){Enemy *e=g.enemy;for(int j=0;j<g.enemies;j++,e++)if(e->active&&absi(s->x-e->x-e->bw*8)<(bw+e->bw)*8&&absi(s->y-e->y-e->bh*8)<(bh+e->bh)*8){enemy_hit(e,scale_damage(s->damage),0,false);s->active=0;break;}}
 if(!s->active)continue;int steps=(absi(s->vx)>absi(s->vy)?absi(s->vx):absi(s->vy))/16+1;
 for(int k=1;k<=steps;k++){int x=(oldx+(s->x-oldx)*k/steps)/16,y=(oldy+(s->y-oldy)*k/steps)/16;if(blocked(x,y)){s->active=0;break;}}
 if(s->type==51)turn_shot(s,m,g.px+4*16,g.py+7*16,100,60);
 else if(s->type==57){if(m->age%3==1)choose_target(s,m);if(m->target>=0&&g.enemy[m->target].active){Enemy *e=&g.enemy[m->target];turn_shot(s,m,e->x+e->bw*8,e->y+e->bh*8,360,100);}else combat_angle(m->angle/256,100,&s->vx,&s->vy);}
 if(s->x< -16*16||s->y< -16*16||s->x>(int)g.w*16*16||s->y>(int)g.h*16*16)s->active=0;
 }
}
